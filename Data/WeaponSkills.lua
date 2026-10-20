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
    DRUID = { WEAPON.ONE_MACES, WEAPON.TWO_MACES, WEAPON.DAGGERS, WEAPON.FISTS,
        WEAPON.STAVES, WEAPON.POLEARMS },
    HUNTER = { WEAPON.BOWS, WEAPON.CROSSBOWS, WEAPON.DAGGERS, WEAPON.FISTS, WEAPON.GUNS,
        WEAPON.ONE_AXES, WEAPON.ONE_SWORDS, WEAPON.POLEARMS, WEAPON.STAVES, WEAPON.THROWN,
        WEAPON.TWO_AXES, WEAPON.TWO_SWORDS },
    MAGE = { WEAPON.DAGGERS, WEAPON.ONE_SWORDS, WEAPON.STAVES, WEAPON.WANDS },
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

local function WeaponNameMatches(itemSubType, definitionName)
    local itemName = NormalizeSkillName(itemSubType)
    local wanted = NormalizeSkillName(definitionName)
    if not itemName or not wanted then return false end
    if itemName == wanted then return true end
    -- A few client builds expose the item subclass in singular form.
    return itemName:gsub("s$", "") == wanted:gsub("s$", "")
end

-- Stable item subclass IDs used by the Classic item API. They supplement the
-- localized subtype text, which is not consistent across client languages.
local ITEM_SUBCLASS_WEAPONS = {
    [0] = { ["one handed axes"] = true, ["two handed axes"] = true },
    [2] = { ["bows"] = true },
    [3] = { ["guns"] = true },
    [4] = { ["one handed maces"] = true, ["two handed maces"] = true },
    [6] = { ["polearms"] = true },
    [7] = { ["one handed swords"] = true },
    [8] = { ["two handed swords"] = true },
    [10] = { ["staves"] = true },
    [13] = { ["fist weapons"] = true },
    [15] = { ["daggers"] = true },
    [16] = { ["thrown"] = true },
    [18] = { ["crossbows"] = true },
    [19] = { ["wands"] = true },
}

-- Ranged individual subtype IDs are still checked below so one ranged weapon
-- does not incorrectly suppress the other ranged training entries.
local RANGED_WEAPON_SPELLS = {
    [264] = true,  -- Bows
    [5011] = true, -- Crossbows
    [266] = true,  -- Guns
    [2567] = true, -- Thrown
    [228] = true,  -- Wands
}

local HARD_CODED_WEAPON_NAMES = {}
for _, definitions in pairs(ns.WeaponSkillsForever) do
    for _, definition in ipairs(definitions) do
        HARD_CODED_WEAPON_NAMES[NormalizeSkillName(definition.name)] = true
    end
end

function ns.IsHardcodedWeaponSkill(name)
    return HARD_CODED_WEAPON_NAMES[NormalizeSkillName(name)] == true
end

local knownWeaponSkills
local knownWeaponSkillSource = "unavailable"

local function EquippedWeaponMatches(slot, definition)
    local isRangedDefinition = RANGED_WEAPON_SPELLS[definition.spellID] == true
    if isRangedDefinition and slot ~= 18 then return false end

    local itemID
    if type(GetInventoryItemID) == "function" then
        local idOK, id = pcall(GetInventoryItemID, "player", slot)
        if idOK then itemID = id end
    end

    local itemLink
    if type(GetInventoryItemLink) == "function" then
        local linkOK, link = pcall(GetInventoryItemLink, "player", slot)
        if linkOK then itemLink = link end
    end
    if not itemID and not itemLink then return false end

    -- Forever uses the ranged equipment slot for wands. The item metadata
    -- APIs are not consistent across Forever builds, but a Mage/ Priest/
    -- Warlock carrying an item in slot 18 is carrying the ranged weapon type
    -- represented by spell ID 228. Treat that as authoritative for the
    -- preview, just as the character Skills tab does.
    if slot == 18 and definition.spellID == 228 then
        return true
    end

    local subtype
    local subclassID
    -- Prefer the modern C_Item API, which avoids deprecated legacy item-info
    -- access while preserving the same tuple layout used by the Classic/Forever
    -- client.
    local getItemInfoInstant = C_Item and C_Item.GetItemInfoInstant
    if itemID and type(getItemInfoInstant) == "function" then
        local instantOK, _, _, itemSubType, _, _, _, itemSubclassID =
            pcall(getItemInfoInstant, itemID)
        if instantOK then
            subtype = itemSubType
            subclassID = itemSubclassID
        end
    end

    -- Read the full item record if the instant lookup missed the weapon subtype.
    local getItemInfo = C_Item and C_Item.GetItemInfo
    if type(getItemInfo) == "function" and (not subtype or not subclassID) then
        local info = { pcall(getItemInfo, itemLink or itemID) }
        if info[1] then
            -- pcall adds one leading result: itemSubType is result 8 and
            -- subclassID is result 14 in the standard GetItemInfo tuple.
            subtype = subtype or info[8]
            subclassID = subclassID or info[14]
        end
    end

    local subclassName = ITEM_SUBCLASS_WEAPONS[tonumber(subclassID)]
    local wanted = NormalizeSkillName(definition.name)
    -- Ranged entries still require their own subtype match. The slot alone is
    -- not enough because bows, guns, crossbows, thrown weapons, and wands all
    -- share slot 18.
    return WeaponNameMatches(subtype, definition.name)
        or (subclassName and wanted and subclassName[wanted] == true)
