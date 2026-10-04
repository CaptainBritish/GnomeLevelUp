local ADDON_NAME, ns = ...

-- Use stat snapshots so the displayed changes are consistent.

local baselineStats
local pendingSinceCombat = false -- true while a level-up is waiting for combat to end
local displayScheduled = false
local levelUpPending = false
local requestedTimeLevel
local cachedTimeLevel
local cachedTimeSeconds
local cachedTimeReceivedAt
local levelTimeForDisplay
local quietChatFrames = {}
local playedTimeRequestToken = 0

local function RestorePlayedTimeChat()
    for _, chatFrame in ipairs(quietChatFrames) do
        chatFrame:RegisterEvent("TIME_PLAYED_MSG")
    end
    wipe(quietChatFrames)
end

local function RequestPlayedTime()
    if type(RequestTimePlayed) ~= "function" then return end
    if not ns.db or not ns.db.showLevelTime or not ns.IsAddonEnabled() then return end
    if requestedTimeLevel then return end
    -- Blizzard chat frames print this event, even when an addon requested it.
    for index = 1, NUM_CHAT_WINDOWS or 10 do
        local chatFrame = _G["ChatFrame" .. index]
        if chatFrame and chatFrame:IsEventRegistered("TIME_PLAYED_MSG") then
            quietChatFrames[#quietChatFrames + 1] = chatFrame
            chatFrame:UnregisterEvent("TIME_PLAYED_MSG")
        end
    end
    requestedTimeLevel = tonumber(UnitLevel("player"))
    playedTimeRequestToken = playedTimeRequestToken + 1
    local token = playedTimeRequestToken
    local ok = pcall(RequestTimePlayed)
    if not ok then
        requestedTimeLevel = nil
        RestorePlayedTimeChat()
        return
    end
    -- A missing response must not leave normal /played output disabled.
    C_Timer.After(5, function()
        if token == playedTimeRequestToken and requestedTimeLevel then
            requestedTimeLevel = nil
            RestorePlayedTimeChat()
        end
    end)
end
ns.RequestLevelPlayedTime = RequestPlayedTime

function ns.GetCurrentLevelPlayedTime()
    local currentLevel = tonumber(UnitLevel("player"))
    if cachedTimeLevel == currentLevel and cachedTimeSeconds then
        local elapsed = cachedTimeReceivedAt and math.max(0, GetTime() - cachedTimeReceivedAt) or 0
        return cachedTimeSeconds + elapsed
    end
    return nil
end

function ns.RefreshBaseline()
    baselineStats = ns.SnapshotStats()
end

local function DisplayLevelUp()
    -- Compare the saved stats with the new stats and show the panel.
    if not baselineStats then
        ns.RefreshBaseline()
        levelUpPending = false
        return
    end

    local afterStats = ns.SnapshotStats()
    levelUpPending = false
    local hasTrainerData = #ns.GetTrainerCatalogIndex() > 0
    local afterSpells = hasTrainerData and ns.SnapshotSpellBook() or {}

    local ok, err = pcall(function()
        local statDiff = ns.DiffStats(baselineStats, afterStats)
        local trainerAbilities = {}
        for _, trainingAbility in ipairs(ns.GetAllTrainableUpToLevel(afterStats.level, afterSpells)) do
            trainerAbilities[#trainerAbilities + 1] = trainingAbility
        end

        local unlearnedWeaponSkills = ns.GetUnlearnedWeaponSkills(afterStats.level)
        if ns.SuppressBlizzardBanner then ns.SuppressBlizzardBanner() end
        ns.ShowLevelUp(afterStats.level, statDiff.stats, trainerAbilities, unlearnedWeaponSkills, levelTimeForDisplay)
        levelTimeForDisplay = nil
    end)
    if not ok then
        print("|cff3fe0ffGnomeLevelUp|r: couldn't display the level-up screen this time (" .. tostring(err) .. ")")
    end

    baselineStats = afterStats
end

local function ScheduleDisplay()
    -- Delay the panel until combat and other level-up UI settle down.
    if displayScheduled then return end
    displayScheduled = true
    C_Timer.After(0.75, function()
        displayScheduled = false
        if ns.db and ns.db.waitForCombatEnd ~= false and UnitAffectingCombat("player") then
            pendingSinceCombat = true
            return
        end
        DisplayLevelUp()
    end)
end

local combatWaitFrame = CreateFrame("Frame")
combatWaitFrame:RegisterEvent("PLAYER_LOGIN")
combatWaitFrame:RegisterEvent("TIME_PLAYED_MSG")
combatWaitFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
combatWaitFrame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
combatWaitFrame:RegisterEvent("UNIT_AURA")
combatWaitFrame:RegisterEvent("UNIT_MAXHEALTH")
combatWaitFrame:RegisterEvent("UNIT_MAXPOWER")
combatWaitFrame:RegisterEvent("UNIT_STATS")
combatWaitFrame:SetScript("OnEvent", function(_, event, unit, ...)
    if event == "PLAYER_LOGIN" then
        RequestPlayedTime()
    elseif event == "TIME_PLAYED_MSG" then
        local timePlayedThisLevel = ...
        timePlayedThisLevel = tonumber(timePlayedThisLevel)
        local currentLevel = tonumber(UnitLevel("player"))
        if timePlayedThisLevel and requestedTimeLevel then
            if requestedTimeLevel == currentLevel then
                cachedTimeLevel = currentLevel
                cachedTimeSeconds = timePlayedThisLevel
                cachedTimeReceivedAt = GetTime()
            elseif levelUpPending and requestedTimeLevel == currentLevel - 1 then
                levelTimeForDisplay = timePlayedThisLevel
            end
        end
        requestedTimeLevel = nil
        -- Restore after the response has finished dispatching to all frames.
        C_Timer.After(0, RestorePlayedTimeChat)
    elseif event == "PLAYER_REGEN_ENABLED" and pendingSinceCombat then
        pendingSinceCombat = false
        ScheduleDisplay()
    elseif not levelUpPending and (event == "PLAYER_EQUIPMENT_CHANGED"
        or (unit == "player" and (event == "UNIT_AURA" or event == "UNIT_MAXHEALTH"
            or event == "UNIT_MAXPOWER" or event == "UNIT_STATS"))) then
        C_Timer.After(0.1, function()
            if not levelUpPending then ns.RefreshBaseline() end
        end)
    end
end)

function ns.HandleLevelUp(newLevel)
    levelUpPending = true
    local reachedLevel = tonumber(newLevel) or tonumber(UnitLevel("player"))
    local previousLevel = reachedLevel and reachedLevel - 1
    levelTimeForDisplay = nil
    if previousLevel and cachedTimeLevel == previousLevel then
        levelTimeForDisplay = cachedTimeSeconds + math.max(0, GetTime() - cachedTimeReceivedAt)
    end
    cachedTimeLevel = reachedLevel
    cachedTimeSeconds = 0
    cachedTimeReceivedAt = GetTime()
    local waitForCombat = not ns.db or ns.db.waitForCombatEnd ~= false
    if waitForCombat and UnitAffectingCombat("player") then
        pendingSinceCombat = true
        return
    end
    ScheduleDisplay()
end
