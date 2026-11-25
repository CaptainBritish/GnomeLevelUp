local ADDON_NAME, ns = ...

-- Teaching knowledge belongs to the Hunter; trained spells and point costs
-- belong to a particular pet. Never infer the former from a tamed pet's book.
local MAX_SAVED_PETS = 12
local MAX_SKILLS_PER_TABLE = 512
local petSpellDefinitions = {}
local petSpellByTeachingID = {}
local beastTrainingOpen = false
local cleanedPetTrainingStore
-- NPC-taught Beast Training spell IDs, matched to GLU's pet-effect families.
-- Teaching and pet-effect IDs are distinct in Forever build 1.60.1.70959.
local teachingSpellIDsByFamily = {
    [24493] = { 24495, 24508, 24509, 24510 },
    [23992] = { 24440, 24441, 24463, 24464 },
    [24446] = { 24475, 24476, 24477, 24478 },
    [4187] = { 4195, 4196, 4197, 4198, 4199, 4200, 4201, 4202, 5048, 5049 },
    [2649] = { 1853, 14922, 14923, 14924, 14925, 14926, 14927 },
    [24545] = { 24547, 24556, 24557, 24558, 24559, 24560, 24561, 24562, 24631, 24632 },
    [24492] = { 24494, 24511, 24512, 24513 },
    [24488] = { 24490, 24514, 24515, 24516 },
}
-- Capture before other classes' catalogues are released at login.
for _, entries in pairs(ns.ClassTrainingForever and ns.ClassTrainingForever.HUNTER or {}) do
    for _, entry in ipairs(entries) do
        if entry.hunterPet then
            petSpellDefinitions[entry.spellID] = { family = entry.familyID, rank = entry.rank }
            local ranks = teachingSpellIDsByFamily[entry.familyID]
            if ranks and ranks[entry.rank] then
                petSpellByTeachingID[ranks[entry.rank]] = entry.spellID
            end
        end
    end
end

local function ReadOptionalAPI(fn, ...)
    if type(fn) ~= "function" then return end
    local ok, a, b, c = pcall(fn, ...)
    if ok then return a, b, c end
end

local function IsSecretValue(value)
    return type(issecretvalue) == "function" and issecretvalue(value)
end

local function IsPetTrackingEnabled()
    local _, class = ReadOptionalAPI(UnitClass, "player")
    return class == "HUNTER" and ns.db and ns.db.enabled ~= false
        and ns.GetCurrentFlavor() == "forever"
end

local function GetSavedPetTraining()
    if not IsPetTrackingEnabled() or type(GnomeLevelUpCharacterDB) ~= "table" then return end
    local store = GnomeLevelUpCharacterDB.hunterPetTraining
    if type(store) == "table" and store.schemaVersion == 1 then return store end
end

local function GetTimestamp()
    return ReadOptionalAPI(GetServerTime) or ReadOptionalAPI(time)
end

local function PrunePetRecords(store, limit)
    local count = 0
    for _ in pairs(store.pets) do
        count = count + 1
    end
    while count > limit do
        local oldest, sequence
        for key, pet in pairs(store.pets) do
            local seen = tonumber(pet.sequence) or 0
            if not oldest or seen < sequence or (seen == sequence and key < oldest) then
                oldest = key
                sequence = seen
            end
        end
        store.pets[oldest] = nil
        count = count - 1
    end
end

local function EnsurePetTrainingStore()
    if not IsPetTrackingEnabled() or type(GnomeLevelUpCharacterDB) ~= "table" then return end
    local store = GetSavedPetTraining()
    if not store then
        store = {
            schemaVersion = 1,
            teaching = {},
            pets = {},
            trainerOffers = {},
            sequence = 0,
        }
        GnomeLevelUpCharacterDB.hunterPetTraining = store
    end
    if store ~= cleanedPetTrainingStore then
        for _, pet in pairs(store.pets) do
            pet.trainerOffers = nil
        end
        if GnomeLevelUpDB then
            GnomeLevelUpDB.petTrainerObservations = nil
        end
        cleanedPetTrainingStore = store
    end
    -- Enforce the cap when data is updated, never during a popup lookup.
    PrunePetRecords(store, MAX_SAVED_PETS)
    return store
end

