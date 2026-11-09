local ADDON_NAME, ns = ...

-- UnitStat uses the same five indexes on the supported clients.
local STAT_NAMES = {
    [1] = _G["STRENGTH"] or "Strength",
    [2] = _G["AGILITY"] or "Agility",
    [3] = _G["STAMINA"] or "Stamina",
    [4] = _G["INTELLECT"] or "Intellect",
    [5] = _G["SPIRIT"] or "Spirit",
}

local STAT_ENGLISH = { "Strength", "Agility", "Stamina", "Intellect", "Spirit" }
local STAT_ABBREVIATIONS = { "STR", "AGI", "STA", "INT", "SPI" }
local POWER_LABELS = { MANA = "Mana", RAGE = "Rage", FOCUS = "Focus", ENERGY = "Energy", RUNIC_POWER = "Runic Power" }
local SECONDARY_ABBREVIATIONS = { crit = "Crit", mastery = "Mast", haste = "Haste", versatility = "Versa" }
local SECONDARY_LABELS = {
    crit = "Crit. Strike", haste = "Haste", mastery = "Mastery", versatility = "Versatility",
    hit = "Hit Chance", expertise = "Expertise", attackPower = "Attack Power", rangedPower = "Ranged Attack Power",
    spellPower = "Spell Power", healing = "Healing Power", armor = "Armor", defense = "Defense",
    dodge = "Dodge", parry = "Parry", block = "Block", armorPen = "Armor Penetration", manaRegen = "Mana per 5 sec",
}
local STAT_INDEX_BY_NAME = {}
for index, name in ipairs(STAT_ENGLISH) do
    STAT_INDEX_BY_NAME[name], STAT_INDEX_BY_NAME[STAT_NAMES[index]] = index, index
end

-- Compact labels are fixed acronyms in equal-width mode on every locale.
function ns.GetStatDisplayLabel(stat)
    local abbreviate = ns.db and ns.db.abbreviateStatNames
    if stat.kind == "secondary" then
        return (abbreviate and SECONDARY_ABBREVIATIONS[stat.key]) or ns.L(SECONDARY_LABELS[stat.key] or stat.name)
    end
    local abbreviatePrimary = abbreviate and ns.db.equalStatWidths
    if stat.kind == "health" or stat.name == "Health" or stat.name == _G.HEALTH then
        return abbreviatePrimary and "HP" or ns.L("Health")
    end
    if stat.kind == "mana" or stat.name == "Mana" or stat.name == _G.MANA then
        return abbreviatePrimary and "MP" or ns.L("Mana")
    end
    local index = stat.statIndex or STAT_INDEX_BY_NAME[stat.name]
    if abbreviatePrimary and not index then
        for i, name in ipairs(STAT_ENGLISH) do
            if stat.name == ns.L(name) then index = i; break end
        end
    end
    return (abbreviatePrimary and STAT_ABBREVIATIONS[index]) or ns.L(STAT_ENGLISH[index] or stat.name)
end

local CLASS_PRIMARY_STAT = {
    WARRIOR = 1, PALADIN = 1, DEATHKNIGHT = 1,
    HUNTER = 2, ROGUE = 2, MONK = 2, DEMONHUNTER = 2,
    MAGE = 4, PRIEST = 4, WARLOCK = 4, DRUID = 4, SHAMAN = 4, EVOKER = 4,
}

local function GetPrimaryStatIndex()
    local getSpec = C_SpecializationInfo and C_SpecializationInfo.GetSpecialization or rawget(_G, "GetSpecialization")
    local getInfo = C_SpecializationInfo and C_SpecializationInfo.GetSpecializationInfo or rawget(_G, "GetSpecializationInfo")
    if type(getSpec) == "function" and type(getInfo) == "function" then
        local ok, spec = pcall(getSpec)
        if ok and spec then
            local valid, _, _, _, _, _, primaryStat = pcall(getInfo, spec)
            if valid and (primaryStat == 1 or primaryStat == 2 or primaryStat == 4) then return primaryStat end
        end
    end
    local _, class = UnitClass("player")
    return CLASS_PRIMARY_STAT[class]
end

function ns.PlayerUsesMana()
    if type(UnitPowerType) ~= "function" then return true end
    local ok, powerType, token = pcall(UnitPowerType, "player")
    if not ok then return true end
    if type(token) == "string" then return token == "MANA" end
    if type(powerType) == "number" then return powerType == 0 end
    return true
end

