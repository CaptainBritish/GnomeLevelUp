local ADDON_NAME, ns = ...

local DATABASE_SCHEMA_VERSION = 5

-- These are the settings used when the addon starts for the first time.
local defaults = {
    schemaVersion = DATABASE_SCHEMA_VERSION,
    enabled = true,
    playSound = true,
    muteNativeDing = true,
    duration = 7,       -- seconds the cinematic stays up before auto-hiding
    scale = 1.0,
    frameStrata = "HIGH",
    printInstructions = true,
    printClassicLevelUpText = false,
    classicLevelUpTextColor = { 1.00, 1.00, 159 / 255 }, -- #FFFF9F
    introShown = false,
    waitForCombatEnd = true, -- delay showing the screen until combat ends
    soundChoice = "LEVELUP",  -- key into ns.SOUND_CHOICES
    soundChannel = "Master",  -- "Master" | "SFX" | "Music" | "Ambience" | "Dialog"
    soundVolume = 1.0,         -- per-addon volume override where the client API supports it
    customSoundFile = nil,    -- e.g. "Interface\\AddOns\\GnomeLevelUp\\Sounds\\MyJingle.ogg"
    customSoundChoice = nil,
    forceFlavor = "auto", -- "auto" | "retail" | "forever"
    autoScanTrainers = true,
    scanProfessionTrainers = false,
    showWeaponSkills = false,
    showTrainerCosts = false,
    showOnlyCurrentLevelSkills = false,
    showOnlyNewSkills = false,
    showWarlockPetSkills = true,
    filterWarlockPetByActivePet = true,
    showAllWarlockGrimoires = false,
    useHorizontalAbilityScroll = false,
    compactMode = false,
    showLevelTime = false,
    ignoreMouseoverDelay = false,
    ignoreMouseoverDelayUserSet = false,
    clickThrough = false,
    hideBlizzardLevelUp = true,
    showTextShadow = true,
    useClassColors = false,
    rightClickClose = false,
    lockFramePosition = false,
    sectionPadding = 8,
    bgOpacity = 0.70,           -- background darkness at its peak (0-1)
    backgroundColor = { 0.00, 0.00, 0.00 },
    animSpeedMultiplier = 1.0,  -- higher = faster animations
    reducedMotion = false,       -- skip entrance/exit movement and fades
    statSlideDirection = "alternate", -- "alternate" | "left" | "right"
    equalStatWidths = false, -- add measured tracking so every stat row has the same visual width
    customFontPath = nil,       -- nil = default (Friz Quadrata)
    framePosition = { point = "CENTER", relativePoint = "CENTER", x = 0, y = 90 },
    minimapButtonShown = true,
    minimapAngle = 225,
    portraitMode = "class",
    playerPortraitPosition = { x = 0, y = 0 }, -- offset from the current portrait top anchor
    playerPortraitScale = 1.0,                 -- theme-controlled multiplier for the player portrait
    portraitRingEnabled = false,
    portraitRingTexture = nil,
    portraitRingChoice = "NONE",
    portraitRingScale = 1.10,
    portraitRingOffset = { x = 0, y = 0 },
    controllerGlyphStyle = "xbox", -- "none" | "xbox" | "playstation" | "nintendo"
    controllerMenuFrameStrata = "HIGH",
    debugEnabled = false,
    collapsedSections = {},

    backgroundMode = "MODERN", -- "MODERN" or "CUSTOM"
    backgroundTheme = nil,
    backgroundChoice = nil,
    frameChoice = nil,
    backgroundStyle = "stretch", -- "fill", "tile", or "stretch"
    backgroundFillMode = "scale", -- legacy center-texture setting
    backgroundTextureColors = {
        topLeft = { 1, 1, 1 },
        top = { 1, 1, 1 },
        topRight = { 1, 1, 1 },
        left = { 1, 1, 1 },
        center = { 1, 1, 1 },
        right = { 1, 1, 1 },
        bottomLeft = { 1, 1, 1 },
        bottom = { 1, 1, 1 },
        bottomRight = { 1, 1, 1 },
    },
    backgroundTextureTransforms = {
        topLeft = { rotation = 0, flipX = false, flipY = false },
        top = { rotation = 0, flipX = false, flipY = false },
        topRight = { rotation = 0, flipX = false, flipY = false },
        left = { rotation = 0, flipX = false, flipY = false },
        center = { rotation = 0, flipX = false, flipY = false },
        right = { rotation = 0, flipX = false, flipY = false },
        bottomLeft = { rotation = 0, flipX = false, flipY = false },
        bottom = { rotation = 0, flipX = false, flipY = false },
        bottomRight = { rotation = 0, flipX = false, flipY = false },
    },
    backgroundThemeTextureVersion = 0,

    colors = {
        title           = { 1.00, 0.82, 0.00 },
        level           = { 1.00, 0.82, 0.00 },
        statsHeader     = { 1.00, 0.82, 0.00 },
        statLabel       = { 1.00, 1.00, 1.00 },
        statNew         = { 0.18, 0.80, 0.44 },
        abilitiesHeader = { 1.00, 0.82, 0.00 },
        abilityName     = { 0.25, 0.88, 1.00 }, -- doubles as the icon border colour
        portraitBorder  = { 1.00, 0.82, 0.20 },
        divider         = { 106 / 255, 106 / 255, 106 / 255 },
    },
}
ns.defaults = defaults

-- These settings travel with a custom background theme. Keeping the list in
-- one place prevents a theme from silently omitting an Appearance option.
ns.APPEARANCE_SETTING_KEYS = {
    "playerPortraitPosition", "playerPortraitScale", "portraitRingEnabled", "portraitRingTexture", "portraitRingChoice", "portraitRingScale", "portraitRingOffset", "bgOpacity", "backgroundColor", "backgroundStyle", "backgroundFillMode",
    "backgroundTextureColors", "backgroundTextureTransforms", "customFontPath",
    "frameStrata", "framePosition", "lockFramePosition", "sectionPadding",
    "scale",
}

