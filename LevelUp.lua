local ADDON_NAME, ns = ...

-- Event handling owns the live baseline, pending popup and /played request cache.
-- Saved timing records belong to LevelHistory.lua.
local baselineStats
local pendingSinceCombat = false -- true while a level-up is waiting for combat to end
local levelUpPending = false
local pendingStart, pendingEnd, pendingFutureSpells, pendingElapsed
local pendingCombatSeen, pendingDialogueSeen
local pendingTimes = {}
local expectedStatGains = {}
local STAT_RETRY_DELAY, STAT_RETRY_LIMIT = .15, 4
local displayToken, displayTimer = 0, nil
local requestedTimeLevel
local cachedTimeLevel
local cachedTimeSeconds
local cachedTimeReceivedAt
local levelTimeForDisplay
local quietChatFrames = {}
local playedTimeRequestToken = 0
local baselineRefreshScheduled = false
local function RestorePlayedTimeChat()
    for _, chatFrame in ipairs(quietChatFrames) do
        chatFrame:RegisterEvent("TIME_PLAYED_MSG")
    end
    wipe(quietChatFrames)
end

local function RequestPlayedTime()
    if type(RequestTimePlayed) ~= "function" then return end
    if not ns.db or not ns.IsAddonEnabled() then return end
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

function ns.ResetLevelTimers()
    ns.ClearRecordedLevelTimes()
    cachedTimeLevel, cachedTimeSeconds, cachedTimeReceivedAt, levelTimeForDisplay = nil, nil, nil, nil
    requestedTimeLevel = nil
    pendingElapsed, pendingTimes = nil, {}
    playedTimeRequestToken = playedTimeRequestToken + 1
    RestorePlayedTimeChat()
    if ns.ClearLevelPaceComparison then ns.ClearLevelPaceComparison() end
    RequestPlayedTime()
end

local function SnapshotBaseline()
    return ns.SnapshotStats(baselineStats)
end

function ns.RefreshBaseline()
    if levelUpPending then return end
    local ok, snapshot = xpcall(SnapshotBaseline, ns.CaptureErrorTrace)
    if ok then
        baselineStats = snapshot
    else
        ns.RecordError("stats", "baseline_snapshot_failed", { source = "baseline" }, snapshot)
    end
end

local function RunBaselineRefresh()
    baselineRefreshScheduled = false
    -- A stat event can arrive before the corresponding level-up event.
    if not baselineStats or UnitLevel("player") == baselineStats.level then ns.RefreshBaseline() end
end

local function QueueBaselineRefresh()
    if baselineRefreshScheduled or levelUpPending then return end
    baselineRefreshScheduled = true
    C_Timer.After(0.1, RunBaselineRefresh)
end

local function ClearPendingBatch()
    pendingStart, pendingEnd, pendingFutureSpells, pendingElapsed = nil, nil, nil, nil
    pendingCombatSeen, pendingDialogueSeen = nil, nil
    pendingTimes = {}
    expectedStatGains = {}
end

local function ReportLevelUpError(code, reason, afterStats, retries, failure)
    ns.RecordError(code, reason, {
        source = "level_up", level = pendingEnd, fromLevel = pendingStart, retries = retries,
        before = baselineStats, after = afterStats, expectedStatGains = expectedStatGains,
        combatDuringCapture = pendingCombatSeen, dialogueDuringCapture = pendingDialogueSeen,
    }, failure)
end

