local ADDON_NAME, ns = ...

ns.PORTRAIT_MEMORY_WARNING = "3D Portraits may consume more memory."

ns.DEFAULT_FONT_PATH = "Fonts\\FRIZQT__.TTF"

local DATABASE_SCHEMA_VERSION = 6

local defaults = {
    language = "auto",
    schemaVersion = DATABASE_SCHEMA_VERSION,
    enabled = true,
    playSound = true,
    muteNativeDing = true,
    duration = 7,       -- seconds the cinematic stays up before auto-hiding
    scale = 1.0,
    horizontalScale = 0.9,
    frameStrata = "HIGH",
    printInstructions = true,
    introShown = false,
    waitForCombatEnd = true, -- delay showing the screen until combat ends
    soundChoice = "LEVELUP",  -- key into ns.SOUND_CHOICES
    soundChannel = "Master",  -- "Master" | "SFX" | "Music" | "Ambience" | "Dialog"
    soundVolume = 1.0,         -- per-addon volume override where the client API supports it
    customSoundFile = nil,    -- e.g. "Interface\\AddOns\\GnomeLevelUp\\Sounds\\MyJingle.ogg"
    customSoundChoice = nil,
    forceFlavor = "auto", -- "auto" | "retail" | "forever"
    autoScanTrainers = true,
    monitorTrainerChanges = true,
    scanProfessionTrainers = false,
    showWeaponSkills = false,
    showTrainerCosts = false,
    showOnlyCurrentLevelSkills = false,
    showOnlyNewSkills = false,
    shortenRetailStatTotals = false,
    relevantRetailStatsOnly = false,
    showWarlockPetSkills = true,
    showHunterPetSkills = true,
    filterWarlockPetByActivePet = true,
    showAllWarlockGrimoires = false,
    useHorizontalAbilityScroll = false,
    compactMode = false,
    horizontalMode = true,
    showLevelTime = true,
    showSecondaryStats = false,
    statTextScale = 1,
    headingTextScale = 1,
    timeTextScale = 1,
    ignoreMouseoverDelay = false,
    ignoreMouseoverDelayUserSet = false,
    clickThrough = false,
    hideBlizzardLevelUp = true,
    showTextShadow = true,
    useClassColors = true,
    rightClickClose = true,
    lockFramePosition = false,
    sectionPadding = 8,
    compactHorizontalPadding = 2,
    bgOpacity = 0.80,           -- background darkness at its peak (0-1)
    backgroundColor = { 0.00, 0.00, 0.00 },
    frameColor = { 1.00, 1.00, 1.00 },
    portraitRingColor = { 1.00, 1.00, 1.00 },
    animSpeedMultiplier = 1.0,  -- higher = faster animations
    reducedMotion = false,       -- Classic Mode: suppress decorative flair, retain structural transitions
    backgroundAnimations = true,
    milestoneAnimations = true,
    maxLevelCelebration = true,
    screenshotMilestones = false,
    portraitRingGlint = true,

    portraitAnimation = true,
    portraitRingSettle = true,
    dividerReveal = true,
    highlightNewAbilities = true,
    emphasizeStatGains = true,
    portraitSparks = true,
    backgroundEmbers = true,
    frameEdgeGlow = true,
    particlePortraitCount = 5,
    particlePortraitSize = 200,
    particlePortraitOpacity = 65,
    particleStarburstCount = 5,
    particleStarburstSize = 100,
    particleStarburstOpacity = 65,
    particleEmberCount = 20,
    particleEmberSize = 150,
    particleEmberOpacity = 40,
    particleSparkleCount = 2,
    particleSparkleSize = 200,
    particleSparkleOpacity = 90,
    starburstOpacity = 50,
    portraitPulseOpacity = 50,
    frameEdgeGlowOpacity = 33,
    fireworkSize = 60,
    fireworkOpacity = 70,
    frameInset = 0,

    statSlideDirection = "alternate", -- "alternate" | "left" | "right"
    abbreviateStatNames = false,
    equalStatWidths = true, -- space whole stat groups to match the longest row
    customFontPath = nil,       -- nil = default (Friz Quadrata)
    framePosition = { point = "CENTER", relativePoint = "CENTER", x = 0, y = 90 },
    horizontalFramePosition = { point = "TOP", relativePoint = "TOP", x = 0, y = -80 },
    minimapButtonShown = true,
    suspendPreview = true,
    minimapAngle = 225,
    portraitMode = "player",
    playerPortraitPosition = { x = 0, y = 0 }, -- offset from the current portrait top anchor
    playerPortraitScale = 1.0,                 -- theme-controlled multiplier for the player portrait
    portraitRingEnabled = false,
    portraitRingTexture = nil,
    portraitRingChoice = "NONE",
    portraitRingScale = 1.10,
    portraitModelRotation = 0,
    portraitModelX = -0.1,
    portraitModelY = -0.05,
    portraitModelZ = 0.03,
    portraitModelScale = 100,
    portraitModelMaskSize = 93,
    portraitModelViewportSize = 105,
    horizontalPortraitRingScale = 1.15,
    horizontalPortraitRingOffset = { x = 0, y = 1 },
    portraitRingOffset = { x = 0, y = 0 },
    controllerGlyphStyle = "none", -- "none" | "xbox" | "playstation" | "nintendo"
    controllerMenuFrameStrata = "HIGH",
    debugEnabled = false,
    collapsedSections = {},

    backgroundMode = "MODERN", -- "MODERN" or "CUSTOM"
    backgroundTheme = nil,
    backgroundChoice = "NONE",
    frameChoice = "BLACK_METAL",
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
        animatedElements = { 1.00, 0.82, 0.20 },
        divider         = { 106 / 255, 106 / 255, 106 / 255 },
    },
}
ns.defaults = defaults

-- A zero file ID leaves an optional animation cue silent.
ns.ANIMATION_SOUND_SETTINGS = {
    { cue="portraitPulse", label="Portrait pulse and starburst" },
    { cue="portraitImpact", label="Portrait impact sound" },
    { cue="starburst", label="Starburst sound" },
    { cue="ringGlint", label="Portrait ring glint" },
    { cue="glintSpark", label="Glint finishing spark" },
    { cue="ringSettle", label="Portrait and ring settle" },
    { cue="statCount", label="Emphasize stat gains" },
    { cue="statImpact", label="Stat impact sparks" },
    { cue="abilityReveal", label="Highlight new abilities" },
    { cue="abilityShine", label="Ability reveal shine" },
    { cue="portraitMotes", label="Portrait motes" },
    { cue="backgroundMotes", label="Background motes" },
    { cue="frameEdge", label="Frame edge glow" },
    { cue="dividers", label="Reveal dividers" },
    { cue="depth", label="Background depth" },
    { cue="closing", label="Closing animation" },
    { cue="anticipation", label="Milestone anticipation" },
    { cue="milestoneTint", label="Milestone color transition" },
    { cue="milestone", label="Milestone Animations" },
    { cue="maxFireworks", label="Max Level Celebration" },
    { cue="portraitShine", label="Portrait shine" },
    { cue="ringSurges", label="Ring surges" },
    { cue="maxSparks", label="Max-level portrait sparks" },
}
for _, spec in ipairs(ns.ANIMATION_SOUND_SETTINGS) do
    spec.key = "animationSound_" .. spec.cue
    defaults[spec.key] = spec.default or 0
end

ns.TEXT_SIZE_SETTINGS = {
    {key = "statTextScale", label = "Stat text size"},
    {key = "headingTextScale", label = "Heading text size"},
    {key = "timeTextScale", label = "Time to Level text size"},
}
function ns.GetTextScale(key)
    local value = tonumber(ns.db and ns.db[key]) or 1
    if value ~= value or value == math.huge or value == -math.huge then value = 1 end
    return math.max(.5, math.min(2, value))
end
function ns.SetTextScale(key, value)
    ns.EnsureDatabase()
    for _, spec in ipairs(ns.TEXT_SIZE_SETTINGS) do
        if key == spec.key then
            ns.db[key] = tonumber(value) or 1
            ns.db[key] = ns.GetTextScale(key)
            if ns.RefreshTextSizes then ns.RefreshTextSizes() end
            return
        end
    end
end

-- Shared controls keep mouse, controller and setup changes on the same path.
ns.OPTION_SETTINGS = {
    duration = { label = "Display duration", minimum = 1, maximum = 60, step = 1,
        get = function() return tonumber(ns.db.duration) or 7 end,
        set = function(value) ns.db.duration = value end,
        format = function(value) return string.format("%ds", value) end },
    popupScale = { label = "Popup scale", minimum = .5, maximum = 2, step = .1,
        get = function() return ns.GetPopupScale() end,
        set = function(value) ns.SetPopupScale(value); ns.RefreshPopupLayout() end,
        format = function(value) return string.format("%.1fx", value) end },
}
for _, setting in ipairs(ns.TEXT_SIZE_SETTINGS) do
    local key = setting.key
    ns.OPTION_SETTINGS[key] = { label = setting.label, minimum = .5, maximum = 2, step = .1,
        get = function() return ns.GetTextScale(key) end,
        set = function(value) ns.SetTextScale(key, value) end,
        format = function(value) return string.format("%.0f%%", value * 100) end }
end

local function SharedToggle(key, label, changed, description, available)
    ns.OPTION_SETTINGS[key] = { label = label, description = description, isAvailable = available,
        get = function()
            if key == "compactMode" and ns.db.horizontalMode then return true end
            return ns.db[key] == true
        end,
        set = function(value)
            ns.db[key] = value == true
            if changed then changed(ns.db[key]) end
        end }
