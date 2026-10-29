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
local SECONDARY_ABBREVIATIONS = { crit = "Crit", mastery = "Mast", haste = "Haste", versatility = "Versa" }

-- Compact labels are fixed acronyms in equal-width mode on every locale.
function ns.GetStatDisplayLabel(stat)
    if not ns.db or not ns.db.abbreviateStatNames then return stat.name end
    if stat.kind == "secondary" then return SECONDARY_ABBREVIATIONS[stat.key] or stat.name end
    if not ns.db.equalStatWidths then return stat.name end
    if stat.kind == "health" or stat.name == "Health" or stat.name == _G["HEALTH"] then return "HP" end
    if stat.kind == "mana" or stat.name == "Mana" or stat.name == _G["MANA"] then return "MP" end
    local index = stat.statIndex
    if not index then
        for i, name in ipairs(STAT_NAMES) do
            if stat.name == name or stat.name == STAT_ENGLISH[i] or ns.L and stat.name == ns.L(STAT_ENGLISH[i]) then index = i; break end
        end
    end
    return STAT_ABBREVIATIONS[index] or stat.name
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
        local index = stat.statIndex
        if not index then
            for i, name in ipairs(STAT_NAMES) do
                if stat.name == name then index = i; break end
            end
        end
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
    local results = {pcall(api, ...)}
    if not results[1] then return nil end
    local value = results[(index or 1) + 1]
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

function ns.SnapshotSecondaryStats()
    local stats = {}
    local function Add(key, label, value, percent, positiveOnly)
        if value == nil or positiveOnly and value <= 0 then return end
        stats[#stats + 1] = { key = key, name = ns.L(label),
            value = math.floor(value * (percent and 100 or 1) + .5),
            unit = percent and "percent" or nil, kind = "secondary" }
    end
    local spellCrit
    for school = 2, 7 do spellCrit = SecondaryMaximum(spellCrit, ReadSecondaryAPI("GetSpellCritChance", 1, school)) end
    Add("crit", "Crit. Strike", SecondaryMaximum(ReadSecondaryAPI("GetCritChance"),
        ReadSecondaryAPI("GetRangedCritChance"), spellCrit), true)
    local rangedHaste = SecondarySum("GetRangedHaste", 2)
        or ReadSecondaryAPI("GetRangedHaste")
    Add("haste", "Haste", SecondaryMaximum(ReadSecondaryAPI("GetHaste"), ReadSecondaryAPI("GetMeleeHaste"),
        rangedHaste, ReadSecondaryAPI("UnitSpellHaste", 1, "player")), true)
    if ns.GetCurrentFlavor() == "retail" then
        Add("mastery", "Mastery", ReadSecondaryAPI("GetMasteryEffect"), true)
        local rating = ReadSecondaryAPI("GetCombatRatingBonus", 1, rawget(_G, "CR_VERSATILITY_DAMAGE_DONE") or 29)
        local bonus = ReadSecondaryAPI("GetVersatilityBonus", 1, rawget(_G, "CR_VERSATILITY_DAMAGE_DONE") or 29)
        Add("versatility", "Versatility", rating and bonus and rating + bonus or rating or bonus, true)
    else
        local function Hit(name, rating)
            local bonus = ReadSecondaryAPI("GetCombatRatingBonus", 1, rating)
            local modifier = ReadSecondaryAPI(name)
            return bonus and modifier and bonus + modifier or modifier or bonus
        end
        Add("hit", "Hit Chance", SecondaryMaximum(Hit("GetHitModifier", rawget(_G, "CR_HIT_MELEE") or 6),
            Hit("GetRangedHitModifier", rawget(_G, "CR_HIT_RANGED") or 7), Hit("GetSpellHitModifier", rawget(_G, "CR_HIT_SPELL") or 8)), true)
        Add("expertise", "Expertise", SecondaryMaximum(ReadSecondaryAPI("GetExpertise",1),
            ReadSecondaryAPI("GetExpertise",2), ReadSecondaryAPI("GetExpertise",3)), true)
        Add("attackPower", "Attack Power", SecondarySum("UnitAttackPower", 3, "player"), false, true)
        local _, class = UnitClass("player")
        if class == "HUNTER" then Add("rangedPower", "Ranged Attack Power", SecondarySum("UnitRangedAttackPower", 3, "player"), false, true) end
        local spellPower
        for school = 2, 7 do spellPower = SecondaryMaximum(spellPower, ReadSecondaryAPI("GetSpellBonusDamage",1,school)) end
        Add("spellPower", "Spell Power", spellPower, false, true)
        Add("healing", "Healing Power", ReadSecondaryAPI("GetSpellBonusHealing"), false, true)
        Add("armor", "Armor", ReadSecondaryAPI("UnitArmor", 2, "player"))
        Add("defense", "Defense", SecondarySum("UnitDefenseSkill", 2, "player"))
        Add("dodge", "Dodge", ReadSecondaryAPI("GetDodgeChance"), true)
        Add("parry", "Parry", ReadSecondaryAPI("GetParryChance"), true, true)
        Add("block", "Block", ReadSecondaryAPI("GetBlockChance"), true, true)
        Add("armorPen", "Armor Penetration", ReadSecondaryAPI("GetArmorPenetration"), false, true)
        if ns.PlayerUsesMana() then
            local regen = ReadSecondaryAPI("GetManaRegen", 2)
            Add("manaRegen", "Mana per 5 sec", regen and regen * 5, false, true)
        end
    end
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
        secondary = ns.db and ns.db.showSecondaryStats and ns.SnapshotSecondaryStats() or nil,
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
    -- Return only values that increased after the level-up.
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
