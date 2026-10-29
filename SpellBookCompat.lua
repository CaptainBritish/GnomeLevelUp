local ADDON_NAME, ns = ...
local GetSpellLevelLearned = rawget(_G, "GetSpellLevelLearned")

-- Keep spellbook differences in one place so the rest of the addon can use names and IDs.
local spellbookRevision = 0
local cachedSpellbook
local cachedRevision = -1
local cachedFutureSpells
local cachedFutureRevision = -1
local retailFutureSpellsBeforeLevel
local knownSpellCache = {}
local knownSpellCacheRevision = -1
local spellbookInvalidationQueued = false

local function IsSecretValue(value)
    return type(issecretvalue) == "function" and issecretvalue(value)
end

function ns.InvalidateSpellBookSnapshot()
    spellbookRevision = spellbookRevision + 1
    cachedSpellbook = nil
    cachedRevision = -1
    cachedFutureSpells = nil
    cachedFutureRevision = -1
    knownSpellCache = {}
    knownSpellCacheRevision = -1
    if ns.InvalidateKnownTrainingLookup then
        ns.InvalidateKnownTrainingLookup()
    end
end

function ns.QueueSpellBookInvalidation(delay)
    if spellbookInvalidationQueued then return end
    spellbookInvalidationQueued = true
    local function Flush()
        spellbookInvalidationQueued = false
        ns.InvalidateSpellBookSnapshot()
    end
    if C_Timer and C_Timer.After then
        C_Timer.After(tonumber(delay) or 0.10, Flush)
    else
        Flush()
    end
end

local function CopyFutureSpells(spells)
    local copy = {}
    for _, spell in ipairs(spells or {}) do
        copy[#copy + 1] = {
            id = spell.id,
            name = spell.name,
            icon = spell.icon,
            requiredLevel = spell.requiredLevel,
        }
    end
    return copy
end

function ns.CaptureRetailFutureSpells()
    if ns.GetCurrentFlavor and ns.GetCurrentFlavor() ~= "retail" then return end
    retailFutureSpellsBeforeLevel = CopyFutureSpells(ns.SnapshotRetailFutureSpells(true))
end

function ns.GetRetailFutureSpellsBeforeLevel()
    return retailFutureSpellsBeforeLevel
end

function ns.GetSpellBookRevision()
    return spellbookRevision
end

function ns.IsSpellKnownAcrossClients(spellID)
    if not spellID then return false end
    if knownSpellCacheRevision ~= spellbookRevision then
        knownSpellCache = {}
        knownSpellCacheRevision = spellbookRevision
    elseif knownSpellCache[spellID] ~= nil then
        return knownSpellCache[spellID]
    end

    local knownSpell = false
    if C_SpellBook and C_SpellBook.IsSpellKnown and Enum and Enum.SpellBookSpellBank then
        local ok, known = pcall(C_SpellBook.IsSpellKnown, spellID, Enum.SpellBookSpellBank.Player)
        if ok and not IsSecretValue(known) and known == true then
            knownSpell = true
        end
    end
    local legacyIsSpellKnown = rawget(_G, "IsSpellKnown")
    if not knownSpell and type(legacyIsSpellKnown) == "function" then
        local ok, known = pcall(legacyIsSpellKnown, spellID)
        if ok and not IsSecretValue(known) and known == true then
            knownSpell = true
        end
    end
    knownSpellCache[spellID] = knownSpell
    return knownSpell
end