end
SharedToggle("horizontalMode", "Horizontal layout", function(value)
    ns.SetHorizontalMode(value); ns.RefreshPopupLayout()
end, "Arrange portrait, stats and abilities side by side.")
SharedToggle("compactMode", "Compact Layout", function() ns.RefreshPopupLayout() end,
    "Use a smaller vertical popup with less empty space.", function() return not ns.db.horizontalMode end)
SharedToggle("reducedMotion", "Classic Mode", function() ns.RefreshVisualEffects() end,
    "No decorative animations, similar to earlier GLU releases.")
SharedToggle("showLevelTime", "Show time played this level", function(value)
    if value then ns.RequestLevelPlayedTime() end
    ns.RefreshLevelPaceDisplay()
end, "Show the level timer and celebrate new best times.")
SharedToggle("rightClickClose", "Right-click to close", nil, "Close the popup by right-clicking it.")
SharedToggle("lockFramePosition", "Lock Location", function(value) ns.ApplyFrameLock(value) end)
SharedToggle("equalStatWidths", "Equal-width stat text", function()
    ns.RefreshStatTextLayout(); ns.RefreshPopupLayout()
end)
SharedToggle("abbreviateStatNames", "Abbreviate stat names", function()
    ns.RefreshStatTextLayout(); ns.RefreshPopupLayout()
end)
SharedToggle("shortenRetailStatTotals", "Shorten stat totals", function() ns.RefreshRetailStatOptions() end,
    "Abbreviate large stat totals without changing gain counters.")
SharedToggle("relevantRetailStatsOnly", "Relevant stats only", function() ns.RefreshRetailStatOptions() end,
    "Show only stats relevant to your current class and specialization.")

SharedToggle("showSecondaryStats", "Show secondary stats", function()
    if ns.RefreshBaseline then ns.RefreshBaseline() end
end, "Replace primary stats with secondary stats halfway through the popup.")

ns.OPTION_SETTINGS_BY_LABEL = {}
for _, setting in pairs(ns.OPTION_SETTINGS) do ns.OPTION_SETTINGS_BY_LABEL[setting.label] = setting end
function ns.AdjustNumericOption(key, direction)
    local setting = ns.OPTION_SETTINGS[key]
    local value = setting.get() + direction * setting.step
    setting.set(math.max(setting.minimum, math.min(setting.maximum, value)))
end

ns.EXTRA_EFFECTS = {
    { key = "portraitRingGlint", label = "Portrait ring glint" },
}

function ns.GetSectionPadding()
    local key = ns.db and ns.db.horizontalMode and "compactHorizontalPadding" or "sectionPadding"
    return math.max(0, math.min(30, tonumber(ns.db and ns.db[key]) or defaults[key]))
end

function ns.SetSectionPadding(value)
    local key = ns.db.horizontalMode and "compactHorizontalPadding" or "sectionPadding"
    ns.db[key] = math.max(0, math.min(30, tonumber(value) or defaults[key]))
end

-- These settings travel with a custom background theme. Keeping the list in
-- one place prevents a theme from silently omitting an Appearance option.
ns.APPEARANCE_SETTING_KEYS = {
    "portraitRingGlint",
    "portraitSparks", "backgroundEmbers", "frameEdgeGlow",
    "portraitAnimation", "highlightNewAbilities", "emphasizeStatGains",
    "portraitRingSettle", "dividerReveal",
    "playerPortraitPosition", "playerPortraitScale", "portraitRingEnabled", "portraitRingTexture", "portraitRingChoice", "portraitRingScale", "portraitRingOffset", "bgOpacity", "backgroundColor", "frameColor", "portraitRingColor", "backgroundStyle", "backgroundFillMode",
    "backgroundTextureColors", "backgroundTextureTransforms", "customFontPath", "statTextScale", "headingTextScale", "timeTextScale",
    "frameStrata", "framePosition", "lockFramePosition", "sectionPadding", "compactHorizontalPadding",
    "scale",
}

-- Keep the reset paths on the same copy-and-restore implementation. The
-- appearance subset is also reused by custom theme application.
ns.RESETTABLE_SETTING_KEYS = {
    "maxLevelCelebration", "showSecondaryStats",
    "shortenRetailStatTotals", "relevantRetailStatsOnly",
    "portraitRingGlint",
    "portraitModelRotation", "portraitModelX", "portraitModelY", "portraitModelZ", "portraitModelScale", "portraitModelMaskSize", "portraitModelViewportSize",
    "starburstOpacity", "portraitPulseOpacity", "frameEdgeGlowOpacity", "fireworkSize", "fireworkOpacity", "frameInset",
    "particlePortraitCount", "particlePortraitSize", "particlePortraitOpacity", "particleStarburstCount", "particleStarburstSize", "particleStarburstOpacity", "particleEmberCount", "particleEmberSize", "particleEmberOpacity", "particleSparkleCount", "particleSparkleSize", "particleSparkleOpacity",
    "milestoneAnimations", "screenshotMilestones", "backgroundAnimations", "portraitSparks", "backgroundEmbers", "frameEdgeGlow",
    "portraitAnimation", "highlightNewAbilities", "emphasizeStatGains",
    "portraitRingSettle", "dividerReveal",
    "playSound", "muteNativeDing", "soundChoice", "soundChannel", "soundVolume", "customSoundFile", "customSoundChoice",
    "enabled", "duration", "scale", "horizontalScale", "autoScanTrainers", "monitorTrainerChanges", "scanProfessionTrainers", "showWeaponSkills", "showTrainerCosts", "showOnlyCurrentLevelSkills", "showOnlyNewSkills", "showWarlockPetSkills", "showHunterPetSkills", "filterWarlockPetByActivePet", "showAllWarlockGrimoires", "useHorizontalAbilityScroll", "compactMode", "horizontalMode", "showLevelTime", "ignoreMouseoverDelay", "ignoreMouseoverDelayUserSet", "clickThrough", "hideBlizzardLevelUp",
    "bgOpacity", "backgroundColor", "frameColor", "portraitRingColor", "animSpeedMultiplier", "reducedMotion", "statSlideDirection", "equalStatWidths", "abbreviateStatNames", "customFontPath", "statTextScale", "headingTextScale", "timeTextScale",
    "waitForCombatEnd", "forceFlavor", "frameStrata", "printInstructions",
    "framePosition", "horizontalFramePosition", "lockFramePosition", "sectionPadding", "compactHorizontalPadding", "rightClickClose", "showTextShadow", "useClassColors", "minimapButtonShown", "minimapAngle", "suspendPreview", "portraitMode", "playerPortraitPosition", "playerPortraitScale", "debugEnabled",
    "collapsedSections", "backgroundMode", "backgroundTheme", "backgroundChoice", "frameChoice", "backgroundStyle", "backgroundFillMode", "backgroundTextureColors", "backgroundTextureTransforms",
    "portraitRingEnabled", "portraitRingTexture", "portraitRingChoice", "portraitRingScale", "portraitRingOffset", "horizontalPortraitRingScale", "horizontalPortraitRingOffset", "controllerGlyphStyle", "controllerMenuFrameStrata",
}

for _, spec in ipairs(ns.ANIMATION_SOUND_SETTINGS) do
    ns.RESETTABLE_SETTING_KEYS[#ns.RESETTABLE_SETTING_KEYS + 1] = spec.key
end

local function ResetSettingKeys(keys)
    if ns.EnsureDatabase then ns.EnsureDatabase() end
    for _, key in ipairs(keys or {}) do
        ns.db[key] = ns.CopyValue(defaults[key])
    end
end
ns.ResetSettingKeys = ResetSettingKeys

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
    SHAMAN      = { 99 / 255, 129 / 255, 255 / 255 },
    WARLOCK     = { 135 / 255, 136 / 255, 238 / 255 },
    WARRIOR     = { 198 / 255, 155 / 255, 109 / 255 },
}

local function PrintStartupInstructions()
    if not ns.db or ns.db.printInstructions == false or ns.db.introShown then return end
    if ns.GetCurrentFlavor() == "retail" then
        print(ns.L("Welcome to GnomeLevelUp!"))
        ns.db.introShown = true
        return
    end
    print(ns.L("Welcome to GnomeLevelUp! As of 1.4.0 you no longer need to scan trainers manually, the list is pre-populated! Please report any issues you encounter to me on GitHub or Curseforge!"))
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

-- Combine appearance changes from one click into a single render pass.
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
-- Refresh themes and individual appearance settings through the same path.
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
    -- Modern starts without a portrait ring. Keep portrait artwork, position
    -- and font choices when switching backgrounds.
    ns.db.backgroundMode = "MODERN"
    ns.db.bgOpacity = 0.80
    ns.db.backgroundTheme = nil
    ns.db.backgroundChoice = "NONE"
    ns.db.portraitRingEnabled = false
    ns.db.portraitRingTexture = nil
    ns.db.portraitRingChoice = "NONE"
    RefreshAppearanceAfterThemeChange()
end

local function NormalizePortraitRingHue()
    local color = ns.db and ns.db.portraitRingColor
    if type(color) == "table" and color[1] == 1 and color[2] == 0.82 and color[3] == 0.20 then
        ns.db.portraitRingColor = { 1, 1, 1 }
    end
end