local function UniqueAbilities(abilities)
    local result, seen = {}, {}
    for _, ability in ipairs(abilities or {}) do
        local key = ability.id and ("spell:" .. ability.id) or ability.itemID and ("item:" .. ability.itemID)
            or (tostring(ability.kind) .. ":" .. tostring(ability.name))
        if not seen[key] then seen[key] = true; result[#result + 1] = ability end
    end
    return result
end

local function DisplayLevelUp(afterStats)
    if not levelUpPending then return end
    pendingSinceCombat = false
    if not baselineStats then
        ReportLevelUpError("stats", "baseline_missing", afterStats)
        levelUpPending = false
        ns.RefreshBaseline()
        ClearPendingBatch()
        return
    end

    levelUpPending = false
    local flavor = ns.GetCurrentFlavor and ns.GetCurrentFlavor() or "forever"
    local startLevel = tonumber(pendingStart) or tonumber(baselineStats.level)
    local combinedGain = startLevel and afterStats.level > startLevel + 1
    local rangeStart = combinedGain and startLevel or nil
    local retailFutureSpells = pendingFutureSpells or (ns.GetRetailFutureSpellsBeforeLevel
        and ns.GetRetailFutureSpellsBeforeLevel() or nil)

    local ok, err = xpcall(function()
        local afterSpells = ns.SnapshotSpellBook()
        local statDiff = ns.DiffStats(baselineStats, afterStats)
        local trainerAbilities
        if flavor == "retail" then
            trainerAbilities = ns.GetRetailUnlearnedSpells(afterStats.level, retailFutureSpells, rangeStart)
        else
            trainerAbilities = ns.GetAllTrainableUpToLevel(afterStats.level, afterSpells, rangeStart)
        end

        local unlearnedWeaponSkills = ns.GetUnlearnedWeaponSkills(afterStats.level)
        local warlockPetAbilities = ns.GetUnlearnedWarlockPetAbilities
            and ns.GetUnlearnedWarlockPetAbilities(afterStats.level, rangeStart) or {}
        if ns.SuppressBlizzardBanner then ns.SuppressBlizzardBanner() end
        local previousFastest
        local displayTime = levelTimeForDisplay
        if combinedGain then
            displayTime = pendingElapsed
            trainerAbilities = UniqueAbilities(trainerAbilities)
            warlockPetAbilities = UniqueAbilities(warlockPetAbilities)
            unlearnedWeaponSkills = UniqueAbilities(unlearnedWeaponSkills)
            for level = startLevel + 1, afterStats.level do
                if pendingTimes[level] then ns.RecordLevelPace(pendingTimes[level]) end
            end
        else
            ns.RecordCompletedLevel(afterStats.level, levelTimeForDisplay)
            previousFastest = ns.RecordLevelPace(levelTimeForDisplay)
        end
        ns.ShowLevelUp(afterStats.level, statDiff.stats, trainerAbilities, unlearnedWeaponSkills, displayTime,
            warlockPetAbilities, false, nil, previousFastest, nil, nil, rangeStart, statDiff.secondary)
        levelTimeForDisplay = nil
        if flavor == "retail" and ns.CaptureRetailFutureSpells then
            ns.CaptureRetailFutureSpells()
        end
    end, ns.CaptureErrorTrace)
    if not ok then
        ReportLevelUpError("popup", "prepare_failed", afterStats, nil, err)
    end

    baselineStats = afterStats
    ClearPendingBatch()
end

local function ScheduleDisplay(delay, retryCount)
    -- Delay the panel until combat and other level-up UI settle down.
    displayToken = displayToken + 1
    local token = displayToken
    if displayTimer then displayTimer:Cancel(); displayTimer = nil end
    local function DisplayWhenReady()
        if token ~= displayToken then return end
        displayTimer = nil
        local inCombat = UnitAffectingCombat("player")
        if inCombat then pendingCombatSeen = true end
        if ns.IsDialogueUIVisible() then pendingDialogueSeen = true end
        if inCombat and (not ns.db or ns.db.waitForCombatEnd ~= false) then
            pendingSinceCombat = true
            return
        end
        local snapshotOK, afterStats = xpcall(ns.SnapshotStats, ns.CaptureErrorTrace)
        if not snapshotOK then
            ReportLevelUpError("stats", "level_up_snapshot_failed", nil, retryCount or 0, afterStats)
            levelUpPending, pendingSinceCombat, baselineStats = false, false, nil
            ClearPendingBatch()
            QueueBaselineRefresh()
            return
        end
        if baselineStats and next(expectedStatGains)
            and ns.HasMissingLevelUpStats(baselineStats, afterStats, expectedStatGains) then
            if (retryCount or 0) < STAT_RETRY_LIMIT then
                ScheduleDisplay(STAT_RETRY_DELAY, (retryCount or 0) + 1)
                return
            end
            if inCombat then
                pendingSinceCombat = true
                return
            end
            print("|cffff4040GnomeLevelUp|r: " .. ns.L("Stat capture failed: Expected stat changes were still missing after retrying."))
            ReportLevelUpError("stats", "expected_gains_missing", afterStats, retryCount or 0)
        end
        DisplayLevelUp(afterStats)
    end
    if type(C_Timer.NewTimer) == "function" then
        displayTimer = C_Timer.NewTimer(delay or .75, DisplayWhenReady)
    else
        C_Timer.After(delay or .75, DisplayWhenReady)
    end
end

local combatWaitFrame = CreateFrame("Frame")
combatWaitFrame:RegisterEvent("PLAYER_LOGIN")
combatWaitFrame:RegisterEvent("TIME_PLAYED_MSG")
combatWaitFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
combatWaitFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
combatWaitFrame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
combatWaitFrame:RegisterEvent("UNIT_AURA")
combatWaitFrame:RegisterEvent("UNIT_MAXHEALTH")
combatWaitFrame:RegisterEvent("UNIT_MAXPOWER")
combatWaitFrame:RegisterEvent("UNIT_STATS")
combatWaitFrame:SetScript("OnEvent", function(_, event, unit, ...)
    if event == "PLAYER_LOGIN" then
        if ns.SyncLevelHistory then ns.SyncLevelHistory() end
        RequestPlayedTime()
        if ns.CaptureRetailFutureSpells then ns.CaptureRetailFutureSpells() end
    elseif event == "TIME_PLAYED_MSG" then
        local timePlayedThisLevel = ...
        timePlayedThisLevel = tonumber(timePlayedThisLevel)
        local currentLevel = tonumber(UnitLevel("player"))
        if timePlayedThisLevel and timePlayedThisLevel == timePlayedThisLevel
            and timePlayedThisLevel >= 0 and timePlayedThisLevel < math.huge
            and requestedTimeLevel and currentLevel then
            if requestedTimeLevel == currentLevel then
                cachedTimeLevel = currentLevel
                cachedTimeSeconds = timePlayedThisLevel
                cachedTimeReceivedAt = GetTime()
            elseif levelUpPending and requestedTimeLevel == currentLevel - 1 then
                levelTimeForDisplay = timePlayedThisLevel
                ns.RecordCompletedLevel(currentLevel, timePlayedThisLevel)
                pendingTimes[currentLevel] = timePlayedThisLevel
                if pendingStart == currentLevel - 1 then pendingElapsed = timePlayedThisLevel end
            end
        end
        requestedTimeLevel = nil
        -- Restore after the response has finished dispatching to all frames.
        C_Timer.After(0, RestorePlayedTimeChat)
    elseif event == "PLAYER_REGEN_DISABLED" and levelUpPending then
        pendingCombatSeen = true
    elseif event == "PLAYER_REGEN_ENABLED" and pendingSinceCombat then
        pendingSinceCombat = false
        ScheduleDisplay()
    elseif not levelUpPending and (event == "PLAYER_EQUIPMENT_CHANGED"
        or event == "PLAYER_REGEN_ENABLED"
        or (unit == "player" and (event == "UNIT_AURA" or event == "UNIT_MAXHEALTH"
            or event == "UNIT_MAXPOWER" or event == "UNIT_STATS"))) then
        QueueBaselineRefresh()
    end
end)

function ns.HandleLevelUp(newLevel, ...)
    local reachedLevel = tonumber(newLevel) or tonumber(UnitLevel("player"))
    if not reachedLevel or reachedLevel ~= reachedLevel or reachedLevel == math.huge or reachedLevel % 1 ~= 0 then return end
    if levelUpPending and pendingEnd and reachedLevel <= pendingEnd then return end
    if not levelUpPending and baselineStats and reachedLevel <= baselineStats.level then return end
    if not levelUpPending then
        ClearPendingBatch()
        pendingCombatSeen, pendingDialogueSeen = false, false
        pendingStart = baselineStats and tonumber(baselineStats.level) or reachedLevel - 1
        pendingFutureSpells = ns.GetRetailFutureSpellsBeforeLevel and ns.GetRetailFutureSpellsBeforeLevel() or nil
    end
    -- The event supplies four fields after the level before the primary stat gains.
    for index = 1, math.min(5, select("#", ...) - 4) do
        local gain = select(index + 4, ...)
        if type(gain) == "number" and (not issecretvalue or not issecretvalue(gain)) and gain > 0 then
            expectedStatGains[index] = (expectedStatGains[index] or 0) + gain
        end
    end
    local previousReached = pendingEnd or pendingStart
    levelUpPending = true
    if ns.IsDialogueUIVisible() then pendingDialogueSeen = true end
    levelTimeForDisplay = nil
    local elapsed
    if previousReached and cachedTimeLevel == previousReached and cachedTimeSeconds then
        elapsed = cachedTimeSeconds + math.max(0, GetTime() - (cachedTimeReceivedAt or GetTime()))
        if previousReached == reachedLevel - 1 then
            levelTimeForDisplay = elapsed
            pendingTimes[reachedLevel] = elapsed
            ns.RecordCompletedLevel(reachedLevel, elapsed)
        end
    end
    if previousReached == pendingStart then pendingElapsed = elapsed
    elseif pendingElapsed and elapsed then pendingElapsed = pendingElapsed + elapsed
    else pendingElapsed = nil end
    pendingEnd = reachedLevel
    cachedTimeLevel, cachedTimeSeconds, cachedTimeReceivedAt = reachedLevel, 0, GetTime()
    local waitForCombat = not ns.db or ns.db.waitForCombatEnd ~= false
    if UnitAffectingCombat("player") then
        pendingCombatSeen = true
        if waitForCombat then
            pendingSinceCombat = true
            return
        end
    end
    ScheduleDisplay()
end