-- Keep the reset paths on the same copy-and-restore implementation. The
-- appearance subset is also reused by custom theme application.
ns.RESETTABLE_SETTING_KEYS = {
    "playSound", "muteNativeDing", "soundChoice", "soundChannel", "soundVolume", "customSoundFile", "customSoundChoice",
    "enabled", "duration", "scale", "autoScanTrainers", "scanProfessionTrainers", "showWeaponSkills", "showTrainerCosts", "showOnlyCurrentLevelSkills", "showOnlyNewSkills", "showWarlockPetSkills", "filterWarlockPetByActivePet", "showAllWarlockGrimoires", "useHorizontalAbilityScroll", "compactMode", "showLevelTime", "ignoreMouseoverDelay", "ignoreMouseoverDelayUserSet", "clickThrough", "hideBlizzardLevelUp",
    "bgOpacity", "backgroundColor", "animSpeedMultiplier", "reducedMotion", "statSlideDirection", "equalStatWidths", "customFontPath",
    "waitForCombatEnd", "forceFlavor", "frameStrata", "printInstructions", "printClassicLevelUpText", "classicLevelUpTextColor",
    "framePosition", "lockFramePosition", "sectionPadding", "rightClickClose", "showTextShadow", "useClassColors", "minimapButtonShown", "minimapAngle", "portraitMode", "playerPortraitPosition", "playerPortraitScale", "debugEnabled",
    "collapsedSections", "backgroundMode", "backgroundTheme", "backgroundChoice", "frameChoice", "backgroundStyle", "backgroundFillMode", "backgroundTextureColors", "backgroundTextureTransforms",
    "portraitRingEnabled", "portraitRingTexture", "portraitRingChoice", "portraitRingScale", "portraitRingOffset", "controllerGlyphStyle", "controllerMenuFrameStrata",
}

local function ResetSettingKeys(keys)
    if ns.EnsureDatabase then ns.EnsureDatabase() end
    for _, key in ipairs(keys or {}) do
        ns.db[key] = ns.CopyValue(defaults[key])
    end
end
ns.ResetSettingKeys = ResetSettingKeys

-- Blizzard's class colors are used when class-color mode is enabled.
ns.CLASS_COLORS = {
    DEATHKNIGHT = { 196 / 255, 30 / 255, 58 / 255 },
    DEMONHUNTER = { 163 / 255, 48 / 255, 201 / 255 },
    DRUID       = { 255 / 255, 124 / 255, 10 / 255 },
    EVOKER      = { 51 / 255, 147 / 255, 127 / 255 },
    HUNTER      = { 170 / 255, 211 / 255, 114 / 255 },
    MAGE        = { 63 / 255, 199 / 255, 235 / 255 },
    MONK        = { 0, 255 / 255, 152 / 255 },
    PALADIN     = { 244 / 255, 140 / 255, 186 / 255 },
    PRIEST      = { 1, 1, 1 },
    ROGUE       = { 255 / 255, 244 / 255, 104 / 255 },
    SHAMAN      = { 0, 112 / 255, 221 / 255 },
    WARLOCK     = { 135 / 255, 136 / 255, 238 / 255 },
    WARRIOR     = { 198 / 255, 155 / 255, 109 / 255 },
}

local function PrintStartupInstructions()
    if not ns.db or ns.db.printInstructions == false or ns.db.introShown then return end
    if ns.GetCurrentFlavor and ns.GetCurrentFlavor() == "retail" then
        print('GnomeLevelUp active! Retail spell unlocks are read from your spellbook. If you\'re updating to a new version and experiencing any issues, use the "Clear Scanned Data" option in the menu or type /glu cleartraining.')
    else
        print('GnomeLevelUp active! Make sure to visit your class trainer to cache available skills. If you\'re updating to a new version and experiencing any issues, use the "Clear Scanned Data" option in the menu or type /glu cleartraining.')
    end
    ns.db.introShown = true
end
ns.PrintStartupInstructions = PrintStartupInstructions

-- Copy nested settings so a reset cannot share tables with the defaults.
local function CopySetting(value)
    if type(value) ~= "table" then return value end
    local out = {}
    for key, nestedValue in pairs(value) do out[key] = CopySetting(nestedValue) end
    return out
end
ns.CopyValue = CopySetting

-- Fill in settings added after an older version was saved.
local EnsureDatabase

local function MergeMissingSettings(db, defaultsTable)
    for key, defaultValue in pairs(defaultsTable) do
        if type(defaultValue) == "table" then
            if type(db[key]) ~= "table" then db[key] = {} end
            MergeMissingSettings(db[key], defaultValue)
        elseif db[key] == nil then
            db[key] = defaultValue
        end
    end
end

local function ApplyAppearanceNow()
    if ns.ApplyBackgroundAppearance then ns.ApplyBackgroundAppearance() end
    if ns.ApplyBackgroundOpacity then ns.ApplyBackgroundOpacity(ns.db.bgOpacity) end
    if ns.ApplyFont then ns.ApplyFont(ns.db.customFontPath) end
    if ns.ApplyFrameStrata then ns.ApplyFrameStrata(ns.db.frameStrata) end
    if ns.ApplyFrameLock then ns.ApplyFrameLock(ns.db.lockFramePosition) end
    if ns.ApplyFrameScale then ns.ApplyFrameScale(ns.db.scale) end
    if ns.PositionFrame and ns.levelUpFrame then ns.PositionFrame(ns.levelUpFrame) end
    if ns.RefreshPortraitGeometry then ns.RefreshPortraitGeometry() end
    if ns.RefreshPortraitRing then ns.RefreshPortraitRing() end
    if ns.RefreshPopupLayout then ns.RefreshPopupLayout() end
    if ns.RefreshOptionsPanel then ns.RefreshOptionsPanel() end
end

-- Theme and independent appearance controls often change several settings in
-- one click. Coalesce those changes into one render pass to avoid repeatedly
-- rebuilding nine-slice textures and portrait geometry in the same frame.
local appearanceRefreshQueued = false
local function RefreshAppearanceAfterThemeChange()
    if appearanceRefreshQueued then return end
    appearanceRefreshQueued = true
    local function apply()
        appearanceRefreshQueued = false
        ApplyAppearanceNow()
    end
    if C_Timer and type(C_Timer.After) == "function" then
        C_Timer.After(0.05, apply)
    else
        apply()
    end
