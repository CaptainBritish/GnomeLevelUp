local ADDON_NAME, ns = ...

-- Version 5 adds cost-aware trainer records. Older caches cannot tell us
-- whether a missing cost means "free" or "not scanned", so they are rebuilt.
local TRAINER_SCHEMA_VERSION = 5
local TRAINER_CACHE_PRUNE_VERSION = 1
local TRAINER_SCAN_DELAY = 0.3
local TRAINER_RECONCILE_DELAY = 0.25

function ns.GetTrainerCacheStatus()
    local flavor = ns.GetCurrentFlavor and ns.GetCurrentFlavor() or "unknown"
    local _, classToken = UnitClass("player")
    local count = 0
    local store = GnomeLevelUpDB and GnomeLevelUpDB.scannedTraining
    local levelMap = store and store[flavor] and classToken and store[flavor][classToken]
    if type(levelMap) == "table" then
        for _, entries in pairs(levelMap) do
            if type(entries) == "table" then count = count + #entries end
        end
    end
    local metadata = GnomeLevelUpDB and GnomeLevelUpDB.trainerCacheMeta
    if type(metadata) ~= "table" or metadata.flavor ~= flavor or metadata.classToken ~= classToken then
        metadata = nil
    end
    return {
        flavor = flavor,
        classToken = classToken,
        count = count,
        npcName = metadata and metadata.npcName,
        lastScanAt = metadata and metadata.lastScanAt,
        schemaVersion = tonumber(GnomeLevelUpDB and GnomeLevelUpDB.trainerSchemaVersion) or 0,
        rescanRequired = GnomeLevelUpDB and GnomeLevelUpDB.trainerRescanRequired == true,
    }
end

-- Saved trainer entries are grouped by class and required level.
local PROFESSION_KEYWORDS = {
    "tailoring", "blacksmithing", "leatherworking", "alchemy", "herbalism",
    "mining", "skinning", "enchanting", "engineering", "jewelcrafting",
    "inscription", "cooking", "fishing", "first aid", "archaeology",
}

local function LooksLikeProfessionTrainer(npcName)
    if not npcName then return false end
    local lower = npcName:lower()
    for _, keyword in ipairs(PROFESSION_KEYWORDS) do
        if lower:find(keyword, 1, true) then return true end
    end
    return false
end

local function IsProfessionTrainer()
    if IsTradeskillTrainer then
        local ok, result = pcall(IsTradeskillTrainer)
        if ok and result == true then return true end
    end
    return LooksLikeProfessionTrainer(UnitName("npc"))
end

local function IsProfessionService(index, professionCost)
    if professionCost ~= nil then
        return professionCost == true or (tonumber(professionCost) or 0) > 0
    end
    if type(GetTrainerServiceCost) == "function" then
        local ok, _, _, rawProfessionCost = pcall(GetTrainerServiceCost, index)
        if ok and (rawProfessionCost == true or (tonumber(rawProfessionCost) or 0) > 0) then
            return true
        end
    end
    return false
end

local function EnsureSavedStore()
    if not GnomeLevelUpDB then return nil end
    GnomeLevelUpDB.scannedTraining = GnomeLevelUpDB.scannedTraining or {}
    local store = GnomeLevelUpDB.scannedTraining
    store.forever = store.forever or {}
    return store
end

local function GetLearnedStore()
    if not GnomeLevelUpDB then return nil end
    local guid = UnitGUID("player")
    if not guid then return nil end
    local flavor = ns.GetCurrentFlavor()
    if flavor ~= "forever" then return nil end
    GnomeLevelUpDB.learnedTraining = GnomeLevelUpDB.learnedTraining or {}
    local store = GnomeLevelUpDB.learnedTraining
    store[flavor] = store[flavor] or {}
    store[flavor][guid] = store[flavor][guid] or {}
    return store[flavor][guid]
end
ns.GetLearnedTrainingStore = GetLearnedStore