function ns.ApplyBackgroundTheme(value)
    EnsureDatabase()
    NormalizePortraitRingHue()
    if value == "MODERN" then
        ns.RestoreModernAppearance()
        return true
    end
    local theme = ns.FindBackgroundTheme(value)
    if not theme or not theme.textures or not theme.textures.center then
        ns.RestoreModernAppearance()
        return false
    end

    -- A locked location belongs to the player, not the selected theme.
    local locationLocked = ns.db.lockFramePosition == true
    local lockedPosition = locationLocked and CopySetting(ns.db.framePosition)

    -- Reset the other Appearance settings so a partially filled theme cannot
    -- inherit stale values from another theme.
    ResetSettingKeys(ns.APPEARANCE_SETTING_KEYS)
    for _, key in ipairs(ns.APPEARANCE_SETTING_KEYS) do
        if theme.appearance and theme.appearance[key] ~= nil then
            -- false is the serializable ThemeList.lua representation of a
            -- setting whose normal value is nil, such as the default font.
            local value = theme.appearance[key]
            if value == false and defaults[key] == nil then
                ns.db[key] = nil
            else
                ns.db[key] = CopySetting(value)
            end
        end
    end
    if locationLocked then
        ns.db.lockFramePosition = true
        ns.db.framePosition = lockedPosition
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
    NormalizePortraitRingHue()
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

-- Enabled controller support alone does not imply a connected device.
function ns.GetDefaultControllerGlyphStyle()
    if C_GamePad and type(C_GamePad.GetAllDeviceIDs) == "function" then
        local ok, devices = pcall(C_GamePad.GetAllDeviceIDs)
        if ok and type(devices) == "table" then return next(devices) and "xbox" or "none" end
    end
    -- Older Forever builds only expose their current input interface mode.
    local getCVar = C_CVar and C_CVar.GetCVar or rawget(_G, "GetCVar")
    if type(getCVar) == "function" then
        local ok, style = pcall(getCVar, "InputDeviceInterfaceStyle")
        if ok and (style == "1" or style == "gamepad") then return "xbox" end
    end
    return "none"
end

local function InitDB()
    defaults.controllerGlyphStyle = ns.GetDefaultControllerGlyphStyle()
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
    -- Early 1.3.4 builds saved a white frame default before migrating the
    -- shared hue. Repair that case once, as well as a direct 1.3.2 upgrade.
    local legacyHue = GnomeLevelUpDB.backgroundColor
    local savedFrameHue = GnomeLevelUpDB.frameColor
    local frameHueMissing = savedFrameHue == nil
    local frameHueIsDefault = type(savedFrameHue) == "table"
        and savedFrameHue[1] == 1 and savedFrameHue[2] == 1 and savedFrameHue[3] == 1
    if GnomeLevelUpDB.sharedHueMigrationVersion ~= 1
        and (frameHueMissing or (savedSchemaVersion <= 6 and frameHueIsDefault))
        and type(legacyHue) == "table"
        and type(legacyHue[1]) == "number" and type(legacyHue[2]) == "number"
        and type(legacyHue[3]) == "number" then
        -- Legacy black meant no tint, so use the new frame's neutral white.
        if legacyHue[1] == 0 and legacyHue[2] == 0 and legacyHue[3] == 0 then
            GnomeLevelUpDB.frameColor = { 1, 1, 1 }
        else
            GnomeLevelUpDB.frameColor = CopySetting(legacyHue)
        end
    end
    GnomeLevelUpDB.sharedHueMigrationVersion = 1
    -- Combine the two portrait effects, retaining a fully disabled old profile.
    if GnomeLevelUpDB.portraitAnimation == nil
        and (GnomeLevelUpDB.portraitRingPulse ~= nil or GnomeLevelUpDB.portraitStarburst ~= nil) then
        GnomeLevelUpDB.portraitAnimation = GnomeLevelUpDB.portraitRingPulse ~= false
            or GnomeLevelUpDB.portraitStarburst ~= false
    end
    GnomeLevelUpDB.portraitRingPulse = nil
    GnomeLevelUpDB.portraitStarburst = nil
    -- Emphasis now controls counting too; preserve its existing preference.
    GnomeLevelUpDB.countStatGains = nil
    GnomeLevelUpDB.statTickerSounds = nil
    GnomeLevelUpDB.portraitImpactSound, GnomeLevelUpDB.starburstSound = nil, nil
    -- Retire the shipped experiment once; later debug selections remain editable.
    if not GnomeLevelUpDB.effectSoundDefaultsRemoved then
        if GnomeLevelUpDB.animationSound_portraitImpact == 4177602 then GnomeLevelUpDB.animationSound_portraitImpact = 0 end
        if GnomeLevelUpDB.animationSound_starburst == 979016 then GnomeLevelUpDB.animationSound_starburst = 0 end
        GnomeLevelUpDB.effectSoundDefaultsRemoved = true
    end
    -- Migrate the particle defaults once; preserve later debug edits.
    if GnomeLevelUpDB.particleTuningPresetVersion ~= 1 then
        GnomeLevelUpDB.particlePortraitCount = 5
        GnomeLevelUpDB.particlePortraitSize = 200
        GnomeLevelUpDB.particleStarburstCount = 5
        GnomeLevelUpDB.particleEmberCount = 20
        GnomeLevelUpDB.particleEmberSize = 150
        GnomeLevelUpDB.particleTuningPresetVersion = 1
    end
    -- Apply the new visual preset once, then preserve later debug tuning.
    if GnomeLevelUpDB.effectReadabilityPresetVersion ~= 1 then
        GnomeLevelUpDB.starburstOpacity = 50
        GnomeLevelUpDB.particleSparkleSize = 200
        GnomeLevelUpDB.particleEmberOpacity = 40
        GnomeLevelUpDB.effectReadabilityPresetVersion = 1
    end
    -- Refresh the old defaults without replacing custom debug values.
    if GnomeLevelUpDB.effectPolishPresetVersion ~= 1 then
        if GnomeLevelUpDB.fireworkSize == nil or GnomeLevelUpDB.fireworkSize == 80 then GnomeLevelUpDB.fireworkSize = 60 end
        if GnomeLevelUpDB.portraitPulseOpacity == nil or GnomeLevelUpDB.portraitPulseOpacity == 71.5 then GnomeLevelUpDB.portraitPulseOpacity = 50 end
        if GnomeLevelUpDB.particleEmberOpacity == nil or GnomeLevelUpDB.particleEmberOpacity == 30 then GnomeLevelUpDB.particleEmberOpacity = 40 end
        GnomeLevelUpDB.effectPolishPresetVersion = 1
    end
    MergeMissingSettings(GnomeLevelUpDB, defaults)
    -- 1.3 stored one theme value for the whole custom appearance. Preserve
    -- that exact pairing while introducing independent frame/background keys.
    -- This is deliberately based on the values captured above; using the
    -- merged defaults here would make an old profile look like a fresh default
    -- profile and leave the background renderer without a valid nine-slice.
    local oldTheme = ns.FindBackgroundTheme(legacyBackgroundTheme)
    local hadIndependentSelectors = legacyBackgroundChoice ~= nil or legacyFrameChoice ~= nil
    if legacyBackgroundMode == "MODERN" and not legacyBackgroundTheme then
        GnomeLevelUpDB.backgroundTheme = nil
        GnomeLevelUpDB.backgroundChoice = legacyBackgroundChoice or "NONE"
        GnomeLevelUpDB.frameChoice = legacyFrameChoice or "BLACK_METAL"
    elseif oldTheme and (not hadIndependentSelectors or savedSchemaVersion < 2) then
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
    elseif hadIndependentSelectors and not legacyBackgroundTheme then
        GnomeLevelUpDB.backgroundTheme = nil
    elseif not hadIndependentSelectors and (legacyBackgroundMode ~= nil or legacyBackgroundTheme ~= nil or savedSchemaVersion > 0) then
        GnomeLevelUpDB.backgroundMode = "MODERN"
        GnomeLevelUpDB.backgroundTheme = nil
        GnomeLevelUpDB.backgroundChoice = "NONE"
        GnomeLevelUpDB.frameChoice = "BLACK_METAL"
    end
    -- Discard stale selectors left by removed themes or manually edited
    -- profiles before the renderer tries to resolve them.
    if savedSchemaVersion < 3 and tonumber(GnomeLevelUpDB.portraitRingScale) == 1.0 then
        GnomeLevelUpDB.portraitRingScale = 1.10
    end
    -- 1.3.4 uses a neutral white default for authored portrait rings. Migrate
    -- the previous built-in gold default while preserving an intentional tint.
    local savedRingColor = GnomeLevelUpDB.portraitRingColor
    if type(savedRingColor) == "table"
        and savedRingColor[1] == 1 and savedRingColor[2] == 0.82 and savedRingColor[3] == 0.20 then
        GnomeLevelUpDB.portraitRingColor = { 1, 1, 1 }
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
    if not legacyBackgroundStyle and not oldTheme
        and (legacyBackgroundMode ~= nil or legacyBackgroundFillMode ~= nil or hadIndependentSelectors) then
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
    -- Blizzard owns level-up chat now; retire the addon-only settings.
    GnomeLevelUpDB.printClassicLevelUpText = nil
    GnomeLevelUpDB.classicLevelUpTextColor = nil
    GnomeLevelUpDB.popupClosingAnimation = nil
    GnomeLevelUpDB.milestoneColorTransition = nil
    GnomeLevelUpDB.statImpactSparks = nil
    GnomeLevelUpDB.newAbilitySparkles = nil
    GnomeLevelUpDB.abilityRevealShine = nil
    GnomeLevelUpDB.backgroundDepth = nil
    GnomeLevelUpDB.milestoneAnticipation = nil
    GnomeLevelUpDB.levelNumberReveal = nil
    GnomeLevelUpDB.persistentOptionsPreview = nil
    GnomeLevelUpDB.themePreview = nil
    ns.db = GnomeLevelUpDB

    -- Retire the deleted placeholder in profiles saved by older theme builds.
    local savedRingTexture = ns.db.portraitRingTexture
    if type(savedRingTexture) == "string"
        and savedRingTexture:lower():match("portrait%-ring%-placeholder%.tga$") then
        ns.db.portraitRingTexture = nil
        ns.db.portraitRingChoice = "NONE"
        ns.db.portraitRingEnabled = false
    end

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
    if GnomeLevelUpDB.horizontalMode then GnomeLevelUpDB.compactMode = true end
    GnomeLevelUpDB.schemaVersion = DATABASE_SCHEMA_VERSION
