local ADDON_NAME, ns = ...

-- Use stat snapshots so the displayed changes are consistent.

local baselineStats
local pendingSinceCombat = false -- true while a level-up is waiting for combat to end
local levelUpPending = false
local pendingStart, pendingEnd, pendingFutureSpells, pendingElapsed
local pendingTimes = {}
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
    GnomeLevelUpCharacterDB = type(GnomeLevelUpCharacterDB) == "table" and GnomeLevelUpCharacterDB or {}
    GnomeLevelUpCharacterDB.levelTimes, GnomeLevelUpCharacterDB.fastestLevelTimes = nil, nil
    cachedTimeLevel, cachedTimeSeconds, cachedTimeReceivedAt, levelTimeForDisplay = nil, nil, nil, nil
    requestedTimeLevel = nil
    pendingElapsed, pendingTimes = nil, {}
    playedTimeRequestToken = playedTimeRequestToken + 1
    RestorePlayedTimeChat()
    if ns.ClearLevelPaceComparison then ns.ClearLevelPaceComparison() end
    RequestPlayedTime()
end

function ns.RecordCompletedLevel(reachedLevel, seconds)
    reachedLevel, seconds = tonumber(reachedLevel), tonumber(seconds)
    if not reachedLevel or reachedLevel % 1 ~= 0 or reachedLevel < 2
        or not seconds or seconds ~= seconds or seconds < 0 or seconds == math.huge then return end
    GnomeLevelUpCharacterDB = type(GnomeLevelUpCharacterDB) == "table" and GnomeLevelUpCharacterDB or {}
    local history = GnomeLevelUpCharacterDB.levelTimes
    if type(history) ~= "table" then history = {}; GnomeLevelUpCharacterDB.levelTimes = history end
    local flavor = ns.GetCurrentFlavor()
    if type(history[flavor]) ~= "table" then history[flavor] = {} end
    -- Keys are the level completed: 1 means the full 1 -> 2 interval.
    if history[flavor][reachedLevel - 1] == nil then
        history[flavor][reachedLevel - 1] = seconds
    end
end

function ns.GetTimeToMaxLevel()
    local cap = ns.GetLevelCap()
    local history = type(GnomeLevelUpCharacterDB) == "table" and GnomeLevelUpCharacterDB.levelTimes
    local times = type(history) == "table" and history[ns.GetCurrentFlavor()]
    if not cap or type(times) ~= "table" then return nil end
    local total = 0
    for level = 1, cap - 1 do
        local seconds = times[level]
        if type(seconds) ~= "number" or seconds ~= seconds or seconds < 0 or seconds == math.huge then return nil end
        total = total + seconds
    end
    return total < math.huge and total or nil
end

function ns.RecordLevelPace(seconds)
    seconds = tonumber(seconds)
    if not seconds or seconds ~= seconds or seconds == math.huge or seconds < 1 then return nil end
    seconds = math.floor(seconds)
    GnomeLevelUpCharacterDB = type(GnomeLevelUpCharacterDB) == "table" and GnomeLevelUpCharacterDB or {}
    local records = GnomeLevelUpCharacterDB.fastestLevelTimes
    if type(records) ~= "table" then records = {}; GnomeLevelUpCharacterDB.fastestLevelTimes = records end
    local flavor = ns.GetCurrentFlavor()
    local previous = tonumber(records[flavor])
    if not previous or previous ~= previous or previous == math.huge or previous < 1 then
        records[flavor] = seconds
        return nil
    elseif seconds < previous then
        records[flavor] = seconds
        return previous
    end
    return previous
end

function ns.RefreshBaseline()
    baselineStats = ns.SnapshotStats()
end

local function QueueBaselineRefresh()
    if baselineRefreshScheduled or levelUpPending then return end
    baselineRefreshScheduled = true
    C_Timer.After(0.1, function()
        baselineRefreshScheduled = false
        if not levelUpPending then ns.RefreshBaseline() end
    end)
end

local function ClearPendingBatch()
    pendingStart, pendingEnd, pendingFutureSpells, pendingElapsed = nil, nil, nil, nil
    pendingTimes = {}
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

local function DisplayLevelUp()
    if not levelUpPending then return end
    pendingSinceCombat = false
    -- Compare the saved stats with the new stats and show the panel.
    if not baselineStats then
        ns.RefreshBaseline()
        levelUpPending = false
        ClearPendingBatch()
        return
    end

    local afterStats = ns.SnapshotStats()
    levelUpPending = false
    local flavor = ns.GetCurrentFlavor and ns.GetCurrentFlavor() or "forever"
    local afterSpells = ns.SnapshotSpellBook()
    local startLevel = tonumber(pendingStart) or tonumber(baselineStats.level)
    local multiple = startLevel and afterStats.level > startLevel + 1
    local rangeStart = multiple and startLevel or nil
    local retailFutureSpells = pendingFutureSpells or (ns.GetRetailFutureSpellsBeforeLevel
        and ns.GetRetailFutureSpellsBeforeLevel() or nil)

    local ok, err = pcall(function()
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
        if multiple then
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
    end)
    if not ok then
        print("|cff3fe0ffGnomeLevelUp|r: couldn't display the level-up screen this time (" .. tostring(err) .. ")")
    end

    baselineStats = afterStats
    ClearPendingBatch()
end

local function ScheduleDisplay()
    -- Delay the panel until combat and other level-up UI settle down.
    displayToken = displayToken + 1
    local token = displayToken
    if displayTimer then displayTimer:Cancel(); displayTimer = nil end
    local function DisplayWhenReady()
        if token ~= displayToken then return end
        displayTimer = nil
        if ns.db and ns.db.waitForCombatEnd ~= false and UnitAffectingCombat("player") then
            pendingSinceCombat = true
            return
        end
        DisplayLevelUp()
    end
    if type(C_Timer.NewTimer) == "function" then
        displayTimer = C_Timer.NewTimer(.75, DisplayWhenReady)
    else
        C_Timer.After(.75, DisplayWhenReady)
    end
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
    elseif event == "PLAYER_REGEN_ENABLED" and pendingSinceCombat then
        pendingSinceCombat = false
        ScheduleDisplay()
    elseif not levelUpPending and (event == "PLAYER_EQUIPMENT_CHANGED"
        or (unit == "player" and (event == "UNIT_AURA" or event == "UNIT_MAXHEALTH"
            or event == "UNIT_MAXPOWER" or event == "UNIT_STATS"))) then
        QueueBaselineRefresh()
    end
end)

function ns.HandleLevelUp(newLevel)
    local reachedLevel = tonumber(newLevel) or tonumber(UnitLevel("player"))
    if not reachedLevel or reachedLevel ~= reachedLevel or reachedLevel == math.huge or reachedLevel % 1 ~= 0 then return end
    if levelUpPending and pendingEnd and reachedLevel <= pendingEnd then return end
    if not levelUpPending and baselineStats and reachedLevel <= baselineStats.level then return end
    if not levelUpPending then
        ClearPendingBatch()
        pendingStart = baselineStats and tonumber(baselineStats.level) or reachedLevel - 1
        pendingFutureSpells = ns.GetRetailFutureSpellsBeforeLevel and ns.GetRetailFutureSpellsBeforeLevel() or nil
    end
    local previousReached = pendingEnd or pendingStart
    levelUpPending = true
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
    if waitForCombat and UnitAffectingCombat("player") then
        pendingSinceCombat = true
        return
    end
    ScheduleDisplay()
end
