local ADDON_NAME, ns = ...

-- Warlock demon grimoires are merchant items in Forever, so their catalog is
-- fixed. Learned status still comes from the active demon's spellbook.
local petRevision = 0
local cachedPetSpells
local cachedPetRevision = -1

local function IsSecretValue(value)
    return type(issecretvalue) == "function" and issecretvalue(value)
end

local function NormalizeName(name)
    if type(name) ~= "string" then return nil end
    name = name:lower():gsub("%s+", " "):match("^%s*(.-)%s*$")
    return name ~= "" and name or nil
end

local function ReadRank(text)
    if type(text) ~= "string" then return nil end
    return tonumber(text:match("[Rr]ank%s*(%d+)$") or text:match("(%d+)$"))
end

local function AddKnownSpell(known, spellID, name, subText)
    if IsSecretValue(spellID) or IsSecretValue(name) then return end
    local normalized = NormalizeName(name)
    if not normalized then return end

    local rank = ReadRank(subText) or ReadRank(name)
    normalized = normalized:gsub("%s*%(rank%s*%d+%)$", "")
        :gsub("%s+rank%s*%d+$", "")
    known.names[normalized] = true
    -- Some Forever spellbook entries expose the spell name but omit the rank
    -- text. Treat that entry as rank 1 so a consumed rank-1 grimoire is still
    -- recognized, while later ranks remain available until their rank is seen.
    known.ranks[normalized] = math.max(known.ranks[normalized] or 0, rank or 1)
    if spellID then known.ids[tonumber(spellID) or spellID] = true end
end

local function AddModernPetSpell(known, index, petBank, itemInfo)
    if type(itemInfo) ~= "table" or not tonumber(itemInfo.spellID) then return end

    local name = itemInfo.name
    local subText = itemInfo.subText or itemInfo.subtext
    if not name and C_SpellBook and C_SpellBook.GetSpellBookItemName then
        local ok, value, rankText = pcall(C_SpellBook.GetSpellBookItemName, index, petBank)
        if ok then name, subText = value, rankText end
    end
    if not name and C_Spell and C_Spell.GetSpellName then
        local ok, value = pcall(C_Spell.GetSpellName, itemInfo.spellID)
        if ok then name = value end
    end
    if not name and C_Spell and C_Spell.GetSpellInfo then
        local ok, info = pcall(C_Spell.GetSpellInfo, itemInfo.spellID)
        if ok then
            name = type(info) == "table" and info.name or info
            subText = subText or (type(info) == "table" and (info.subText or info.subtext))
        end
    end
    AddKnownSpell(known, itemInfo.spellID, name, subText)
end

local function AddLegacyPetSpell(known, index, spellBank)
    if type(GetSpellBookItemInfo) ~= "function" then return end
    local ok, spellType, spellID = pcall(GetSpellBookItemInfo, index, spellBank)
    -- Classic pet spellbooks report learned abilities as PETACTION rather than
    -- SPELL. Accept both kinds so consuming a grimoire is visible in the
    -- learned snapshot.
    if not ok or not spellID
        or (spellType and spellType ~= "SPELL" and spellType ~= "PETACTION") then
        return
    end
    local name, subText
    if type(GetSpellBookItemName) == "function" then
        local nameOK
        nameOK, name, subText = pcall(GetSpellBookItemName, index, spellBank)
        if not nameOK then name, subText = nil, nil end
    end
    if not name and GetSpellInfo then name = GetSpellInfo(spellID) end
    AddKnownSpell(known, spellID, name, subText)
end

function ns.InvalidatePetSpellBookSnapshot()
    petRevision = petRevision + 1
    cachedPetSpells = nil
    cachedPetRevision = -1
end