local function PruneTrainerCache()
    local store = EnsureSavedStore()
    if not store then return false end
    local changed = false
    local forever = store.forever
    for classToken, levelMap in pairs(forever) do
        if type(levelMap) ~= "table" then
            forever[classToken] = nil
            changed = true
        else
            for rawLevel, entries in pairs(levelMap) do
                if type(entries) ~= "table" then
                    levelMap[rawLevel] = nil
                    changed = true
                else
                    local seen = {}
                    local write = 1
                    for _, entry in ipairs(entries) do
                        local spellID = type(entry) == "table" and tonumber(entry.spellID)
                        local rawName = ns.TrainingEntryName and ns.TrainingEntryName(entry)
                            or (type(entry) == "table" and entry.name or entry)
                        local name = ns.NormalizeTrainingName and ns.NormalizeTrainingName(rawName)
                        local key = spellID and ("spell:" .. spellID) or (name and ("name:" .. name))
                        if key and seen[key] then
                            local existing = seen[key]
                            if type(existing) == "table" and type(entry) == "table" then
                                for field, value in pairs(entry) do
                                    if existing[field] == nil then existing[field] = value end
                                end
                            end
                            changed = true
                        else
                            if key then seen[key] = entry end
                            entries[write] = entry
                            write = write + 1
                        end
                    end
                    for index = #entries, write, -1 do entries[index] = nil end
                    if #entries == 0 then levelMap[rawLevel] = nil; changed = true end
                end
            end
            if next(levelMap) == nil then forever[classToken] = nil; changed = true end
        end
    end
    local learned = GnomeLevelUpDB.learnedTraining
    if type(learned) == "table" then
        for flavor, byGUID in pairs(learned) do
            if type(byGUID) == "table" then
                for guid, records in pairs(byGUID) do
                    if type(records) ~= "table" or next(records) == nil then
                        byGUID[guid] = nil
                        changed = true
                    end
                end
                if next(byGUID) == nil then learned[flavor] = nil; changed = true end
            end
        end
    end
    if changed and ns.InvalidateTrainerIndex then ns.InvalidateTrainerIndex() end
    return changed
end

function ns.MigrateTrainerData()
    -- Rebuild old caches when their record format cannot provide trainer costs.
    if not GnomeLevelUpDB then return end
    local store = EnsureSavedStore()
    store.classic = nil
    store.retail = nil
    if GnomeLevelUpDB.learnedTraining then
        GnomeLevelUpDB.learnedTraining.classic = nil
        GnomeLevelUpDB.learnedTraining.retail = nil
    end
    if (tonumber(GnomeLevelUpDB.trainerCachePruneVersion) or 0) < TRAINER_CACHE_PRUNE_VERSION then
        PruneTrainerCache()
        GnomeLevelUpDB.trainerCachePruneVersion = TRAINER_CACHE_PRUNE_VERSION
    end
    local currentVersion = tonumber(GnomeLevelUpDB.trainerSchemaVersion) or 0
    if currentVersion >= TRAINER_SCHEMA_VERSION then return end

    local hadOldCache = currentVersion > 0 or next(store.forever) ~= nil
    if not hadOldCache then
        GnomeLevelUpDB.trainerSchemaVersion = TRAINER_SCHEMA_VERSION
        return
    end

    -- A 1.1 cache has no reliable cost marker. Keep settings intact, but
    -- remove the stale skill entries so the next trainer visit rebuilds them.
    store.forever = {}
    if GnomeLevelUpDB.learnedTraining then
        GnomeLevelUpDB.learnedTraining.forever = nil
    end
    GnomeLevelUpDB.trainerRescanRequired = true

    GnomeLevelUpDB.trainerSchemaVersion = TRAINER_SCHEMA_VERSION
    if ns.InvalidateTrainerIndex then ns.InvalidateTrainerIndex() end
    print("|cff3fe0ffGnomeLevelUp|r: trainer data was updated. Visit your class trainer once to rescan skills and costs.")
end

local function MarkLearned(entry, level)
    local store = GetLearnedStore()
    if not store then return end
    store[ns.TrainingEntryKey(entry, level)] = true
    if type(entry) == "table" and entry.spellID then
        store["spell:" .. entry.spellID] = true
    end
end

function ns.IsTrainerSkillLearned(entry, level, learnedStore)
    -- Check whether a cached skill is already learned.
    local spellID = type(entry) == "table" and entry.spellID
    local store = learnedStore or GetLearnedStore()
    if not store then return false end
    return store[ns.TrainingEntryKey(entry, level)] == true
        or (spellID and store["spell:" .. spellID] == true) or false