end
ns.InitDB = InitDB

EnsureDatabase = function()
    if not ns.db then InitDB() end
    return ns.db
end
ns.EnsureDatabase = EnsureDatabase

function ns.SetHorizontalMode(enabled)
    EnsureDatabase()
    ns.db.horizontalMode = enabled == true
    if ns.db.horizontalMode then ns.db.compactMode = true end
    if ns.PositionFrame and ns.levelUpFrame then ns.PositionFrame(ns.levelUpFrame) end
    if ns.RefreshOptionsPanel then ns.RefreshOptionsPanel() end
end

function ns.GetPortraitRingSettingKey(setting)
    return (ns.db and ns.db.horizontalMode and "horizontalPortraitRing" or "portraitRing") .. setting
end

function ns.GetPopupScale()
    EnsureDatabase()
    return ns.db.horizontalMode and (ns.db.horizontalScale or 0.9) or (ns.db.scale or 1)
end

function ns.SetPopupScale(value)
    EnsureDatabase()
    ns.db[ns.db.horizontalMode and "horizontalScale" or "scale"] = math.max(0.5, math.min(2, value))
end

local CLASS_COLOR_KEYS = {
    "title", "level", "statsHeader", "abilitiesHeader", "abilityName", "portraitBorder", "animatedElements", "divider",
}

function ns.GetClassColor(key)
    local _, token = UnitClass("player")
    local base = ns.CLASS_COLORS and ns.CLASS_COLORS[token]
    if not base then return end
    local overrides = ns.db and ns.db.classColorOverrides and ns.db.classColorOverrides[token]
    if overrides and overrides[key] then return overrides[key] end
    if key == "divider" then return { base[1] * .8, base[2] * .8, base[3] * .8 } end
    return base
end

local function ApplyCurrentClassColors()
    for _, key in ipairs(CLASS_COLOR_KEYS) do
        local color = ns.GetClassColor(key)
        if color then ns.db.colors[key] = CopySetting(color) end
    end
end

function ns.SetOptionColor(key, color)
    EnsureDatabase()
    if ns.db.useClassColors then
        for _, classKey in ipairs(CLASS_COLOR_KEYS) do
            if key == classKey then
                local _, token = UnitClass("player")
                ns.db.classColorOverrides = ns.db.classColorOverrides or {}
                ns.db.classColorOverrides[token] = ns.db.classColorOverrides[token] or {}
                ns.db.classColorOverrides[token][key] = CopySetting(color)
                break
            end
        end
    end
    ns.db.colors[key] = CopySetting(color)
    if ns.ApplyColors then ns.ApplyColors() end
end

function ns.SyncClassColors()
    EnsureDatabase()
    if ns.db.useClassColors then
        if not ns.db.classColorBackup then
            ns.db.classColorBackup = {}
        end
        -- Include keys introduced while an older class-colour backup exists.
        for _, key in ipairs(CLASS_COLOR_KEYS) do
            if ns.db.classColorBackup[key] == nil then
                ns.db.classColorBackup[key] = CopySetting(ns.db.colors[key])
            end
        end
        ApplyCurrentClassColors()
    end
    if ns.ApplyColors then ns.ApplyColors() end
    if ns.RefreshOptionsPanel then ns.RefreshOptionsPanel() end
end

function ns.InvalidateColorPicker()
    ns.colorPaletteRevision = (ns.colorPaletteRevision or 0) + 1
    if ColorPickerFrame and ColorPickerFrame:IsShown() then ColorPickerFrame:Hide() end
end

function ns.SetClassColorsEnabled(enabled)
    EnsureDatabase()
    ns.InvalidateColorPicker()
    if enabled then
        -- The controller menu updates the flag before calling this setter.
        -- A missing backup also marks the start of a fresh class-colour session.
        if not ns.db.useClassColors or not ns.db.classColorBackup then ns.db.classColorOverrides = nil end
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
    ns.InvalidateColorPicker()
    ResetSettingKeys(ns.APPEARANCE_SETTING_KEYS)
    -- Explicitly clear legacy and composed-theme selectors so old texture
    -- pieces cannot remain active after the reset.
    ns.db.backgroundMode = defaults.backgroundMode
    ns.db.backgroundTheme = defaults.backgroundTheme
    ns.db.backgroundChoice = defaults.backgroundChoice
    ns.db.frameChoice = defaults.frameChoice
    ns.db.showTextShadow = CopySetting(defaults.showTextShadow)
    ns.db.collapsedSections = CopySetting(defaults.collapsedSections)
    ns.db.colors = CopySetting(defaults.colors)
    ns.db.useClassColors = false
    ns.db.classColorBackup = nil
    ns.db.classColorOverrides = nil

    if ns.ApplyCurrentAppearance then ns.ApplyCurrentAppearance() end
    if ns.ApplyColors then ns.ApplyColors() end
    if ns.ApplyTextShadow then ns.ApplyTextShadow(ns.db.showTextShadow) end
end

function ns.IsDebugEnabled()
    return ns.db and ns.db.debugEnabled == true
end

-- Collect performance counters only in debug mode.
local performanceMetrics = {}
local function PerformanceClock()
    if type(GetTimePreciseSec) == "function" then return GetTimePreciseSec() * 1000 end
    return (type(GetTime) == "function" and GetTime() or 0) * 1000
end

function ns.PerfStart(label, popupAge)
    if not ns.IsDebugEnabled() then return nil end
    return { label = label, started = PerformanceClock(), popupAge = popupAge }
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
    if elapsed > record.maximum then
        record.maximum, record.peakAge = elapsed, token.popupAge
    end
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
        print("|cff3fe0ffGnomeLevelUp|r: " .. ns.L("Enable debug commands") .. ": /glu debug on")
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
            label, record.calls, average, record.maximum, record.last)
            .. (record.peakAge and string.format(" peak@=%.2fs", record.peakAge) or ""))
    end
end

function ns.IsAddonEnabled()
    return not ns.db or ns.db.enabled ~= false
end

function ns.UsesNativeLevelUpSound()
    return not ns.db or (ns.db.soundChoice or "LEVELUP") == "LEVELUP"
end

function ns.ApplyAddonState(updateBanner)
    EnsureDatabase()
    local active = ns.db.enabled ~= false

    -- Native Ding muting is independent from Blizzard toast visibility.
    if ns.SetGnomeLevelUpSoundMuted then
        ns.SetGnomeLevelUpSoundMuted(active and not ns.UsesNativeLevelUpSound() and ns.db.muteNativeDing ~= false)
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
    if GnomeLevelUpCharacterDB then GnomeLevelUpCharacterDB.portraitModelTuning = nil end
    -- Restore the settings page to the default values.
    ns.InvalidateColorPicker()
    ResetSettingKeys(ns.RESETTABLE_SETTING_KEYS)
    ns.db.colors = CopySetting(defaults.colors)
    ns.db.classColorBackup = nil
    ns.db.classColorOverrides = nil
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
    { value = "LEVELUP", label = "Level Up (default)", fileID = 6696263, retailFileID = 567431 },
    { value = "MANDOKIR", label = "Bloodlord Mandokir",     fileID = 554922 },
    { value = "GRATS_MON", label = "Grats, mon!",            fileID = 552911 },
    { value = "QUEST",   label = "Quest Complete",      id = (SOUNDKIT and SOUNDKIT.IG_QUEST_LIST_COMPLETE) or 878 },
    { value = "READY",   label = "Ready Check",         id = (SOUNDKIT and SOUNDKIT.READY_CHECK) or 8960 },
    { value = "AUCTION", label = "Auction Window Open", id = (SOUNDKIT and SOUNDKIT.AUCTION_WINDOW_OPEN) or 5274 },
    { value = "ALARM",   label = "Alarm Clock",         id = (SOUNDKIT and SOUNDKIT.ALARM_CLOCK_WARNING_3) or 18871 },
    { value = "CUSTOM",  label = "Custom sound" },
}
ns.SOUND_CHANNELS = {
    { value = "Master",   label = "Master" },
    { value = "SFX",      label = "Sound Effects" },
    { value = "Music",    label = "Music" },
    { value = "Ambience", label = "Ambience" },
    { value = "Dialog",   label = "Dialog" },
}

ns.MODE_CHOICES = {
    { value = "auto",    label = "Auto Detect" },
    { value = "retail",  label = "Retail" },
    { value = "forever", label = "WoW: Forever" },
}

