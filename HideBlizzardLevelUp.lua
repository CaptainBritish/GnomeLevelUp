local ADDON_NAME, ns = ...

local CANDIDATE_BANNER_NAMES = {
    "LevelUpDisplay",
    "LevelUpDisplayAlertFrame",
    "LevelUpDisplayFrame",
    "LevelUpDisplayLevelFrame",
    "LevelUpDisplayLevelFrameTextLine",
}

local eventToastFrameName = "EventToastManagerFrame"

local hookedFrames = {}
local savedAlpha = {}
local dedicatedAlpha = {}
local suppressionToken = 0
local suppressionActive = false
local suppressionQueueToken = 0

local suppressionTimers = {}
local function CancelSuppressionTimers()
    for key, timer in pairs(suppressionTimers) do timer:Cancel(); suppressionTimers[key] = nil end
end

local function ScheduleSuppressionTimer(key, delay, callback)
    if suppressionTimers[key] then suppressionTimers[key]:Cancel(); suppressionTimers[key] = nil end
    if C_Timer and type(C_Timer.NewTimer) == "function" then
        local timer
        timer = C_Timer.NewTimer(delay, function()
            if suppressionTimers[key] ~= timer then return end
            suppressionTimers[key] = nil
            callback()
        end)
        suppressionTimers[key] = timer
    else
        C_Timer.After(delay, callback)
    end
end

-- Forever uses a separate default sound. Retail plays 567431 directly, so
-- leave that file available while still muting the other native sound.
local NATIVE_LEVEL_UP_FILES = { forever = 569593, retail = 567431 }
local GLU_MUTED_SOUND_IDS = { NATIVE_LEVEL_UP_FILES.forever, NATIVE_LEVEL_UP_FILES.retail }

function ns.GetNativeLevelUpSoundFileID()
    return NATIVE_LEVEL_UP_FILES[ns.GetCurrentFlavor()] or NATIVE_LEVEL_UP_FILES.forever
end

function ns.SetGnomeLevelUpSoundMuted(muted)
    if ns.UsesNativeLevelUpSound() then muted = false end
    local retail = ns.GetCurrentFlavor() == "retail"
    for _, soundID in ipairs(GLU_MUTED_SOUND_IDS) do
        local shouldMute = muted and not (retail and soundID == NATIVE_LEVEL_UP_FILES.retail)
        local soundFunction = shouldMute and MuteSoundFile or UnmuteSoundFile
        if type(soundFunction) == "function" then pcall(soundFunction, soundID) end
    end
end

local function SetFrameAlpha(frame, alpha)
    if frame and type(frame.SetAlpha) == "function" then
        pcall(frame.SetAlpha, frame, alpha)
    end
end

local function GetFrameAlpha(frame)
    if not frame or type(frame.GetAlpha) ~= "function" then return 1 end
    local ok, alpha = pcall(frame.GetAlpha, frame)
    return ok and tonumber(alpha) or 1
end

local function ShouldHideBanner()
    return ns.db and ns.db.hideBlizzardLevelUp ~= false and (not ns.IsAddonEnabled or ns.IsAddonEnabled())
end

local function HideToastArtwork(frame, originalAlpha)
    if not frame then return end
    if originalAlpha[frame] == nil then originalAlpha[frame] = GetFrameAlpha(frame) end
    SetFrameAlpha(frame, 0)
end

local function RestoreArtwork(originalAlpha)
    for frame, alpha in pairs(originalAlpha) do
        SetFrameAlpha(frame, alpha)
        originalAlpha[frame] = nil
    end
end

local function HideEventToastArtwork(frame)
    HideToastArtwork(frame, savedAlpha)
    -- Blizzard animates the manager separately from its shadow and gold lines.
    -- Hide the textures too so they stay invisible through a native fade.
    HideToastArtwork(frame.BlackBG, savedAlpha)
    HideToastArtwork(frame.GLine, savedAlpha)
    HideToastArtwork(frame.GLine2, savedAlpha)
end

local function GetLevelUpToastStatus(frame)
    local eventTypes = Enum and Enum.EventToastEventType
    local toast = frame.currentDisplayingToast
    local info = toast and toast.toastInfo
    if not eventTypes or eventTypes.LevelUp == nil then return nil end
    if not info then return false end
    if info.eventType == nil then return nil end
    return info.eventType == eventTypes.LevelUp
end

function ns.FindBlizzardLevelUpFrame()
    for _, name in ipairs(CANDIDATE_BANNER_NAMES) do
        local frame = _G[name]
        if frame then return frame end
    end
    return nil
end

local function HookBlizzardFrame(frame)
    if not frame or hookedFrames[frame] or not frame.HookScript then return end
    hookedFrames[frame] = true
    pcall(frame.HookScript, frame, "OnShow", function(self)
        if ShouldHideBanner() then HideToastArtwork(self, dedicatedAlpha) end
    end)
