local ADDON_NAME, ns = ...

-- Options are copied into the existing DB so trainer data and references held
-- by other modules stay intact. Profiles never contain reports or scan caches.
local store, character, activeName
local keys, allowed = {}, {}
for _, key in ipairs(ns.RESETTABLE_SETTING_KEYS) do
    keys[#keys + 1], allowed[key] = key, true
end
for _, key in ipairs({ "language", "colors", "classColorBackup", "classColorOverrides" }) do
    keys[#keys + 1], allowed[key] = key, true
end
local optional = {
    customFontPath = "", customSoundFile = "", customSoundChoice = "",
    portraitRingTexture = "", backgroundTheme = "", backgroundChoice = "", frameChoice = "",
}

local function NormalizeSettings(settings)
    -- Older themes serialized an unset optional path as false. Keep accepting
    -- those exports, but store and export the ordinary nil representation.
    for key in pairs(optional) do
        if settings[key] == false then settings[key] = nil end
    end
    -- Old exports may contain the separate effect switches. The grouped
    -- settings now control those effects; accept and discard old booleans.
    for _, key in ipairs({ "newAbilitySparkles", "abilityRevealShine", "backgroundDepth", "milestoneAnticipation", "statImpactSparks", "milestoneColorTransition", "popupClosingAnimation" }) do
        if type(settings[key]) == "boolean" then settings[key] = nil end
    end
    if settings.horizontalMode then settings.compactMode = true end
    return settings
end

local function Snapshot()
    local settings = {}
    for _, key in ipairs(keys) do settings[key] = ns.CopyValue(ns.db[key]) end
    return NormalizeSettings(settings)
end

function ns.SaveActiveProfile()
    if store and activeName then store.profiles[activeName] = Snapshot() end
end

local function ApplySettings(settings, refresh)
    ns.InvalidateColorPicker()
    settings = NormalizeSettings(ns.CopyValue(settings))
    for _, key in ipairs(keys) do
        local value = settings[key]
        if value == nil then value = ns.defaults[key] end
        ns.db[key] = ns.CopyValue(value)
    end
    -- An absent theme name in an existing Modern/composed profile is deliberate,
    -- rather than a request to inherit another theme from defaults.
    if settings.backgroundTheme == nil
        and (settings.backgroundMode ~= nil or settings.backgroundChoice ~= nil or settings.frameChoice ~= nil) then
        ns.db.backgroundTheme = nil
    end
    if settings.backgroundMode == "MODERN" then
        ns.db.backgroundChoice = settings.backgroundChoice or "NONE"
        ns.db.frameChoice = settings.frameChoice or "BLACK_METAL"
    end
    if not refresh then return end
    if ColorPickerFrame and ColorPickerFrame:IsShown() then ColorPickerFrame:Hide() end
    if ns.CloseLevelUp then ns.CloseLevelUp() end
    if ns.InvalidateTrainerIndex then ns.InvalidateTrainerIndex() end
    ns.SyncClassColors()
    ns.SetLocale(ns.db.language)
    if ns.RefreshLocalizedPopupText then ns.RefreshLocalizedPopupText() end
    ns.ApplyCurrentAppearance()
    if ns.FlushAppearanceRefresh then ns.FlushAppearanceRefresh() end
    ns.ApplyAddonState(true)
    if ns.ApplyClickThrough then ns.ApplyClickThrough(ns.db.clickThrough) end
    if ns.ApplyTextShadow then ns.ApplyTextShadow(ns.db.showTextShadow) end
    if ns.SetMinimapButtonShown then ns.SetMinimapButtonShown(ns.db.minimapButtonShown) end
    if ns.RefreshBlizzardSuppression then ns.RefreshBlizzardSuppression() end
    if ns.RefreshPreviewSuspension then ns.RefreshPreviewSuspension() end
    if ns.RefreshOptionsPanel then ns.RefreshOptionsPanel() end
end

local function ProfileID(name)
    if not store.profileIDs[name] then
        store.nextProfileID = (tonumber(store.nextProfileID) or 0) + 1
        store.profileIDs[name] = "p" .. store.nextProfileID
    end
    return store.profileIDs[name]
end

local function SetSelection(selection, name)
    selection.profile, selection.profileID = name, ProfileID(name)
end

local function ResolveSelection(selection)
    local id = selection.profileID or store.legacyProfileIDs[selection.profile]
    if id then
        for name, candidate in pairs(store.profileIDs) do
            if candidate == id and store.profiles[name] then return name end
        end
        return "Default"
    end
    return selection.profile and store.profiles[selection.profile] and selection.profile or nil
end

function ns.InitializeProfiles()
    ns.EnsureDatabase()
    GnomeLevelUpProfilesDB = type(GnomeLevelUpProfilesDB) == "table" and GnomeLevelUpProfilesDB or {}
    GnomeLevelUpCharacterDB = type(GnomeLevelUpCharacterDB) == "table" and GnomeLevelUpCharacterDB or {}
    store, character = GnomeLevelUpProfilesDB, GnomeLevelUpCharacterDB
    store.profiles = type(store.profiles) == "table" and store.profiles or {}
    if type(store.profiles.Default) ~= "table" then store.profiles.Default = Snapshot() end
    store.profileIDs = type(store.profileIDs) == "table" and store.profileIDs or {}
    store.legacyProfileIDs = type(store.legacyProfileIDs) == "table" and store.legacyProfileIDs or {}
    for name in pairs(store.profiles) do ProfileID(name) end
    local selection = character.savePerCharacter and character or store
    activeName = ResolveSelection(selection) or "Default"
    SetSelection(selection, activeName)
    ApplySettings(store.profiles[activeName], false)
    store.version = 2
end

local function EnsureProfiles()
    if not store then ns.InitializeProfiles() end
end

local function FinishEditing()
    if type(GetCurrentKeyBoardFocus) == "function" then
        local focus = GetCurrentKeyBoardFocus()
        if focus then focus:ClearFocus() end
    end
    if ColorPickerFrame and ColorPickerFrame:IsShown() then ColorPickerFrame:Hide() end
end

function ns.GetActiveProfileName()
    EnsureProfiles()
    return activeName
end

function ns.GetProfileID(name)
    EnsureProfiles()
    return store.profileIDs[name or activeName]
end

function ns.GetSavePerCharacter()
    EnsureProfiles()
    return character.savePerCharacter == true
end

function ns.GetProfileChoices()
    EnsureProfiles()
    local choices = {}
    for name in pairs(store.profiles) do choices[#choices + 1] = { value = name, label = name, literal = true } end
    table.sort(choices, function(a, b) return a.value < b.value end)
    return choices
end

function ns.SelectProfile(name)
    EnsureProfiles()
    if type(name) ~= "string" or type(store.profiles[name]) ~= "table" then return false end
    FinishEditing()
    ns.SaveActiveProfile()
    activeName = name
    SetSelection(character.savePerCharacter and character or store, name)
    ApplySettings(store.profiles[name], true)
    return true
end

local function UniqueName(base)
    local name, suffix = base, 2
    while store.profiles[name] do name = base .. " " .. suffix; suffix = suffix + 1 end
    return name
end

local function CleanProfileName(name)
    if type(name) ~= "string" then return end
    name = name:match("^%s*(.-)%s*$")
    if name == "" or #name > 320 or name:find("[%c|]") then return end
    local pos, count = 1, 0
    while pos <= #name do
        local byte = name:byte(pos)
        local length
        if byte < 128 then length = 1
        elseif byte >= 194 and byte <= 223 then length = 2
        elseif byte >= 224 and byte <= 239 then length = 3
        elseif byte >= 240 and byte <= 244 then length = 4
        else return end
        for offset = 1, length - 1 do
            local continuation = name:byte(pos + offset)
            if not continuation or continuation < 128 or continuation > 191 then return end
        end
        local second = name:byte(pos + 1)
        if (byte == 224 and second < 160) or (byte == 237 and second > 159)
            or (byte == 240 and second < 144) or (byte == 244 and second > 143) then return end
        pos, count = pos + length, count + 1
        if count > 80 then return end
    end
    return name
end

function ns.CreateProfile(name, settings)
    EnsureProfiles()
    name = CleanProfileName(name)
    if not name or store.profiles[name] then return false, "Enter a unique profile name (up to 80 characters)." end
    local count = 0
    for _ in pairs(store.profiles) do count = count + 1 end
    if count >= 50 then return false, "Profile limit reached (50)." end
    FinishEditing()
    store.profiles[name] = ns.CopyValue(settings or Snapshot())
    ProfileID(name)
    return ns.SelectProfile(name)
end

function ns.RenameProfile(name)
    EnsureProfiles()
    if activeName == "Default" then return false, "Default profile cannot be renamed or deleted." end
    name = CleanProfileName(name)
    if not name or (store.profiles[name] and name ~= activeName) then
        return false, "Enter a unique profile name (up to 80 characters)."
    end
    if name == activeName then return true end
    FinishEditing()
    ns.SaveActiveProfile()
    local old, id = activeName, ProfileID(activeName)
    -- Stable IDs preserve selections on other characters, including when an
    -- old display name is reused. Legacy names resolve once on their next login.
    store.legacyProfileIDs[old] = store.legacyProfileIDs[old] or id
    store.profiles[name], store.profileIDs[name] = store.profiles[old], id
    store.profiles[old], store.profileIDs[old] = nil, nil
    activeName = name
    for _, selection in ipairs({ store, character }) do
        if selection.profileID == id or (not selection.profileID and selection.profile == old) then SetSelection(selection, name) end
    end
    if ns.RefreshOptionsPanel then ns.RefreshOptionsPanel() end
    return true
end

function ns.DeleteProfile(name)
    EnsureProfiles()
    name = name or activeName
    if name == "Default" then return false, "Default profile cannot be renamed or deleted." end
    if not store.profiles[name] then return false, "Profile not found." end
    local id = ProfileID(name)
    store.legacyProfileIDs[name] = store.legacyProfileIDs[name] or id
    if activeName == name then ns.SelectProfile("Default") end
    store.profiles[name], store.profileIDs[name] = nil, nil
    for _, selection in ipairs({ store, character }) do
        if selection.profileID == id or (not selection.profileID and selection.profile == name) then SetSelection(selection, "Default") end
    end
    if ns.RefreshOptionsPanel then ns.RefreshOptionsPanel() end
    return true
end

function ns.SetSavePerCharacter(enabled)
    EnsureProfiles()
    enabled = enabled == true
    if enabled == (character.savePerCharacter == true) then return end
    FinishEditing()
    ns.SaveActiveProfile()
    if enabled then
        local selected = ResolveSelection(character)
        if not selected then
            local name = type(UnitName) == "function" and UnitName("player") or "Player"
            local realm = type(GetRealmName) == "function" and GetRealmName() or "Realm"
            local profileName = UniqueName(name .. " - " .. realm)
            store.profiles[profileName] = Snapshot()
            selected = profileName
        end
        character.savePerCharacter = true
        ns.SelectProfile(selected)
    else
        character.savePerCharacter = false
        ns.SelectProfile(ResolveSelection(store) or "Default")
    end
end

-- A small typed format keeps sharing independent of optional libraries. Parsing
-- never executes Lua; lengths, depth, entry counts and option types are bounded.
local function Encode(value)
    local kind = type(value)
    if kind == "boolean" then return value and "b1" or "b0" end
    if kind == "number" then return "n" .. tostring(value) .. ":" end
    if kind == "string" then return "s" .. #value .. ":" .. value end
    local fields = {}
    for key in pairs(value) do fields[#fields + 1] = key end
    table.sort(fields, function(a, b) return tostring(a) < tostring(b) end)
    local parts = { "t", tostring(#fields), ":" }
    for _, key in ipairs(fields) do
        parts[#parts + 1], parts[#parts + 2] = Encode(key), Encode(value[key])
    end
    return table.concat(parts)
end

local function Decode(text)
    local pos, nodes = 1, 0
    local parse
    local function Number()
        local finish = text:find(":", pos, true)
        if not finish or finish - pos > 32 then error("number") end
        local value = tonumber(text:sub(pos, finish - 1))
        if not value or value ~= value or math.abs(value) > 1000000 then error("number") end
        pos = finish + 1
        return value
    end
    parse = function(depth)
        nodes = nodes + 1
        if depth > 12 or nodes > 6000 then error("limit") end
        local tag = text:sub(pos, pos); pos = pos + 1
        if tag == "b" then
            local digit = text:sub(pos, pos); pos = pos + 1
            if digit ~= "0" and digit ~= "1" then error("boolean") end
            return digit == "1"
        elseif tag == "n" then return Number()
        elseif tag == "s" then
            local length = Number()
            if length < 0 or length > 8192 or length % 1 ~= 0 or pos + length - 1 > #text then error("length") end
            local value = text:sub(pos, pos + length - 1); pos = pos + length
            return value
        elseif tag == "t" then
            local count, result = Number(), {}
            if count < 0 or count > 1024 or count % 1 ~= 0 then error("count") end
            for _ = 1, count do
                local key = parse(depth + 1)
                if (type(key) ~= "string" and type(key) ~= "number") or result[key] ~= nil then error("key") end
                result[key] = parse(depth + 1)
            end
            return result
        end
        error("tag")
    end
    local result = parse(0)
    if pos ~= #text + 1 then error("trailing data") end
    return result
end

local ranges = {
    portraitModelRotation = { -180, 180 }, portraitModelX = { -5, 5 },
    portraitModelY = { -5, 5 }, portraitModelZ = { -5, 5 }, portraitModelScale = { 25, 300 },
    portraitModelMaskSize = { 25, 300 },
    portraitModelViewportSize = { 25, 300 },
    scale = { 0.5, 2 }, horizontalScale = { 0.5, 2 }, duration = { 1, 60 }, soundVolume = { 0, 1 }, bgOpacity = { 0, 1 },
    animSpeedMultiplier = { 0.25, 3 }, playerPortraitScale = { 0.1, 5 },
    portraitRingScale = { 0.1, 5 }, horizontalPortraitRingScale = { 0.1, 5 }, sectionPadding = { 0, 100 },
}
local anchors = { CENTER = true, TOP = true, BOTTOM = true, LEFT = true, RIGHT = true,
    TOPLEFT = true, TOPRIGHT = true, BOTTOMLEFT = true, BOTTOMRIGHT = true }
local enums = {
    frameStrata = { BACKGROUND = true, LOW = true, MEDIUM = true, HIGH = true,
        DIALOG = true, FULLSCREEN = true, FULLSCREEN_DIALOG = true, TOOLTIP = true },
    controllerMenuFrameStrata = { AUTO = true, BACKGROUND = true, LOW = true, MEDIUM = true,
        HIGH = true, DIALOG = true, FULLSCREEN = true, FULLSCREEN_DIALOG = true, TOOLTIP = true },
    forceFlavor = { auto = true, retail = true, forever = true },
    portraitMode = { none = true, class = true, player = true, player3d = true },
    statSlideDirection = { none = true, alternate = true, left = true, right = true },
    backgroundMode = { MODERN = true, CUSTOM = true },
    soundChannel = { Master = true, SFX = true, Music = true, Ambience = true, Dialog = true },
}

local function ValidateLike(value, template, depth)
    if depth > 10 or type(value) ~= type(template) then return false end
    if type(value) == "number" then return value == value and math.abs(value) <= 100000 end
    if type(value) == "string" then return #value <= 4096 and not value:find("%z") end
    if type(value) == "boolean" then return true end
    if type(value) ~= "table" then return false end
    for key, item in pairs(value) do
        if template[key] == nil or not ValidateLike(item, template[key], depth + 1) then return false end
    end
    -- Nested settings (positions, RGB triples, texture transforms) need all fields.
    for key in pairs(template) do if value[key] == nil then return false end end
    if #template == 3 then
        for _, channel in ipairs(value) do if channel < 0 or channel > 1 then return false end end
    end
    return true
end

local function ValidColors(colors)
    if type(colors) ~= "table" then return false end
    for key, color in pairs(colors) do
        if not ns.defaults.colors[key] or not ValidateLike(color, { 1, 1, 1 }, 0) then return false end
        for _, channel in ipairs(color) do if channel < 0 or channel > 1 then return false end end
    end
    return true
end

local function ValidSettings(settings)
    if type(settings) ~= "table" then return false end
    for key, value in pairs(settings) do
        if not allowed[key] then return false end
        if key == "colors" or key == "classColorBackup" then
            if not ValidColors(value) then return false end
            if key == "colors" then
                for colorKey in pairs(ns.defaults.colors) do if not value[colorKey] then return false end end
            end
        elseif key == "classColorOverrides" then
            if type(value) ~= "table" then return false end
            for token, colors in pairs(value) do
                if not ns.CLASS_COLORS[token] or not ValidColors(colors) then return false end
            end
        elseif key == "collapsedSections" then
            if type(value) ~= "table" then return false end
            for section, collapsed in pairs(value) do
                if type(section) ~= "string" or #section > 80 or type(collapsed) ~= "boolean" then return false end
            end
        else
            local template = ns.defaults[key]
            if template == nil then template = optional[key] end
            if template == nil or not ValidateLike(value, template, 0) then return false end
            if enums[key] and not enums[key][value] then return false end
            if (key == "framePosition" or key == "horizontalFramePosition") and (not anchors[value.point] or not anchors[value.relativePoint]) then return false end
            local range = ranges[key]
            if range and (value < range[1] or value > range[2]) then return false end
            if key:match("Opacity$") and (value < 0 or value > 100) then return false end
            for _, spec in ipairs(ns.PARTICLE_SETTINGS) do
                if key == spec.count and (value < 0 or value > spec.maxCount or value % 1 ~= 0) then return false end
                if key == spec.size and (value < 25 or value > 400) then return false end
            end
        end
    end
    return true
end

function ns.ExportProfile()
    EnsureProfiles()
    ns.SaveActiveProfile()
    local text = Encode({ version = 1, settings = Snapshot() })
    return "GLU1:" .. (text:gsub(".", function(char) return string.format("%02x", char:byte()) end))
end

function ns.ImportProfile(text, name)
    EnsureProfiles()
    if type(text) ~= "string" or #text > 65536 then return false, "Invalid profile string." end
    text = text:gsub("%s", "")
    local hex = text:match("^GLU1:([%da-fA-F]+)$")
    if not hex or #hex % 2 ~= 0 then return false, "Invalid profile string." end
    local raw = hex:gsub("..", function(pair) return string.char(tonumber(pair, 16)) end)
    local ok, data = pcall(Decode, raw)
    if not ok or type(data) ~= "table" or data.version ~= 1 or type(data.settings) ~= "table" then
        return false, "Invalid profile string."
    end
    NormalizeSettings(data.settings)
    if not ValidSettings(data.settings) then return false, "Invalid profile settings." end
    if name ~= nil and type(name) ~= "string" then return false, "Enter a unique profile name (up to 80 characters)." end
    if name == nil or name:match("^%s*$") then name = UniqueName(ns.L("Imported profile")) end
    return ns.CreateProfile(name, data.settings)
end

local events = CreateFrame("Frame")
events:RegisterEvent("PLAYER_LOGOUT")
events:SetScript("OnEvent", function() ns.SaveActiveProfile() end)
