local ADDON_NAME, ns = ...

-- The bundled Forever catalogue is loaded before this shared query layer.

-- Decide which trainer data path is active.
function ns.GetCurrentFlavor()
    local override = ns.db and ns.db.forceFlavor
    if override == "retail" or override == "forever" then
        return override
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
    catalogIndex = { revision = catalogRevision, entries = entries }
    return entries
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
    if onlyNewSkills then
        for _, item in ipairs(catalog) do
            local family = item.entry.familyID
            if family and (ns.IsTrainerSkillKnown(item.entry, known)
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
        if talentMatches and levelMatches and displayLevel <= currentLevel
            and not hiddenHunterPetSkill and not learned and not ns.IsTrainerSkillKnown(catalogEntry.entry, known) then
            local ability = {
                name = catalogEntry.name,
                icon = catalogEntry.icon,
                id = catalogEntry.id,
                cost = catalogEntry.cost,
            }
            local baseName, rank = ns.GetTrainingRankInfo(catalogEntry.name)
            if entry.familyID then baseName, rank = "spell:" .. entry.familyID, entry.rank end
            -- Retain display metadata separately from the temporary filter rank.
            ability.trainingRank = rank
            ability.isNewAbility = rank == nil or rank == 1
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