end

local function UpdateEventToastArtwork(frame)
    local levelUp = GetLevelUpToastStatus(frame)
    if ShouldHideBanner() and (levelUp or (levelUp == nil and suppressionActive)) then
        HideEventToastArtwork(frame)
    else
        RestoreArtwork(savedAlpha)
    end
end

local function HookEventToastManager(frame)
    if not frame or hookedFrames[frame] or not frame.HookScript then return end
    hookedFrames[frame] = true
    pcall(frame.HookScript, frame, "OnShow", UpdateEventToastArtwork)
    -- SetupButton runs after Blizzard assigns the toast type and before it shows
    -- the manager. PlayAnim can reveal the artwork again during the native fade.
    if type(hooksecurefunc) == "function" then
        for _, method in ipairs({ "SetupButton", "DisplayToast", "SetupBlackBGAtlas", "PlayAnim" }) do
            if type(frame[method]) == "function" then pcall(hooksecurefunc, frame, method, UpdateEventToastArtwork) end
        end
        if type(frame.Reset) == "function" then
            pcall(hooksecurefunc, frame, "Reset", function() RestoreArtwork(savedAlpha) end)
        end
    end
end

function ns.UpdateBlizzardBannerVisibility()
    local manager = _G[eventToastFrameName]
    HookEventToastManager(manager)
    if manager then UpdateEventToastArtwork(manager) end
    if not ShouldHideBanner() then
        RestoreArtwork(dedicatedAlpha)
        return
    end
    for _, name in ipairs(CANDIDATE_BANNER_NAMES) do
        local frame = _G[name]
        if frame then
            HookBlizzardFrame(frame)
            HideToastArtwork(frame, dedicatedAlpha)
        end
    end
end

function ns.HideBlizzardBannerNow()
    if not ShouldHideBanner() then return end
    suppressionActive = true
    ns.UpdateBlizzardBannerVisibility()
    local manager = _G[eventToastFrameName]
    -- Older clients may omit the type. Retain their event-based fallback.
    if manager and GetLevelUpToastStatus(manager) == nil and not ns.UsesNativeLevelUpSound()
        and type(manager.StopToasting) == "function" then
        pcall(manager.StopToasting, manager)
        SetFrameAlpha(manager, 0)
    end
end

function ns.RestoreBlizzardBanner()
    CancelSuppressionTimers()
    suppressionToken = suppressionToken + 1
    suppressionQueueToken = suppressionQueueToken + 1
    suppressionActive = false
    RestoreArtwork(savedAlpha)
    RestoreArtwork(dedicatedAlpha)
end

function ns.SuppressBlizzardBanner()
    if ns.IsAddonEnabled and not ns.IsAddonEnabled() then return end
    if ns.db and ns.db.hideBlizzardLevelUp == false then return end

    suppressionToken = suppressionToken + 1
    local token = suppressionToken
    ns.HideBlizzardBannerNow()

    local duration = math.max(15, (ns.db and tonumber(ns.db.duration)) or 7)
    ScheduleSuppressionTimer("restore", duration + 1.0, function()
        if token == suppressionToken then
            suppressionActive = false
            local manager = _G[eventToastFrameName]
            if manager then UpdateEventToastArtwork(manager) else RestoreArtwork(savedAlpha) end
        end
    end)
end

ns.RefreshBlizzardSuppression = ns.SuppressBlizzardBanner

function ns.QueueBlizzardSuppression()
    if ns.IsAddonEnabled and not ns.IsAddonEnabled() then return end
    if ns.db and ns.db.hideBlizzardLevelUp == false then return end
    -- The toast container may be created lazily. Retry in one cancellable
    -- chain instead of scheduling several independent timers.
    suppressionQueueToken = suppressionQueueToken + 1
    local token = suppressionQueueToken
    local retryDelays = { 0, 0.15, 0.4, 0.8 }
    local function Retry(index)
        if token ~= suppressionQueueToken then return end
        if ns.db and ns.db.hideBlizzardLevelUp == false then return end
        if index == 1 then
            ns.SuppressBlizzardBanner()
        else
            ns.HideBlizzardBannerNow()
        end
        if retryDelays[index + 1] then
            ScheduleSuppressionTimer("retry", retryDelays[index + 1], function() Retry(index + 1) end)
        end
    end
    ScheduleSuppressionTimer("retry", retryDelays[1], function() Retry(1) end)
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_LEVEL_UP")
eventFrame:RegisterEvent("ADDON_LOADED")
HookEventToastManager(_G[eventToastFrameName])
eventFrame:SetScript("OnEvent", function(_, event)
    if event == "ADDON_LOADED" then
        ns.UpdateBlizzardBannerVisibility()
        return
    end
    ns.HideBlizzardBannerNow()
    -- Blizzard can create or start the toast after the level-up event runs.
    ns.QueueBlizzardSuppression()
end)
