local _, ns = ...
local records = { ready = false }
ns.GuildRecords = records
local authority, authorityGuild = {}, nil
local MAX_DELETIONS = 4096

local function GuildKey(realm, name)
    realm = realm:gsub("[%s%-']", ""):lower()
    if ns.GetCurrentFlavor() == "forever" then realm = realm:gsub("%d+realm", "realm"):gsub("realm%d+", "realm") end
    return realm .. ":" .. name
end

local function NormalizedGuildKey(key)
    if type(key) ~= "string" then return end
    local realm, name = key:match("^(.-):(.*)$")
    if realm then return GuildKey(realm, name) end
end

function records.Identity()
    if not IsInGuild or not IsInGuild() or not GetGuildInfo then return end
    local name, _, _, realm = GetGuildInfo("player")
    if type(name) == "string" and name ~= "" then return GuildKey(realm or GetRealmName(), name) end
end

function records.Enabled()
    return ns.db and ns.db.enabled ~= false and ns.db.guildTimeSync ~= false
        and C_ChatInfo and C_ChatInfo.SendAddonMessage and records.Identity() ~= nil
end

function records.Cap(flavor)
    return flavor == "forever" and 60 or math.min(1000,
        ns.GetCurrentFlavor() == "retail" and ns.GetLevelCap() or 90)
end

-- The cap itself is reserved for the complete 1-to-cap run, never its last interval.
function records.ValidInterval(level, seconds, flavor)
    return type(level) == "number" and level % 1 == 0 and level >= 1 and level <= records.Cap(flavor)
        and type(seconds) == "number" and seconds == seconds and seconds >= 1
        and seconds <= (level == records.Cap(flavor) and ns.MAX_FULL_RUN_SECONDS or 365 * 86400)
end

function records.ValidOwner(owner)
    return type(owner) == "string" and #owner <= 128 and owner:find("%S") and not owner:find("[%c|=,]")
end

function records.ValidGUID(guid)
    return type(guid) == "string" and #guid <= 48 and guid:match("^Player%-%x+%-%x+$") ~= nil
end

function records.ValidClass(token)
    return type(token) == "string" and ns.CLASS_COLORS and ns.CLASS_COLORS[token] ~= nil
end

function records.OwnName()
    local wire = ns.GetPlayerCharacterNames()
    return wire
end

local function CanonicalName(name)
    return ns.CanonicalCharacterName(name)
end

function records.RefreshAuthority()
    if ns.InvalidateCharacterNames then ns.InvalidateCharacterNames() end
    authority, authorityGuild = {}, records.Identity()
    if not authorityGuild then return end
    local flags = C_GuildInfo and C_GuildInfo.GuildControlGetRankFlags
    if GetNumGuildMembers and GetGuildRosterInfo then
        for index = 1, math.min(1000, GetNumGuildMembers() or 0) do
            local member = { GetGuildRosterInfo(index) }
            local name, rank, guid = member[1], member[3], member[17]
            if records.ValidOwner(name) and type(rank) == "number" then
                local officer = rank == 0
                if not officer and flags then
                    local ok, permissions = pcall(flags, rank + 1)
                    -- Guild control flag 7: edit officer notes. No assumptions
                    -- about localized rank names or the number of officer ranks.
                    officer = ok and type(permissions) == "table" and permissions[7] == true
                end
                local entry = { officer = officer == true, guid = guid,
                    classToken = records.ValidClass(member[11]) and member[11] or nil }
                authority[CanonicalName(name)] = entry
                if records.ValidGUID(guid) then authority[guid] = entry end
            end
        end
    end
    local _, _, rank = GetGuildInfo("player")
    local check = C_GuildInfo and C_GuildInfo.CanEditOfficerNote or CanEditOfficerNote
    local ok, allowed = false, false
    if check then ok, allowed = pcall(check) end
    local guid = UnitGUID and UnitGUID("player")
    local previous = authority[CanonicalName(records.OwnName())]
    local _, classToken = UnitClass("player")
    local entry = { officer = rank == 0 or ok and allowed == true
        or not check and previous and previous.officer == true, guid = guid,
        classToken = records.ValidClass(classToken) and classToken or nil }
    authority[CanonicalName(records.OwnName())] = entry
    if records.ValidGUID(guid) then authority[guid] = entry end
end

function records.Authority(name)
    if authorityGuild ~= records.Identity() then records.RefreshAuthority() end
    if not records.ValidOwner(name) then return end
    local entry = authority[name] or authority[CanonicalName(name)]
    return entry and entry.officer, entry and entry.guid
end