function ns.SnapshotSpellBook(forceRefresh)
    if not forceRefresh and cachedSpellbook and cachedRevision == spellbookRevision then
        return cachedSpellbook
    end

    local perf = ns.PerfStart and ns.PerfStart("spellbook_snapshot")
    local known = {}
    local playerBank = Enum and Enum.SpellBookSpellBank and Enum.SpellBookSpellBank.Player
    if not C_SpellBook or not C_SpellBook.GetNumSpellBookSkillLines or not playerBank then
        cachedSpellbook = known
        cachedRevision = spellbookRevision
        if ns.PerfEnd then ns.PerfEnd(perf) end
        return known
    end

    for i = 1, C_SpellBook.GetNumSpellBookSkillLines() do
        local skillLineInfo = C_SpellBook.GetSpellBookSkillLineInfo(i)
        if skillLineInfo and not skillLineInfo.isGuild then
            local offset = skillLineInfo.itemIndexOffset or 0
            local count = skillLineInfo.numSpellBookItems or 0
            for j = offset + 1, offset + count do
                local itemInfo = C_SpellBook.GetSpellBookItemInfo(j, playerBank)
                local isSpell = itemInfo and itemInfo.spellID ~= nil
                if isSpell and Enum.SpellBookItemType then
                    isSpell = itemInfo.itemType == Enum.SpellBookItemType.Spell
                end
                if isSpell then
                    local name = itemInfo.name
                    if not name and C_Spell and C_Spell.GetSpellInfo then
                        local spellInfo = C_Spell.GetSpellInfo(itemInfo.spellID)
                        name = type(spellInfo) == "table" and spellInfo.name or spellInfo
                    end
                    local getSpellInfo = rawget(_G, "GetSpellInfo")
                    if not name and type(getSpellInfo) == "function" then
                        local ok, spellName = pcall(getSpellInfo, itemInfo.spellID)
                        if ok then
                            name = spellName
                        end
                    end
                    known[itemInfo.spellID] = name
                end
            end
        end
    end
    cachedSpellbook = known
    cachedRevision = spellbookRevision
    if ns.PerfEnd then ns.PerfEnd(perf) end
    return known
end

local function GetSpellName(spellID, itemInfo)
    if itemInfo and itemInfo.name then return itemInfo.name end
    if C_Spell and C_Spell.GetSpellName then
        local ok, name = pcall(C_Spell.GetSpellName, spellID)
        if ok and name then return name end
    end
    if C_Spell and C_Spell.GetSpellInfo then
        local ok, spellInfo = pcall(C_Spell.GetSpellInfo, spellID)
        if ok then
            return type(spellInfo) == "table" and spellInfo.name or spellInfo
        end
    end
    local getSpellInfo = rawget(_G, "GetSpellInfo")
    if type(getSpellInfo) == "function" then
        local ok, name = pcall(getSpellInfo, spellID)
        if ok then return name end
    end
end

local function GetSpellTexture(spellID)
    if C_Spell and C_Spell.GetSpellTexture then
        local ok, texture = pcall(C_Spell.GetSpellTexture, spellID)
        if ok and texture then return texture end
    end
    if type(GetSpellTexture) == "function" then
        local ok, texture = pcall(GetSpellTexture, spellID)
        if ok then return texture end
    end
end

local function GetSpellLearnedLevel(index, spellBank, spellID, itemInfo)
    if C_SpellBook and C_SpellBook.GetSpellBookItemLevelLearned then
        local ok, level = pcall(C_SpellBook.GetSpellBookItemLevelLearned, index, spellBank)
        if ok and tonumber(level) then return tonumber(level) end
    end
    if itemInfo and tonumber(itemInfo.levelLearned) then
        return tonumber(itemInfo.levelLearned)
    end
    if C_Spell and C_Spell.GetSpellLevelLearned then
        local ok, level = pcall(C_Spell.GetSpellLevelLearned, spellID)
        if ok and tonumber(level) then return tonumber(level) end
    end
    if type(GetSpellLevelLearned) == "function" then
        local ok, level = pcall(GetSpellLevelLearned, spellID)
        if ok and tonumber(level) then return tonumber(level) end
    end
    return nil
end

local function IsRetailSkillLineAllowed(skillLineIndex, skillLineInfo)
    if not skillLineInfo or skillLineInfo.isGuild or skillLineInfo.isOffSpec then
        return false
    end
    -- Retail can place level-gated entries in more than one player skill
    -- line. Keep every current-spec player line and skip only off-spec data.
    return true
end