end
ns.FlushAppearanceRefresh = function()
    if appearanceRefreshQueued then
        appearanceRefreshQueued = false
        ApplyAppearanceNow()
    end
end
-- All theme and independent appearance selectors use the same refresh path.
-- This prevents one selector from leaving stale texture, font, or geometry
-- state behind when another selector changes.
ns.ApplyCurrentAppearance = RefreshAppearanceAfterThemeChange

function ns.FindBackgroundTheme(value)
    for _, theme in ipairs(ns.CUSTOM_BACKGROUND_THEMES or {}) do
        if type(theme) == "table" and theme.value == value then return theme end
    end
end

local function SelectedCompositeTheme()
    local background = ns.db and ns.db.backgroundChoice
    local frame = ns.db and ns.db.frameChoice
    if background and background ~= "NONE" and ns.GetCompositeTheme then
        return ns.GetCompositeTheme(frame or background, background)
    end
end
ns.GetSelectedCompositeTheme = SelectedCompositeTheme

function ns.RestoreModernAppearance()
    EnsureDatabase()
    -- The background dropdown controls only the background. Keep the user's
    -- portrait, frame position, font, and other appearance settings intact.
    ns.db.backgroundMode = "MODERN"
    ns.db.backgroundTheme = nil
    ns.db.backgroundChoice = "NONE"
    RefreshAppearanceAfterThemeChange()
end

function ns.ApplyBackgroundTheme(value)
    EnsureDatabase()
    if value == "MODERN" then
        ns.RestoreModernAppearance()
        return true
    end
    local theme = ns.FindBackgroundTheme(value)
    if not theme or not theme.textures or not theme.textures.center then
        ns.RestoreModernAppearance()
        return false
    end

    -- A theme is self-contained. Reset the Appearance settings first so a
    -- partially filled theme cannot inherit stale values from another theme.
    ResetSettingKeys(ns.APPEARANCE_SETTING_KEYS)
    for _, key in ipairs(ns.APPEARANCE_SETTING_KEYS) do
        if theme.appearance and theme.appearance[key] ~= nil then
            -- false is the serializable ThemeList.lua representation of a
            -- setting whose normal value is nil, such as the default font.
            ns.db[key] = theme.appearance[key] == false and nil or CopySetting(theme.appearance[key])
        end
    end
    ns.db.backgroundMode = "CUSTOM"
    ns.db.backgroundTheme = value
    ns.db.backgroundChoice = theme.backgroundName
    ns.db.frameChoice = theme.frameName or theme.backgroundName
    RefreshAppearanceAfterThemeChange()
    return true
end

function ns.ApplyBackgroundPreset(value)
    EnsureDatabase()
    local theme = ns.FindBackgroundTheme(value)
    if not theme or not theme.textures or not theme.textures.center then
        ns.RestoreModernAppearance()
        return false
    end

    -- Background selection is independent from the portrait and frame
    -- settings. Only replace values owned by the selected background preset.
    ns.db.backgroundMode = "CUSTOM"
    ns.db.backgroundTheme = value
    ns.db.backgroundChoice = theme.backgroundName
    ns.db.frameChoice = theme.frameName or theme.backgroundName
    if theme.appearance then
        if theme.appearance.backgroundStyle ~= nil then
            ns.db.backgroundStyle = CopySetting(theme.appearance.backgroundStyle)
        end
        if theme.appearance.backgroundFillMode ~= nil then
            ns.db.backgroundFillMode = CopySetting(theme.appearance.backgroundFillMode)
        end
        if theme.appearance.backgroundTextureColors ~= nil then
            ns.db.backgroundTextureColors = CopySetting(theme.appearance.backgroundTextureColors)
        end
        if theme.appearance.backgroundTextureTransforms ~= nil then
            ns.db.backgroundTextureTransforms = CopySetting(theme.appearance.backgroundTextureTransforms)
        end
    end
    RefreshAppearanceAfterThemeChange()
    return true
end

function ns.ApplyBackgroundChoice(value)
    EnsureDatabase()
    if value ~= "NONE" and ns.BACKGROUND_TEXTURES and not ns.BACKGROUND_TEXTURES[value] then
        value = "NONE"
    end
    ns.db.backgroundChoice = value
    if value == "NONE" then
        return ns.RestoreModernAppearance()
    end
    ns.db.backgroundMode = "CUSTOM"
    ns.db.backgroundTheme = nil
    RefreshAppearanceAfterThemeChange()
    return true
end

function ns.ApplyFrameChoice(value)
    EnsureDatabase()
    if ns.FRAME_TEXTURES and not ns.FRAME_TEXTURES[value] then
        value = "BLACK_METAL"
    end
    ns.db.frameChoice = value
    if ns.db.backgroundChoice and ns.db.backgroundChoice ~= "NONE" then
        ns.db.backgroundMode = "CUSTOM"
    end
    RefreshAppearanceAfterThemeChange()
    return true
end