local function UpdateCurrentPetRecord(store)
    local guid = ReadOptionalAPI(UnitGUID, "pet")
    -- Never merge same-name pets or guess an identity when the client hides it.
    if IsSecretValue(guid) or type(guid) ~= "string" or not guid:match("^Pet%-") then return end
    local pet = store.pets[guid]
    if not pet then
        PrunePetRecords(store, MAX_SAVED_PETS - 1)
        pet = { spells = {}, availability = {} }
        store.pets[guid] = pet
    end
    store.sequence = (tonumber(store.sequence) or 0) + 1
    pet.sequence = store.sequence
    pet.lastSeen = GetTimestamp()
    local level, family = ReadOptionalAPI(UnitLevel, "pet"), ReadOptionalAPI(UnitCreatureFamily, "pet")
    if pet.level ~= level or pet.family ~= family then
        pet.availability = {}
    end
    pet.level = level
    pet.family = family
    pet.name = ReadOptionalAPI(UnitName, "pet")
    PrunePetRecords(store, MAX_SAVED_PETS)
    return pet, guid
end

local function SaveBoundedEntry(target, key, value)
    if not key then return end
    if target[key] == nil then
        local count = 0
        for _ in pairs(target) do
            count = count + 1
        end
        if count >= MAX_SKILLS_PER_TABLE then return end
    end
    target[key] = value
end

local function GetLocalizedSpellName(id)
    local name = ReadOptionalAPI(C_Spell and C_Spell.GetSpellName, id) or ReadOptionalAPI(GetSpellInfo, id)
    if not name then
        local info = ReadOptionalAPI(C_Spell and C_Spell.GetSpellInfo, id)
        if type(info) == "table" then
            name = info.name
        end
    end
    return type(name) == "string" and not IsSecretValue(name) and name or nil
end

local function FindPetSpellID(name, rank)
    -- Match names in the client's language, using IDs to establish each rank.
    for id, definition in pairs(petSpellDefinitions) do
        if definition.rank == rank and GetLocalizedSpellName(id) == name then
            return id
        end
    end
end

local function RecordTeachingRank(store, id)
    id = petSpellByTeachingID[id] or id
    SaveBoundedEntry(store.teaching, id, true)
end

function ns.IsHunterPetTeachingSpell(id)
    return petSpellByTeachingID[id] ~= nil
end

function ns.IsHunterPetTeachingKnown(id)
    local store = GetSavedPetTraining()
    return store and store.teaching[id] == true or false
end

function ns.GetHunterPetTrainerCost(id, fallback)
    local store = GetSavedPetTraining()
    local offer = store and store.trainerOffers[id]
    return offer and offer.goldCost or fallback
end

function ns.RecordHunterPetTrainerObservation(observation)
    local store = EnsurePetTrainingStore()
    local source = observation.source
    -- Only a positively identified NPC pet trainer supplies gold fees or
    -- confirms that the Hunter has purchased a teaching rank.
    if not store or type(source) ~= "table" or not source.petTrainer or not source.npcPresent then return end
    local id = petSpellByTeachingID[observation.spellID] or observation.spellID
    local offer = {
        goldCost = observation.cost,
        offeredLevel = observation.level,
        lastSeen = GetTimestamp(),
        npcGUID = source.npcGUID,
    }
    SaveBoundedEntry(store.trainerOffers, id, offer)
    UpdateCurrentPetRecord(store)
    if observation.status == "used" then
        RecordTeachingRank(store, id)
    end
    if ns.InvalidateTrainerIndex then
        ns.InvalidateTrainerIndex()
    end
end

