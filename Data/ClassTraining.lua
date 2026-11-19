local ADDON_NAME, ns = ...

-- The bundled Forever catalogue is loaded before this shared query layer.

function ns.GetClientFlavor()
    if WOW_PROJECT_CAMELOT and WOW_PROJECT_ID == WOW_PROJECT_CAMELOT then
        return "forever"
    end

    if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
        if LE_EXPANSION_LEVEL_CURRENT == LE_EXPANSION_CLASSIC then
            return "forever"
        end
        return "retail"
    end

    if C_SpellBook and C_SpellBook.GetNumSpellBookSkillLines then
        return "forever"
    end
    return "retail"
end

-- Decide which trainer data path is active.
function ns.GetCurrentFlavor()
    local override = ns.db and ns.db.forceFlavor
    if override == "retail" or override == "forever" then return override end
    return ns.GetClientFlavor()
end

local function GetTrainingName(entry)
    if type(entry) == "table" and not entry.name and ns.ResolveTrainingEntry then
        return ns.ResolveTrainingEntry(entry)
    end
    return type(entry) == "table" and entry.name or entry
end
ns.TrainingEntryName = GetTrainingName

-- Make trainer names easier to compare.
function ns.NormalizeTrainingName(label)
    if type(label) ~= "string" then return nil end
    label = label:match("^%s*(.-)%s*$")
    label = label:gsub("%s+", " "):lower()
    label = label:gsub("%s*%(available%)$", "")
        :gsub("%s*%(unavailable%)$", "")
        :gsub("%s*%(used%)$", "")
    label = label:gsub("%s*%(", " (")
    return label ~= "" and label or nil
end

function ns.GetTrainingRankInfo(label)
    local normalized = ns.NormalizeTrainingName(label)
    if not normalized then return nil, nil end
    local base, rank = normalized:match("^(.-)%s*%([^()]-(%d+)%s*%)$")
    if not rank then base, rank = normalized:match("^(.-)%s+rank%s*(%d+)$") end
    return base or normalized, tonumber(rank)
end

