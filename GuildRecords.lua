local _, ns = ...
local records = { ready = false }
ns.GuildRecords = records
local authority, authorityGuild = {}, nil
local MAX_DELETIONS = 4096

function records.Identity()
    if not IsInGuild or not IsInGuild() or not GetGuildInfo then return end
    local name, _, _, realm = GetGuildInfo("player")
    if type(name) == "string" and name ~= "" then return (realm or GetRealmName()) .. ":" .. name end
end

function records.Enabled()
    return ns.db and ns.db.enabled ~= false and ns.db.guildTimeSync ~= false
        and C_ChatInfo and C_ChatInfo.SendAddonMessage and records.Identity() ~= nil
end

function records.Cap(flavor)
    return flavor == "forever" and 60 or math.min(1000,
        ns.GetCurrentFlavor() == "retail" and ns.GetLevelCap() or 90)
end

function records.ValidInterval(level, seconds, flavor)
    return type(level) == "number" and level % 1 == 0 and level >= 1 and level < records.Cap(flavor)
        and type(seconds) == "number" and seconds == seconds and seconds >= 1 and seconds <= 365 * 86400
end

function records.ValidOwner(owner)
    return type(owner) == "string" and #owner <= 128 and owner:find("%S") and not owner:find("[%c|=,]")
end

function records.ValidGUID(guid)
    return type(guid) == "string" and #guid <= 48 and guid:match("^Player%-%x+%-%x+$") ~= nil
end

function records.OwnName()
    local name, realm = UnitName("player")
    return name .. "-" .. (realm and realm ~= "" and realm or GetRealmName()):gsub("%s", "")
end

local function CanonicalName(name)
    if not name:find("-", 1, true) then name = name .. "-" .. GetRealmName() end
    return name:gsub("%s", ""):lower()
end

function records.RefreshAuthority()
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
                local entry = { officer = officer == true, guid = guid }
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
    local entry = { officer = rank == 0 or ok and allowed == true
        or not check and previous and previous.officer == true, guid = guid }
    authority[CanonicalName(records.OwnName())] = entry
    if records.ValidGUID(guid) then authority[guid] = entry end
end

function records.Authority(name)
    if authorityGuild ~= records.Identity() then records.RefreshAuthority() end
    if not records.ValidOwner(name) then return end
    local entry = authority[name] or authority[CanonicalName(name)]
    return entry and entry.officer, entry and entry.guid
end

function ns.CanDeleteGuildRecords()
    if not records.ready or not records.Enabled() then return false end
    local allowed, guid = records.Authority(records.OwnName())
    return allowed == true and records.ValidGUID(guid)
end

function records.Store(create)
    if not records.ready then return end
    local key = records.Identity()
    if type(GnomeLevelUpCharacterDB) ~= "table" then
        if not create then return end
        GnomeLevelUpCharacterDB = {}
    end
    local db = GnomeLevelUpCharacterDB
    if IsInGuild and not IsInGuild() then db.guildLevelTimes = nil; return end
    if not key then return end -- Guild name may arrive after login.
    local store = db.guildLevelTimes
    if type(store) ~= "table" or store.guild ~= key then
        db.guildLevelTimes = nil
        if not create then return end
        store = { guild = key }; db.guildLevelTimes = store
    end
    return store
end

local function Flavor(flavor, create)
    if not ns.db or ns.db.guildTimeSync == false or (flavor ~= "forever" and flavor ~= "retail") then return end
    local store = records.Store(create)
    if not store then return end
    if type(store[flavor]) ~= "table" and create then store[flavor] = {} end
    return store[flavor], store
end

local function DeletionKey(seconds, owner) return tostring(math.floor(seconds)) .. "=" .. owner end

function records.Deletions(level, flavor)
    local _, store = Flavor(flavor, false)
    local deleted = store and store.deleted
    local mode = type(deleted) == "table" and deleted[flavor]
    return type(mode) == "table" and type(mode[level]) == "table" and mode[level] or nil
end

function records.IsDeleted(level, seconds, owner, flavor)
    local deleted = records.Deletions(level, flavor)
    return deleted and deleted[DeletionKey(seconds, owner)] ~= nil
end

function ns.GetGuildLevelRecord(level, flavor)
    local mode = Flavor(flavor, false)
    local record = type(mode) == "table" and mode[level]
    if type(record) == "table" and records.ValidInterval(level, record.seconds, flavor)
        and records.ValidOwner(record.owner) and not records.IsDeleted(level, record.seconds, record.owner, flavor) then return record end
end

function records.Save(level, seconds, owner, flavor, source)
    if not records.ValidInterval(level, seconds, flavor) or not records.ValidOwner(owner)
        or records.IsDeleted(level, seconds, owner, flavor) then return false end
    local mode = Flavor(flavor, true)
    if not mode then return false end
    local previous = ns.GetGuildLevelRecord(level, flavor)
    if not previous or seconds < previous.seconds or seconds == previous.seconds and owner < previous.owner then
        local clock = GetServerTime or time
        mode[level] = { seconds = seconds, owner = owner, receivedFrom = source or records.OwnName(),
            receivedAt = clock and clock() or 0 }
        return true
    end
    return false
end

function records.Best(level, flavor)
    local history = type(GnomeLevelUpCharacterDB) == "table" and GnomeLevelUpCharacterDB.levelBests
    local bests = type(history) == "table" and history[flavor]
    local seconds = type(bests) == "table" and bests[level]
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
    if type(previous) == "table" and previous.seconds == seconds and previous.owner == owner then mode[level] = nil end
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
    local first, second = 1, 0
    local text = table.concat(entries, "\n")
    for index = 1, #text do first = (first + text:byte(index)) % 65521; second = (second + first) % 65521 end
    return string.format("%x", second * 65536 + first)
end