function ns.FilterRelevantStats(changes)
    local retail, usesMana = ns.GetCurrentFlavor() == "retail", ns.PlayerUsesMana()
    local function Hidden(stat)
        local mana = stat.kind == "mana" or stat.name == "Mana" or stat.name == _G["MANA"]
        return mana and not usesMana or retail and stat.kind == "power" and not mana
    end
    local filteredResources
    for index, stat in ipairs(changes) do
        if Hidden(stat) then
            if not filteredResources then
                filteredResources = {}
                for i=1,index-1 do filteredResources[#filteredResources+1]=changes[i] end
            end
        elseif filteredResources then filteredResources[#filteredResources+1]=stat end
    end
    changes = filteredResources or changes
    if not retail then return changes end
    if not ns.db or ns.db.relevantRetailStatsOnly ~= true then return changes end
    local primary = GetPrimaryStatIndex()
    if not primary then return changes end
    local filtered = {}
    for _, stat in ipairs(changes) do
        local index = stat.statIndex or STAT_INDEX_BY_NAME[stat.name]
        if stat.kind == "secondary" or index == 3 or index == primary or stat.kind == "health" or stat.kind == "mana" or stat.kind == "power"
            or stat.name == "Health" or stat.name == (_G["HEALTH"] or "Health")
            or stat.name == "Mana" or stat.name == (_G["MANA"] or "Mana") then
            filtered[#filtered + 1] = stat
        end
    end
    return filtered
end

function ns.GetStatAbbreviationThreshold()
    if ns.GetCurrentFlavor() == "retail" and ns.db and ns.db.shortenRetailStatTotals == true then
        return ns.db.horizontalMode and 10000 or 100000
    end
    return nil
end

-- Lua 5.1 clients may narrow %d to 32 bits even though Lua numbers are doubles.
function ns.FormatStatInteger(value) return string.format("%.0f", value) end
function ns.FormatStatGain(value, stat)
    if stat and stat.unit == "percent" then return string.format(" (%+.2f%%)", value / 100) end
    return string.format(" (%+.0f)", value)
end

function ns.FormatStatTotal(value, stat)
    if stat and stat.unit == "percent" then return string.format("%.2f%%", value / 100) end
    local threshold = ns.GetStatAbbreviationThreshold()
    if not threshold or math.abs(value) < threshold then return ns.FormatStatInteger(value) end
    local magnitude, divisor, suffix = math.abs(value), 1000, "%sk"
    local thousands = math.floor(magnitude / 1000 + .5)
    if thousands >= 1100 and thousands < 1000000 then
        local millions = math.floor(thousands / 1000)
        local result = ns.L("%sM %sk", ns.FormatStatInteger(millions), ns.FormatStatInteger(thousands % 1000))
        return value < 0 and "-" .. result or result
    end
    if magnitude >= 1000000000 then divisor, suffix = 1000000000, "%sb"
    elseif magnitude >= 1000000 then divisor, suffix = 1000000, "%sm" end
    local scaled = math.floor(magnitude / divisor * 10 + 0.5) / 10
    if scaled >= 1000 and divisor < 1000000000 then
        scaled, suffix = scaled / 1000, divisor == 1000 and "%sm" or "%sb"
    end
    if value < 0 then scaled = -scaled end
    local number = string.format("%.1f", scaled):gsub("%.0$", "")
    return ns.L(suffix, number)
end

-- Match the client character-sheet values. Missing/secret values are omitted,
-- and the selected GLU flavour controls the stat set, independent of the client.
local function ReadSecondaryAPI(name, index, ...)
    local api = rawget(_G, name)
    if type(api) ~= "function" then return nil end
    local ok, first, second, third = pcall(api, ...)
    if not ok then return nil end
    local value
    if not index or index == 1 then value = first
    elseif index == 2 then value = second
    elseif index == 3 then value = third end
    if type(issecretvalue) == "function" and issecretvalue(value) then return nil end
    if type(value) ~= "number" or value ~= value or math.abs(value) == math.huge then return nil end
    return value
end

local function SecondarySum(name, count, ...)
    local total = ReadSecondaryAPI(name, 1, ...)
    if total == nil then return nil end
    for index = 2, count do
        local value = ReadSecondaryAPI(name, index, ...)
        if value == nil then return nil end
        total = total + value
    end
    return total
end

local function SecondaryMaximum(...)
    local best
    for index = 1, select("#", ...) do
        local value = select(index, ...)
        if value ~= nil then best = best and math.max(best, value) or value end
    end
    return best
end

-- Shared writers avoid new closures/upvalues on every idle baseline refresh.
local function AddSecondaryStat(stats, count, key, value, percent, positiveOnly)
    if value == nil or positiveOnly and value <= 0 then return count end
    count = count + 1
    local stat = stats[count] or {}
    stat.key, stat.name = key, ns.L(SECONDARY_LABELS[key])
    stat.value = math.floor(value * (percent and 100 or 1) + .5)
    stat.unit, stat.kind = percent and "percent" or nil, "secondary"
    stats[count] = stat
    return count
end

local function SecondaryHit(name, rating)
    local bonus = ReadSecondaryAPI("GetCombatRatingBonus", 1, rating)
    local modifier = ReadSecondaryAPI(name)
    return bonus and modifier and bonus + modifier or modifier or bonus
end

function ns.SnapshotSecondaryStats(reuse)
    local stats, count = reuse or {}, 0
    local spellCrit
    for school = 2, 7 do spellCrit = SecondaryMaximum(spellCrit, ReadSecondaryAPI("GetSpellCritChance", 1, school)) end
    count = AddSecondaryStat(stats, count, "crit", SecondaryMaximum(ReadSecondaryAPI("GetCritChance"),
        ReadSecondaryAPI("GetRangedCritChance"), spellCrit), true)
    local rangedHaste = SecondarySum("GetRangedHaste", 2)
        or ReadSecondaryAPI("GetRangedHaste")
    count = AddSecondaryStat(stats, count, "haste", SecondaryMaximum(ReadSecondaryAPI("GetHaste"), ReadSecondaryAPI("GetMeleeHaste"),
        rangedHaste, ReadSecondaryAPI("UnitSpellHaste", 1, "player")), true)
    if ns.GetCurrentFlavor() == "retail" then
        count = AddSecondaryStat(stats, count, "mastery", ReadSecondaryAPI("GetMasteryEffect"), true)
        local rating = ReadSecondaryAPI("GetCombatRatingBonus", 1, rawget(_G, "CR_VERSATILITY_DAMAGE_DONE") or 29)
        local bonus = ReadSecondaryAPI("GetVersatilityBonus", 1, rawget(_G, "CR_VERSATILITY_DAMAGE_DONE") or 29)
        count = AddSecondaryStat(stats, count, "versatility", rating and bonus and rating + bonus or rating or bonus, true)
    else
        count = AddSecondaryStat(stats, count, "hit", SecondaryMaximum(SecondaryHit("GetHitModifier", rawget(_G, "CR_HIT_MELEE") or 6),
            SecondaryHit("GetRangedHitModifier", rawget(_G, "CR_HIT_RANGED") or 7), SecondaryHit("GetSpellHitModifier", rawget(_G, "CR_HIT_SPELL") or 8)), true)
        count = AddSecondaryStat(stats, count, "expertise", SecondaryMaximum(ReadSecondaryAPI("GetExpertise",1),
            ReadSecondaryAPI("GetExpertise",2), ReadSecondaryAPI("GetExpertise",3)), true)
        count = AddSecondaryStat(stats, count, "attackPower", SecondarySum("UnitAttackPower", 3, "player"), false, true)
        local _, class = UnitClass("player")
        if class == "HUNTER" then count = AddSecondaryStat(stats, count, "rangedPower", SecondarySum("UnitRangedAttackPower", 3, "player"), false, true) end
        local spellPower
        for school = 2, 7 do spellPower = SecondaryMaximum(spellPower, ReadSecondaryAPI("GetSpellBonusDamage",1,school)) end
        count = AddSecondaryStat(stats, count, "spellPower", spellPower, false, true)
        count = AddSecondaryStat(stats, count, "healing", ReadSecondaryAPI("GetSpellBonusHealing"), false, true)
        count = AddSecondaryStat(stats, count, "armor", ReadSecondaryAPI("UnitArmor", 2, "player"))
        count = AddSecondaryStat(stats, count, "defense", SecondarySum("UnitDefenseSkill", 2, "player"))
        count = AddSecondaryStat(stats, count, "dodge", ReadSecondaryAPI("GetDodgeChance"), true)
        count = AddSecondaryStat(stats, count, "parry", ReadSecondaryAPI("GetParryChance"), true, true)
        count = AddSecondaryStat(stats, count, "block", ReadSecondaryAPI("GetBlockChance"), true, true)
        count = AddSecondaryStat(stats, count, "armorPen", ReadSecondaryAPI("GetArmorPenetration"), false, true)
        if ns.PlayerUsesMana() then
            local regen = ReadSecondaryAPI("GetManaRegen", 2)
            count = AddSecondaryStat(stats, count, "manaRegen", regen and regen * 5, false, true)
        end
    end
    for index = #stats, count + 1, -1 do stats[index] = nil end
    return stats
end

function ns.DiffSecondaryStats(before, after)
    local previous, changes = {}, {}
    for _, stat in ipairs(before or {}) do previous[stat.key] = stat end
    for _, stat in ipairs(after or {}) do
        local old = previous[stat.key]
        -- No fabricated gain if the setting was enabled after the baseline.
        changes[#changes + 1] = { name = stat.name, key = stat.key, kind = "secondary", unit = stat.unit,
            old = old and old.value or stat.value, new = stat.value }
    end
    return changes
end

function ns.BuildSecondaryPreviewStats()
    local current = ns.SnapshotSecondaryStats()
    return ns.DiffSecondaryStats(current, current)
end

function ns.SnapshotStats(reuse)
    -- Store raw values here; DiffStats rejects protected values before comparing them.
    local _, powerToken = UnitPowerType("player")
    local powerLabel = POWER_LABELS[powerToken]
    if not powerLabel then
        powerLabel = type(powerToken) == "string" and type(_G[powerToken]) == "string" and _G[powerToken] or "Power"
    end
    local snap = reuse or {}
    snap.level = UnitLevel("player")
    snap.health = UnitHealthMax("player")
    snap.power = UnitPowerMax("player")
    snap.powerToken, snap.powerLabel = powerToken, powerLabel
    snap.stats = snap.stats or {}
    snap.secondary = ns.db and ns.db.showSecondaryStats and ns.SnapshotSecondaryStats(snap.secondary) or nil
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

function ns.HasMissingLevelUpStats(before, after, expectedGains)
    for _, index in ipairs(GetDisplayedStatIndexes()) do
        if expectedGains[index] then
            local old = GetVisibleNumber(before.stats[index])
            local new = GetVisibleNumber(after.stats[index])
            if type(old) ~= "number" or type(new) ~= "number" or not (new > old) then
                return true
            end
        end
    end
    return false
end

function ns.BuildMaxLevelPreviewStats()
    local snapshot, changes = ns.SnapshotStats(), {}
    local function Add(name, value, kind, index)
        value = GetVisibleNumber(value)
        if type(value) ~= "number" or value ~= value or value < 0 or value == math.huge then return end
        value = math.floor(value)
        local gain = value > 0 and math.max(1, math.floor(value * .01 + .5)) or 0
        changes[#changes + 1] = { name = name, old = value - gain, new = value, kind = kind, statIndex = index }
    end
    Add(_G["HEALTH"] or "Health", snapshot.health, "health")
    if ns.GetCurrentFlavor() ~= "retail" or snapshot.powerToken == "MANA" then
        Add(snapshot.powerLabel or "Power", snapshot.power, snapshot.powerToken == "MANA" and "mana" or "power")
    end
    for _, index in ipairs(GetDisplayedStatIndexes()) do
        local base, effective = UnitStat("player", index)
        local value = GetVisibleNumber(effective)
        if value == nil then value = GetVisibleNumber(base) end
        Add(STAT_NAMES[index], value, nil, index)
    end
    return changes
end

function ns.DiffStats(before, after)
    -- Primary rows show increases; the secondary page can also show decreases.
    local diff = {
        level = GetVisibleNumber(after.level) or after.level,
        stats = {},
        secondary = ns.DiffSecondaryStats(before.secondary, after.secondary),
    }

    local function AddStat(name, oldVal, newVal, kind, statIndex)
        oldVal, newVal = GetVisibleNumber(oldVal), GetVisibleNumber(newVal)
        if oldVal == nil or newVal == nil then
            return -- secret right now; skip this one rather than crash
        end
        local ok, increased = pcall(function() return newVal > oldVal end)
        if not ok or not increased then
            return -- unchanged or (shouldn't happen, but just in case) went down
        end
        diff.stats[#diff.stats + 1] = { name = name, old = oldVal, new = newVal, kind = kind, statIndex = statIndex }
    end

    AddStat("Health", before.health, after.health, "health")
    if ns.GetCurrentFlavor() ~= "retail" or after.powerToken == "MANA" then
        AddStat(after.powerLabel or "Power", before.power, after.power,
            after.powerToken == "MANA" and "mana" or "power")
    end

    for _, i in ipairs(GetDisplayedStatIndexes()) do
        AddStat(STAT_NAMES[i], before.stats[i], after.stats[i], nil, i)
    end

    return diff
end