function ns.SnapshotRetailFutureSpells(forceRefresh)
    if not forceRefresh and cachedFutureSpells and cachedFutureRevision == spellbookRevision then
        return cachedFutureSpells
    end

    local perf = ns.PerfStart and ns.PerfStart("retail_future_snapshot")
    local futureSpells = {}
    local seen = {}
    local playerBank = Enum and Enum.SpellBookSpellBank and Enum.SpellBookSpellBank.Player
    local futureType = Enum and Enum.SpellBookItemType and Enum.SpellBookItemType.FutureSpell
    if not C_SpellBook or not C_SpellBook.GetNumSpellBookSkillLines
        or not C_SpellBook.GetSpellBookSkillLineInfo
        or not C_SpellBook.GetSpellBookItemInfo or not playerBank or not futureType then
        cachedFutureSpells = futureSpells
        cachedFutureRevision = spellbookRevision
        if ns.PerfEnd then ns.PerfEnd(perf) end
        return futureSpells
    end

    for skillLineIndex = 1, C_SpellBook.GetNumSpellBookSkillLines() do
        local skillLineInfo = C_SpellBook.GetSpellBookSkillLineInfo(skillLineIndex)
        if IsRetailSkillLineAllowed(skillLineIndex, skillLineInfo) then
            local offset = tonumber(skillLineInfo.itemIndexOffset) or 0
            local count = tonumber(skillLineInfo.numSpellBookItems) or 0
            for index = offset + 1, offset + count do
                local ok, itemInfo = pcall(C_SpellBook.GetSpellBookItemInfo, index, playerBank)
                local spellID = ok and itemInfo and tonumber(itemInfo.spellID)
                if spellID and itemInfo.itemType == futureType and not seen[spellID] then
                    local requiredLevel = GetSpellLearnedLevel(index, playerBank, spellID, itemInfo)
                    if requiredLevel then
                        seen[spellID] = true
                        futureSpells[#futureSpells + 1] = {
                            id = spellID,
                            name = GetSpellName(spellID, itemInfo) or ("Spell " .. spellID),
                            icon = GetSpellTexture(spellID),
                            requiredLevel = requiredLevel,
                        }
                    end
                end
            end
        end
    end

    table.sort(futureSpells, function(a, b)
        if a.requiredLevel ~= b.requiredLevel then
            return a.requiredLevel < b.requiredLevel
        end
        return a.name < b.name
    end)
    cachedFutureSpells = futureSpells
    cachedFutureRevision = spellbookRevision
    if ns.PerfEnd then ns.PerfEnd(perf) end
    return futureSpells
end

function ns.GetRetailUnlearnedSpells(currentLevel, futureSpells, rangeStart)
    if ns.GetCurrentFlavor and ns.GetCurrentFlavor() ~= "retail" then return {} end
    currentLevel = tonumber(currentLevel) or tonumber(UnitLevel("player")) or 0
    futureSpells = futureSpells or ns.SnapshotRetailFutureSpells()

    local onlyCurrentLevel = ns.db and ns.db.showOnlyCurrentLevelSkills == true
    local available = {}
    for _, spell in ipairs(futureSpells) do
        local levelMatches = rangeStart and spell.requiredLevel > rangeStart
            or not rangeStart and (not onlyCurrentLevel or spell.requiredLevel == currentLevel)
        if spell.requiredLevel <= currentLevel and levelMatches then
            local rank
            if ns.GetTrainingRankInfo then
                local _, parsedRank = ns.GetTrainingRankInfo(spell.name)
                rank = parsedRank
            end
            -- Retail upgrades happen automatically; saved rank-filter choices
            -- from Forever must not expose them as new unlocks.
            if rank == nil or rank == 1 then
                available[#available + 1] = {
                    id = spell.id,
                    name = spell.name,
                    icon = spell.icon,
                    requiredLevel = spell.requiredLevel,
                    trainingRank = rank,
                    isNewAbility = true,
                }
            end
        end
    end
    return available
end