function records.ResolveClass(owner, fallback)
    if authorityGuild ~= records.Identity() then records.RefreshAuthority() end
    local member = authority[CanonicalName(owner)]
    if member and records.ValidClass(member.classToken) then return member.classToken end
    local store = records.Store and records.Store(false)
    local saved = store and type(store.classes) == "table" and store.classes[CanonicalName(owner)]
    if records.ValidClass(saved) then return saved end
    if records.ValidClass(fallback) then return fallback end
end

function ns.CanDeleteGuildRecords()
    if not records.ready or not records.Enabled() then return false end
    local allowed, guid = records.Authority(records.OwnName())
    return allowed == true and records.ValidGUID(guid)
end

local function RemovedIn(store, mode, level, value)
    local deleted = type(store.deleted) == "table" and store.deleted[mode]
    local markers = type(deleted) == "table" and deleted[level]
    if type(markers) ~= "table" then return false end
    for _, marker in pairs(markers) do
        if type(marker) == "table" and marker.seconds == value.seconds and records.ValidOwner(marker.owner)
            and CanonicalName(marker.owner) == CanonicalName(value.owner) then return true end
    end
    return false
end

local function MergeArchive(target, source)
    if target == source or type(source) ~= "table" then return end
    target.deleted = type(target.deleted) == "table" and target.deleted or {}
    target.classes = type(target.classes) == "table" and target.classes or {}
    local markerCount = 0
    for _, mode in ipairs({ "forever", "retail" }) do
        for _, entries in pairs(type(target.deleted[mode]) == "table" and target.deleted[mode] or {}) do
            if type(entries) == "table" then for _ in pairs(entries) do markerCount = markerCount + 1 end end
        end
    end
    for _, mode in ipairs({ "forever", "retail" }) do
        target[mode] = type(target[mode]) == "table" and target[mode] or {}
        target.deleted[mode] = type(target.deleted[mode]) == "table" and target.deleted[mode] or {}
        local deleted = type(source.deleted) == "table" and source.deleted[mode]
        for level, entries in pairs(type(deleted) == "table" and deleted or {}) do
            if type(entries) == "table" then for key, marker in pairs(entries) do
                if markerCount < MAX_DELETIONS and type(marker) == "table"
                    and records.ValidInterval(level, marker.seconds, mode) and records.ValidOwner(marker.owner)
                    and records.ValidGUID(marker.issuer) then
                    local destination = target.deleted[mode][level] or {}
                    target.deleted[mode][level] = destination
                    if not destination[key] then destination[key] = ns.CopyValue(marker); markerCount = markerCount + 1 end
                end
            end end
        end
        for level, value in pairs(type(source[mode]) == "table" and source[mode] or {}) do
            if type(value) == "table" and records.ValidInterval(level, value.seconds, mode) and records.ValidOwner(value.owner)
                and not RemovedIn(target, mode, level, value) then
                local previous = target[mode][level]
                if type(previous) ~= "table" or not records.ValidInterval(level, previous.seconds, mode)
                    or value.seconds < previous.seconds or value.seconds == previous.seconds and value.owner < previous.owner then
                    target[mode][level] = ns.CopyValue(value)
                elseif previous.seconds == value.seconds and previous.owner == value.owner
                    and not records.ValidClass(previous.classToken) and records.ValidClass(value.classToken) then previous.classToken = value.classToken end
            end
        end
        for level, value in pairs(target[mode]) do
            if type(value) == "table" and records.ValidOwner(value.owner) and RemovedIn(target, mode, level, value) then target[mode][level] = nil end
        end
    end
    local classCount = 0; for _ in pairs(target.classes) do classCount = classCount + 1 end
    for owner, token in pairs(type(source.classes) == "table" and source.classes or {}) do
        if type(owner) == "string" and records.ValidClass(token) and (target.classes[owner] or classCount < 4096) then
            if not target.classes[owner] then classCount = classCount + 1 end
            target.classes[owner] = token
        end
    end
end

