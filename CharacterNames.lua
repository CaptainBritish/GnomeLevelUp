local _, ns = ...
local playerNameCache

function ns.InvalidateCharacterNames() playerNameCache = nil end

local function Forever() return ns.GetCurrentFlavor and ns.GetCurrentFlavor() == "forever" end
local function RealmKey(name) return name:gsub("[%s%-']", ""):lower() end

local function WithoutRealm(name)
    local base, suffix = name:match("^(.+)%-([^%-]+)$")
    if not suffix then return name end
    local realm = GetRealmName and GetRealmName() or ""
    local normalized = GetNormalizedRealmName and GetNormalizedRealmName() or realm
    local key = RealmKey(suffix)
    if key == RealmKey(realm) or key == RealmKey(normalized)
        or key:match("^camwow%a+%d+realm%d+%a+$") then return base end
    return name
end

function ns.FormatCharacterName(name, realm, includeRealm)
    if type(name) ~= "string" then return "" end
    if Forever() then
        name = name:match("^(.-) %- ") or name
        return (WithoutRealm(name):gsub("%-", " "):gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", ""))
    end
    local character, suffix = name:match("^(.-) %- (.+)$")
    if not character then character, suffix = name:match("^([^%-]+)%-(.+)$") end
    character, realm = character or name, realm or suffix
    return includeRealm and realm and realm ~= "" and character .. " - " .. realm or character
end

function ns.CanonicalCharacterName(name)
    if Forever() then return ns.FormatCharacterName(name):gsub("%s+", "-"):lower() end
    if not name:find("-", 1, true) then name = name .. "-" .. (GetRealmName and GetRealmName() or "") end
    return name:gsub("%s", ""):lower()
end

function ns.GetPlayerCharacterNames()
    local first, realm = "Player", nil
    if UnitName then first, realm = UnitName("player"); first = first or "Player" end
    local guid = UnitGUID and UnitGUID("player")
    local mode = ns.GetCurrentFlavor and ns.GetCurrentFlavor()
    local clientRealm = GetRealmName and GetRealmName() or ""
    local cached = playerNameCache
    if cached and cached.guid == guid and cached.first == first and cached.second == realm
        and cached.mode == mode and cached.clientRealm == clientRealm then return cached.wire, cached.display, cached.realm end
    local apiFirst, apiSecond = first, realm
    local function Remember(wire, display, homeRealm)
        playerNameCache = { guid = guid, first = apiFirst, second = apiSecond, mode = mode,
            clientRealm = clientRealm, wire = wire, display = display, realm = homeRealm }
        return wire, display, homeRealm
    end
    if Forever() then
        if guid and GetNumGuildMembers and GetGuildRosterInfo then
            for index = 1, math.min(1000, GetNumGuildMembers() or 0) do
                local member = { GetGuildRosterInfo(index) }
                if member[17] == guid and type(member[1]) == "string" and member[1] ~= "" then
                    local wire = WithoutRealm(member[1])
                    GnomeLevelUpCharacterDB = type(GnomeLevelUpCharacterDB) == "table" and GnomeLevelUpCharacterDB or {}
                    GnomeLevelUpCharacterDB.historyFullName = { guid = guid, name = wire }
                    return Remember(wire, ns.FormatCharacterName(wire), clientRealm)
                end
            end
        end
        local saved = type(GnomeLevelUpCharacterDB) == "table" and GnomeLevelUpCharacterDB.historyFullName
        if type(saved) == "table" and saved.guid == guid and type(saved.name) == "string" then
            return Remember(saved.name, ns.FormatCharacterName(saved.name), clientRealm)
        end
        local wire = first
        if type(realm) == "string" and realm ~= "" and RealmKey(realm) ~= RealmKey(GetRealmName and GetRealmName() or "")
            and not RealmKey(realm):match("^camwow") then wire = first .. "-" .. realm end
        return Remember(wire, ns.FormatCharacterName(wire), clientRealm)
    end
    if UnitFullName then
        local full, fullRealm = UnitFullName("player")
        first, realm = full or first, fullRealm or realm
    end
    realm = realm and realm ~= "" and realm or (GetRealmName and GetRealmName() or "")
    return Remember(first .. "-" .. realm:gsub("%s", ""), first, realm)
end