-- Bounded numeric tuning shared by the options fields and visible-only effects.
ns.PARTICLE_SETTINGS = {
    { group = "portrait", countLabel = "Portrait mote count", sizeLabel = "Portrait mote size (%)", opacityLabel = "Portrait mote opacity (%)",
        count = "particlePortraitCount", size = "particlePortraitSize", opacity = "particlePortraitOpacity", maxCount = 30 },
    { group = "starburst", countLabel = "Starburst mote count", sizeLabel = "Starburst mote size (%)", opacityLabel = "Starburst mote opacity (%)",
        count = "particleStarburstCount", size = "particleStarburstSize", opacity = "particleStarburstOpacity", maxCount = 30 },
    { group = "ember", countLabel = "Background ember count", sizeLabel = "Background ember size (%)", opacityLabel = "Background ember opacity (%)",
        count = "particleEmberCount", size = "particleEmberSize", opacity = "particleEmberOpacity", maxCount = 200 },
    { group = "sparkle", countLabel = "Ability sparkle count", sizeLabel = "Ability sparkle size (%)", opacityLabel = "Ability sparkle opacity (%)",
        count = "particleSparkleCount", size = "particleSparkleSize", opacity = "particleSparkleOpacity", maxCount = 8 },
}
ns.FRAME_INSET_SETTING = {
    value = "frameInset", valueLabel = "Frame inset (px)", min = 0, max = 100, layout = true,
}
ns.FIREWORK_SETTINGS = {
    size = "fireworkSize", sizeLabel = "Firework size (%)",
    opacity = "fireworkOpacity", opacityLabel = "Firework opacity (%)",
}
ns.EFFECT_OPACITY_SETTINGS = {
    { opacity = "starburstOpacity", opacityLabel = "Starburst opacity (%)", precision = 10 },
    { opacity = "portraitPulseOpacity", opacityLabel = "Portrait pulse opacity (%)", precision = 10 },
    { opacity = "frameEdgeGlowOpacity", opacityLabel = "Frame edge glow opacity (%)", precision = 10 },
}
function ns.GetParticleValue(spec, kind)
    local key = spec[kind]
    local value = tonumber(ns.db and ns.db[key])
    if not value or value ~= value then value = ns.defaults[key] end
    local minimum = spec.min or (kind == "size" and 25 or 0)
    local maximum = spec.max or (kind == "count" and spec.maxCount or (kind == "size" and 400 or 100))
    local precision = spec.precision or 1
    local rounded = math.floor(math.max(minimum, math.min(maximum, value)) * precision + 0.5)
    return spec.precision and rounded / precision or rounded
end

-- Portrait calibration from the worksheet and in-game tuning (22 October 2026).
-- Values: depth, horizontal, vertical, scale %, mask %, viewport %, rotation degrees.
local portraitModelPresets = {
    Human = {
        [2] = { -0.08, 0.08, -0.02, 100, 93, 105, 0 },
        [3] = { -0.06, 0.06, 0, 100, 93, 105, -10 },
    },
    Dwarf = {
        [2] = { -0.12, 0.09, -0.06, 100, 93, 105, 6 },
        [3] = { -0.13, 0.07, -0.03, 100, 93, 105, 0 },
    },
    NightElf = {
        [2] = { -0.06, 0.12, -0.01, 100, 93, 105, 0 },
        [3] = { -0.08, 0.05, 0, 100, 93, 105, 1 },
    },
    Gnome = {
        [2] = { -0.06, 0.1, -0.03, 100, 93, 105, 0 },
        [3] = { -0.04, 0.12, -0.07, 100, 93, 105, -6 },
    },
    Orc = {
        [2] = { -0.31, 0.16, 0.01, 100, 93, 105, 0 },
        [3] = { -0.08, 0.14, -0.05, 100, 93, 105, -6 },
    },
    Scourge = {
        [2] = { -0.03, 0.05, 0, 100, 93, 105, 0 },
        [3] = { -0.23, 0.06, 0.04, 100, 93, 105, 7 },
    },
    Tauren = {
        [2] = { -0.37, 0.41, -0.07, 100, 93, 105, -4 },
        [3] = { -0.13, 0.23, -0.01, 100, 93, 105, -3 },
    },
    Troll = {
        [2] = { -0.05, 0.23, 0.06, 100, 93, 105, -10 },
        [3] = { -0.08, 0.19, 0, 100, 93, 105, -15 },
    },
    Skyborne = {
        [2] = { -0.1, 0.04, 0.03, 100, 93, 105, 9 },
        [3] = { -0.02, -0.02, 0, 100, 93, 105, -3 },
    },

    -- Retail presets are independent so each race can be calibrated separately.
    Haranir = {
        [2] = { -0.06, 0.12, -0.01, 100, 93, 105, 0 },
        [3] = { -0.08, 0.05, 0, 100, 93, 105, 1 },
    },
    Nightborne = {
        [2] = { -0.06, 0.12, -0.01, 100, 93, 105, 0 },
        [3] = { -0.08, 0.05, 0, 100, 93, 105, 1 },
    },
    DarkIronDwarf = {
        [2] = { -0.12, 0.09, -0.06, 100, 93, 105, 6 },
        [3] = { -0.13, 0.07, -0.03, 100, 93, 105, 0 },
    },
    EarthenDwarf = {
        [2] = { -0.12, 0.09, -0.06, 100, 93, 105, 6 },
        [3] = { -0.13, 0.07, -0.03, 100, 93, 105, 0 },
    },
    Mechagnome = {
        [2] = { -0.06, 0.1, -0.03, 100, 93, 105, 0 },
        [3] = { -0.04, 0.1, -0.08, 100, 93, 105, -6 },
    },
    BloodElf = {
        [2] = { -0.1, 0.04, 0.03, 100, 93, 105, 9 },
        [3] = { -0.02, -0.02, 0, 100, 93, 105, -3 },
    },
    VoidElf = {
        [2] = { -0.1, 0.04, 0.03, 100, 93, 105, 9 },
        [3] = { -0.02, -0.02, 0, 100, 93, 105, -3 },
    },
    HighmountainTauren = {
        [2] = { -0.37, 0.41, -0.07, 100, 93, 105, -4 },
        [3] = { -0.13, 0.23, -0.01, 100, 93, 105, -3 },
    },
    MagharOrc = {
        [2] = { -0.31, 0.16, 0.01, 100, 93, 105, 0 },
        [3] = { -0.08, 0.14, -0.05, 100, 93, 105, -6 },
    },
    ZandalariTroll = {
        [2] = { -0.05, 0.23, 0.06, 100, 93, 105, -10 },
        [3] = { -0.08, 0.19, 0, 100, 93, 105, -15 },
    },
    Goblin = {
        [2] = { -0.02, 0.06, 0.04, 100, 93, 105, -6 },
        [3] = { -0.05, 0.17, -0.03, 100, 93, 105, -4 },
    },
    Vulpera = {
        [2] = { -0.08, 0.13, 0.02, 100, 93, 105, 0 },
        [3] = { -0.04, 0.09, 0.01, 100, 93, 105, 0 },
    },
    Draenei = {
        [2] = { -0.26, 0.24, -0.01, 100, 93, 105, 1 },
        [3] = { 0.04, 0.01, -0.01, 100, 93, 105, 0 },
    },
    Worgen = {
        [2] = { -0.21, 0.1, 0, 100, 93, 105, 5 },
        [3] = { -0.18, 0.07, -0.08, 100, 93, 105, 4 },
    },
    Pandaren = {
        [2] = { -0.13, 0.19, -0.01, 100, 93, 105, -3 },
        [3] = { -0.08, 0.02, 0, 100, 93, 105, 6 },
    },
    LightforgedDraenei = {
        [2] = { -0.26, 0.24, -0.01, 100, 93, 105, 1 },
        [3] = { 0.04, 0.01, -0.01, 100, 93, 105, 0 },
    },
    KulTiran = {
        [2] = { -0.22, 0.17, 0, 100, 93, 105, 0 },
        [3] = { 0, 0, 0, 100, 93, 105, 0 },
    },
    Dracthyr = {
        [2] = { 0, 0, 0, 100, 93, 105, 0 },
        [3] = { 0, 0, 0, 100, 93, 105, 0 },
    },
    -- Humanoid forms have their own presets and saved Debug overrides.
    WorgenHuman = {
        [2] = { -0.08, 0.08, -0.02, 100, 93, 105, 0 },
        [3] = { -0.06, 0.06, 0, 100, 93, 105, -10 },
    },
    DracthyrVisage = {
        [2] = { -0.16, 0.08, 0, 100, 93, 105, 0 },
        [3] = { -0.16, 0.08, 0, 100, 93, 105, 0 },
    },
}
local portraitModelIndexes = {
    portraitModelX = 1, portraitModelY = 2, portraitModelZ = 3,
    portraitModelScale = 4, portraitModelMaskSize = 5,
    portraitModelViewportSize = 6, portraitModelRotation = 7,
}
local portraitRaceIDs = { [1] = "Human", [2] = "Orc", [3] = "Dwarf",
    [4] = "NightElf", [5] = "Scourge", [6] = "Tauren", [7] = "Gnome", [8] = "Troll",
    [9] = "Goblin", [10] = "BloodElf", [11] = "Draenei", [22] = "Worgen",
    [24] = "Pandaren", [25] = "Pandaren", [26] = "Pandaren",
    [27] = "Nightborne", [28] = "HighmountainTauren", [29] = "VoidElf",
    [30] = "LightforgedDraenei", [31] = "ZandalariTroll", [32] = "KulTiran",
    [34] = "DarkIronDwarf", [35] = "Vulpera", [36] = "MagharOrc", [37] = "Mechagnome",
    [52] = "Dracthyr", [70] = "Dracthyr", [84] = "EarthenDwarf", [85] = "EarthenDwarf",
    [86] = "Haranir",
}
local portraitRaceAliases = { Harronir = "Haranir", Earthen = "EarthenDwarf" }
local portraitIdentityReady, portraitIdentity, portraitPreset