local function InitDB()
    -- Load saved settings and fill in anything that is missing.
    GnomeLevelUpDB = GnomeLevelUpDB or {}
    local savedSchemaVersion = tonumber(GnomeLevelUpDB.schemaVersion) or 0
    -- Capture the pre-1.3.2 selectors before defaults add the new independent
    -- fields. This lets the migration distinguish an old custom theme from a
    -- deliberately selected Modern appearance.
    local legacyBackgroundMode = GnomeLevelUpDB.backgroundMode
    local legacyBackgroundTheme = GnomeLevelUpDB.backgroundTheme
    if type(legacyBackgroundTheme) == "string" then
        legacyBackgroundTheme = legacyBackgroundTheme:gsub("^CUSTOM:", "")
    end
    local legacyBackgroundChoice = GnomeLevelUpDB.backgroundChoice
    local legacyFrameChoice = GnomeLevelUpDB.frameChoice
    local legacyBackgroundStyle = GnomeLevelUpDB.backgroundStyle
    local legacyBackgroundFillMode = GnomeLevelUpDB.backgroundFillMode
    MergeMissingSettings(GnomeLevelUpDB, defaults)
    -- 1.3 stored one theme value for the whole custom appearance. Preserve
    -- that exact pairing while introducing independent frame/background keys.
    -- This is deliberately based on the values captured above; using the
    -- merged defaults here would make an old profile look like a new Modern
    -- profile and leave the background renderer without a valid nine-slice.
    local oldTheme = ns.FindBackgroundTheme(legacyBackgroundTheme)
    local hadIndependentSelectors = legacyBackgroundChoice ~= nil or legacyFrameChoice ~= nil
    if oldTheme and (not hadIndependentSelectors or savedSchemaVersion < 2) then
        GnomeLevelUpDB.backgroundMode = "CUSTOM"
        GnomeLevelUpDB.backgroundTheme = oldTheme.value
        GnomeLevelUpDB.backgroundChoice = oldTheme.backgroundName
        GnomeLevelUpDB.frameChoice = oldTheme.frameName or oldTheme.backgroundName
        if not legacyBackgroundStyle then
            local appearance = oldTheme.appearance or {}
            GnomeLevelUpDB.backgroundStyle = appearance.backgroundStyle
                or (legacyBackgroundFillMode == "tile" and "tile" or "stretch")
        end
    elseif legacyBackgroundMode == "CUSTOM" and not hadIndependentSelectors then
        -- A removed or manually edited 1.3 theme must not leave CUSTOM mode
        -- pointing at missing textures. Fall back cleanly to Modern.
        GnomeLevelUpDB.backgroundMode = "MODERN"
        GnomeLevelUpDB.backgroundTheme = nil
        GnomeLevelUpDB.backgroundChoice = "NONE"
        GnomeLevelUpDB.frameChoice = "BLACK_METAL"
    elseif not hadIndependentSelectors then
        GnomeLevelUpDB.backgroundChoice = "NONE"
        GnomeLevelUpDB.frameChoice = "BLACK_METAL"
    end
    -- Discard stale selectors left by removed themes or manually edited
    -- profiles before the renderer tries to resolve them.
    if savedSchemaVersion < 3 and tonumber(GnomeLevelUpDB.portraitRingScale) == 1.0 then
        GnomeLevelUpDB.portraitRingScale = 1.10
    end
    if GnomeLevelUpDB.backgroundChoice ~= "NONE"
        and ns.BACKGROUND_TEXTURES
        and not ns.BACKGROUND_TEXTURES[GnomeLevelUpDB.backgroundChoice] then
        GnomeLevelUpDB.backgroundChoice = "NONE"
        GnomeLevelUpDB.backgroundMode = "MODERN"
        GnomeLevelUpDB.backgroundTheme = nil
    end
    if ns.FRAME_TEXTURES and not ns.FRAME_TEXTURES[GnomeLevelUpDB.frameChoice] then
        GnomeLevelUpDB.frameChoice = "BLACK_METAL"
    end
    -- Older profiles only stored the center fill mode. Preserve that choice
    -- when introducing the per-theme style setting.
    if not legacyBackgroundStyle and not oldTheme then
        GnomeLevelUpDB.backgroundStyle = GnomeLevelUpDB.backgroundFillMode == "tile"
            and "tile" or "stretch"
    end
    if GnomeLevelUpDB.forceFlavor ~= "auto"
        and GnomeLevelUpDB.forceFlavor ~= "retail"
        and GnomeLevelUpDB.forceFlavor ~= "forever" then
        GnomeLevelUpDB.forceFlavor = "auto"
    end
    -- Move the first layout defaults forward without overwriting a custom divider color.
    if savedSchemaVersion < 2 and (GnomeLevelUpDB.uiDefaultsVersion or 0) < 2 then
        if GnomeLevelUpDB.sectionPadding == 6 then
            GnomeLevelUpDB.sectionPadding = 8
        end
        local divider = GnomeLevelUpDB.colors and GnomeLevelUpDB.colors.divider
        if divider and divider[1] == 1 and divider[2] == 1 and divider[3] == 1 then
            divider[1], divider[2], divider[3] = 106 / 255, 106 / 255, 106 / 255
        end
        GnomeLevelUpDB.uiDefaultsVersion = 2
    end
    -- Profiles from the pre-versioned format may contain partial or removed
    -- selectors. A versioned pass makes later migrations deterministic while
    -- preserving every user-owned setting that still has a valid meaning.
    if savedSchemaVersion < 4 then
        if not GnomeLevelUpDB.backgroundStyle then
            GnomeLevelUpDB.backgroundStyle = GnomeLevelUpDB.backgroundFillMode == "tile"
                and "tile" or "stretch"
        end
        if not GnomeLevelUpDB.frameChoice then GnomeLevelUpDB.frameChoice = "BLACK_METAL" end
        if not GnomeLevelUpDB.backgroundChoice then GnomeLevelUpDB.backgroundChoice = "NONE" end
    end
    ns.db = GnomeLevelUpDB

    -- Existing saved themes keep their appearance transforms in SavedVariables.
    -- Refresh only the nine-slice transform map so the shared corner/edge
    -- textures take effect without resetting the user's other appearance work.
    local themeTextureVersion = 1
    if (tonumber(GnomeLevelUpDB.backgroundThemeTextureVersion) or 0) < themeTextureVersion then
        local theme = ns.FindBackgroundTheme(GnomeLevelUpDB.backgroundTheme)
        local transforms = theme and theme.appearance and theme.appearance.backgroundTextureTransforms
        if transforms then
            GnomeLevelUpDB.backgroundTextureTransforms = CopySetting(transforms)
        end
        GnomeLevelUpDB.backgroundThemeTextureVersion = themeTextureVersion
    end
    GnomeLevelUpDB.schemaVersion = DATABASE_SCHEMA_VERSION
end
ns.InitDB = InitDB

EnsureDatabase = function()
    if not ns.db then InitDB() end
    return ns.db
end
ns.EnsureDatabase = EnsureDatabase

local CLASS_COLOR_KEYS = {
    "title", "level", "statsHeader", "abilitiesHeader", "abilityName", "portraitBorder",
}