end

function ns.MarkKnownTrainerSkills(spellSnapshot, known)
    -- Mark cached skills that are already in the spellbook.
    local store = EnsureSavedStore()
    if not store or not UnitGUID("player") then return end
    known = known or ns.BuildKnownTrainingLookup(spellSnapshot)
    for _, item in ipairs(ns.GetTrainerCatalogIndex and ns.GetTrainerCatalogIndex() or {}) do
        if ns.IsTrainerSkillKnown(item.entry, known) then
            MarkLearned(item.entry, item.level)
        end
    end
end

function ns.MarkTrainerSpellLearned(spellID)
    spellID = tonumber(spellID)
    if not spellID then return end
    for _, item in ipairs(ns.GetTrainerCatalogIndex and ns.GetTrainerCatalogIndex() or {}) do
        if item.id == spellID then
            MarkLearned(item.entry, item.level)
        end
    end
end

function ns.MergeSavedTrainerData()
    EnsureSavedStore()
    ns.MigrateTrainerData()
end

function ns.ClearScannedTrainerData()
    -- Remove all saved trainer data and start a fresh scan.
    GnomeLevelUpDB.scannedTraining = { forever = {} }
    GnomeLevelUpDB.learnedTraining = nil
    GnomeLevelUpDB.trainerRescanRequired = false
    GnomeLevelUpDB.trainerCacheMeta = nil
    if ns.InvalidateTrainerIndex then ns.InvalidateTrainerIndex() end
end

local function GetRequiredLevel(index, infoRequiredLevel, serviceType)
    if GetTrainerServiceLevelReq then
        local ok, level = pcall(GetTrainerServiceLevelReq, index)
        level = ok and tonumber(level)
        if level then return level end
    end
    local level = tonumber(infoRequiredLevel)
    if level and level > 0 then return level end
    return nil
end

local function GetServiceSpellID(index)
    if not C_TooltipInfo or not C_TooltipInfo.GetTrainerService then return nil end
    local ok, data = pcall(C_TooltipInfo.GetTrainerService, index)
    if ok and data then
        local rawID = data.id or data.spellID
        local idOK, id = pcall(tonumber, rawID)
        if idOK then return id end
    end
end

local function ReadService(index)
    if type(GetTrainerServiceInfo) ~= "function" then return end
    local ok, a, b, c, d, e, f = pcall(GetTrainerServiceInfo, index)
    if not ok then return end

    -- Forever-style clients use name, type, texture, requiredLevel, subText.
    -- Older clients commonly expose name, subText, type, texture, requiredLevel.
    local name, status, icon, level, subtext, category
    local function IsStatus(value)
        return value == "available" or value == "unavailable" or value == "used"
    end
    if IsStatus(b) or b == "header" then
        name, status, icon, level, subtext, category = a, b, c, d, e, f
    elseif IsStatus(c) or c == "header" then
        name, subtext, status, icon, level, category = a, b, c, d, e, f
    else
        -- Unknown signatures are ignored instead of being stored incorrectly.
        return
    end

    local spellID = GetServiceSpellID(index)
    if (not subtext or subtext == "") and spellID and C_Spell and C_Spell.GetSpellSubtext then
        subtext = C_Spell.GetSpellSubtext(spellID)
    end
    local serviceCost, professionCost
    if type(GetTrainerServiceCost) == "function" then
        local costOK, rawCost, _, rawProfessionCost = pcall(GetTrainerServiceCost, index)
        if costOK then
            serviceCost = tonumber(rawCost)
            professionCost = rawProfessionCost
        end
    end
    return name, subtext, status, level, icon, spellID, category, serviceCost, professionCost
end

-- Build a short-lived index for one scan so duplicate checks do not walk every
-- saved entry for every service returned by the trainer API.
local function BuildRecordIndex(classMap, classToken)
    local index = {}
    local levelMap = classMap and classMap[classToken]
    if type(levelMap) ~= "table" then return index end

    for rawLevel, entries in pairs(levelMap) do
        local level = tonumber(rawLevel)
        if level and type(entries) == "table" then
            local levelIndex = { bySpell = {}, byName = {}, byBase = {} }
            index[level] = levelIndex
            for _, existing in ipairs(entries) do
                local oldName = ns.NormalizeTrainingName(ns.TrainingEntryName(existing))
                if oldName then
                    levelIndex.byName[oldName] = existing
                    local base = oldName:match("^(.-) %(") or oldName
                    levelIndex.byBase[base] = levelIndex.byBase[base] or existing
                end
                if type(existing) == "table" and existing.spellID then
                    levelIndex.bySpell[existing.spellID] = existing
                end
            end
        end
    end
    return index