function ns.LatestTrainingRanks(abilities)
    local latest, shown = {}, {}
    for _, ability in ipairs(abilities) do
        local family, rank = ability.trainingFamily, ability.trainingRank
        if not family and not ability.preview then family, rank = ns.GetTrainingRankInfo(ability.name) end
        local previous = family and latest[family]
        if not family or not rank then
            shown[#shown + 1] = ability
        elseif not previous then
            shown[#shown + 1] = ability
            latest[family] = { rank = rank, index = #shown }
        elseif rank > previous.rank then
            shown[previous.index] = ability
            previous.rank = rank
        end
    end
    return shown
end

function ns.TrainingEntryKey(entry, level)
    local id = type(entry) == "table" and entry.spellID
    if id then return "spell:" .. tostring(id) end
    return (ns.NormalizeTrainingName(GetTrainingName(entry)) or "") .. "@" .. tostring(tonumber(level) or level)
end

local knownTrainingLookupSource
local knownTrainingLookup

function ns.InvalidateKnownTrainingLookup()
    knownTrainingLookupSource = nil
    knownTrainingLookup = nil
end

-- Build a quick lookup of spells already known by the player.
function ns.BuildKnownTrainingLookup(spellSnapshot)
    spellSnapshot = spellSnapshot or {}
    if knownTrainingLookupSource == spellSnapshot and knownTrainingLookup then
        return knownTrainingLookup
    end

    local known = { spells = spellSnapshot, names = {}, ranks = {} }
    for id, name in pairs(known.spells) do
        local normalized = ns.NormalizeTrainingName(name)
        if normalized then
            local subtext = C_Spell and C_Spell.GetSpellSubtext and C_Spell.GetSpellSubtext(id)
            if subtext and subtext ~= "" then
                known.names[ns.NormalizeTrainingName(name .. " (" .. subtext .. ")")] = true
                local baseName, nameRank = ns.GetTrainingRankInfo(normalized)
                local rank = tonumber(subtext:match("(%d+)%s*$")) or nameRank
                if rank and baseName then known.ranks[baseName] = math.max(known.ranks[baseName] or 0, rank) end
            else
                known.names[normalized] = true
            end
        end
    end
    knownTrainingLookupSource = spellSnapshot
    knownTrainingLookup = known
    return known
end

function ns.IsTrainerSkillKnown(entry, known)
    known = known or { spells = {}, names = {}, ranks = {} }
    local spellID = type(entry) == "table" and entry.spellID
    if spellID then
        if known.spells[spellID] then return true end
        if ns.IsSpellKnownAcrossClients and ns.IsSpellKnownAcrossClients(spellID) then return true end
        for _, higher in ipairs(entry.replacedBy or {}) do
            if known.spells[higher] or (ns.IsSpellKnownAcrossClients and ns.IsSpellKnownAcrossClients(higher)) then return true end
        end
        return false
    end

    local name = ns.NormalizeTrainingName(GetTrainingName(entry))
    if not name then return false end
    if known.names[name] then return true end

    local base, rank = ns.GetTrainingRankInfo(name)
    return rank ~= nil and (known.ranks[base] or 0) >= rank
end

local catalogRevision = 0
local catalogIndex

function ns.InvalidateTrainerIndex()
    catalogRevision = catalogRevision + 1
    catalogIndex = nil
end

local function GetClassSources()
    if ns.GetCurrentFlavor() ~= "forever" then return nil, nil end
    local _, classToken = UnitClass("player")
    local static = ns.ClassTrainingForever[classToken]
    -- Old character scans must not change bundled levels, costs or restrictions.
    if static then return static, nil end
    local scanned = GnomeLevelUpDB and GnomeLevelUpDB.scannedTraining
    scanned = scanned and scanned.forever and scanned.forever[classToken]
    return static, scanned
end

function ns.IsLevelUpTrainingSpellHidden(spellID)
    if not spellID or ns.GetCurrentFlavor() ~= "forever" then return false end
    local training = GetClassSources()
    for _, entry in ipairs(training and training[1] or {}) do
        if entry.spellID == spellID then return entry.hideInLevelUp == true end
    end
    return false
end

function ns.FilterLevelUpTrainingAbilities(abilities)
    if ns.GetCurrentFlavor() ~= "forever" then return abilities or {} end
    local visible = {}
    for _, ability in ipairs(abilities or {}) do
        if not ns.IsLevelUpTrainingSpellHidden(ability.id) then visible[#visible + 1] = ability end
    end
    return visible
end

function ns.GetBundledTimelineTraining(level)
    local static = GetClassSources()
    local eligible = {}
    for _, entry in ipairs(static and static[level] or {}) do
        if type(entry) == "table" and entry.spellID and not entry.hideInLevelUp and ns.IsTrainingEntryEligible(entry)
            and (not entry.profession or (ns.db and ns.db.scanProfessionTrainers))
            and (not entry.requiredTalentId or ns.IsSpellKnownAcrossClients(entry.requiredTalentId)) then
            -- An upcoming icon only needs the spell ID, even while its name loads.
            eligible[#eligible + 1] = entry
        end
    end
    return eligible
end

function ns.GetTrainerCatalogIndex()
    -- Use the bundled catalogue where available, otherwise legacy scan data.
    if catalogIndex and catalogIndex.revision == catalogRevision then
        return catalogIndex.entries
    end

    local static, scanned = GetClassSources()
    local entries, byKey = {}, {}
    local function addSource(source)
        if not source then return end
        for rawLevel, list in pairs(source) do
            local level = tonumber(rawLevel)
            if level and type(list) == "table" then
                for _, entry in ipairs(list) do
                    local name = GetTrainingName(entry)
                    if type(entry) == "table" and entry.profession
                        and not (ns.db and ns.db.scanProfessionTrainers) then
                        name = nil
                    end
                    local id = type(entry) == "table" and entry.spellID or nil
                    local nameKey = ns.NormalizeTrainingName(name)
                    local idKey = id and ("spell:" .. tostring(id)) or nil
                    local key = idKey or nameKey
                    if name and key and (not ns.IsTrainingEntryEligible or ns.IsTrainingEntryEligible(entry)) then
                        local existing = byKey[idKey or nameKey]
                        if not existing then
                            existing = {
                                entry = entry,
                                level = level,
                                name = name,
                                icon = type(entry) == "table" and entry.icon or nil,
                                cost = type(entry) == "table" and entry.cost or nil,
                                id = id,
                                key = key,
                            }
                            entries[#entries + 1] = existing
                        else
                            if id and not existing.id then
                                existing.id = id
                                existing.entry = entry
                                existing.key = idKey
                            end
                            if not existing.icon and type(entry) == "table" then
                                existing.icon = entry.icon
                            end
                            if existing.cost == nil and type(entry) == "table" then
                                existing.cost = entry.cost
                            end
                            if id and existing.level ~= level then
                                existing.level = math.min(existing.level, level)
                            end
                        end
                        byKey[key] = existing
                        if nameKey then byKey[nameKey] = existing end
                        if idKey then byKey[idKey] = existing end
                    end
                end
            end
        end
    end

    addSource(static)
    addSource(scanned)
    table.sort(entries, function(a, b)
        if a.level ~= b.level then return a.level < b.level end
        return a.name < b.name
    end)
    local byLevel, bySpellID = {}, {}
    for _, item in ipairs(entries) do
        local bucket = byLevel[item.level]
        if not bucket then bucket = {}; byLevel[item.level] = bucket end
        bucket[#bucket + 1] = item
        if item.id then bySpellID[item.id] = item end
    end
    catalogIndex = { revision = catalogRevision, entries = entries, byLevel = byLevel, bySpellID = bySpellID }
    return entries
end

function ns.GetTrainerCatalogLookups()
    ns.GetTrainerCatalogIndex()
    return catalogIndex.byLevel, catalogIndex.bySpellID
end

-- Pet training records share the Hunter trainer catalog. Match complete
-- ability names, never the word "pet", so Mend Pet/Revive Pet stay visible.
local HUNTER_PET_TRAINING_NAMES = {
    ["great stamina"] = true, ["natural armor"] = true,
    ["arcane resistance"] = true, ["fire resistance"] = true,
    ["frost resistance"] = true, ["nature resistance"] = true,
    ["shadow resistance"] = true, ["growl"] = true, ["cower"] = true,
    ["bite"] = true, ["claw"] = true, ["dash"] = true, ["dive"] = true,
    ["screech"] = true, ["scorpid poison"] = true, ["furious howl"] = true,
    ["lightning breath"] = true, ["prowl"] = true, ["charge"] = true,
    ["shell shield"] = true, ["thunderstomp"] = true,
}

function ns.IsHunterPetTrainingEntry(entry)
    if type(entry) == "table" and entry.hunterPet == true then return true end
    local base = ns.GetTrainingRankInfo(GetTrainingName(entry))
    if base and HUNTER_PET_TRAINING_NAMES[base] then return true end
    return false
end

local function BuildTrainerAbility(item, displayLevel)
    local family, rank = ns.GetTrainingRankInfo(item.name)
    if item.entry.familyID then family, rank = "spell:" .. item.entry.familyID, item.entry.rank end
    return {
        name = item.name,
        icon = item.icon,
        id = item.id,
        cost = item.cost,
        requiredLevel = displayLevel,
        trainingFamily = rank and family or nil,
        trainingRank = rank,
        isNewAbility = rank == nil or rank == 1,
    }
end

function ns.GetTrainerAbilitiesForLevel(level)
    local _, classToken = UnitClass("player")
    local byLevel = ns.GetTrainerCatalogLookups()
    local isHunter = classToken == "HUNTER"
    local showPetSkills = isHunter and ns.db.showHunterPetSkills ~= false and level >= 10
    local abilities = {}
    local function AddLevel(catalogueLevel, petOnly)
        local entries = byLevel[catalogueLevel]
        if not entries then return end
        for _, item in ipairs(entries) do
            local hunterPet = isHunter and ns.IsHunterPetTrainingEntry(item.entry)
            local include = hunterPet and showPetSkills or not hunterPet and not petOnly
            local talent = item.entry.requiredTalentId
            if include and not item.entry.hideInLevelUp and (not talent or ns.IsSpellKnownAcrossClients(talent)) then
                local ability = BuildTrainerAbility(item, level)
                if not ns.db.showOnlyNewSkills or ability.isNewAbility then abilities[#abilities + 1] = ability end
            end
        end
    end

    -- The earliest pet training appears at level 10, even if indexed at a lower level.
    if level == 10 and showPetSkills then
        for catalogueLevel = 1, 9 do AddLevel(catalogueLevel, true) end
    end
    AddLevel(level, false)
    return abilities
end

function ns.GetAllTrainableUpToLevel(currentLevel, spellSnapshot, rangeStart)
    -- Return only skills that fit the player's level and are not learned.
    currentLevel = tonumber(currentLevel) or 0
    local catalog = ns.GetTrainerCatalogIndex()
    if #catalog == 0 then return {} end
    spellSnapshot = spellSnapshot or (ns.SnapshotSpellBook and ns.SnapshotSpellBook()) or {}
    local known = ns.BuildKnownTrainingLookup(spellSnapshot)
    local _, classToken = UnitClass("player")
    local learnedStore = ns.GetLearnedTrainingStore and ns.GetLearnedTrainingStore()
    local onlyCurrentLevel = ns.db and ns.db.showOnlyCurrentLevelSkills == true
    local onlyNewSkills = ns.db and ns.db.showOnlyNewSkills == true

    local unlearnedAbilities = {}
    local rankedAbilities = {}
    local knownFamilies = {}
    local currentRanks = {}
    for _, item in ipairs(catalog) do
        local family, rank = item.entry.familyID, item.entry.rank
        if family then
            local exactKnown = item.id and known.spells[item.id]
            if exactKnown and rank and (not currentRanks[family] or rank > currentRanks[family].entry.rank) then
                currentRanks[family] = item
            end
            if onlyNewSkills and (exactKnown or ns.IsTrainerSkillKnown(item.entry, known)
                or known.spells[family]
                or (ns.IsSpellKnownAcrossClients and ns.IsSpellKnownAcrossClients(family))) then
                knownFamilies[family] = true
            end
        end
    end
    for _, catalogEntry in ipairs(catalog) do
        local entry = catalogEntry.entry
        local learned = not entry.bundled and ns.IsTrainerSkillLearned
            and ns.IsTrainerSkillLearned(entry, catalogEntry.level, learnedStore)
        local talentMatches = not entry.requiredTalentId or known.spells[entry.requiredTalentId]
            or (ns.IsSpellKnownAcrossClients and ns.IsSpellKnownAcrossClients(entry.requiredTalentId))
        local hunterPetSkill = classToken == "HUNTER"
            and ns.IsHunterPetTrainingEntry(catalogEntry.entry)
        -- Pet training knowledge cannot be inferred from the summoned pet.
        -- Hunters first obtain pets at level 10; defer earlier pet ranks to
        -- that level, then show later ranks only when they unlock.
        local displayLevel = hunterPetSkill and math.max(10, catalogEntry.level) or catalogEntry.level
        local levelMatches = rangeStart and displayLevel > rangeStart and displayLevel <= currentLevel
            or displayLevel == currentLevel
            or (not onlyCurrentLevel and not hunterPetSkill)
        local hiddenHunterPetSkill = hunterPetSkill
            and ns.db and ns.db.showHunterPetSkills == false
        if not entry.hideInLevelUp and talentMatches and levelMatches and displayLevel <= currentLevel
            and not hiddenHunterPetSkill and not learned and not ns.IsTrainerSkillKnown(catalogEntry.entry, known) then
            local ability = BuildTrainerAbility(catalogEntry, displayLevel)
            local baseName, rank = ability.trainingFamily, ability.trainingRank
            local current = currentRanks[entry.familyID]
            if not hunterPetSkill and current and rank and current.entry.rank < rank then
                ability.previousRankSpellID = current.id
            end
            if onlyNewSkills and rank and baseName then
                if not knownFamilies[entry.familyID] and (known.ranks[baseName] or 0) == 0 then
                    local existing = rankedAbilities[baseName]
                    if not existing or rank < existing.rank then
                        if existing then unlearnedAbilities[existing.index] = ability end
                        ability.rank = rank
                        ability.index = #unlearnedAbilities + 1
                        rankedAbilities[baseName] = ability
                        unlearnedAbilities[#unlearnedAbilities + 1] = ability
                    end
                end
            else
                unlearnedAbilities[#unlearnedAbilities + 1] = ability
            end
        end
    end
    for _, ability in ipairs(unlearnedAbilities) do ability.rank, ability.index = nil, nil end
    return unlearnedAbilities
end
