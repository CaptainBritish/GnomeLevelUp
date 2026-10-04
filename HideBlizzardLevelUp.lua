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
local soundToken = 0
local BLIZZARD_SOUND_MUTE_DURATION = 60
-- These are the level-up files used by the supported clients. Keep the list
-- narrow so unrelated spell, creature, and interface sounds stay untouched.
local levelUpSoundFiles = {
    "Sound\\Spells\\LevelUp.ogg",
    "Sound\\Interface\\LevelUp.ogg",
    "Sound\\Doodad\\GO_LevelUp_Custom_6696263.ogg",
}

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

function ns.WithLevelUpSoundsUnmuted(callback)
    if type(callback) ~= "function" then return end
    if type(UnmuteSoundFile) == "function" then
        for _, soundFile in ipairs(levelUpSoundFiles) do
            pcall(UnmuteSoundFile, soundFile)
        end
    end
    pcall(callback)
    if type(MuteSoundFile) == "function" then
        for _, soundFile in ipairs(levelUpSoundFiles) do
            pcall(MuteSoundFile, soundFile)
        end
    end
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

function ns.RestoreBlizzardLevelUpSound()
    soundToken = soundToken + 1
    ns.blizzardLevelUpSoundMutedUntil = 0
    if type(UnmuteSoundFile) == "function" then
        for _, soundFile in ipairs(levelUpSoundFiles) do
            pcall(UnmuteSoundFile, soundFile)
        end
    end
end

function ns.SuppressBlizzardLevelUpSound()
    if type(MuteSoundFile) ~= "function" then return end
    if ns.db and ns.db.hideBlizzardLevelUp == false then return end
    soundToken = soundToken + 1
    local token = soundToken
    ns.blizzardLevelUpSoundMutedUntil = (GetTime and GetTime() or 0) + BLIZZARD_SOUND_MUTE_DURATION
    for _, soundFile in ipairs(levelUpSoundFiles) do
        pcall(MuteSoundFile, soundFile)
    end
    C_Timer.After(BLIZZARD_SOUND_MUTE_DURATION, function()
        if token == soundToken and type(UnmuteSoundFile) == "function" then
            for _, soundFile in ipairs(levelUpSoundFiles) do
                pcall(UnmuteSoundFile, soundFile)
            end
        end
    end)
end

function ns.RestoreBlizzardBanner()
    suppressionToken = suppressionToken + 1
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
    -- The toast container may be created lazily, so retry only direct globals.
    for _, delay in ipairs({ 0, 0.15, 0.4, 0.8 }) do
        C_Timer.After(delay, ns.SuppressBlizzardBanner)
    end
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_LEVEL_UP")
eventFrame:SetScript("OnEvent", function()
    ns.HideBlizzardBannerNow()
    if ns.db and ns.db.hideBlizzardLevelUp ~= false then
        ns.SuppressBlizzardLevelUpSound()
    end
end)