local function ReadKnownTeachingSpells()
    local store = EnsurePetTrainingStore()
    if not store or type(IsPlayerSpell) ~= "function" then return end
    local hits, count = {}, 0
    for teachingID, petID in pairs(petSpellByTeachingID) do
        count = count + 1
        local known = ReadOptionalAPI(IsPlayerSpell, teachingID)
        if not IsSecretValue(known) and known == true then
            hits[#hits + 1] = petID
        end
    end
    -- Some builds answer yes for essentially every teaching spell. Reject
    -- that unreliable result and wait for Beast Training.
    if count == 0 or #hits > count * 0.9 then return end
    for _, id in ipairs(hits) do
        RecordTeachingRank(store, id)
    end
end

local function UpdatePetSpellSnapshot()
    local store = EnsurePetTrainingStore()
    if not store then return end
    local pet, guid = UpdateCurrentPetRecord(store)
    if not pet or not ns.SnapshotPetSpellBook then return end
    local book = ns.SnapshotPetSpellBook(true)
    if ReadOptionalAPI(UnitGUID, "pet") ~= guid then return end
    if book and next(book.ids or {}) then
        local spells = {}
        for id in pairs(book.ids) do
            SaveBoundedEntry(spells, id, true)
        end
        pet.spells = spells
        pet.spellsSeen = GetTimestamp()
    end
end

local function IsBeastTrainingOpen()
    if not beastTrainingOpen then return false end
    local line = ReadOptionalAPI(GetCraftDisplaySkillLine)
    return type(line) == "string" and (line == "Beast Training" or line == BEAST_TRAINING or line == GetLocalizedSpellName(5149))
end

local function ReadBeastTraining()
    local store = EnsurePetTrainingStore()
    if not store or not IsBeastTrainingOpen() then return end
    local count = ReadOptionalAPI(GetNumCrafts)
    if type(count) ~= "number" then return end
    local pet, guid = UpdateCurrentPetRecord(store)
    for index = 1, math.min(count, MAX_SKILLS_PER_TABLE) do
        local name, subtext, status = ReadOptionalAPI(GetCraftInfo, index)
        if type(name) == "string" and name ~= "" and status ~= "header" then
            local rank = type(subtext) == "string" and tonumber(subtext:match("(%d+)")) or 1
            local id = FindPetSpellID(name, rank or 1)
            -- Unknown/wild ranks are kept separately without adding new popup
            -- entries. Missing rows never remove teaching knowledge.
            local key = id or (name .. ":" .. tostring(rank or 1))
            RecordTeachingRank(store, key)
            if pet and ReadOptionalAPI(UnitGUID, "pet") == guid then
                SaveBoundedEntry(pet.availability, key, {
                    status = status,
                    trainingPoints = ReadOptionalAPI(GetCraftTrainingPoints, index),
                    lastSeen = GetTimestamp(),
                })
            end
        end
    end
    store.teachingSeen = GetTimestamp()
    if ns.InvalidateTrainerIndex then
        ns.InvalidateTrainerIndex()
    end
end

local refreshQueued = false
local function QueuePetTrainingRefresh()
    if refreshQueued then return end
    refreshQueued = true
    local function RefreshPetTraining()
        refreshQueued = false
        ReadKnownTeachingSpells()
        UpdatePetSpellSnapshot()
        ReadBeastTraining()
    end
    if C_Timer and C_Timer.After then
        C_Timer.After(0.2, RefreshPetTraining)
    else
        RefreshPetTraining()
    end
end

local frame = CreateFrame("Frame")
ns.hunterPetEventFrame = frame
for _, event in ipairs({ "PLAYER_LOGIN", "PLAYER_ENTERING_WORLD", "UNIT_PET", "UNIT_LEVEL", "UNIT_PET_TRAINING_POINTS",
    "PET_BAR_UPDATE", "PET_STABLE_UPDATE", "SPELLS_CHANGED", "LEARNED_SPELL_IN_SKILL_LINE",
    "CRAFT_SHOW", "CRAFT_UPDATE", "CRAFT_CLOSE"}) do
    pcall(frame.RegisterEvent, frame, event)
end
frame:SetScript("OnEvent", function(_, event, eventArgument)
    if event == "CRAFT_CLOSE" then
        beastTrainingOpen = false
        return
    end
    if not IsPetTrackingEnabled() then return end
    if event == "CRAFT_SHOW" then
        beastTrainingOpen = true
    end
    if event == "UNIT_PET" and eventArgument ~= "player" then return end
    if (event == "UNIT_LEVEL" or event == "UNIT_PET_TRAINING_POINTS") and eventArgument ~= "pet" then return end
    local store = EnsurePetTrainingStore()
    if event == "LEARNED_SPELL_IN_SKILL_LINE" and petSpellByTeachingID[eventArgument] and store then
        RecordTeachingRank(store, eventArgument)
    end
    if event == "UNIT_PET" or event == "PET_BAR_UPDATE" or event == "UNIT_LEVEL"
        or event == "UNIT_PET_TRAINING_POINTS" or event == "PET_STABLE_UPDATE" then
        local pet = store and UpdateCurrentPetRecord(store)
        if pet then
            pet.availability = {}
        end
    end
    QueuePetTrainingRefresh()
end)