function ns.SnapshotPetSpellBook(forceRefresh)
    if not forceRefresh and cachedPetSpells and cachedPetRevision == petRevision then
        return cachedPetSpells
    end

    local known = { ids = {}, names = {}, ranks = {} }
    local petBank = Enum and Enum.SpellBookSpellBank and Enum.SpellBookSpellBank.Pet

    if C_SpellBook and petBank and C_SpellBook.GetNumSpellBookSkillLines
        and C_SpellBook.GetSpellBookSkillLineInfo and C_SpellBook.GetSpellBookItemInfo then
        local okCount, skillLineCount = pcall(C_SpellBook.GetNumSpellBookSkillLines)
        if okCount and tonumber(skillLineCount) then
            for skillLineIndex = 1, skillLineCount do
                local okLine, skillLineInfo = pcall(C_SpellBook.GetSpellBookSkillLineInfo, skillLineIndex)
                if okLine and type(skillLineInfo) == "table" and not skillLineInfo.isGuild then
                    local offset = tonumber(skillLineInfo.itemIndexOffset) or 0
                    local count = tonumber(skillLineInfo.numSpellBookItems) or 0
                    for index = offset + 1, offset + count do
                        local okItem, itemInfo = pcall(C_SpellBook.GetSpellBookItemInfo, index, petBank)
                        if okItem then AddModernPetSpell(known, index, petBank, itemInfo) end
                    end
                end
            end
        end
    end

    if next(known.names) == nil and type(GetNumSpellBookItems) == "function" then
        local petBook = BOOKTYPE_PET or "pet"
        local okCount, count = pcall(GetNumSpellBookItems, petBook)
        if not okCount or not tonumber(count) then
            okCount, count = pcall(GetNumSpellBookItems)
        end
        if okCount and tonumber(count) then
            for index = 1, count do AddLegacyPetSpell(known, index, petBook) end
        end
    end

    cachedPetSpells = known
    cachedPetRevision = petRevision
    return known
end

local function GetPetFamily()
    if type(UnitExists) ~= "function" or not UnitExists("pet") then return nil end
    if type(UnitCreatureFamily) ~= "function" then return nil end
    local ok, family = pcall(UnitCreatureFamily, "pet")
    if not ok or type(family) ~= "string" then return nil end
    family = family:lower()
    if family:find("imp", 1, true) then return "IMP" end
    if family:find("voidwalker", 1, true) or family:find("void walker", 1, true) then return "VOIDWALKER" end
    if family:find("succubus", 1, true) or family:find("incubus", 1, true) then return "SUCCUBUS" end
    if family:find("felhunter", 1, true) then return "FELHUNTER" end
end

local function IsGrimoireLearned(grimoire, known)
    local name = NormalizeName(grimoire.spellName)
    if not name then return false end
    if grimoire.rank then return (known.ranks[name] or 0) >= grimoire.rank end
    return known.names[name] == true
end

function ns.GetUnlearnedWarlockPetAbilities(currentLevel)
    if ns.GetCurrentFlavor and ns.GetCurrentFlavor() ~= "forever" then return {} end
    local _, classToken = UnitClass("player")
    if classToken ~= "WARLOCK" then return {} end
    if ns.db and ns.db.showWarlockPetSkills == false then return {} end

    currentLevel = tonumber(currentLevel) or tonumber(UnitLevel("player")) or 0
    local family = GetPetFamily()
    local filterByActivePet = ns.db and ns.db.filterWarlockPetByActivePet ~= false
    local showAllAvailable = ns.db and ns.db.showAllWarlockGrimoires == true
    -- Refresh at display time so consuming a vendor grimoire cannot remain
    -- hidden behind a stale snapshot if the client misses an update event.
    local known = ns.SnapshotPetSpellBook(true)
    -- Depending on the client build, learned pet abilities can also be exposed
    -- through the player spellbook (especially when no pet is currently out).
    -- Merge that view so a consumed grimoire is filtered independently of the
    -- active pet's current spellbook page.
    if ns.SnapshotSpellBook then
        local playerSpells = ns.SnapshotSpellBook(true)
        for spellID, name in pairs(playerSpells or {}) do
            AddKnownSpell(known, spellID, name)
        end
    end
    local available = {}
    for _, grimoire in ipairs(ns.WarlockPetGrimoires or {}) do
        -- Normal level-ups show only grimoires newly available at the level
        -- reached. Debug mode can opt into the complete list unlocked so far.
        local levelMatches = showAllAvailable
            and grimoire.requiredLevel <= currentLevel
            or grimoire.requiredLevel == currentLevel
        if levelMatches and (not filterByActivePet or not family or grimoire.pet == family)
            and not IsGrimoireLearned(grimoire, known) then
            local name = grimoire.spellName
            if grimoire.rank then name = name .. " (Rank " .. grimoire.rank .. ")" end
            available[#available + 1] = {
                id = nil,
                name = name,
                icon = grimoire.icon,
                cost = grimoire.cost,
                itemID = grimoire.itemID,
                pet = grimoire.pet,
                kind = "warlockPet",
            }
        end
    end
    return available
end

local petEvents = CreateFrame("Frame")
for _, event in ipairs({ "PLAYER_LOGIN", "PLAYER_ENTERING_WORLD", "UNIT_PET", "PET_BAR_UPDATE", "SPELLS_CHANGED", "LEARNED_SPELL_IN_SKILL_LINE" }) do
    petEvents:RegisterEvent(event)
end
petEvents:SetScript("OnEvent", function()
    ns.InvalidatePetSpellBookSnapshot()
end)
