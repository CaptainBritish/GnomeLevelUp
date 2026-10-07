local ADDON_NAME, ns = ...

-- Keep exceptional Forever trainer skills here when they are missing from scans.
ns.ClassTrainingForever = {
}

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
                local rank = tonumber(subtext:match("(%d+)%s*$"))
                if rank then known.ranks[normalized] = math.max(known.ranks[normalized] or 0, rank) end
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
        return false
    end

    local name = ns.NormalizeTrainingName(GetTrainingName(entry))
    if not name then return false end
    if known.names[name] then return true end

    local base, rank = name:match("^(.-) %([^()]- (%d+)%)$")
    rank = tonumber(rank)
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
    local scanned = GnomeLevelUpDB and GnomeLevelUpDB.scannedTraining
    scanned = scanned and scanned.forever and scanned.forever[classToken]
    return static, scanned
end

function ns.GetTrainerCatalogIndex()
    -- Merge hand-written skills and skills found at visited trainers.
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
                    if name and key then
                        local existing = byKey[idKey] or byKey[nameKey]
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

function ns.GetAllTrainableUpToLevel(currentLevel, spellSnapshot)
    -- Return only skills that fit the player's level and are not learned.
    currentLevel = tonumber(currentLevel) or 0
    local catalog = ns.GetTrainerCatalogIndex()
    if #catalog == 0 then return {} end
    spellSnapshot = spellSnapshot or (ns.SnapshotSpellBook and ns.SnapshotSpellBook()) or {}
    local known = ns.BuildKnownTrainingLookup(spellSnapshot)
    local learnedStore = ns.GetLearnedTrainingStore and ns.GetLearnedTrainingStore()
    local onlyCurrentLevel = ns.db and ns.db.showOnlyCurrentLevelSkills == true

    local unlearnedAbilities = {}
    for _, catalogEntry in ipairs(catalog) do
        local learned = ns.IsTrainerSkillLearned and ns.IsTrainerSkillLearned(catalogEntry.entry, catalogEntry.level, learnedStore)
        local levelMatches = not onlyCurrentLevel or catalogEntry.level == currentLevel
        if levelMatches and catalogEntry.level <= currentLevel
            and not learned and not ns.IsTrainerSkillKnown(catalogEntry.entry, known) then
            unlearnedAbilities[#unlearnedAbilities + 1] = {
                name = catalogEntry.name,
                icon = catalogEntry.icon,
                id = catalogEntry.id,
                cost = catalogEntry.cost,
            }
        end
    end
    return unlearnedAbilities
end