function ns.RefreshPlayerModelIdentity()
    local name, token, raceID
    if UnitRace then name, token, raceID = UnitRace("player") end
    local sex = UnitSex and UnitSex("player")
    token = portraitRaceAliases[token] or token
    name = portraitRaceAliases[name] or name
    -- Prefer the client token, including custom races, before standard race IDs.
    local race = portraitModelPresets[token] and token
        or (portraitModelPresets[name] and name) or portraitRaceIDs[raceID]
    if (race == "Worgen" or race == "Dracthyr") and C_PlayerInfo
        and type(C_PlayerInfo.GetAlternateFormInfo) == "function" then
        local ok, hasAlternateForm, inAlternateForm = pcall(C_PlayerInfo.GetAlternateFormInfo)
        if ok and hasAlternateForm and inAlternateForm then
            race = race == "Worgen" and "WorgenHuman" or "DracthyrVisage"
        end
    end
    local previousIdentity = portraitIdentity
    portraitPreset = race and portraitModelPresets[race][sex]
    portraitIdentity = portraitPreset and (race .. ":" .. sex) or nil
    portraitIdentityReady = true
    return portraitIdentity ~= previousIdentity
end

function ns.GetPlayerModelSetting(key)
    if not portraitIdentityReady then ns.RefreshPlayerModelIdentity() end
    local index = portraitModelIndexes[key]
    if portraitPreset and index then
        local all = GnomeLevelUpCharacterDB and GnomeLevelUpCharacterDB.portraitModelTuning
        local tuning = type(all) == "table" and all[portraitIdentity]
        local value = type(tuning) == "table" and tonumber(tuning[key])
        if value and value == value and value ~= math.huge and value ~= -math.huge then return value end
        return portraitPreset[index]
    end
    return tonumber(ns.db and ns.db[key]) or ns.defaults[key]
end

function ns.SetPlayerModelSetting(key, value)
    if not portraitModelIndexes[key] then return end
    ns.RefreshPlayerModelIdentity()
    if portraitIdentity then
        -- Calibration belongs to this character, not a shared appearance profile.
        GnomeLevelUpCharacterDB = GnomeLevelUpCharacterDB or {}
        local all = GnomeLevelUpCharacterDB.portraitModelTuning
        if type(all) ~= "table" then all = {}; GnomeLevelUpCharacterDB.portraitModelTuning = all end
        if type(all[portraitIdentity]) ~= "table" then all[portraitIdentity] = {} end
        all[portraitIdentity][key] = value
    else
        ns.db[key] = value
    end
end

ns.MODEL_SETTINGS = {
    { key = "portraitModelRotation", label = "3D model rotation (degrees)", min = -180, max = 180 },
    { key = "portraitModelX", label = "3D model depth", min = -5, max = 5 },
    { key = "portraitModelY", label = "3D model horizontal position", min = -5, max = 5 },
    { key = "portraitModelZ", label = "3D model vertical position", min = -5, max = 5 },
    { key = "portraitModelScale", label = "3D model scale (%)", min = 25, max = 300 },
    { key = "portraitModelMaskSize", label = "3D mask size (%)", min = 25, max = 300 },
    { key = "portraitModelViewportSize", label = "3D viewport size (%)", min = 25, max = 300 },
}