function records.Store(create)
    if not records.ready then return end
    local key = records.Identity()
    if type(GnomeLevelUpCharacterDB) ~= "table" then
        if not create then return end
        GnomeLevelUpCharacterDB = {}
    end
    local db = GnomeLevelUpCharacterDB
    GnomeLevelUpHistoryDB = type(GnomeLevelUpHistoryDB) == "table" and GnomeLevelUpHistoryDB or {}
    local account = GnomeLevelUpHistoryDB
    account.guildRecords = type(account.guildRecords) == "table" and account.guildRecords or {}
    account.guildCharacters = type(account.guildCharacters) == "table" and account.guildCharacters or {}
    local character = UnitGUID and UnitGUID("player") or records.OwnName()
    local previous = account.guildCharacters[character]
    local left = IsInGuild and not IsInGuild()
    if previous and (left or key and previous ~= key) then
        account.guildCharacters[character] = nil
        local used = false
        for _, other in pairs(account.guildCharacters) do if other == previous then used = true; break end end
        if not used then account.guildRecords[previous] = nil end
        db.guildLevelTimes = nil
    end
    if left then db.guildLevelTimes = nil; return end
    if not key then return end -- Guild name may arrive after login.
    account.guildCharacters[character] = key
    local store = db.guildLevelTimes
    if type(store) ~= "table" or NormalizedGuildKey(store.guild) ~= key then store = nil; db.guildLevelTimes = nil end
    local shared = account.guildRecords[key]
    if type(shared) ~= "table" then
        if not store and not create then return end
        shared = { guild = key }; account.guildRecords[key] = shared
    end
    if store and store ~= shared then MergeArchive(shared, store) end
    db.guildLevelTimes = shared
    return shared
end

local function Flavor(flavor, create)
    if not ns.db or ns.db.guildTimeSync == false or (flavor ~= "forever" and flavor ~= "retail") then return end
    local store = records.Store(create)
    if not store then return end
    if type(store[flavor]) ~= "table" and create then store[flavor] = {} end
    return store[flavor], store
end

local function DeletionKey(seconds, owner) return tostring(math.floor(seconds)) .. "=" .. CanonicalName(owner) end

function records.Deletions(level, flavor)
    local _, store = Flavor(flavor, false)
    local deleted = store and store.deleted
    local mode = type(deleted) == "table" and deleted[flavor]
    return type(mode) == "table" and type(mode[level]) == "table" and mode[level] or nil
end

function records.IsDeleted(level, seconds, owner, flavor)
    local deleted = records.Deletions(level, flavor)
    if not deleted then return false end
    if deleted[DeletionKey(seconds, owner)] then return true end
    -- Older caches used the raw wire spelling. Forever sends surnames with
    -- either spaces or hyphens, which must identify the same removed record.
    for _, marker in pairs(deleted) do
        if type(marker) == "table" and marker.seconds == seconds and records.ValidOwner(marker.owner)
            and CanonicalName(marker.owner) == CanonicalName(owner) then return true end
    end
    return false
end

function ns.GetGuildLevelRecord(level, flavor)
    local mode = Flavor(flavor, false)
    local record = type(mode) == "table" and mode[level]
    if type(record) == "table" and records.ValidInterval(level, record.seconds, flavor)
        and records.ValidOwner(record.owner) and not records.IsDeleted(level, record.seconds, record.owner, flavor) then
        record.classToken = records.ResolveClass(record.owner, record.classToken)
        return record
    end
end

-- Browsing another character must not switch the live guild's store or roster.
function records.CharacterRecord(character, level, flavor)
    if not ns.db or ns.db.guildTimeSync == false then return end
    local account = GnomeLevelUpHistoryDB
    local key = type(account) == "table" and type(account.guildCharacters) == "table" and account.guildCharacters[character]
    local archive = key and type(account.guildRecords) == "table" and account.guildRecords[key]
    local mode = type(archive) == "table" and archive[flavor]
    local record = type(mode) == "table" and mode[level]
    if type(record) ~= "table" or not records.ValidInterval(level, record.seconds, flavor)
        or not records.ValidOwner(record.owner) or RemovedIn(archive, flavor, level, record) then return end
    local copy = ns.CopyValue(record)
    local class = type(archive.classes) == "table" and archive.classes[CanonicalName(record.owner)]
    if records.ValidClass(class) then copy.classToken = class end
    return copy, key
end

function records.RecordClass(level, owner, flavor)
    local record = ns.GetGuildLevelRecord(level, flavor)
    return records.ResolveClass(owner, record and record.owner == owner and record.classToken or nil)
end

function records.UpdateClass(owner, classToken, flavor)
    if not records.ValidOwner(owner) or not records.ValidClass(classToken) then return false end
    local mode, store = Flavor(flavor, true)
    if type(mode) ~= "table" then return false end
    local member = authority[CanonicalName(owner)]
    if member and records.ValidClass(member.classToken) then classToken = member.classToken end
    store.classes = type(store.classes) == "table" and store.classes or {}
    local key = CanonicalName(owner)
    local changed = store.classes[key] ~= classToken
    if store.classes[key] == nil then
        local count = 0; for _ in pairs(store.classes) do count = count + 1 end
        if count >= 4096 then store.classes = {} end
    end
    store.classes[key] = classToken
    for level = 1, records.Cap(flavor) do
        local record = mode[level]
        if type(record) == "table" and record.owner == owner and record.classToken ~= classToken then
            record.classToken, changed = classToken, true
        end
    end
    return changed