local function ApplyCurrentClassColors()
    local _, classToken = UnitClass("player")
    local classColor = ns.CLASS_COLORS and ns.CLASS_COLORS[classToken]
    if not classColor then return end

    for _, key in ipairs(CLASS_COLOR_KEYS) do
        ns.db.colors[key] = CopySetting(classColor)
    end
end

function ns.SyncClassColors()
    EnsureDatabase()
    if ns.db.useClassColors then
        if not ns.db.classColorBackup then
            ns.db.classColorBackup = {}
            for _, key in ipairs(CLASS_COLOR_KEYS) do
                ns.db.classColorBackup[key] = CopySetting(ns.db.colors[key])
            end
        end
        ApplyCurrentClassColors()
    end
    if ns.ApplyColors then ns.ApplyColors() end
    if ns.RefreshOptionsPanel then ns.RefreshOptionsPanel() end
end

function ns.SetClassColorsEnabled(enabled)
    EnsureDatabase()
    if enabled then
        ns.db.useClassColors = true
        ns.SyncClassColors()
        return
    end

    ns.db.useClassColors = false
    local backup = ns.db.classColorBackup
    if backup then
        for _, key in ipairs(CLASS_COLOR_KEYS) do
            if backup[key] then ns.db.colors[key] = CopySetting(backup[key]) end
        end
    end
    ns.db.classColorBackup = nil
    if ns.ApplyColors then ns.ApplyColors() end
    if ns.RefreshOptionsPanel then ns.RefreshOptionsPanel() end
end

function ns.ResetAppearanceToDefaults()
    ResetSettingKeys(ns.APPEARANCE_SETTING_KEYS)
    -- Explicitly clear legacy and composed-theme selectors so old texture
    -- pieces cannot remain active after the reset.
    ns.db.backgroundMode = "MODERN"
    ns.db.backgroundTheme = nil
    ns.db.backgroundChoice = "NONE"
    ns.db.frameChoice = "BLACK_METAL"
    ns.db.showTextShadow = CopySetting(defaults.showTextShadow)
    ns.db.collapsedSections = CopySetting(defaults.collapsedSections)
    ns.db.colors = CopySetting(defaults.colors)
    ns.db.useClassColors = false
    ns.db.classColorBackup = nil

    if ns.ApplyCurrentAppearance then ns.ApplyCurrentAppearance() end
    if ns.ApplyColors then ns.ApplyColors() end
    if ns.ApplyTextShadow then ns.ApplyTextShadow(ns.db.showTextShadow) end
end

function ns.IsDebugEnabled()
    return ns.db and ns.db.debugEnabled == true
end

-- Performance counters stay dormant unless debug mode is enabled. This keeps
-- the normal popup path free of timing allocations while still making reports
-- useful when a user is investigating a stutter.
local performanceMetrics = {}
local function PerformanceClock()
    if type(GetTimePreciseSec) == "function" then return GetTimePreciseSec() * 1000 end
    return (type(GetTime) == "function" and GetTime() or 0) * 1000
end

function ns.PerfStart(label)
    if not ns.IsDebugEnabled() then return nil end
    return { label = label, started = PerformanceClock() }
end

function ns.PerfEnd(token)
    if not token then return end
    local elapsed = math.max(0, PerformanceClock() - token.started)
    local record = performanceMetrics[token.label]
    if not record then
        record = { calls = 0, total = 0, maximum = 0, last = 0 }
        performanceMetrics[token.label] = record
    end
    record.calls = record.calls + 1
    record.total = record.total + elapsed
    record.maximum = math.max(record.maximum, elapsed)
    record.last = elapsed
end

function ns.PerfCount(label, amount)
    if not ns.IsDebugEnabled() then return end
    local record = performanceMetrics[label]
    if not record then
        record = { calls = 0, total = 0, maximum = 0, last = 0 }
        performanceMetrics[label] = record
    end
    record.calls = record.calls + (tonumber(amount) or 1)
end

function ns.ResetPerformanceDiagnostics()
    performanceMetrics = {}
end

