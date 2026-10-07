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

-- Blizzard's native level-up files. GLU mutes these while the addon is
-- active; its own sound uses a separate FileDataID below.
local GLU_MUTED_SOUND_IDS = { 569593, 567431 }

function ns.SetGnomeLevelUpSoundMuted(muted)
    local soundFunction = muted and MuteSoundFile or UnmuteSoundFile
    if type(soundFunction) ~= "function" then return end
    for _, soundID in ipairs(GLU_MUTED_SOUND_IDS) do
        pcall(soundFunction, soundID)
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

-- Blizzard's toast manager already knows how to stop its active animation.
-- Use that method instead of changing the shared container's alpha.
local function StopEventToastManager()
    local frame = _G[eventToastFrameName]
    if not frame then return end
    if type(frame.StopToasting) == "function" then
        pcall(frame.StopToasting, frame)
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

local function HookEventToastManager()
    local frame = _G[eventToastFrameName]
    if not frame or hookedFrames[frame] or not frame.HookScript then return end
    hookedFrames[frame] = true
    pcall(function()
        frame:HookScript("OnShow", function()
            if suppressionActive and (not ns.db or ns.db.hideBlizzardLevelUp ~= false) then
                StopEventToastManager()
            end
        end)
    end)
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
    HookEventToastManager()
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
    C_Timer.After(duration + 1.0, function()
        if token == suppressionToken then
            RestoreSuppressedFrames()
        end
    end)
end

ns.RefreshBlizzardSuppression = ns.SuppressBlizzardBanner

function ns.QueueBlizzardSuppression()
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
            C_Timer.After(retryDelays[index + 1], function() Retry(index + 1) end)
        end
    end
    C_Timer.After(retryDelays[1], function() Retry(1) end)
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_LEVEL_UP")
eventFrame:SetScript("OnEvent", function()
    ns.HideBlizzardBannerNow()
end)
