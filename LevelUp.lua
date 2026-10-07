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
local baselineRefreshScheduled = false
local levelUpChatFilterRegistered = false

local function IsBuiltInLevelUpMessage(message)
    if type(message) ~= "string" then return false end

    local plainMessage = message:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")
    local currentLevel = tonumber(UnitLevel("player"))
    local localizedTemplate = _G.ERR_LEVEL_UP
    if currentLevel and type(localizedTemplate) == "string" then
        local ok, expected = pcall(string.format, localizedTemplate, currentLevel)
        if ok then
            expected = expected:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")
            if expected == plainMessage then return true end
        end
    end

    -- Keep an English fallback for clients where ERR_LEVEL_UP is unavailable.
    plainMessage = plainMessage:lower()
    return plainMessage:find("congratulations", 1, true) ~= nil
        and plainMessage:find("you have reached", 1, true) ~= nil
        and plainMessage:find("level%s+%d+") ~= nil
end

function ns.RegisterLevelUpChatFilter()
    if levelUpChatFilterRegistered or type(ChatFrame_AddMessageEventFilter) ~= "function" then return end
    ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", function(_, _, message)
        if ns.IsAddonEnabled and not ns.IsAddonEnabled() then return false end
        if IsBuiltInLevelUpMessage(message) then return true end
        return false
    end)
    levelUpChatFilterRegistered = true
end

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

local function PrintClassicLevelUpText(currentLevel, statDiff)
    if not ns.db or ns.db.printClassicLevelUpText ~= true then return end

    local hitPoints
    local mana
    local statLines = {}
    for _, change in ipairs(statDiff.stats or {}) do
        local increase = change.new - change.old
        if change.kind == "health" then
            hitPoints = increase
        elseif change.kind == "mana" then
            mana = increase
        elseif change.kind ~= "power" and increase > 0 then
            statLines[#statLines + 1] = string.format("Your %s increased by %d", change.name, increase)
        end
    end

    local lines = { string.format("Congratulations! You have reached level %d!", currentLevel) }
    if hitPoints and hitPoints > 0 then
        if mana and mana > 0 then
            lines[#lines + 1] = string.format("You have gained %d hit points and %d mana", hitPoints, mana)
        else
            lines[#lines + 1] = string.format("You have gained %d hit points", hitPoints)
        end
    elseif mana and mana > 0 then
        lines[#lines + 1] = string.format("You have gained %d mana", mana)
    end

    for _, line in ipairs(statLines) do
        lines[#lines + 1] = line
    end

    local color = ns.db.classicLevelUpTextColor or { 1.00, 1.00, 159 / 255 }
    local red = math.floor(math.max(0, math.min(1, tonumber(color[1]) or 1)) * 255 + 0.5)
    local green = math.floor(math.max(0, math.min(1, tonumber(color[2]) or 1)) * 255 + 0.5)
    local blue = math.floor(math.max(0, math.min(1, tonumber(color[3]) or (159 / 255))) * 255 + 0.5)
    for index, line in ipairs(lines) do
        local coloredLine = string.format("|cff%02X%02X%02X%s|r", red, green, blue, line)
        C_Timer.After((index - 1) * 0.05, function()
            print(coloredLine)
        end)
    end
end

local function QueueBaselineRefresh()
    if baselineRefreshScheduled or levelUpPending then return end
    baselineRefreshScheduled = true
    C_Timer.After(0.1, function()
        baselineRefreshScheduled = false
        if not levelUpPending then ns.RefreshBaseline() end
    end)
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
    local flavor = ns.GetCurrentFlavor and ns.GetCurrentFlavor() or "forever"
    local afterSpells = ns.SnapshotSpellBook()
    local retailFutureSpells = ns.GetRetailFutureSpellsBeforeLevel
        and ns.GetRetailFutureSpellsBeforeLevel() or nil

    local ok, err = pcall(function()
        local statDiff = ns.DiffStats(baselineStats, afterStats)
        PrintClassicLevelUpText(afterStats.level, statDiff)
        local trainerAbilities
        if flavor == "retail" and ns.GetRetailUnlearnedSpells then
            trainerAbilities = ns.GetRetailUnlearnedSpells(afterStats.level, retailFutureSpells)
        else
            trainerAbilities = ns.GetAllTrainableUpToLevel(afterStats.level, afterSpells)
        end

        local unlearnedWeaponSkills = ns.GetUnlearnedWeaponSkills(afterStats.level)
        local warlockPetAbilities = ns.GetUnlearnedWarlockPetAbilities
            and ns.GetUnlearnedWarlockPetAbilities(afterStats.level) or {}
        if ns.SuppressBlizzardBanner then ns.SuppressBlizzardBanner() end
        ns.ShowLevelUp(afterStats.level, statDiff.stats, trainerAbilities, unlearnedWeaponSkills, levelTimeForDisplay, warlockPetAbilities)
        levelTimeForDisplay = nil
        if flavor == "retail" and ns.CaptureRetailFutureSpells then
            ns.CaptureRetailFutureSpells()
        end
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
        ns.RegisterLevelUpChatFilter()
        RequestPlayedTime()
        if ns.CaptureRetailFutureSpells then ns.CaptureRetailFutureSpells() end
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
        QueueBaselineRefresh()
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