ns.PORTRAIT_CHOICES = {
    { value = "none", label = "None" },
    { value = "class",  label = "Class icon" },
    { value = "player", label = "Player portrait" },
    { value = "player3d", label = "Player 3D portrait" },
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

function ns.CanAdjustSoundVolume()
    if ns.UsesNativeLevelUpSound() or ns.GetCurrentFlavor() ~= "retail"
        or not C_Sound or type(C_Sound.PlaySound) ~= "function" then return false end
    if ns.db.customSoundFile and ns.db.customSoundFile ~= "" then return false end
    for _, choice in ipairs(ns.SOUND_CHOICES) do
        if choice.value == ns.db.soundChoice then return choice.id ~= nil end
    end
    return false
end

function ns.SoundSelectionChanged()
    ns.StopPreviewSound()
    ns.ApplyAddonState(false)
    ns.RefreshOptionsPanel()
end

local function SoundFileID(choice)
    if choice.retailFileID and ns.GetCurrentFlavor() == "retail" then return choice.retailFileID end
    return choice.fileID
end

local function PlaySoundKitWithVolume(soundKitID, channel)
    local volume = SoundVolume()
    -- volumeOverride was added to C_Sound.PlaySound after the older client
    -- API. Probe it safely and fall back to the legacy function when absent.
    if ns.CanAdjustSoundVolume() then
        local ok, success, handle = pcall(C_Sound.PlaySound, soundKitID, channel, false, false, nil, volume)
        if ok and success ~= nil then return success, handle end
    end
    if type(PlaySound) == "function" then
        return PlaySound(soundKitID, channel)
    end
end

local previewSoundHandle
function ns.StopPreviewSound()
    if previewSoundHandle and type(StopSound) == "function" then pcall(StopSound, previewSoundHandle) end
    previewSoundHandle = nil
end

function ns.PlayLevelUpSound(force)
    -- Play a custom sound or one of the built-in sounds.
    local db = ns.db or {}
    if force or ns.UsesNativeLevelUpSound() then ns.StopPreviewSound() end
    if ns.UsesNativeLevelUpSound() then
        if ns.SetGnomeLevelUpSoundMuted then ns.SetGnomeLevelUpSoundMuted(false) end
        return
    end
    if db.playSound == false and not force then return end
    if ns.CanAdjustSoundVolume() and SoundVolume() == 0 then return end

    local function PlaySelectedSound()
        local channel = db.soundChannel or "Master"
        if db.customSoundFile and db.customSoundFile ~= "" then
            local ok, success, handle = pcall(PlaySoundFile, db.customSoundFile, channel)
            if ok and success then return success, handle end
        end

        local wanted = db.soundChoice or "LEVELUP"
        for _, choice in ipairs(ns.SOUND_CHOICES) do
            if choice.value == wanted then
                local ok, success, handle
                local fileID = SoundFileID(choice)
                if fileID then ok, success, handle = pcall(PlaySoundFile, fileID, channel)
                elseif choice.id then ok, success, handle = pcall(PlaySoundKitWithVolume, choice.id, channel)
                elseif choice.path then ok, success, handle = pcall(PlaySoundFile, choice.path, channel) end
                if ok and success then return success, handle end
            end
        end
        local defaultChoice = ns.SOUND_CHOICES[1]
        local defaultFileID = SoundFileID(defaultChoice)
        if defaultFileID then return PlaySoundFile(defaultFileID, channel)
        elseif defaultChoice.id then return PlaySoundKitWithVolume(defaultChoice.id, channel) end
    end

    local success, handle = PlaySelectedSound()
    if force and success then previewSoundHandle = handle end
end


local animationSoundHandles = {}
function ns.GetAnimationSoundID(cue)
    local key = "animationSound_" .. cue
    local value = ns.db and ns.db[key]
    if type(value) ~= "number" or value ~= value or value < 0 or value > 2147483647 or value % 1 ~= 0 then
        return defaults[key] or 0
    end
    return value
end

function ns.SetAnimationSoundID(cue, value)
    local key = "animationSound_" .. cue
    value = tonumber(value)
    if defaults[key] == nil or not value or value ~= value or value < 0 or value > 2147483647 or value % 1 ~= 0 then return false end
    ns.StopAnimationSound(cue)
    ns.db[key] = value
    return true
end

function ns.StopAnimationSound(cue)
    local handle = animationSoundHandles[cue]
    if handle and type(StopSound) == "function" then pcall(StopSound, handle) end
    animationSoundHandles[cue] = nil
end

function ns.StopAnimationSounds()
    for cue in pairs(animationSoundHandles) do ns.StopAnimationSound(cue) end
end

-- Classic Mode is an override; saved per-effect choices resume when it is off.
ns.CLASSIC_FLAIR_SETTINGS = {
    milestoneAnimations = "Milestone Animations", maxLevelCelebration = "Max Level Celebration",
    portraitAnimation = "Portrait pulse and starburst", portraitRingGlint = "Portrait ring glint",
    portraitRingSettle = "Portrait and ring settle", highlightNewAbilities = "Highlight new abilities",
    emphasizeStatGains = "Emphasize stat gains", portraitSparks = "Portrait motes",
    backgroundEmbers = "Background motes", frameEdgeGlow = "Frame edge glow",
    dividerReveal = "Reveal dividers", backgroundAnimations = "Background animations",
}
for _, spec in ipairs(ns.EXTRA_EFFECTS) do ns.CLASSIC_FLAIR_SETTINGS[spec.key] = spec.label end

function ns.PlayAnimationSound(cue)
    local id = ns.GetAnimationSoundID(cue)
    if id == 0 or not ns.db or ns.db.enabled == false or ns.db.reducedMotion
        or ns.db.backgroundAnimations == false or type(PlaySoundFile) ~= "function" then return end
    ns.StopAnimationSound(cue)
    local ok, success, handle = pcall(PlaySoundFile, id, ns.db.soundChannel or "Master")
    if ok and success then animationSoundHandles[cue] = handle end
end

function ns.StopPortraitImpactSound() ns.StopAnimationSound("portraitImpact") end
function ns.PlayPortraitImpactSound()
    ns.PlayAnimationSound("portraitImpact")
end
function ns.StopStarburstSound() ns.StopAnimationSound("starburst") end
function ns.PlayStarburstSound()
    ns.PlayAnimationSound("starburst")
end

local function AddPreviewEntries(target, source, limit)
    for _, entry in ipairs(source or {}) do
        if #target >= limit then break end
        target[#target + 1] = entry
    end
end

local function BuildPreviewAbilityExamples()
    local previewCost = 1337 * 10000
    local abilities = {
        { id = 11362, name = "Teleport to Gnomeregan", cost = previewCost, trainingRank = 1, isNewAbility = true, preview = true },
        { id = 432423, name = "Gnomeregan Smash", cost = previewCost, trainingRank = 2, isNewAbility = false, preview = true },
        { id = 1459, name = "Arcane Intellect", cost = previewCost, trainingRank = 1, isNewAbility = true, preview = true },
    }
    if ns.GetCurrentFlavor() == "retail" then
        abilities[1].id, abilities[2].id = 463715, 463551
        abilities[3].id = 463707
        for _, ability in ipairs(abilities) do
            ability.trainingRank, ability.isNewAbility = nil, true
            local name
            if C_Spell and type(C_Spell.GetSpellName) == "function" then
                local ok, value = pcall(C_Spell.GetSpellName, ability.id)
                if ok then name = value end
            end
            if not name and C_Spell and type(C_Spell.GetSpellInfo) == "function" then
                local ok, info = pcall(C_Spell.GetSpellInfo, ability.id)
                if ok and info then name = info.name end
            end
            ability.name = name or ("Spell " .. ability.id)
        end
    end
    return abilities
end

local function BuildDebugAbilityPreview(currentLevel, limit)
    local previewCost = 1337 * 10000
    local abilities = BuildPreviewAbilityExamples()
    for i = #abilities, limit + 1, -1 do abilities[i] = nil end
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
            isNewAbility = flavor == "retail" or nil,
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
            trainingRank = grimoire.rank,
            isNewAbility = grimoire.rank == nil or grimoire.rank == 1,
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

function ns.GetLevelCap()
    if ns.GetCurrentFlavor() == "forever" then return 60 end
    for _, name in ipairs({ "GetMaxLevelForPlayerExpansion", "GetMaxPlayerLevel" }) do
        local query = rawget(_G, name)
        if type(query) == "function" then
            local ok, level = pcall(query)
            if ok and type(level) == "number" and level > 0 and level < math.huge then return math.floor(level) end
        end
    end
    return nil
end

function ns.PreviewLevelUp(debugSkills, milestoneLevel, maxLevelPreview, abilityCount, paceScenario, rangeStart)
    -- Use a predictable example so the options preview does not depend on live data.
    EnsureDatabase()
    -- A preview does not fire PLAYER_LEVEL_UP, so queue the popup cleanup below.
    local currentLevel = maxLevelPreview and ns.GetLevelCap() or milestoneLevel or UnitLevel("player")

    local trainerAbilities = {}
    if debugSkills or abilityCount then
        trainerAbilities = BuildDebugAbilityPreview(currentLevel, abilityCount or 15)
    else
        -- Include client-appropriate examples without requiring trainer data.
        trainerAbilities = BuildPreviewAbilityExamples()
    end

    local unlearnedWeaponSkills = ns.GetUnlearnedWeaponSkills(currentLevel)
    local _, classToken = UnitClass("player")
    local warlockPetAbilities = {}
    local forever = ns.GetCurrentFlavor() == "forever"
    if forever and debugSkills then
        warlockPetAbilities = BuildDebugGrimoirePreview(15)
    elseif forever and classToken == "WARLOCK" then
        warlockPetAbilities[1] = {
            name = "Firebolt (Rank 2)",
            icon = 133738,
            cost = 1337 * 10000,
            itemID = 16302,
            kind = "warlockPet",
            trainingRank = 2,
            isNewAbility = false,
            preview = true,
        }
    end
    if ns.SuppressBlizzardBanner then ns.SuppressBlizzardBanner() end
    local previewStats = {
        { name = STRENGTH or "Strength", old = 20, new = 23 },
        { name = STAMINA or "Stamina", old = 22, new = 27 },
        { name = INTELLECT or "Intellect", old = 15, new = 17 },
        { name = _G["AGILITY"] or "Agility", old = 18, new = 19 },
        { name = _G["SPIRIT"] or "Spirit", old = 16, new = 18 },
        { name = _G["HEALTH"] or "Health", old = 200, new = 217, kind = "health" },
    }
    if ns.PlayerUsesMana() then
        previewStats[#previewStats+1] = { name = _G["MANA"] or "Mana", old = 150, new = 170, kind = "mana" }
    end
    if maxLevelPreview then
        previewStats = ns.BuildMaxLevelPreviewStats()
    elseif ns.previewStatRange then
        -- Use the no-argument RNG: integer bounds can overflow on Lua 5.1.
        local function RandomTotal(low, high)
            if high <= low then return high end
            local span = high - low
            return low + math.min(span, math.floor(math.random() * (span + 1)))
        end
        for index, stat in ipairs(previewStats) do
            if index == 1 then -- Strength is the exact reference row.
                stat.old, stat.new = ns.previewStatRange.old, ns.previewStatRange.new
            else
                stat.old = RandomTotal(1, ns.previewStatRange.old)
                stat.new = RandomTotal(math.max(1, stat.old), ns.previewStatRange.new)
            end
        end
    end
    local seconds = ns.GetCurrentLevelPlayedTime and ns.GetCurrentLevelPlayedTime()
    local previous
    if paceScenario then
        seconds = 110
        previous = paceScenario == "slower" and 90 or paceScenario == "best" and 140 or nil
    end
    ns.ShowLevelUp(currentLevel, previewStats, trainerAbilities, unlearnedWeaponSkills, seconds, warlockPetAbilities,
        true, milestoneLevel ~= nil or maxLevelPreview == true, previous, maxLevelPreview, paceScenario ~= nil, rangeStart, ns.db.showSecondaryStats and ns.BuildSecondaryPreviewStats() or nil)
    if ns.QueueBlizzardSuppression then ns.QueueBlizzardSuppression() end
end


local frame = CreateFrame("Frame")
ns.eventFrame = frame

-- Wait until the loading screen has released the UI before opening setup.
-- A newer world/loading event supersedes an older queued check.
local setupCheckToken = 0
local setupLoading = true
local function QueueFirstTimeSetup()
    setupCheckToken = setupCheckToken + 1
    if ns.db and ns.db.firstTimeSetupCompleted then return end
    local token = setupCheckToken
    local function check()
        if token ~= setupCheckToken or setupLoading then return end
        if ns.ShowFirstTimeSetupIfNeeded then ns.ShowFirstTimeSetupIfNeeded() end
    end
    if C_Timer and C_Timer.After then C_Timer.After(1, check) else check() end
end

frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("PLAYER_REGEN_ENABLED")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("LOADING_SCREEN_ENABLED")
frame:RegisterEvent("LOADING_SCREEN_DISABLED")
frame:RegisterEvent("PLAYER_LEVEL_UP")

frame:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" then
        local loadedAddon = ...
        if loadedAddon == ADDON_NAME then
            InitDB()
            if ns.InitializeProfiles then ns.InitializeProfiles() end
            ns.SetLocale(ns.db.language)
            if ns.RefreshLocalizedPopupText then ns.RefreshLocalizedPopupText() end
            if ns.InitializeOptions then ns.InitializeOptions() end
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
        QueueFirstTimeSetup()
        ns.ApplyAddonState(false)
        if ns.SyncClassColors then ns.SyncClassColors() elseif ns.ApplyColors then ns.ApplyColors() end
        if ns.RefreshBaseline then
            ns.RefreshBaseline()
        end
        if ns.GetTrainerCatalogIndex and #ns.GetTrainerCatalogIndex() > 0
            and ns.MarkKnownTrainerSkills and ns.SnapshotSpellBook then
            ns.MarkKnownTrainerSkills(ns.SnapshotSpellBook())
        end
    elseif event == "LOADING_SCREEN_ENABLED" then
        setupLoading = true
        setupCheckToken = setupCheckToken + 1
    elseif event == "LOADING_SCREEN_DISABLED" then
        setupLoading = false
        QueueFirstTimeSetup()
    elseif event == "PLAYER_REGEN_ENABLED" then
        QueueFirstTimeSetup()
    elseif event == "PLAYER_ENTERING_WORLD" then
        QueueFirstTimeSetup()
        ns.ApplyAddonState(false)
        if ns.SyncClassColors then ns.SyncClassColors() elseif ns.ApplyColors then ns.ApplyColors() end
    elseif event == "PLAYER_LEVEL_UP" then
        if ns.HandleLevelUp then
            ns.HandleLevelUp(...)
        end
    end
end)


local function PrintSettingStatus(label, enabled)
    print("|cff3fe0ffGnomeLevelUp|r: " .. ns.L(label) .. ": " .. ns.L(enabled and "On" or "Off"))
end

SLASH_GNOMELEVELUP1 = "/glu"
SlashCmdList["GNOMELEVELUP"] = function(msg)
    EnsureDatabase()
    msg = (msg or ""):lower()
    msg = msg:match("^%s*(.-)%s*$") -- trim

    if msg == "firsttime" then
        if ns.OpenFirstTimeSetup then ns.OpenFirstTimeSetup() end
    elseif msg == "controlleroptions" then
        if ns.ToggleControllerOptions then ns.ToggleControllerOptions(true, true) end
    elseif msg == "debugskills" then
        ns.PreviewLevelUp(true)
    elseif msg == "testlevels" or msg:match("^testlevels%s") then
        if not ns.IsDebugEnabled() then
            print("|cff3fe0ffGnomeLevelUp|r: " .. ns.L("Enable debug commands") .. ": /glu debug on")
            return
        end
        local fromText, toText, countText = msg:match("^testlevels%s+(%d+)%s+(%d+)%s*(%d*)$")
        local from, to, count = tonumber(fromText), tonumber(toText), tonumber(countText) or 3
        local cap = ns.GetLevelCap() or 90
        if from and to and from >= 1 and to >= from + 2 and to <= cap and count >= 1 and count <= 30 then
            ns.PreviewLevelUp(false, to, to == cap, count, nil, from)
        else
            print("|cff3fe0ffGnomeLevelUp|r: /glu testlevels <from> <to> [1-30]")
        end
    elseif msg == "debugtime" or msg:match("^debugtime%s") then
        if not ns.IsDebugEnabled() then
            print("|cff3fe0ffGnomeLevelUp|r: " .. ns.L("Enable debug commands") .. ": /glu debug on")
            return
        end
        local scenario = msg:match("^debugtime%s+(%a+)$")
        if scenario == "new" or scenario == "slower" or scenario == "best" then
            ns.PreviewLevelUp(false, nil, nil, 3, scenario)
        else
            print("|cff3fe0ffGnomeLevelUp|r: /glu debugtime <new|slower|best>")
        end
    elseif msg == "debugstats" or msg:match("^debugstats%s") then
        if not ns.IsDebugEnabled() then
            print("|cff3fe0ffGnomeLevelUp|r: " .. ns.L("Enable debug commands") .. ": /glu debug on")
            return
        end
        local oldText, newText = msg:match("^debugstats%s+(%d+)%s+(%d+)$")
        local old, new = tonumber(oldText), tonumber(newText)
        if msg == "debugstats reset" then
            ns.previewStatRange = nil
            ns.PreviewLevelUp()
        elseif old and new and old >= 0 and new >= old and new <= 9007199254740991 then
            ns.previewStatRange = { old = old, new = new }
            ns.PreviewLevelUp()
        else
            print("|cff3fe0ffGnomeLevelUp|r: /glu debugstats <old total> <new total> or /glu debugstats reset (0–9007199254740991).")
        end
    elseif msg == "resettimers" then
        ns.ResetLevelTimers()
        print("|cff3fe0ffGnomeLevelUp|r: " .. ns.L("Recorded level timers and best times reset for this character."))
    elseif msg == "maxlevel" or msg:match("^maxlevel%s") then
        local count = msg == "maxlevel" and 3 or tonumber(msg:match("^maxlevel%s+(%d+)$"))
        if not count or count < 1 or count > 30 then
            print("|cff3fe0ffGnomeLevelUp|r: /glu maxlevel [1-30]")
            return
        end
        if not ns.IsDebugEnabled() then
            print("|cff3fe0ffGnomeLevelUp|r: " .. ns.L("Enable debug commands") .. ": /glu debug on")
        elseif ns.GetLevelCap() then
            ns.RequestLevelPlayedTime()
            ns.PreviewLevelUp(false, nil, true, count)
        else
            print("|cff3fe0ffGnomeLevelUp|r: the client did not report a level cap.")
        end
    elseif msg == "milestone" or msg:match("^milestone%s") then
        local levelText, countText = msg:match("^milestone%s+(%d+)%s+(%d+)$")
        local count = countText and tonumber(countText) or 3
        local level = msg == "milestone" and math.max(10, math.ceil(UnitLevel("player") / 10) * 10)
            or tonumber(levelText or msg:match("^milestone%s+(%d+)$"))
        if level and count >= 1 and count <= 30 and level >= 10 and level <= 1000 and level % 10 == 0 then
            ns.PreviewLevelUp(false, level, nil, count)
        else
            print("|cff3fe0ffGnomeLevelUp|r: /glu milestone [level] [1-30] — level: 10–1000, multiple of 10; default count: 3.")
        end
    elseif msg == "test" or msg:match("^test%s") then
        local count = msg == "test" and 3 or tonumber(msg:match("^test%s+(%d+)$"))
        if count and count >= 1 and count <= 30 then
            ns.PreviewLevelUp(false, nil, nil, count)
        else
            print("|cff3fe0ffGnomeLevelUp|r: /glu test [1-30]")
        end
    elseif msg == "sound" then
        ns.db.playSound = not ns.db.playSound
        PrintSettingStatus("Play sound on level up", ns.db.playSound)
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
            ns.ApplyAddonState(false)
            print("|cff3fe0ffGnomeLevelUp|r: mode set to " .. choice
                .. " (currently resolves to \"" .. ns.GetCurrentFlavor() .. "\")")
        else
            print("|cff3fe0ffGnomeLevelUp|r: currently \"" .. (ns.db.forceFlavor or "auto")
                .. "\" (resolves to \"" .. ns.GetCurrentFlavor() .. "\"). Use /glu mode <retail|forever|auto>")
        end
    elseif msg == "scan" then
        ns.db.autoScanTrainers = not ns.db.autoScanTrainers
        PrintSettingStatus("Automatically save trainer data", ns.db.autoScanTrainers)
    elseif msg:match("^scanprof") then
        ns.db.scanProfessionTrainers = not ns.db.scanProfessionTrainers
        if ns.InvalidateTrainerIndex then ns.InvalidateTrainerIndex() end
        PrintSettingStatus("Include profession trainers", ns.db.scanProfessionTrainers)
    elseif msg == "trainerreport" then
        if ns.OpenTrainerReport then ns.OpenTrainerReport() end
    elseif msg == "trainerreport clear" then
        if ns.ClearTrainerReports then ns.ClearTrainerReports() end
        print("|cff3fe0ffGnomeLevelUp|r: " .. ns.L("Trainer reports cleared."))
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
        PrintSettingStatus("Enable debug commands", ns.db.debugEnabled)
    elseif msg == "perf reset" or msg == "performance reset" then
        if ns.ResetPerformanceDiagnostics then ns.ResetPerformanceDiagnostics() end
        print("|cff3fe0ffGnomeLevelUp|r: performance counters reset")
    elseif msg == "perf" or msg == "performance" then
        if ns.PrintPerformanceDiagnostics then ns.PrintPerformanceDiagnostics() end
    elseif msg == "dumptraining" then
        if not ns.IsDebugEnabled() then
            print("|cff3fe0ffGnomeLevelUp|r: " .. ns.L("Enable debug commands") .. ": /glu debug on")
        elseif ns.DumpTrainerData then
            ns.DumpTrainerData()
        end
    elseif msg == "dumpskills" then
        if ns.DumpWeaponSkills then ns.DumpWeaponSkills() end
    elseif msg == "testtrainer" then
        if not ns.IsDebugEnabled() then
            print("|cff3fe0ffGnomeLevelUp|r: " .. ns.L("Enable debug commands") .. ": /glu debug on")
        elseif ns.TestTrainerList then
            ns.TestTrainerList()
        end
    elseif msg == "combat" then
        ns.db.waitForCombatEnd = not ns.db.waitForCombatEnd
        PrintSettingStatus("Don't show until combat ends", ns.db.waitForCombatEnd)
    elseif msg == "options" or msg == "config" then
        if ns.ToggleOptions then
            ns.ToggleOptions()
        end
    else
        print("|cff3fe0ffGnomeLevelUp|r commands:")
        print("  /glu test [1-30]   - preview the normal level-up screen with an ability count")
        print("  /glu milestone [level] [1-30] - preview milestone effects (e.g. 30 3; default count: 3)")
        print("  /glu maxlevel [1-30] - preview max-level celebration (debug mode)")
        print("  /glu testlevels <from> <to> [1-30] - preview combined level gains (debug mode)")
        print("  /glu options       - open the settings page (also under Options > AddOns)")
        print("  /glu sound         - toggle the level-up sound")
        print("  /glu duration N    - set how long the screen stays up (seconds)")
        print("  /glu mode <x>      - use retail/forever training data, or auto-detect")
        print("  /glu scan          - toggle auto-saving trainer data when you visit a trainer")
        print("  /glu scanprof      - toggle including profession trainers in that scan")
        print("  /glu trainerreport - export observed trainer catalogue changes")
        print("  /glu trainerreport clear - clear saved change reports")
        print("  /glu cleartraining - wipe all scanned trainer data (fixes old bad/duplicate entries)")
        print("  /glu debug [on|off] - enable or disable debug commands (off by default)")
        print("  /glu dumptraining - print cached skills and learned status")
        print("  /glu dumpskills    - print Skills-tab, equipped, and trainable weapon data")
        print("  /glu testtrainer   - print the current unlearned skill list")
        print("  /glu debugtime <new|slower|best> - preview level-time scenarios (debug mode)")
        print("  /glu debugstats <old> <new> | reset - exact Strength totals, randomized remaining stats (debug mode)")
        print("  /glu resettimers - clear this character's recorded level timers and best times")
        print("  /glu perf          - print debug performance diagnostics")
        print("  /glu perf reset    - clear performance counters")
        print("  /glu combat        - toggle waiting for combat to end before showing")
    end
end