end

local function IsWeaponSkillEquipped(definition)
    -- A character cannot equip a weapon type without having its proficiency.
    -- This also covers clients where weapon proficiencies are not exposed as
    -- spellbook entries or where the skill-line snapshot has not refreshed yet.
    -- Wands occupy the ranged slot on Classic/Forever (18); main-hand and
    -- off-hand cover the remaining weapon proficiency cases.
    for _, slot in ipairs({ 16, 17, 18 }) do
        if EquippedWeaponMatches(slot, definition) then return true end
    end
    return false
end

function ns.InvalidateWeaponSkillSnapshot()
    knownWeaponSkills = nil
    knownWeaponSkillSource = "unavailable"
end

local function SnapshotKnownWeaponSkills(forceRefresh)
    if knownWeaponSkills and not forceRefresh then return knownWeaponSkills, knownWeaponSkillSource end
    local known = {}
    -- Stop here if the skill-line API is unavailable.
    local getNumSkillLines = _G["GetNumSkillLines"]
    local getSkillLineInfo = _G["GetSkillLineInfo"]
    if type(getNumSkillLines) ~= "function" or type(getSkillLineInfo) ~= "function" then
        knownWeaponSkills, knownWeaponSkillSource = known, "unavailable"
        return known, knownWeaponSkillSource
    end

    local ok, count = pcall(getNumSkillLines)
    if not ok or type(count) ~= "number" then
        knownWeaponSkills, knownWeaponSkillSource = known, "unavailable"
        return known, knownWeaponSkillSource
    end
    for index = 1, count do
        local readOK, name, isHeader = pcall(getSkillLineInfo, index)
        if readOK and not isHeader then
            local normalized = NormalizeSkillName(name)
            if normalized then known[normalized] = true end
        end
    end
    knownWeaponSkills = known
    knownWeaponSkillSource = "character-skills"
    return known, knownWeaponSkillSource
end

function ns.GetWeaponSkillStatus(currentLevel)
    -- The character Skills tab is the authoritative learned-state source on
    -- Forever. The class table only describes what the class can eventually
    -- learn; it never assumes a racial starting-weapon difference.
    if ns.GetCurrentFlavor and ns.GetCurrentFlavor() ~= "forever" then return {} end

    local _, classToken = UnitClass("player")
    local definitions = classToken and ns.WeaponSkillsForever[classToken]
    if not definitions then return { known = {}, available = {}, equipped = {}, source = "character-skills" } end

    currentLevel = tonumber(currentLevel) or tonumber(UnitLevel("player")) or 0
    local known, source = SnapshotKnownWeaponSkills(true)
    local status = { known = {}, available = {}, equipped = {}, source = source, classToken = classToken }
    for _, definition in ipairs(definitions) do
        local name = NormalizeSkillName(definition.name)
        local isKnown = known[name] == true
            or (ns.IsSpellKnownAcrossClients and ns.IsSpellKnownAcrossClients(definition.spellID))
        local isEquipped = IsWeaponSkillEquipped(definition)
        local entry = {
            name = definition.name,
            requiredLevel = definition.requiredLevel,
            spellID = definition.spellID,
            known = isKnown,
            equipped = isEquipped,
            eligible = currentLevel >= definition.requiredLevel,
        }
        if isKnown then
            status.known[#status.known + 1] = entry
        elseif isEquipped then
            status.equipped[#status.equipped + 1] = entry
        elseif entry.eligible then
            status.available[#status.available + 1] = entry
        end
    end
    table.sort(status.known, function(a, b) return a.name < b.name end)
    table.sort(status.equipped, function(a, b) return a.name < b.name end)
    table.sort(status.available, function(a, b) return a.name < b.name end)
    return status
end

function ns.GetUnlearnedWeaponSkills(currentLevel)
    if ns.db and ns.db.showWeaponSkills == false then return {} end
    local status = ns.GetWeaponSkillStatus(currentLevel)
    local unlearnedWeaponSkills = {}
    for _, entry in ipairs(status.available or {}) do
        unlearnedWeaponSkills[#unlearnedWeaponSkills + 1] = {
            name = entry.name,
            requiredLevel = entry.requiredLevel,
            spellID = entry.spellID,
        }
    end
    return unlearnedWeaponSkills
end

function ns.DumpWeaponSkills()
    if ns.IsDebugEnabled and not ns.IsDebugEnabled() then
        print("|cff3fe0ffGnomeLevelUp|r: debug is OFF. Use /glu debug on first.")
        return
    end
    local currentLevel = tonumber(UnitLevel("player")) or 0
    local status = ns.GetWeaponSkillStatus(currentLevel)
    local function printGroup(label, entries)
        print(string.format("  %s (%d)", label, #(entries or {})))
        for _, entry in ipairs(entries or {}) do
            local level = entry.requiredLevel and ("; level " .. entry.requiredLevel) or ""
            print("    " .. entry.name .. level)
        end
    end
    print(string.format("|cff3fe0ffGnomeLevelUp|r weapon skills: %s; class %s; level %d",
        status.source or "unavailable", status.classToken or "unknown", currentLevel))
    printGroup("already known", status.known)
    printGroup("equipped but not reported as known", status.equipped)
    printGroup("available to train", status.available)
end