end

function records.Save(level, seconds, owner, flavor, source)
    if not records.ValidInterval(level, seconds, flavor) or not records.ValidOwner(owner)
        or records.IsDeleted(level, seconds, owner, flavor) then return false end
    local mode = Flavor(flavor, true)
    if not mode then return false end
    local previous = ns.GetGuildLevelRecord(level, flavor)
    local classToken = records.ResolveClass(owner, previous and previous.owner == owner and previous.classToken or nil)
    if not previous or seconds < previous.seconds or seconds == previous.seconds and owner < previous.owner then
        local clock = GetServerTime or time
        mode[level] = { seconds = seconds, owner = owner, receivedFrom = source or records.OwnName(),
            receivedAt = clock and clock() or 0, classToken = classToken }
        return true
    end
    return false
end

function records.Best(level, flavor)
    local history = type(GnomeLevelUpCharacterDB) == "table" and GnomeLevelUpCharacterDB.levelBests
    local bests = type(history) == "table" and history[flavor]
    local seconds = type(bests) == "table" and bests[level]
    if level == records.Cap(flavor) then
        local totals = type(GnomeLevelUpCharacterDB) == "table" and GnomeLevelUpCharacterDB.maxLevelTimes
        totals = type(totals) == "table" and totals[flavor]
        seconds = type(totals) == "table" and totals[level]
    end
    local owner = records.OwnName()
    if not records.ValidInterval(level, seconds, flavor) then seconds = nil end
    if seconds then seconds = math.floor(seconds) end
    if seconds and records.IsDeleted(level, seconds, owner, flavor) then seconds = nil end
    local cached = ns.GetGuildLevelRecord(level, flavor)
    if cached and (not seconds or cached.seconds < seconds or cached.seconds == seconds and cached.owner < owner) then
        seconds, owner = cached.seconds, cached.owner
    end
    return seconds, owner
end

function records.AddDeletion(level, seconds, owner, issuer, flavor)
    if not records.ValidInterval(level, seconds, flavor) or not records.ValidOwner(owner)
        or not records.ValidGUID(issuer) then return false end
    if records.IsDeleted(level, seconds, owner, flavor) then return false end
    local allowed = records.Authority(issuer)
    if allowed ~= true then return false end
    local mode, store = Flavor(flavor, true)
    if not mode then return false end
    local count = 0
    for _, levels in pairs(store.deleted or {}) do
        for _, entries in pairs(levels) do for _ in pairs(entries) do count = count + 1 end end
    end
    if count >= MAX_DELETIONS then return false end
    store.deleted = store.deleted or {}
    store.deleted[flavor] = store.deleted[flavor] or {}
    local levels = store.deleted[flavor]
    levels[level] = levels[level] or {}
    levels[level][DeletionKey(seconds, owner)] = { seconds = seconds, owner = owner, issuer = issuer }
    local previous = mode[level]
    if type(previous) == "table" and previous.seconds == seconds and records.ValidOwner(previous.owner)
        and CanonicalName(previous.owner) == CanonicalName(owner) then mode[level] = nil end
    return true
end

function records.Entries(level, flavor)
    local entries = {}
    for _, marker in pairs(records.Deletions(level, flavor) or {}) do
        if type(marker) == "table" and records.ValidInterval(level, marker.seconds, flavor)
            and records.ValidOwner(marker.owner) and records.ValidGUID(marker.issuer) then
            entries[#entries + 1] = "x:" .. level .. "=" .. marker.seconds .. "=" .. marker.owner .. "=" .. marker.issuer
        end
    end
    table.sort(entries)
    local seconds, owner = records.Best(level, flavor)
    if seconds then entries[#entries + 1] = "r:" .. level .. "=" .. seconds .. "=" .. owner end
    return entries
end

function records.Fingerprint(level, flavor)
    local entries = records.Entries(level, flavor)
    if #entries == 0 then return "0" end
    -- The removal itself is the shared state; later officer endorsements do
    -- not make equivalent archives appear different.
    for index, entry in ipairs(entries) do
        if entry:sub(1, 2) == "x:" then entries[index] = entry:gsub("=Player%-%x+%-%x+$", "") end
    end
    local seconds, owner = records.Best(level, flavor)
    local classToken = seconds and records.RecordClass(level, owner, flavor)
    if classToken then entries[#entries + 1] = "class:" .. classToken end
    local first, second = 1, 0
    local text = table.concat(entries, "\n")
    for index = 1, #text do first = (first + text:byte(index)) % 65521; second = (second + first) % 65521 end
    return string.format("%x", second * 65536 + first)
end