end

local function IndexRecord(levelIndex, entry)
    if not levelIndex or not entry then return end
    local name = ns.NormalizeTrainingName(ns.TrainingEntryName(entry))
    if name then
        levelIndex.byName[name] = entry
        local base = name:match("^(.-) %(") or name
        levelIndex.byBase[base] = levelIndex.byBase[base] or entry
    end
    if type(entry) == "table" and entry.spellID then
        levelIndex.bySpell[entry.spellID] = entry
    end
end

-- Preserve one saved record per spell or normalized trainer name.
local function RecordAbility(classMap, classToken, level, label, icon, spellID, isProfession, serviceCost, recordIndex)
    recordIndex = recordIndex or {}
    classMap[classToken] = classMap[classToken] or {}
    local levelMap = classMap[classToken]
    local entries = levelMap[level] or levelMap[tostring(level)]
    if not entries then entries = {}; levelMap[level] = entries end
    local normalized = ns.NormalizeTrainingName(label)
    local base = normalized:match("^(.-) %(") or normalized

    recordIndex[level] = recordIndex[level] or { bySpell = {}, byName = {}, byBase = {} }
    local levelIndex = recordIndex[level]
    local existing = (spellID and levelIndex.bySpell[spellID]) or levelIndex.byName[normalized]

    local function Matches(candidate)
        if not candidate then return false end
        local oldName = ns.NormalizeTrainingName(ns.TrainingEntryName(candidate))
        local oldID = type(candidate) == "table" and candidate.spellID
        local oldBase = oldName and (oldName:match("^(.-) %(") or oldName)
        local oldHasSuffix = oldName and oldName:find(" %(") ~= nil
        local newHasSuffix = normalized:find(" %(") ~= nil
        return (spellID and oldID and spellID == oldID)
            or (not oldID and (oldName == normalized
                or (not oldHasSuffix and newHasSuffix and oldName == base)
                or (oldHasSuffix and not newHasSuffix and oldBase == normalized)))
            or (not spellID and oldName == normalized)
    end

    if not Matches(existing) then
        existing = Matches(levelIndex.byBase[base]) and levelIndex.byBase[base] or nil
    end
    if not existing then
        -- The indexed paths cover normal scans. Keep the old comparison as a
        -- fallback for unusual rank/name combinations already in the cache.
        for index, candidate in ipairs(entries) do
            if Matches(candidate) then
                existing = candidate
                break
            end
        end
    end

    if existing then
        local existingIndex
        if type(existing) ~= "table" then
            for index, candidate in ipairs(entries) do
                if candidate == existing then existingIndex = index; break end
            end
        end
        local index = existingIndex
        local changed = false
        if type(existing) ~= "table" then
            existing = { name = existing }
            if index then entries[index] = existing end
        end
        if existing.name ~= label then existing.name = label; changed = true end
        if icon and existing.icon ~= icon then existing.icon = icon; changed = true end
        if spellID and existing.spellID ~= spellID then existing.spellID = spellID; changed = true end
        if isProfession and not existing.profession then existing.profession = true; changed = true end
        if serviceCost ~= nil and existing.cost ~= serviceCost then
            existing.cost = serviceCost
            changed = true
        end
        IndexRecord(levelIndex, existing)
        return existing, false, changed
    end
    local savedEntry = {
        name = label,
        icon = icon,
        spellID = spellID,
        profession = isProfession or nil,
        cost = serviceCost,
    }
    entries[#entries + 1] = savedEntry
    IndexRecord(levelIndex, savedEntry)
    return savedEntry, true, true
end

local function ScanTrainer()
    -- Read the trainer window and save valid class skills.
    if not GetNumTrainerServices or not GetTrainerServiceInfo then return end
    if ns.db and ns.db.autoScanTrainers == false
        and not GnomeLevelUpDB.trainerRescanRequired then return end
    local store = EnsureSavedStore()
    if not store then return end
    local flavor = ns.GetCurrentFlavor()
    if flavor ~= "forever" then return end
    local npcName = UnitName("npc")
    local trainerIsProfession = IsProfessionTrainer()
    if trainerIsProfession and not (ns.db and ns.db.scanProfessionTrainers) then return end
    local _, classToken = UnitClass("player")
    if not classToken then return end
    local recordIndex = BuildRecordIndex(store[flavor], classToken)

    local added, skippedNoLevel, changed = 0, 0, false
    for i = 1, GetNumTrainerServices() do
        local name, subtext, status, infoLevel, icon, spellID, category, serviceCost, professionCost = ReadService(i)
        if name and (status == "available" or status == "unavailable" or status == "used") then
            local level = GetRequiredLevel(i, infoLevel, status)
            if level then
                local label = (subtext and subtext ~= "") and (name .. " (" .. subtext .. ")") or name
                if not icon and GetTrainerServiceIcon then
                    local ok, texture = pcall(GetTrainerServiceIcon, i)
                    if ok then icon = texture end
                end
                local professionService = trainerIsProfession
                    or IsProfessionService(i, professionCost)
                    or category == "profession"
                local isWeaponSkill = ns.IsHardcodedWeaponSkill
                    and (ns.IsHardcodedWeaponSkill(name) or ns.IsHardcodedWeaponSkill(label))
                if not isWeaponSkill
                    and (not professionService or (ns.db and ns.db.scanProfessionTrainers)) then
                    local savedEntry, isNew, wasChanged = RecordAbility(
                        store[flavor], classToken, level, label, icon, spellID, professionService, serviceCost, recordIndex)
                    if isNew then added = added + 1 end
                    changed = changed or wasChanged
                    if status == "used" then MarkLearned(savedEntry, level) end
                end
            elseif status == "unavailable" then
                skippedNoLevel = skippedNoLevel + 1
            end
        end
    end
    if changed and ns.InvalidateTrainerIndex then ns.InvalidateTrainerIndex() end
    if GnomeLevelUpDB.trainerRescanRequired then
        GnomeLevelUpDB.trainerRescanRequired = false
    end
    GnomeLevelUpDB.trainerCacheMeta = {
        flavor = flavor,
        classToken = classToken,
        npcName = npcName,
        lastScanAt = type(time) == "function" and time() or nil,
    }
    if ns.SnapshotSpellBook and ns.MarkKnownTrainerSkills then
        ns.MarkKnownTrainerSkills(ns.SnapshotSpellBook())
    end
    if added > 0 then
        print(string.format("|cff3fe0ffGnomeLevelUp|r: saved %d new trainer %s from %s.",
            added, added == 1 and "entry" or "entries", npcName or "this trainer"))
    elseif skippedNoLevel > 0 then
        print(string.format("|cff3fe0ffGnomeLevelUp|r: skipped %d future skills without a readable required level.", skippedNoLevel))
    end
end
ns.ScanTrainer = ScanTrainer

local frame = CreateFrame("Frame")
ns.trainerEventFrame = frame
local trainerOpen, scanQueued, reconcileQueued = false, false, false
local trainerSession = 0
local function QueueScan()
    -- Wait briefly so the trainer list has time to finish loading.
    if ns.GetCurrentFlavor and ns.GetCurrentFlavor() ~= "forever" then return end
    if scanQueued then return end
    scanQueued = true
    local session = trainerSession
    C_Timer.After(TRAINER_SCAN_DELAY, function()
        scanQueued = false
        if trainerOpen and trainerSession == session then ScanTrainer() end
    end)
end
local function QueueReconcile()
    -- Recheck saved skills after the trainer window closes.
    if ns.GetCurrentFlavor and ns.GetCurrentFlavor() ~= "forever" then return end
    if reconcileQueued then return end
    reconcileQueued = true
    C_Timer.After(TRAINER_RECONCILE_DELAY, function()
        reconcileQueued = false
        if ns.db and ns.GetTrainerCatalogIndex and #ns.GetTrainerCatalogIndex() > 0
            and ns.SnapshotSpellBook and ns.MarkKnownTrainerSkills then
            ns.MarkKnownTrainerSkills(ns.SnapshotSpellBook())
        end
    end)
end

function ns.DumpTrainerData()
    -- Print saved skills when debug mode is enabled.
    if not ns.IsDebugEnabled or not ns.IsDebugEnabled() then return end
    local flavor = ns.GetCurrentFlavor()
    local _, classToken = UnitClass("player")
    local count = 0
    print(string.format("|cff3fe0ffGnomeLevelUp|r trainer cache: %s / %s", flavor, classToken or "unknown"))
    for _, catalogEntry in ipairs(ns.GetTrainerCatalogIndex and ns.GetTrainerCatalogIndex() or {}) do
        local learned = ns.IsTrainerSkillLearned and ns.IsTrainerSkillLearned(catalogEntry.entry, catalogEntry.level)
        print(string.format("  [%d] %s%s%s", catalogEntry.level, catalogEntry.name,
            catalogEntry.id and (" (spell " .. catalogEntry.id .. ")") or "",
            learned and " |cff66ff66[learned]|r" or " |cffffcc66[available]|r"))
        count = count + 1
    end
    if count == 0 then print("  (no cached trainer skills)") end
end

function ns.TestTrainerList()
    -- Print the skills currently shown in the level-up panel.
    if not ns.IsDebugEnabled or not ns.IsDebugEnabled() then return end
    local currentLevel = UnitLevel("player")
    local abilities
    if ns.GetCurrentFlavor and ns.GetCurrentFlavor() == "retail" and ns.GetRetailUnlearnedSpells then
        abilities = ns.GetRetailUnlearnedSpells(currentLevel)
        print(string.format("|cff3fe0ffGnomeLevelUp|r unlearned Retail spell unlocks: %d", #abilities))
    else
        abilities = ns.GetAllTrainableUpToLevel(currentLevel)
        print(string.format("|cff3fe0ffGnomeLevelUp|r unlearned trainer skills: %d", #abilities))
    end
    for _, ability in ipairs(abilities) do
        print("  " .. ability.name)
    end
    local unlearnedWeaponSkills = ns.GetUnlearnedWeaponSkills
        and ns.GetUnlearnedWeaponSkills(currentLevel) or {}
    print(string.format("|cff3fe0ffGnomeLevelUp|r unlearned weapon skills: %d", #unlearnedWeaponSkills))
    for _, weaponSkill in ipairs(unlearnedWeaponSkills) do
        print("  " .. weaponSkill.name)
    end
end

frame:RegisterEvent("TRAINER_SHOW")
frame:RegisterEvent("TRAINER_UPDATE")
frame:RegisterEvent("TRAINER_CLOSED")
frame:RegisterEvent("SPELLS_CHANGED")
frame:RegisterEvent("LEARNED_SPELL_IN_SKILL_LINE")
frame:RegisterEvent("SKILL_LINES_CHANGED")
-- Keep the cache updated while the player visits trainers or learns spells.
frame:SetScript("OnEvent", function(self, event, ...)
    if ns.GetCurrentFlavor and ns.GetCurrentFlavor() ~= "forever"
        and event ~= "SPELLS_CHANGED" and event ~= "LEARNED_SPELL_IN_SKILL_LINE" then
        return
    end
    if event == "TRAINER_SHOW" then
        trainerSession = trainerSession + 1
        trainerOpen = true
        QueueScan()
    elseif event == "TRAINER_CLOSED" then
        trainerOpen = false
        QueueReconcile()
    elseif event == "TRAINER_UPDATE" then
        if trainerOpen then QueueScan() end
    elseif event == "LEARNED_SPELL_IN_SKILL_LINE" then
        if ns.InvalidateSpellBookSnapshot then ns.InvalidateSpellBookSnapshot() end
        if ns.InvalidateWeaponSkillSnapshot then ns.InvalidateWeaponSkillSnapshot() end
        ns.MarkTrainerSpellLearned((...))
    else
        if ns.InvalidateSpellBookSnapshot then ns.InvalidateSpellBookSnapshot() end
        if ns.InvalidateWeaponSkillSnapshot then ns.InvalidateWeaponSkillSnapshot() end
        if ns.GetCurrentFlavor and ns.GetCurrentFlavor() == "forever" then
            QueueReconcile()
        end
    end
end)
