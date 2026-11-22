local ADDON_NAME, ns = ...

-- Teaching knowledge belongs to the Hunter; trained spells and point costs
-- belong to a particular pet. Never infer the former from a tamed pet's book.
local MAX_PETS, MAX_SKILLS = 12, 512
local definitions, teachingIDs, craftOpen = {}, {}, false
local TrimPets
-- NPC-taught Beast Training spell IDs, matched to GLU's pet-effect families.
-- Teaching and pet-effect IDs are distinct in Forever build 1.60.1.70959.
local teachingRanks = {
    [24493] = {24495,24508,24509,24510},
    [23992] = {24440,24441,24463,24464},
    [24446] = {24475,24476,24477,24478},
    [4187] = {4195,4196,4197,4198,4199,4200,4201,4202,5048,5049},
    [2649] = {1853,14922,14923,14924,14925,14926,14927},
    [24545] = {24547,24556,24557,24558,24559,24560,24561,24562,24631,24632},
    [24492] = {24494,24511,24512,24513},
    [24488] = {24490,24514,24515,24516},
}
-- Capture before other classes' catalogues are released at login.
for _, entries in pairs(ns.ClassTrainingForever and ns.ClassTrainingForever.HUNTER or {}) do
    for _, entry in ipairs(entries) do
        if entry.hunterPet then
            definitions[entry.spellID] = {family = entry.familyID, rank = entry.rank}
            local ranks = teachingRanks[entry.familyID]
            if ranks and ranks[entry.rank] then teachingIDs[ranks[entry.rank]] = entry.spellID end
        end
    end
end

local function Read(fn, ...)
    if type(fn) ~= "function" then return end
    local ok, a, b, c = pcall(fn, ...)
    if ok then return a, b, c end
end

local function Secret(value)
    return type(issecretvalue) == "function" and issecretvalue(value)
end

local function Active()
    local _, class = Read(UnitClass, "player")
    return class == "HUNTER" and ns.db and ns.db.enabled ~= false
        and ns.GetCurrentFlavor() == "forever"
end

local function Store()
    if not Active() or type(GnomeLevelUpCharacterDB) ~= "table" then return end
    local store = GnomeLevelUpCharacterDB.hunterPetTraining
    if type(store) ~= "table" or store.schemaVersion ~= 1 then
        store = {schemaVersion = 1, teaching = {}, pets = {}, trainerOffers = {}, sequence = 0}
        GnomeLevelUpCharacterDB.hunterPetTraining = store
    end
    TrimPets(store, MAX_PETS)
    return store
end

local function Now()
    return Read(GetServerTime) or Read(time)
end

TrimPets = function(store, limit)
    local count = 0
    for _ in pairs(store.pets) do count = count + 1 end
    while count > limit do
        local oldest, sequence
        for key, pet in pairs(store.pets) do
            local seen = tonumber(pet.sequence) or 0
            if not oldest or seen < sequence or (seen == sequence and key < oldest) then oldest, sequence = key, seen end
        end
        store.pets[oldest] = nil
        count = count - 1
    end
end

local function CurrentPet(store)
    local guid = Read(UnitGUID, "pet")
    -- Never merge same-name pets or guess an identity when the client hides it.
    if Secret(guid) or type(guid) ~= "string" or not guid:match("^Pet%-") then return end
    local pet = store.pets[guid]
    if not pet then
        TrimPets(store, MAX_PETS - 1)
        pet = {spells = {}, availability = {}, trainerOffers = {}}
        store.pets[guid] = pet
    end
    store.sequence = (tonumber(store.sequence) or 0) + 1
    pet.sequence, pet.lastSeen = store.sequence, Now()
    local level, family = Read(UnitLevel, "pet"), Read(UnitCreatureFamily, "pet")
    if pet.level ~= level or pet.family ~= family then pet.availability = {} end
    pet.level, pet.family, pet.name = level, family, Read(UnitName, "pet")
    TrimPets(store, MAX_PETS)
    return pet, guid
end

local function BoundedSet(target, key, value)
    if not key then return end
    if target[key] == nil then
        local count = 0
        for _ in pairs(target) do count = count + 1 end
        if count >= MAX_SKILLS then return end
    end
    target[key] = value
end

local function SpellName(id)
    local name = Read(C_Spell and C_Spell.GetSpellName, id) or Read(GetSpellInfo, id)
    if not name then
        local info = Read(C_Spell and C_Spell.GetSpellInfo, id)
        if type(info) == "table" then name = info.name end
    end
    return type(name) == "string" and not Secret(name) and name or nil
end

local function MatchSpell(name, rank)
    -- Match names in the client's language, using IDs to establish each rank.
    for id, definition in pairs(definitions) do
        if definition.rank == rank and SpellName(id) == name then return id end
    end
end

local function Teach(store, id)
    id = teachingIDs[id] or id
    BoundedSet(store.teaching, id, true)
end

function ns.IsHunterPetTeachingSpell(id)
    return teachingIDs[id] ~= nil
end

function ns.IsHunterPetTeachingKnown(id)
    local store = Store()
    return store and store.teaching[id] == true or false
end

function ns.GetHunterPetTrainerCost(id, fallback)
    local store = Store()
    local offer = store and store.trainerOffers[id]
    return offer and offer.goldCost or fallback
