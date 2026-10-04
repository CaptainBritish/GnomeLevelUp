local ADDON_NAME, ns = ...

-- Forever weapon proficiencies are stable, so they can be listed without trainer scans.
local function CreateWeaponSkill(name, spellID, requiredLevel)
    return { name = name, spellID = spellID, requiredLevel = requiredLevel or 1 }
end

local WEAPON = {
    BOWS = CreateWeaponSkill("Bows", 264),
    CROSSBOWS = CreateWeaponSkill("Crossbows", 5011),
    DAGGERS = CreateWeaponSkill("Daggers", 1180),
    FISTS = CreateWeaponSkill("Fist Weapons", 15590),
    GUNS = CreateWeaponSkill("Guns", 266),
    ONE_AXES = CreateWeaponSkill("One-Handed Axes", 196),
    ONE_MACES = CreateWeaponSkill("One-Handed Maces", 198),
    ONE_SWORDS = CreateWeaponSkill("One-Handed Swords", 201),
    POLEARMS = CreateWeaponSkill("Polearms", 200, 20),
    STAVES = CreateWeaponSkill("Staves", 227),
    THROWN = CreateWeaponSkill("Thrown", 2567),
    TWO_AXES = CreateWeaponSkill("Two-Handed Axes", 197),
    TWO_MACES = CreateWeaponSkill("Two-Handed Maces", 199),
    TWO_SWORDS = CreateWeaponSkill("Two-Handed Swords", 202),
    WANDS = CreateWeaponSkill("Wands", 228),
}

-- These are the weapon types each class can eventually learn in the Classic
-- ruleset used by Forever.  The live skill list is still checked below, so a
-- proficiency that the character already knows is never shown as missing.
ns.WeaponSkillsForever = {
    DRUID = { WEAPON.ONE_MACES, WEAPON.TWO_MACES, WEAPON.DAGGERS, WEAPON.FISTS, WEAPON.STAVES },
    HUNTER = { WEAPON.BOWS, WEAPON.CROSSBOWS, WEAPON.DAGGERS, WEAPON.FISTS, WEAPON.GUNS,
        WEAPON.ONE_AXES, WEAPON.ONE_SWORDS, WEAPON.POLEARMS, WEAPON.STAVES, WEAPON.THROWN,
        WEAPON.TWO_AXES, WEAPON.TWO_SWORDS },
    MAGE = { WEAPON.DAGGERS, WEAPON.STAVES, WEAPON.WANDS },
    PALADIN = { WEAPON.ONE_AXES, WEAPON.ONE_MACES, WEAPON.ONE_SWORDS, WEAPON.POLEARMS,
        WEAPON.TWO_AXES, WEAPON.TWO_MACES, WEAPON.TWO_SWORDS },
    PRIEST = { WEAPON.DAGGERS, WEAPON.ONE_MACES, WEAPON.STAVES, WEAPON.WANDS },
    ROGUE = { WEAPON.BOWS, WEAPON.CROSSBOWS, WEAPON.DAGGERS, WEAPON.FISTS, WEAPON.GUNS,
        WEAPON.ONE_MACES, WEAPON.ONE_SWORDS, WEAPON.THROWN },
    SHAMAN = { WEAPON.DAGGERS, WEAPON.FISTS, WEAPON.ONE_AXES, WEAPON.ONE_MACES,
        WEAPON.STAVES },
    WARLOCK = { WEAPON.DAGGERS, WEAPON.STAVES, WEAPON.WANDS },
    WARRIOR = { WEAPON.BOWS, WEAPON.CROSSBOWS, WEAPON.DAGGERS, WEAPON.FISTS, WEAPON.GUNS,
        WEAPON.ONE_AXES, WEAPON.ONE_MACES, WEAPON.ONE_SWORDS, WEAPON.POLEARMS, WEAPON.STAVES,
        WEAPON.THROWN, WEAPON.TWO_AXES, WEAPON.TWO_MACES, WEAPON.TWO_SWORDS },
}

local function NormalizeSkillName(name)
    if type(name) ~= "string" then return nil end
    name = name:lower():gsub("[%p]", " "):gsub("%s+", " ")
    return name:match("^%s*(.-)%s*$")
end

local HARD_CODED_WEAPON_NAMES = {}
for _, definitions in pairs(ns.WeaponSkillsForever) do
    for _, definition in ipairs(definitions) do
        HARD_CODED_WEAPON_NAMES[NormalizeSkillName(definition.name)] = true
    end
end

function ns.IsHardcodedWeaponSkill(name)
    return HARD_CODED_WEAPON_NAMES[NormalizeSkillName(name)] == true
end

local function SnapshotKnownWeaponSkills()
    local known = {}
    if type(GetNumSkillLines) ~= "function" or type(GetSkillLineInfo) ~= "function" then
        return known
    end

    local ok, count = pcall(GetNumSkillLines)
    if not ok or type(count) ~= "number" then return known end
    for index = 1, count do
        local readOK, name, isHeader = pcall(GetSkillLineInfo, index)
        if readOK and not isHeader then
            local normalized = NormalizeSkillName(name)
            if normalized then known[normalized] = true end
        end
    end
    return known
end

function ns.GetUnlearnedWeaponSkills(currentLevel)
    if ns.GetCurrentFlavor and ns.GetCurrentFlavor() ~= "forever" then return {} end
    if ns.db and ns.db.showWeaponSkills == false then return {} end

    local _, classToken = UnitClass("player")
    local definitions = classToken and ns.WeaponSkillsForever[classToken]
    if not definitions then return {} end

    currentLevel = tonumber(currentLevel) or tonumber(UnitLevel("player")) or 0
    local known = SnapshotKnownWeaponSkills()
    local unlearnedWeaponSkills = {}
    for _, definition in ipairs(definitions) do
        if currentLevel >= definition.requiredLevel
            and not known[NormalizeSkillName(definition.name)]
            and not (ns.IsSpellKnownAcrossClients and ns.IsSpellKnownAcrossClients(definition.spellID)) then
            unlearnedWeaponSkills[#unlearnedWeaponSkills + 1] = {
                name = definition.name,
                requiredLevel = definition.requiredLevel,
            }
        end
    end
    table.sort(unlearnedWeaponSkills, function(a, b) return a.name < b.name end)
    return unlearnedWeaponSkills
end
