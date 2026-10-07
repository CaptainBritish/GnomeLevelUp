local ADDON_NAME, ns = ...

-- UnitStat uses the same five indexes on the supported clients.
local STAT_NAMES = {
    [1] = STRENGTH or "Strength",
    [2] = AGILITY or "Agility",
    [3] = STAMINA or "Stamina",
    [4] = INTELLECT or "Intellect",
    [5] = SPIRIT or "Spirit",
}

function ns.SnapshotStats()
    -- Keep the snapshot simple; the values may be secret, so DiffStats filters them later.
    local _, powerToken = UnitPowerType("player")
    local powerLabel = "Power"
    if type(powerToken) == "string" and type(_G[powerToken]) == "string" then
        powerLabel = _G[powerToken]
    end
    local snap = {
        level = UnitLevel("player"),
        health = UnitHealthMax("player"),
        power = UnitPowerMax("player"),
        powerToken = powerToken,
        powerLabel = powerLabel,
        stats = {},
    }
    for i = 1, 5 do
        snap.stats[i] = UnitStat("player", i)
    end
    return snap
end

local function GetDisplayedStatIndexes()
    if ns.GetCurrentFlavor and ns.GetCurrentFlavor() == "retail" then
        return { 1, 2, 3, 4 } -- Strength, Agility, Stamina, Intellect
    end
    return { 1, 2, 3, 4, 5 } -- + Spirit
end

local function GetVisibleNumber(value)
    if type(issecretvalue) == "function" and issecretvalue(value) then
        return nil
    end
    return value
end

function ns.DiffStats(before, after)
    -- Return only values that increased after the level-up.
    local diff = {
        level = GetVisibleNumber(after.level) or after.level,
        stats = {},
    }

    local function AddStat(name, oldVal, newVal, kind)
        oldVal, newVal = GetVisibleNumber(oldVal), GetVisibleNumber(newVal)
        if oldVal == nil or newVal == nil then
            return -- secret right now; skip this one rather than crash
        end
        local ok, increased = pcall(function() return newVal > oldVal end)
        if not ok or not increased then
            return -- unchanged or (shouldn't happen, but just in case) went down
        end
        diff.stats[#diff.stats + 1] = { name = name, old = oldVal, new = newVal, kind = kind }
    end

    AddStat("Health", before.health, after.health, "health")
    AddStat(after.powerLabel or "Power", before.power, after.power,
        after.powerToken == "MANA" and "mana" or "power")

    for _, i in ipairs(GetDisplayedStatIndexes()) do
        AddStat(STAT_NAMES[i], before.stats[i], after.stats[i])
    end

    return diff
end
