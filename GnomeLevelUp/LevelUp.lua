local ADDON_NAME, ns = ...

-- Use stat snapshots so the displayed changes are consistent.

local baselineStats
local pendingSinceCombat = false -- true while a level-up is waiting for combat to end
local displayScheduled = false
local levelUpPending = false

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
        ns.ShowLevelUp(afterStats.level, statDiff.stats, trainerAbilities, unlearnedWeaponSkills)
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
combatWaitFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
combatWaitFrame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
combatWaitFrame:RegisterEvent("UNIT_AURA")
combatWaitFrame:RegisterEvent("UNIT_MAXHEALTH")
combatWaitFrame:RegisterEvent("UNIT_MAXPOWER")
combatWaitFrame:RegisterEvent("UNIT_STATS")
combatWaitFrame:SetScript("OnEvent", function(_, event, unit)
    if event == "PLAYER_REGEN_ENABLED" and pendingSinceCombat then
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

function ns.HandleLevelUp()
    levelUpPending = true
    local waitForCombat = not ns.db or ns.db.waitForCombatEnd ~= false
    if waitForCombat and UnitAffectingCombat("player") then
        pendingSinceCombat = true
        return
    end
    ScheduleDisplay()
end
