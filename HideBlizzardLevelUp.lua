local ADDON_NAME, ns = ...

-- Temporarily hide Blizzard's shared event-toast container while our own
-- level-up panel is visible. Other Blizzard toasts return afterward.
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

local function HideToastArtwork(frame)
    if savedAlpha[frame] == nil then savedAlpha[frame] = GetFrameAlpha(frame) end
    SetFrameAlpha(frame, 0)
end

-- Keep native toast execution intact when Blizzard owns sound playback.
-- Replacement sounds can retain the existing StopToasting suppression path.
local function StopEventToastManager()
    local frame = _G[eventToastFrameName]
    if not frame then return end
    HideToastArtwork(frame)
    if not ns.UsesNativeLevelUpSound() and type(frame.StopToasting) == "function" then
        pcall(frame.StopToasting, frame)
        SetFrameAlpha(frame, 0)
    end
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
    pcall(function()
        frame:HookScript("OnShow", function(self)
            if ns.db and ns.db.hideBlizzardLevelUp == false then return end
            if suppressionActive then
                SetFrameAlpha(self, 0)
            end
        end)
    end)
end

local function HideIfSuppressed(frame)
    if suppressionActive and (not ns.db or ns.db.hideBlizzardLevelUp ~= false) then
        HideToastArtwork(frame)
    end
end

local function HookEventToastManager(frame)
    if not frame or hookedFrames[frame] or not frame.HookScript then return end
    hookedFrames[frame] = true
    pcall(frame.HookScript, frame, "OnShow", HideIfSuppressed)
    -- A new toast can reuse the already shown manager and reset its alpha.
    -- Hide after native setup, before the next render, without stopping it here.
    if type(hooksecurefunc) == "function" then
        if type(frame.SetupButton) == "function" then pcall(hooksecurefunc, frame, "SetupButton", HideIfSuppressed) end
        if type(frame.DisplayToast) == "function" then pcall(hooksecurefunc, frame, "DisplayToast", HideIfSuppressed) end
    end
end

local function RestoreSuppressedFrames()
    for frame, alpha in pairs(savedAlpha) do
        SetFrameAlpha(frame, alpha)
    end
    savedAlpha = {}
    suppressionActive = false
end

function ns.HideBlizzardBannerNow()
    if ns.IsAddonEnabled and not ns.IsAddonEnabled() then return end
    if ns.db and ns.db.hideBlizzardLevelUp == false then return end
    suppressionActive = true
    HookEventToastManager(_G[eventToastFrameName])
    StopEventToastManager()
    for _, name in ipairs(CANDIDATE_BANNER_NAMES) do
        local frame = _G[name]
        if frame then
            if savedAlpha[frame] == nil then
                savedAlpha[frame] = GetFrameAlpha(frame)
            end
            HookBlizzardFrame(frame)
            SetFrameAlpha(frame, 0)
        end
    end
end

function ns.RestoreBlizzardBanner()
    CancelSuppressionTimers()
    suppressionToken = suppressionToken + 1
    suppressionQueueToken = suppressionQueueToken + 1
    RestoreSuppressedFrames()
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
            RestoreSuppressedFrames()
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
if not _G[eventToastFrameName] then eventFrame:RegisterEvent("ADDON_LOADED") end
eventFrame:SetScript("OnEvent", function(self, event, addonName)
    if event == "ADDON_LOADED" then
        if addonName == "Blizzard_EventToast" then
            local manager = _G[eventToastFrameName]
            if manager then
                HookEventToastManager(manager)
                HideIfSuppressed(manager)
                self:UnregisterEvent("ADDON_LOADED")
            end
        end
        return
    end
    ns.HideBlizzardBannerNow()
    -- Blizzard can create or start the toast after the level-up event runs.
    ns.QueueBlizzardSuppression()
end)