function ns.PrintPerformanceDiagnostics()
    if not ns.IsDebugEnabled() then
        print("|cff3fe0ffGnomeLevelUp|r: debug is OFF. Use /glu debug on first.")
        return
    end
    local labels = {}
    for label in pairs(performanceMetrics) do labels[#labels + 1] = label end
    table.sort(labels)
    print("|cff3fe0ffGnomeLevelUp|r performance diagnostics:")
    if #labels == 0 then
        print("  (no measured work yet)")
        return
    end
    for _, label in ipairs(labels) do
        local record = performanceMetrics[label]
        local average = record.calls > 0 and record.total / record.calls or 0
        print(string.format("  %-28s calls=%d avg=%.2fms max=%.2fms last=%.2fms",
            label, record.calls, average, record.maximum, record.last))
    end
end

function ns.IsAddonEnabled()
    return not ns.db or ns.db.enabled ~= false
end

function ns.ApplyAddonState(updateBanner)
    EnsureDatabase()
    local active = ns.db.enabled ~= false

    -- Native Ding muting is independent from Blizzard toast visibility.
    if ns.SetGnomeLevelUpSoundMuted then
        ns.SetGnomeLevelUpSoundMuted(active and ns.db.muteNativeDing ~= false)
    end

    if updateBanner == false then return end
    if not active then
        ns.CloseLevelUp()
        if ns.RestoreBlizzardBanner then ns.RestoreBlizzardBanner() end
    elseif ns.db.hideBlizzardLevelUp ~= false then
        if ns.SuppressBlizzardBanner then ns.SuppressBlizzardBanner() end
    elseif ns.RestoreBlizzardBanner then
        ns.RestoreBlizzardBanner()
    end
end

function ns.SetAddonEnabled(enabled)
    EnsureDatabase()
    ns.db.enabled = enabled ~= false
    ns.ApplyAddonState(true)
end

function ns.ResetOptionsToDefaults()
    -- Restore the settings page to the default values.
    ResetSettingKeys(ns.RESETTABLE_SETTING_KEYS)
    ns.db.colors = CopySetting(defaults.colors)
    ns.db.classColorBackup = nil
    ns.ApplyBackgroundOpacity(ns.db.bgOpacity)
    ns.ApplyFont(ns.db.customFontPath)
    ns.ApplyColors()
    ns.ApplyFrameStrata(ns.db.frameStrata)
    if ns.ApplyFrameLock then ns.ApplyFrameLock(ns.db.lockFramePosition) end
    if ns.ApplyClickThrough then ns.ApplyClickThrough(ns.db.clickThrough) end
    if ns.ApplyTextShadow then ns.ApplyTextShadow(ns.db.showTextShadow) end
    ns.ApplyAddonState(true)
    ns.SetMinimapButtonShown(ns.db.minimapButtonShown)
    ns.RefreshClassIcon()
    ns.PositionFrame(ns.levelUpFrame)
    ns.RefreshBlizzardSuppression()
    ns.RefreshOptionsPanel()
end


ns.SOUND_CHOICES = {
    { value = "LEVELUP", label = "Level Up (default)",  fileID = 6696263 },
    { value = "MANDOKIR", label = "Bloodlord Mandokir",     fileID = 554922 },
    { value = "GRATS_MON", label = "Grats, mon!",            fileID = 552911 },
    { value = "QUEST",   label = "Quest Complete",      id = (SOUNDKIT and SOUNDKIT.IG_QUEST_LIST_COMPLETE) or 878 },
    { value = "READY",   label = "Ready Check",         id = (SOUNDKIT and SOUNDKIT.READY_CHECK) or 8960 },
    { value = "AUCTION", label = "Auction Window Open", id = (SOUNDKIT and SOUNDKIT.AUCTION_WINDOW_OPEN) or 5274 },
    { value = "ALARM",   label = "Alarm Clock",         id = (SOUNDKIT and SOUNDKIT.ALARM_CLOCK_WARNING_3) or 18871 },
    { value = "CUSTOM",  label = "Custom sound" },
}
-- Sound channels that the player can choose from.
ns.SOUND_CHANNELS = {
    { value = "Master",   label = "Master" },
    { value = "SFX",      label = "Sound Effects" },
    { value = "Music",    label = "Music" },
    { value = "Ambience", label = "Ambience" },
    { value = "Dialog",   label = "Dialog" },
}

ns.MODE_CHOICES = {
    { value = "auto",    label = "Auto-detect" },
    { value = "retail",  label = "Retail" },
    { value = "forever", label = "WoW: Forever" },
}

-- The two portrait styles shown at the top of the level-up panel.
ns.PORTRAIT_CHOICES = {
    { value = "class",  label = "Class icon" },
    { value = "player", label = "Player portrait" },
}


ns.STRATA_CHOICES = {
    { value = "BACKGROUND",          label = "Background" },
    { value = "LOW",                 label = "Low" },
    { value = "MEDIUM",              label = "Medium" },
    { value = "HIGH",                label = "High" },
    { value = "DIALOG",              label = "Dialog" },
    { value = "FULLSCREEN",          label = "Fullscreen" },
    { value = "FULLSCREEN_DIALOG",   label = "Fullscreen Dialog" },
    { value = "TOOLTIP",             label = "Tooltip (highest)" },
}

ns.BACKGROUND_MODE_CHOICES = {
    { value = "MODERN", label = "Modern" },
    { value = "CUSTOM", label = "Custom" },
}

ns.BACKGROUND_FILL_CHOICES = {
    { value = "fill",    label = "Fill" },
    { value = "tile",    label = "Tile" },
    { value = "stretch", label = "Stretch" },
}

ns.BACKGROUND_ROTATION_CHOICES = {
    { value = 0, label = "0°" },
    { value = 90, label = "90°" },
    { value = 180, label = "180°" },
    { value = 270, label = "270°" },
}

local function SoundVolume()
    local value = tonumber(ns.db and ns.db.soundVolume) or 1.0
    return math.max(0, math.min(1, value))
end

local function PlaySoundKitWithVolume(soundKitID, channel)
    local volume = SoundVolume()
    -- volumeOverride was added to C_Sound.PlaySound after the older client
    -- API. Probe it safely and fall back to the legacy function when absent.
    if volume ~= 1 and C_Sound and type(C_Sound.PlaySound) == "function" then
        local ok, success = pcall(C_Sound.PlaySound, soundKitID, channel, false, false, nil, volume)
        if ok and success ~= nil then return success end
    end
    if type(PlaySound) == "function" then
        return PlaySound(soundKitID, channel)
    end
end

function ns.PlayLevelUpSound(force)
    -- Play a custom sound or one of the built-in sounds.
    local db = ns.db or {}
    if db.playSound == false and not force then return end

    local function PlaySelectedSound()
        local channel = db.soundChannel or "Master"
        if db.customSoundFile and db.customSoundFile ~= "" then
            local ok = pcall(PlaySoundFile, db.customSoundFile, channel)
            if ok then return end
        end

        local wanted = db.soundChoice or "LEVELUP"
        for _, choice in ipairs(ns.SOUND_CHOICES) do
            if choice.value == wanted then
                local ok
                if choice.fileID then ok = pcall(PlaySoundFile, choice.fileID, channel)
                elseif choice.id then ok = pcall(PlaySoundKitWithVolume, choice.id, channel)
                elseif choice.path then ok = pcall(PlaySoundFile, choice.path, channel) end
                if ok then return end
            end
        end
        local defaultChoice = ns.SOUND_CHOICES[1]
        if defaultChoice.fileID then PlaySoundFile(defaultChoice.fileID, channel)
        elseif defaultChoice.id then PlaySoundKitWithVolume(defaultChoice.id, channel) end
    end

    PlaySelectedSound()
end


local function AddPreviewEntries(target, source, limit)
    for _, entry in ipairs(source or {}) do
        if #target >= limit then break end
        target[#target + 1] = entry
    end
end

local function BuildDebugAbilityPreview(currentLevel, limit)
    local previewCost = 1337 * 10000
    local abilities = { { id = 11362, name = "Teleport to Gnomeregan", cost = previewCost } }
    local availableAbilities = {}
    local flavor = ns.GetCurrentFlavor and ns.GetCurrentFlavor() or "forever"
    if flavor == "retail" and ns.GetRetailUnlearnedSpells then
        availableAbilities = ns.GetRetailUnlearnedSpells(currentLevel) or {}
    elseif ns.GetAllTrainableUpToLevel then
        availableAbilities = ns.GetAllTrainableUpToLevel(currentLevel) or {}
    end
    AddPreviewEntries(abilities, availableAbilities, limit)
    for _, ability in ipairs(abilities) do
        ability.cost = previewCost
    end
    local placeholder = 1
    while #abilities < limit do
        abilities[#abilities + 1] = {
            name = string.format("Test Ability %02d", placeholder),
            icon = "Interface\\Icons\\INV_Misc_QuestionMark",
            cost = previewCost,
            preview = true,
        }
        placeholder = placeholder + 1
    end
    return abilities
end

local function BuildDebugGrimoirePreview(limit)
    local previewCost = 1337 * 10000
    local grimoires = {}
    for _, grimoire in ipairs(ns.WarlockPetGrimoires or {}) do
        if #grimoires >= limit then break end
        local name = grimoire.spellName
        if grimoire.rank then name = name .. " (Rank " .. grimoire.rank .. ")" end
        grimoires[#grimoires + 1] = {
            name = name,
            icon = grimoire.icon,
            cost = previewCost,
            itemID = grimoire.itemID,
            kind = "warlockPet",
            preview = true,
        }
    end
    for _, grimoire in ipairs(grimoires) do
        grimoire.cost = previewCost
    end
    local placeholder = 1
    while #grimoires < limit do
        grimoires[#grimoires + 1] = {
            name = string.format("Test Grimoire %02d", placeholder),
            icon = 133738,
            cost = previewCost,
            preview = true,
        }
        placeholder = placeholder + 1
    end
    return grimoires
end

function ns.PreviewLevelUp(debugSkills)
    -- Use a predictable example so the options preview does not depend on live data.
    EnsureDatabase()
    -- A preview does not fire PLAYER_LEVEL_UP, so queue the popup cleanup below.
    local currentLevel = UnitLevel("player")

    local trainerAbilities = {}
    if debugSkills then
        trainerAbilities = BuildDebugAbilityPreview(currentLevel, 20)
    else
        trainerAbilities = { { id = 11362, name = "Teleport to Gnomeregan", cost = 1337 * 10000 } }
        local flavor = ns.GetCurrentFlavor and ns.GetCurrentFlavor() or "forever"
        local availableAbilities
        if flavor == "retail" and ns.GetRetailUnlearnedSpells then
            availableAbilities = ns.GetRetailUnlearnedSpells(currentLevel) or {}
        elseif ns.GetAllTrainableUpToLevel then
            availableAbilities = ns.GetAllTrainableUpToLevel(currentLevel) or {}
        else
            availableAbilities = {}
        end
        for _, trainingAbility in ipairs(availableAbilities) do
            trainerAbilities[#trainerAbilities + 1] = trainingAbility
        end
    end

    local unlearnedWeaponSkills = ns.GetUnlearnedWeaponSkills(currentLevel)
    local _, classToken = UnitClass("player")
    local warlockPetAbilities = {}
    if debugSkills then
        warlockPetAbilities = BuildDebugGrimoirePreview(20)
    elseif classToken == "WARLOCK" then
        warlockPetAbilities[1] = {
            name = "Firebolt (Rank 2)",
            icon = 133738,
            cost = 1337 * 10000,
            itemID = 16302,
            kind = "warlockPet",
            preview = true,
        }
    end
    if ns.SuppressBlizzardBanner then ns.SuppressBlizzardBanner() end
    ns.ShowLevelUp(currentLevel, {
        { name = STRENGTH or "Strength", old = 20, new = 23 },
        { name = STAMINA or "Stamina", old = 22, new = 27 },
        { name = INTELLECT or "Intellect", old = 15, new = 17 },
    }, trainerAbilities, unlearnedWeaponSkills, ns.GetCurrentLevelPlayedTime and ns.GetCurrentLevelPlayedTime(), warlockPetAbilities)
    if ns.QueueBlizzardSuppression then ns.QueueBlizzardSuppression() end
end


local frame = CreateFrame("Frame")
ns.eventFrame = frame

-- Listen for addon setup, login, and level-up events.
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("PLAYER_LEVEL_UP")

frame:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" then
        local loadedAddon = ...
        if loadedAddon == ADDON_NAME then
            InitDB()
            ns.ApplyAddonState(true)
            if ns.MergeSavedTrainerData then
                ns.MergeSavedTrainerData()
            end
            PrintStartupInstructions()
            if ns.ApplyBackgroundOpacity then
                ns.ApplyBackgroundOpacity(ns.db.bgOpacity)
            end
            if ns.ApplyFont then
                ns.ApplyFont(ns.db.customFontPath)
            end
            if ns.SyncClassColors then
                ns.SyncClassColors()
            elseif ns.ApplyColors then
                ns.ApplyColors()
            end
            if ns.ApplyFrameStrata then
                ns.ApplyFrameStrata(ns.db.frameStrata)
            end
            if ns.ApplyFrameLock then ns.ApplyFrameLock(ns.db.lockFramePosition) end
            if ns.ApplyClickThrough then ns.ApplyClickThrough(ns.db.clickThrough) end
        end
    elseif event == "PLAYER_LOGIN" then
        EnsureDatabase()
        ns.ApplyAddonState(false)
        if ns.SyncClassColors then ns.SyncClassColors() elseif ns.ApplyColors then ns.ApplyColors() end
        if ns.RefreshBaseline then
            ns.RefreshBaseline()
        end
        if ns.GetTrainerCatalogIndex and #ns.GetTrainerCatalogIndex() > 0
            and ns.MarkKnownTrainerSkills and ns.SnapshotSpellBook then
            ns.MarkKnownTrainerSkills(ns.SnapshotSpellBook())
        end
    elseif event == "PLAYER_ENTERING_WORLD" then
        ns.ApplyAddonState(false)
        if ns.SyncClassColors then ns.SyncClassColors() elseif ns.ApplyColors then ns.ApplyColors() end
    elseif event == "PLAYER_LEVEL_UP" then
        if ns.HandleLevelUp then
            ns.HandleLevelUp(...)
        end
    end
end)


SLASH_GNOMELEVELUP1 = "/glu"
SlashCmdList["GNOMELEVELUP"] = function(msg)
    EnsureDatabase()
    msg = (msg or ""):lower()
    msg = msg:match("^%s*(.-)%s*$") -- trim

    if msg == "debugskills" then
        ns.PreviewLevelUp(true)
    elseif msg == "test" then
        ns.PreviewLevelUp()
    elseif msg == "sound" then
        ns.db.playSound = not ns.db.playSound
        print("|cff3fe0ffGnomeLevelUp|r: sound " .. (ns.db.playSound and "ON" or "OFF"))
    elseif msg:match("^duration") then
        local n = tonumber(msg:match("(%d+)"))
        if n then
            ns.db.duration = math.max(1, math.min(60, n))
            print("|cff3fe0ffGnomeLevelUp|r: duration set to " .. ns.db.duration .. "s")
        else
            print("|cff3fe0ffGnomeLevelUp|r: current duration is " .. (ns.db.duration or 7) .. "s. Use /glu duration <seconds>")
        end
    elseif msg:match("^flavor") or msg:match("^mode") then
        local choice = msg:match("%s+(%a+)")
        if choice == "retail" or choice == "forever" or choice == "auto" then
            ns.db.forceFlavor = choice
            if ns.InvalidateTrainerIndex then ns.InvalidateTrainerIndex() end
            print("|cff3fe0ffGnomeLevelUp|r: mode set to " .. choice
                .. " (currently resolves to \"" .. ns.GetCurrentFlavor() .. "\")")
        else
            print("|cff3fe0ffGnomeLevelUp|r: currently \"" .. (ns.db.forceFlavor or "auto")
                .. "\" (resolves to \"" .. ns.GetCurrentFlavor() .. "\"). Use /glu mode <retail|forever|auto>")
        end
    elseif msg == "scan" then
        ns.db.autoScanTrainers = not ns.db.autoScanTrainers
        print("|cff3fe0ffGnomeLevelUp|r: trainer auto-scan " .. (ns.db.autoScanTrainers and "ON" or "OFF"))
    elseif msg:match("^scanprof") then
        ns.db.scanProfessionTrainers = not ns.db.scanProfessionTrainers
        if ns.InvalidateTrainerIndex then ns.InvalidateTrainerIndex() end
        print("|cff3fe0ffGnomeLevelUp|r: scanning profession trainers "
            .. (ns.db.scanProfessionTrainers and "ON" or "OFF"))
    elseif msg == "cleartraining" then
        if ns.ClearScannedTrainerData then
            ns.ClearScannedTrainerData()
            print("|cff3fe0ffGnomeLevelUp|r: cleared all scanned trainer data. Visit a trainer again to re-scan it.")
        end
    elseif msg:match("^bgtest") then
        local fileName = msg:match("^bgtest%s+(.+)$")
        if ns.SetOptionsWatermarkTest then
            ns.SetOptionsWatermarkTest(fileName)
        end
    elseif msg == "debug" or msg:match("^debug%s+") then
        local value = msg:match("^debug%s+(%a+)$")
        if value == "on" then
            ns.db.debugEnabled = true
        elseif value == "off" then
            ns.db.debugEnabled = false
        else
            ns.db.debugEnabled = not ns.db.debugEnabled
        end
        if ns.RefreshOptionsPanel then ns.RefreshOptionsPanel() end
        print("|cff3fe0ffGnomeLevelUp|r: debug " .. (ns.db.debugEnabled and "ON" or "OFF"))
    elseif msg == "perf reset" or msg == "performance reset" then
        if ns.ResetPerformanceDiagnostics then ns.ResetPerformanceDiagnostics() end
        print("|cff3fe0ffGnomeLevelUp|r: performance counters reset")
    elseif msg == "perf" or msg == "performance" then
        if ns.PrintPerformanceDiagnostics then ns.PrintPerformanceDiagnostics() end
    elseif msg == "dumptraining" then
        if not ns.IsDebugEnabled() then
            print("|cff3fe0ffGnomeLevelUp|r: debug is OFF. Use /glu debug on first.")
        elseif ns.DumpTrainerData then
            ns.DumpTrainerData()
        end
    elseif msg == "dumpskills" then
        if ns.DumpWeaponSkills then ns.DumpWeaponSkills() end
    elseif msg == "testtrainer" then
        if not ns.IsDebugEnabled() then
            print("|cff3fe0ffGnomeLevelUp|r: debug is OFF. Use /glu debug on first.")
        elseif ns.TestTrainerList then
            ns.TestTrainerList()
        end
    elseif msg == "combat" then
        ns.db.waitForCombatEnd = not ns.db.waitForCombatEnd
        print("|cff3fe0ffGnomeLevelUp|r: waiting for combat to end before showing - "
            .. (ns.db.waitForCombatEnd and "ON" or "OFF"))
    elseif msg == "options" or msg == "config" then
        if ns.ToggleOptions then
            ns.ToggleOptions()
        end
    else
        print("|cff3fe0ffGnomeLevelUp|r commands:")
        print("  /glu test          - preview the level-up screen")
        print("  /glu options       - open the settings page (also under Options > AddOns)")
        print("  /glu sound         - toggle the level-up sound")
        print("  /glu duration N    - set how long the screen stays up (seconds)")
        print("  /glu mode <x>      - use retail/forever training data, or auto-detect")
        print("  /glu scan          - toggle auto-saving trainer data when you visit a trainer")
        print("  /glu scanprof      - toggle including profession trainers in that scan")
        print("  /glu cleartraining - wipe all scanned trainer data (fixes old bad/duplicate entries)")
        print("  /glu debug [on|off] - enable or disable debug commands (off by default)")
        print("  /glu dumptraining - print cached skills and learned status")
        print("  /glu dumpskills    - print Skills-tab, equipped, and trainable weapon data")
        print("  /glu testtrainer   - print the current unlearned skill list")
        print("  /glu perf          - print debug performance diagnostics")
        print("  /glu perf reset    - clear performance counters")
        print("  /glu combat        - toggle waiting for combat to end before showing")
    end
end