end

function ns.RecordHunterPetTrainerObservation(observation)
    local store = Store()
    local source = observation.source
    -- Only a positively identified NPC pet trainer supplies gold fees or
    -- confirms that the Hunter has purchased a teaching rank.
    if not store or type(source) ~= "table" or not source.petTrainer or not source.npcPresent then return end
    local id = teachingIDs[observation.spellID] or observation.spellID
    local offer = {goldCost = observation.cost, offeredLevel = observation.level,
        lastSeen = Now(), npcGUID = source.npcGUID}
    BoundedSet(store.trainerOffers, id, offer)
    local pet = CurrentPet(store)
    if pet then BoundedSet(pet.trainerOffers, id, offer) end
    if observation.status == "used" then Teach(store, id) end
    if ns.InvalidateTrainerIndex then ns.InvalidateTrainerIndex() end
end

local function ScanKnownTeaching()
    local store = Store()
    if not store or type(IsPlayerSpell) ~= "function" then return end
    local hits, count = {}, 0
    for teachingID, petID in pairs(teachingIDs) do
        count = count + 1
        local known = Read(IsPlayerSpell, teachingID)
        if not Secret(known) and known == true then hits[#hits + 1] = petID end
    end
    -- Some builds answer yes for essentially every teaching spell. Reject
    -- that unreliable result and wait for Beast Training.
    if count == 0 or #hits > count * 0.9 then return end
    for _, id in ipairs(hits) do Teach(store, id) end
end

local function ScanPet()
    local store = Store()
    if not store then return end
    TrimPets(store, MAX_PETS)
    local pet, guid = CurrentPet(store)
    if not pet or not ns.SnapshotPetSpellBook then return end
    local book = ns.SnapshotPetSpellBook(true)
    if Read(UnitGUID, "pet") ~= guid then return end
    if book and next(book.ids or {}) then
        local spells = {}
        for id in pairs(book.ids) do BoundedSet(spells, id, true) end
        pet.spells, pet.spellsSeen = spells, Now()
    end
end

local function IsBeastTraining()
    if not craftOpen then return false end
    local line = Read(GetCraftDisplaySkillLine)
    return type(line) == "string" and (line == "Beast Training" or line == BEAST_TRAINING or line == SpellName(5149))
end

local function ScanTeaching()
    local store = Store()
    if not store or not IsBeastTraining() then return end
    local count = Read(GetNumCrafts)
    if type(count) ~= "number" then return end
    local pet, guid = CurrentPet(store)
    for index = 1, math.min(count, MAX_SKILLS) do
        local name, subtext, status = Read(GetCraftInfo, index)
        if type(name) == "string" and name ~= "" and status ~= "header" then
            local rank = type(subtext) == "string" and tonumber(subtext:match("(%d+)")) or 1
            local id = MatchSpell(name, rank or 1)
            -- Unknown/wild ranks are kept separately without adding new popup
            -- entries. Missing rows never remove teaching knowledge.
            local key = id or (name .. ":" .. tostring(rank or 1))
            Teach(store, key)
            if pet and Read(UnitGUID, "pet") == guid then
                BoundedSet(pet.availability, key, {status = status,
                    trainingPoints = Read(GetCraftTrainingPoints, index), lastSeen = Now()})
            end
        end
    end
    store.teachingSeen = Now()
    if ns.InvalidateTrainerIndex then ns.InvalidateTrainerIndex() end
end

local queued
local function RefreshSoon()
    if queued then return end
    queued = true
    local function Refresh()
        queued = false
        ScanKnownTeaching()
        ScanPet()
        ScanTeaching()
    end
    if C_Timer and C_Timer.After then C_Timer.After(0.2, Refresh) else Refresh() end
end

local frame = CreateFrame("Frame")
ns.hunterPetEventFrame = frame
for _, event in ipairs({"PLAYER_LOGIN", "PLAYER_ENTERING_WORLD", "UNIT_PET", "UNIT_LEVEL", "UNIT_PET_TRAINING_POINTS",
    "PET_BAR_UPDATE", "PET_STABLE_UPDATE", "SPELLS_CHANGED", "LEARNED_SPELL_IN_SKILL_LINE",
    "CRAFT_SHOW", "CRAFT_UPDATE", "CRAFT_CLOSE"}) do
    pcall(frame.RegisterEvent, frame, event)
end
frame:SetScript("OnEvent", function(_, event, unit)
    if event == "CRAFT_CLOSE" then craftOpen = false; return end
    if not Active() then return end
    if event == "CRAFT_SHOW" then craftOpen = true end
    if event == "UNIT_PET" and unit ~= "player" then return end
    if (event == "UNIT_LEVEL" or event == "UNIT_PET_TRAINING_POINTS") and unit ~= "pet" then return end
    local store = Store()
    if event == "LEARNED_SPELL_IN_SKILL_LINE" and teachingIDs[unit] and store then Teach(store, unit) end
    if event == "UNIT_PET" or event == "PET_BAR_UPDATE" or event == "UNIT_LEVEL"
        or event == "UNIT_PET_TRAINING_POINTS" or event == "PET_STABLE_UPDATE" then
        local pet = store and CurrentPet(store)
        if pet then pet.availability = {} end
    end
    RefreshSoon()
end)
