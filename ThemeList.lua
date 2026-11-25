local ADDON_NAME, ns = ...

local FONT_ROLES = { stats = true, headings = true, level = true, time = true,
    abilityCosts = true, timeline = true, body = true }
ns.THEME_FONT_ROLES = FONT_ROLES
ns.THEME_FONT_PARENTS = {
    title = "body", statsHeader = "headings", secondaryStatsHeader = "statsHeader",
    abilitiesHeader = "headings", petAbilitiesHeader = "headings",
    statLabel = "stats", statOld = "stats", statArrow = "stats", statNew = "stats", statDelta = "stats",
    recordLabel = "time", recordPrefix = "time", recordOld = "time", recordNew = "time",
    weaponSkills = "body", noAbilities = "body", petAbilityCosts = "abilityCosts",
    timelineLevel = "timeline", timelineUnlock = "timeline", closeButton = "body", pinGlyph = "body",
}
for role in pairs(ns.THEME_FONT_PARENTS) do FONT_ROLES[role] = true end
local themeFontLabels = {}

function ns.GetThemeFontLabel(path)
    return themeFontLabels[path]
end

local function DefaultFontSizes()
    local sizes = {}
    for role in pairs(FONT_ROLES) do sizes[role] = 0 end
    return sizes
end
ns.DefaultThemeFontSizes = DefaultFontSizes

local TEXTURE_ROOT = "Interface\\AddOns\\GnomeLevelUp\\Textures\\"
local function Texture(path)
    return TEXTURE_ROOT .. path:gsub("/", string.char(92))
end

local function Atlas(name, useAtlasSize)
    return { atlas = name, useAtlasSize = useAtlasSize == true }
end
ns.AtlasTexture = Atlas

-- --------------------------------------------------------------------------
-- Selectable asset registries
-- --------------------------------------------------------------------------

local PORTRAIT_RING_TEXTURES = {
    NONE = { label = "No portrait ring", texture = nil, scale = 1.10, offsetX = 0, offsetY = 0 },
    ALLIANCE = { label = "Alliance ring", texture = Texture("Backgrounds/ally-circle-frame.tga"), scale = 1.10, offsetX = 0, offsetY = 0 },
    HORDE = { label = "Horde ring", texture = Texture("Backgrounds/horde-circle-frame.tga"), scale = 1.10, offsetX = 0, offsetY = 0 },
    STEEL = { label = "Steel ring", texture = Texture("Backgrounds/circle-frame.tga"), glintRadius = .43, scale = 1.10, offsetX = 0, offsetY = 0 },
    COPPER = { label = "Copper ring", texture = Texture("Backgrounds/copper-circle-frame.tga"), glintRadius = .43, scale = 1.10, offsetX = 0, offsetY = 0 },
}
ns.PORTRAIT_RING_TEXTURES = PORTRAIT_RING_TEXTURES
ns.PORTRAIT_RING_CHOICES = {
    { value = "NONE", label = "No portrait ring" },
    { value = "ALLIANCE", label = "Alliance ring" },
    { value = "HORDE", label = "Horde ring" },
    { value = "COPPER", label = "Copper ring" },
    { value = "STEEL", label = "Steel ring" },
}
function ns.GetPortraitRingReference(name)
    local ring = PORTRAIT_RING_TEXTURES[name]
    return ring and ring.texture
end

local FRAME_TEXTURES = {
    TRELLIS = {
        label = "Trellis", cornerSize = 92, edgeSize = 39,
        cornerSizes = {
            topLeft = { width = 92, height = 69 },
            topRight = { width = 92, height = 69 },
            bottomLeft = { width = 113, height = 77 },
            bottomRight = { width = 113, height = 77 },
        },
        topLeft = Texture("Backgrounds/Trellis/trellis-tl.tga"),
        bottomLeft = Texture("Backgrounds/Trellis/trellis-bl.tga"),
        top = Texture("Backgrounds/Trellis/trellis-top.tga"),
        left = Texture("Backgrounds/Trellis/trellis-side.tga"),
        transforms = {
            bottomLeft = { rotation = 0, flipX = false, flipY = false },
            bottomRight = { rotation = 0, flipX = true, flipY = false },
            left = { rotation = 0, flipX = false, flipY = false },
            right = { rotation = 0, flipX = true, flipY = false },
        },
    },
    BLACK_METAL = {
        label = "Black Metal", cornerSize = 120, edgeSize = 40,
        topLeft = Texture("Backgrounds/Metal/metalblack-tl.tga"),
        top = Texture("Backgrounds/Metal/metalblack-top.tga"),
        left = Texture("Backgrounds/Metal/metalblack-left.tga"),
    },
    WOOD_PANEL = {
        label = "Wood Panel", cornerSize = 100, edgeSize = 27,
        topLeft = Texture("Backgrounds/Wood/wood-corner.tga"),
        top = Texture("Backgrounds/Wood/wood-top.tga"),
        left = Texture("Backgrounds/Wood/wood-left.tga"),
    },
    ALLIANCE = {
        label = "Alliance", cornerSize = 163, edgeSize = 28,
        topLeft = Texture("Backgrounds/Alliance/allyframe-corner.tga"),
        top = Texture("Backgrounds/Alliance/allyframe-top.tga"),
        left = Texture("Backgrounds/Alliance/allyframe-side.tga"),
    },
    HORDE = {
        label = "Horde", cornerSize = 163, edgeSize = 28,
        topLeft = Texture("Backgrounds/Horde/hordecorner.tga"),
        top = Texture("Backgrounds/Horde/hordetop.tga"),
        left = Texture("Backgrounds/Horde/hordeside.tga"),
    },
    GNOMEREGAN = {
        label = "Gnomeregan", cornerSize = 163, edgeSize = 26,
        topLeft = Texture("Backgrounds/Gnome Metal/gnomer-corner.tga"),
        top = Texture("Backgrounds/Gnome Metal/gnomer-top.tga"),
        left = Texture("Backgrounds/Gnome Metal/gnomer-side.tga"),
    },
}
ns.FRAME_TEXTURES = FRAME_TEXTURES
ns.FRAME_CHOICES = {
    { value = "TRELLIS", label = "Trellis" },
    { value = "BLACK_METAL", label = "Black Metal" },
    { value = "WOOD_PANEL", label = "Wood Panel" },
    { value = "ALLIANCE", label = "Alliance" },
    { value = "HORDE", label = "Horde" },
    { value = "GNOMEREGAN", label = "Gnomeregan" },
}
function ns.GetFrameReference(name)
    return FRAME_TEXTURES[name]
end

local BACKGROUND_TEXTURES = {
    -- Interface/Glues/CharacterSelect/GlueAnnouncementPopupBackground.blp
    SCRATCHED_STONE = { label = "Scratched Stone", center = 3775278, width = 512, height = 512, defaultStyle = "fill", defaultHue = { 176/255, 176/255, 176/255 } },
    -- Interface/FrameGeneral/UIFrameMarineBackground.blp
    CORAL = { label = "Coral", center = 2921659, width = 512, height = 512, defaultStyle = "tile" },
    SOLID = { label = "Solid Colour", center = "Interface\\Buttons\\WHITE8X8", defaultStyle = "stretch" },
    BLACK_METAL = { label = "Black Metal", center = Texture("Backgrounds/Metal/warwithinbackground.tga"), width = 256, height = 256 },
    WOOD_PANEL = { label = "Wood Panel", center = Texture("Backgrounds/Wood/uiframehordebackground.tga"), width = 256, height = 256 },
    ALLIANCE = { label = "Alliance Brick", center = Texture("Backgrounds/Alliance/allyframe-bg.tga"), width = 256, height = 256, defaultStyle = "tile" },
    GNOMEREGAN = { label = "Gnomeregan", center = Texture("Backgrounds/Gnome Metal/gnomer-bg.tga"), width = 400, height = 400, defaultStyle = "fill" },
}
ns.BACKGROUND_TEXTURES = BACKGROUND_TEXTURES
ns.BACKGROUND_TEXTURE_CHOICES = {
    { value = "SCRATCHED_STONE", label = "Scratched Stone" },
    { value = "CORAL", label = "Coral" },
    { value = "SOLID", label = "Solid Colour" },
    { value = "BLACK_METAL", label = "Black Metal" },
    { value = "WOOD_PANEL", label = "Wood Panel" },
    { value = "ALLIANCE", label = "Alliance Brick" },
    { value = "GNOMEREGAN", label = "Gnomeregan" },
}
function ns.GetBackgroundReference(name)
    return BACKGROUND_TEXTURES[name]
end

-- --------------------------------------------------------------------------
-- Theme declarations
-- --------------------------------------------------------------------------

local THEME_DEFINITIONS = {
    { value = "Trellis", label = "Trellis", portraitRing = "COPPER", frame = "TRELLIS", background = "WOOD_PANEL", backgroundStyle = "tile" },
    { value = "Black Metal", label = "Black Metal", portraitRing = "NONE", frame = "BLACK_METAL", background = "BLACK_METAL", backgroundStyle = "tile" },
    { value = "Wood Panel", label = "Wood Panel", portraitRing = "COPPER", frame = "WOOD_PANEL", background = "WOOD_PANEL", backgroundStyle = "tile" },
    { value = "Alliance", label = "Alliance", portraitRing = "ALLIANCE", frame = "ALLIANCE", background = "ALLIANCE", backgroundStyle = "tile" },
    { value = "Horde", label = "Horde", portraitRing = "HORDE", frame = "HORDE", background = "WOOD_PANEL", backgroundStyle = "tile" },
    { value = "Gnomeregan", label = "Gnomeregan", portraitRing = "STEEL", frame = "GNOMEREGAN", background = "GNOMEREGAN", backgroundStyle = "fill" },
}

ns.THEME_CHOICES = {
    { value = "MODERN", label = "Modern" },
    { value = "Black Metal", label = "Black Metal" },
    { value = "Wood Panel", label = "Wood Panel" },
    { value = "Alliance", label = "Alliance" },
    { value = "Horde", label = "Horde" },
    { value = "Gnomeregan", label = "Gnomeregan" },
    { value = "Trellis", label = "Trellis" },
}

local function Copy(value)
    if type(value) ~= "table" then return value end
    local out = {}
    for key, child in pairs(value) do out[key] = Copy(child) end
    return out
end

local SHARED_TRANSFORMS = {
    topLeft = { rotation = 0, flipX = false, flipY = false },
    top = { rotation = 0, flipX = false, flipY = false },
    topRight = { rotation = 0, flipX = true, flipY = false },
    left = { rotation = 0, flipX = false, flipY = false },
    center = { rotation = 0, flipX = false, flipY = false },
    right = { rotation = 0, flipX = true, flipY = false },
    bottomLeft = { rotation = 90, flipX = false, flipY = false },
    bottom = { rotation = 0, flipX = false, flipY = true },
    bottomRight = { rotation = 180, flipX = false, flipY = false },
}

-- Frame-specific defaults also apply when selecting a frame independently.
function ns.GetFrameTransforms(frameName)
    local transforms = Copy(SHARED_TRANSFORMS)
    local frame = FRAME_TEXTURES[frameName]
    for key, transform in pairs(frame and frame.transforms or {}) do
        transforms[key] = Copy(transform)
    end
    return transforms
end

local function Appearance(ringName, backgroundStyle)
    local ring = PORTRAIT_RING_TEXTURES[ringName] or PORTRAIT_RING_TEXTURES.NONE
    return {
        playerPortraitPosition = { x = 0, y = 0 },
        playerPortraitScale = 1.0,
        portraitRingEnabled = ring.texture ~= nil,
        portraitRingTexture = ring.texture,
        portraitRingChoice = PORTRAIT_RING_TEXTURES[ringName] and ringName or "NONE",
        portraitRingScale = ring.scale or 1.10,
        portraitRingOffset = { x = ring.offsetX or 0, y = ring.offsetY or 0 },
        bgOpacity = 0.95,
        backgroundColor = { 0, 0, 0 },
        frameColor = { 1, 1, 1 },
        portraitRingColor = { 1, 1, 1 },
        backgroundStyle = backgroundStyle or "tile",
        backgroundFillMode = backgroundStyle == "tile" and "tile" or "scale",
        backgroundTextureColors = {
            topLeft = { 1, 1, 1 }, top = { 1, 1, 1 }, topRight = { 1, 1, 1 },
            left = { 1, 1, 1 }, center = { 1, 1, 1 }, right = { 1, 1, 1 },
            bottomLeft = { 1, 1, 1 }, bottom = { 1, 1, 1 }, bottomRight = { 1, 1, 1 },
        },
        backgroundTextureTransforms = Copy(SHARED_TRANSFORMS),
        customFontPath = false,
        themeFontSizes = DefaultFontSizes(),
        themeFontSizeOffsets = DefaultFontSizes(),
        themeFontSizeOffset = 0,
        frameStrata = "HIGH",
        framePosition = { point = "CENTER", relativePoint = "CENTER", x = 0, y = 90 },
        lockFramePosition = false,
        sectionPadding = 8,
        scale = 1.0,
        compactMode = false,
    }
end

local function ResolveTheme(frameName, backgroundName, ringName, style, value, label)
    local frame = FRAME_TEXTURES[frameName]
    local background = BACKGROUND_TEXTURES[backgroundName]
    if not frame or not background then return nil end
    local textures = {
        topLeft = frame.topLeft, top = frame.top, topRight = frame.topRight or frame.topLeft,
        left = frame.left, center = background.center, right = frame.right or frame.left,
        bottomLeft = frame.bottomLeft or frame.topLeft, bottom = frame.bottom or frame.top,
        bottomRight = frame.bottomRight or frame.bottomLeft or frame.topLeft,
    }
    local appearance = Appearance(ringName or "NONE", style or background.defaultStyle or "tile")
    appearance.backgroundTextureTransforms = ns.GetFrameTransforms(frameName)
    return {
        value = value or "CUSTOM", label = label or "Custom",
        frameName = frameName, backgroundName = backgroundName,
        cornerSize = frame.cornerSize, cornerSizes = Copy(frame.cornerSizes),
        edgeSize = frame.edgeSize, edgeMaskInset = frame.edgeMaskInset or 5,
        backgroundInset = frame.backgroundInset or 0,
        textures = textures,
        appearance = appearance,
    }
end

-- Resolved declarations are read-only. Mutable appearance settings are copied
-- into the player's DB by the selection helpers, never written into this cache.
local compositeThemes = {}
function ns.GetCompositeTheme(frameName, backgroundName)
    if not FRAME_TEXTURES[frameName] or not BACKGROUND_TEXTURES[backgroundName] then return nil end
    local frames = compositeThemes[frameName]
    if not frames then frames = {}; compositeThemes[frameName] = frames end
    local theme = frames[backgroundName]
    if not theme then
        theme = ResolveTheme(frameName, backgroundName, "NONE", nil)
        frames[backgroundName] = theme
    end
    return theme
end

ns.CUSTOM_BACKGROUND_THEMES = {}
for _, definition in ipairs(THEME_DEFINITIONS) do
    ns.CUSTOM_BACKGROUND_THEMES[#ns.CUSTOM_BACKGROUND_THEMES + 1] = ResolveTheme(
        definition.frame, definition.background, definition.portraitRing,
        definition.backgroundStyle, definition.value, definition.label)
end

-- Public helper for migration and callers that need a named declaration.
function ns.GetThemeDefinition(value)
    for _, definition in ipairs(THEME_DEFINITIONS) do
        if definition.value == value then return definition end
    end
end

-- A pack's folder and local ID form the saved key for its theme and custom assets.
local PACK_PREFIX = "GLUTheme:"
local registeredPacks = {}
function ns.IsThemePackKey(key)
    return type(key) == "string" and key:sub(1, #PACK_PREFIX) == PACK_PREFIX
end

local function MissingPackAsset(registry, key)
    return not registry[key] and ns.IsThemePackKey(key)
end

function ns.GetEffectiveBackgroundMode()
    local db = ns.db
    if not db then return "MODERN" end
    if db.backgroundMode == "CUSTOM" and (MissingPackAsset(registeredPacks, db.backgroundTheme)
        or MissingPackAsset(FRAME_TEXTURES, db.frameChoice)
        or MissingPackAsset(BACKGROUND_TEXTURES, db.backgroundChoice)) then return "MODERN" end
    return db.backgroundMode
end

function ns.HasPortraitRingArtwork()
    local db = ns.db
    return db and db.portraitRingEnabled == true and not MissingPackAsset(PORTRAIT_RING_TEXTURES, db.portraitRingChoice)
end

function ns.GetSelectedPortraitRingReference()
    local db = ns.db or {}
    local reference = db.portraitRingTexture
    if ns.IsThemePackKey(db.portraitRingChoice) or type(reference) ~= "string" or reference == "" then
        return ns.GetPortraitRingReference(db.portraitRingChoice)
    end
    return reference
end

local function PackAsset(addonName, path, extensions)
    if type(path) ~= "string" then return nil end
    path = path:gsub("/", "\\")
    if #path > 220 or not path:match("^[%w_][%w_%. %-\\]*$") or path:find("..", 1, true) then return nil end
    local extension = path:lower():match("%.(%a+)$")
    if extensions[extension] then return "Interface\\AddOns\\" .. addonName .. "\\" .. path end
end

local function PackTexture(addonName, path)
    return PackAsset(addonName, path, { tga = true, blp = true })
end

local function InRange(value, minimum, maximum)
    return type(value) == "number" and value >= minimum and value <= maximum
end

local function ReadHue(hue)
    if type(hue) == "table" and InRange(hue[1], 0, 1) and InRange(hue[2], 0, 1) and InRange(hue[3], 0, 1) then
        return { hue[1], hue[2], hue[3] }
    end
end

local function InvalidField(field, expected)
    return nil, field .. ": " .. expected
end

local function Default(value, fallback)
    if value == nil then return fallback end
    return value
end

local BUILTIN_THEME_FONTS = {
    FRIZQT = "Fonts\\FRIZQT__.TTF", ARIALN = "Fonts\\ARIALN.TTF",
    MORPHEUS = "Fonts\\MORPHEUS.TTF", SKURRI = "Fonts\\SKURRI.TTF",
}

local function ReadPackFont(addonName, font)
    if font == nil then return false end
    if type(font) == "string" and BUILTIN_THEME_FONTS[font] then return BUILTIN_THEME_FONTS[font] end
    local path = PackAsset(addonName, font, { ttf = true, otf = true })
    if not path then
        return InvalidField("font", "expected FRIZQT, ARIALN, MORPHEUS, SKURRI, or a relative .ttf/.otf path inside the theme addon")
    end
    return path, nil, true
end

local function ReadPackFontSizes(sizes, offsets)
    local result = DefaultFontSizes()
    if sizes == nil then return result end
    if type(sizes) ~= "table" then return InvalidField(offsets and "fontSizeOffsets" or "fontSizes", "expected a table of popup text roles") end
    for role, size in pairs(sizes) do
        local field = (offsets and "fontSizeOffsets." or "fontSizes.") .. tostring(role)
        if not FONT_ROLES[role] then return InvalidField(field, "unknown popup text element; see the theme guide") end
        if not InRange(size, offsets and -8 or 6, offsets and 16 or 72) then
            return InvalidField(field, offsets and "expected an adjustment from -8 to 16 points" or "expected a point size from 6 to 72")
        end
        result[role] = size
    end
    return result
end

local function ReadPackDivider(addonName, divider)
    if divider == nil then return false end
    if type(divider) ~= "table" then return InvalidField("divider", "expected a texture/height table") end
    local texture = PackTexture(addonName, divider.texture)
    if not texture then return InvalidField("divider.texture", "expected a relative .tga or .blp path inside the theme addon") end
    local height = Default(divider.height, 3)
    if not InRange(height, 1, 32) then return InvalidField("divider.height", "expected a height from 1 to 32 pixels") end
    local hue = ReadHue(divider.hue)
    if divider.hue ~= nil and not hue then return InvalidField("divider.hue", "expected three RGB numbers from 0 to 1") end
    return { texture = texture, height = height, hue = hue or { 1, 1, 1 } }
end

function ns.GetSelectedThemeDivider()
    if not ns.db or ns.GetEffectiveBackgroundMode() ~= "CUSTOM" then return end
    local definition = ns.GetThemeDefinition(ns.db.backgroundTheme)
    return definition and definition.divider or nil
end

function ns.GetAvailableThemeFontPath(path)
    local themeKey = ns.db and ns.db.backgroundTheme
    if not ns.IsThemePackKey(themeKey) or registeredPacks[themeKey] or type(path) ~= "string" then return path end
    local addon = themeKey:match("^GLUTheme:([^:]+):")
    local prefix = addon and ("interface\\addons\\" .. addon:lower() .. "\\")
    if prefix and path:gsub("/", "\\"):lower():sub(1, #prefix) == prefix then return ns.DEFAULT_FONT_PATH end
    return path
end

local function ReadPackFrame(addonName, frame)
    if type(frame) ~= "table" then
        return InvalidField("frame", "expected a registered frame key or a frame table")
    end
    local cornerSize = Default(frame.cornerSize, 48)
    local edgeSize = Default(frame.edgeSize, 16)
    local edgeMaskInset = Default(frame.edgeMaskInset, 5)
    local backgroundInset = Default(frame.backgroundInset, 0)
    if not InRange(cornerSize, 1, 1024) then return InvalidField("frame.cornerSize", "expected a number from 1 to 1024") end
    if not InRange(edgeSize, 1, cornerSize) then return InvalidField("frame.edgeSize", "expected a number from 1 to cornerSize") end
    if not InRange(edgeMaskInset, 0, 64) then return InvalidField("frame.edgeMaskInset", "expected a number from 0 to 64") end
    if not InRange(backgroundInset, 0, cornerSize) then return InvalidField("frame.backgroundInset", "expected a number from 0 to cornerSize") end
    local hue = ReadHue(frame.hue)
    if frame.hue ~= nil and not hue then return InvalidField("frame.hue", "expected three RGB numbers from 0 to 1") end
    local result = {
        cornerSize = cornerSize, edgeSize = edgeSize, edgeMaskInset = edgeMaskInset,
        backgroundInset = backgroundInset,
        defaultHue = hue, transforms = {}, cornerSizes = {},
    }
    for piece, transform in pairs(SHARED_TRANSFORMS) do
        if piece ~= "center" and frame[piece] ~= nil then
            result[piece] = PackTexture(addonName, frame[piece])
            if not result[piece] then return InvalidField("frame." .. piece, "expected a relative .tga or .blp path inside the theme addon") end
            -- Authored pieces already face the right way. Reused pieces mirror as usual.
            if transform.rotation ~= 0 or transform.flipX or transform.flipY then
                result.transforms[piece] = { rotation = 0, flipX = false, flipY = false }
            end
        end
    end
    for _, piece in ipairs({"topLeft", "top", "left"}) do
        if not result[piece] then return InvalidField("frame." .. piece, "required relative .tga or .blp path is missing") end
    end
    if result.bottomLeft and not result.bottomRight then
        result.transforms.bottomRight = { rotation = 0, flipX = true, flipY = false }
    end
    if frame.transforms ~= nil and type(frame.transforms) ~= "table" then return InvalidField("frame.transforms", "expected a table") end
    for piece, transform in pairs(frame.transforms or {}) do
        local field = "frame.transforms." .. tostring(piece)
        if piece == "center" or not SHARED_TRANSFORMS[piece] then return InvalidField(field, "expected an edge or corner name") end
        if type(transform) ~= "table" then return InvalidField(field, "expected a transform table") end
        if not InRange(Default(transform.rotation, 0), -360, 360) then return InvalidField(field .. ".rotation", "expected degrees from -360 to 360") end
        for _, flip in ipairs({"flipX", "flipY"}) do
            if transform[flip] ~= nil and type(transform[flip]) ~= "boolean" then return InvalidField(field .. "." .. flip, "expected true or false") end
        end
        result.transforms[piece] = { rotation = Default(transform.rotation, 0), flipX = transform.flipX == true, flipY = transform.flipY == true }
    end
    if frame.cornerSizes ~= nil and type(frame.cornerSizes) ~= "table" then return InvalidField("frame.cornerSizes", "expected a table") end
    for corner, size in pairs(frame.cornerSizes or {}) do
        local field = "frame.cornerSizes." .. tostring(corner)
        if corner ~= "topLeft" and corner ~= "topRight" and corner ~= "bottomLeft" and corner ~= "bottomRight" then
            return InvalidField(field, "expected topLeft, topRight, bottomLeft or bottomRight")
        end
        if type(size) ~= "table" then return InvalidField(field, "expected a width/height table") end
        for _, dimension in ipairs({"width", "height"}) do
            if not InRange(size[dimension], 1, 1024) then return InvalidField(field .. "." .. dimension, "expected a number from 1 to 1024") end
        end
        result.cornerSizes[corner] = { width = size.width, height = size.height }
    end
    return result
end

local function ReadPackBackground(addonName, background)
    if type(background) ~= "table" then return InvalidField("background", "expected a registered background key or a background table") end
    local texture = PackTexture(addonName, background.texture)
    if not texture then return InvalidField("background.texture", "expected a relative .tga or .blp path inside the theme addon") end
    local style = Default(background.style, "tile")
    if style ~= "tile" and style ~= "fill" and style ~= "stretch" then return InvalidField("background.style", "expected tile, fill or stretch") end
    local opacity = Default(background.opacity, 1)
    if not InRange(opacity, 0, 1) then return InvalidField("background.opacity", "expected a number from 0 to 1") end
    local hue = ReadHue(background.hue)
    if background.hue ~= nil and not hue then return InvalidField("background.hue", "expected three RGB numbers from 0 to 1") end
    if style == "fill" or background.width ~= nil or background.height ~= nil then
        for _, dimension in ipairs({"width", "height"}) do
            if not InRange(background[dimension], 1, 8192) then
                return InvalidField("background." .. dimension, "expected the source image dimension from 1 to 8192; fill requires both width and height")
            end
        end
    end
    return {
        center = texture, defaultStyle = style, width = background.width, height = background.height,
        defaultHue = hue, defaultOpacity = opacity,
    }
end

local function ReadPackRing(addonName, ring)
    if type(ring) ~= "table" then return InvalidField("portraitRing", "expected a registered ring key or a ring table") end
    local texture = PackTexture(addonName, ring.texture)
    if not texture then return InvalidField("portraitRing.texture", "expected a relative .tga or .blp path inside the theme addon") end
    local scale = Default(ring.scale, 1.10)
    if not InRange(scale, .5, 2) then return InvalidField("portraitRing.scale", "expected a number from 0.5 to 2") end
    local offsetX, offsetY = Default(ring.offsetX, 0), Default(ring.offsetY, 0)
    if not InRange(offsetX, -300, 300) then return InvalidField("portraitRing.offsetX", "expected a number from -300 to 300") end
    if not InRange(offsetY, -300, 300) then return InvalidField("portraitRing.offsetY", "expected a number from -300 to 300") end
    local hue = ReadHue(ring.hue)
    if ring.hue ~= nil and not hue then return InvalidField("portraitRing.hue", "expected three RGB numbers from 0 to 1") end
    local glintRadius = Default(ring.glintRadius, .5)
    if not InRange(glintRadius, 0, 1) then return InvalidField("portraitRing.glintRadius", "expected a fraction of texture width from 0 to 1") end
    return { texture = texture, scale = scale, offsetX = offsetX, offsetY = offsetY, glintRadius = glintRadius, defaultHue = hue }
end

local function AddPackChoice(registry, choices, key, label, asset)
    asset.label = label
    registry[key] = asset
    choices[#choices + 1] = { value = key, label = label, literal = true }
end

local SOUND_CUES = {
    levelUp = true, portraitImpact = true, starburst = true, idleMotes = true,
    statGlint = true, fireworks = true, fadeIn = true, fadeOut = true,
}

local function ReadPackSounds(sounds)
    if sounds == nil then return {} end
    if type(sounds) ~= "table" then return InvalidField("sounds", "expected a table of sound cues") end
    local result = {}
    for cue, sound in pairs(sounds) do
        local field = "sounds." .. tostring(cue)
        if not SOUND_CUES[cue] then return InvalidField(field, "unknown cue; use levelUp, portraitImpact, starburst, statGlint, idleMotes, fireworks, fadeIn or fadeOut") end
        if type(sound) ~= "table" then return InvalidField(field, "expected a sound cue table") end
        local media, kit, volume, loop = sound.media, sound.soundKit, sound.volume, sound.loopSeconds
        if media ~= nil then
            if kit ~= nil then return InvalidField(field, "choose media or soundKit, not both") end
            if type(media) ~= "string" or not media:find("%S") or #media > 100 or media:find("%c") then
                return InvalidField(field .. ".media", "expected a LibSharedMedia name of 1 to 100 bytes without control characters")
            end
        elseif not InRange(kit, 1, 2147483647) or kit % 1 ~= 0 then
            return InvalidField(field .. ".soundKit", "expected a positive integer sound-kit ID, or supply media")
        end
        if volume ~= nil and not InRange(volume, 0, 1) then return InvalidField(field .. ".volume", "expected a number from 0 to 1") end
        if cue == "idleMotes" then
            if not InRange(loop, .1, 60) then return InvalidField(field .. ".loopSeconds", "expected the clip length from 0.1 to 60 seconds") end
        elseif loop ~= nil then
            return InvalidField(field .. ".loopSeconds", "only idleMotes can loop")
        end
        result[cue] = { media = media, soundKit = kit, volume = volume, loopSeconds = loop }
    end
    return result
end

local function RegisterTheme(addonName, id, definition)
    if type(addonName) ~= "string" or not addonName:match("^[%w_%-]+$") then
        return InvalidField("addonName", "expected an addon folder name using letters, digits, underscores or hyphens")
    end
    if type(id) ~= "string" or not id:match("^[%w_%-]+$") then
        return InvalidField("id", "expected a stable theme ID using letters, digits, underscores or hyphens")
    end
    local key = PACK_PREFIX .. addonName:lower() .. ":" .. id:lower()
    local function Reject(reason)
        return nil, key .. " - " .. reason
    end
    if #key > 80 then return Reject("id: combined addon/theme key exceeds 80 bytes") end
    if registeredPacks[key] then return Reject("id: this theme is already registered; use a unique ID within the addon") end
    if type(definition) ~= "table" then return Reject("definition: expected a theme table") end
    local label = definition.label
    if type(label) ~= "string" or not label:find("%S") or #label > 80 or label:find("%c") then
        return Reject("label: expected a nonblank display label of up to 80 bytes without control characters")
    end
    local opacity = Default(definition.opacity, .95)
    if not InRange(opacity, 0, 1) then return Reject("opacity: expected a number from 0 to 1") end
    local font, fontError, customFont = ReadPackFont(addonName, definition.font)
    if fontError then return Reject(fontError) end
    local fontName = definition.fontName
    if fontName ~= nil and (type(fontName) ~= "string" or not fontName:find("%S") or #fontName > 80 or fontName:find("%c")) then
        return Reject("fontName: expected a nonblank font name of up to 80 bytes")
    end
    local fontSizes, fontSizeError = ReadPackFontSizes(definition.fontSizes)
    if not fontSizes then return Reject(fontSizeError) end
    local fontOffsets, fontOffsetError = ReadPackFontSizes(definition.fontSizeOffsets, true)
    if not fontOffsets then return Reject(fontOffsetError) end
    local fontSizeOffset = Default(definition.fontSizeOffset, 0)
    if not InRange(fontSizeOffset, -8, 16) then return Reject("fontSizeOffset: expected a point adjustment from -8 to 16") end
    local divider, dividerError = ReadPackDivider(addonName, definition.divider)
    if dividerError then return Reject(dividerError) end
    local soundsEnabled = Default(definition.soundsEnabled, true)
    if type(soundsEnabled) ~= "boolean" then return Reject("soundsEnabled: expected true or false") end
    local sounds = {}
    if soundsEnabled then
        local reason
        sounds, reason = ReadPackSounds(definition.sounds)
        if not sounds then return Reject(reason) end
    end

    local frameName = definition.frame
    local backgroundName = definition.background
    local ringName = Default(definition.portraitRing, "NONE")
    local frame, frameError = ReadPackFrame(addonName, frameName)
    local background, backgroundError = ReadPackBackground(addonName, backgroundName)
    local ring, ringError = ReadPackRing(addonName, ringName)
    if not frame and not FRAME_TEXTURES[frameName] then return Reject(frameError) end
    if not background and not BACKGROUND_TEXTURES[backgroundName] then return Reject(backgroundError) end
    if not ring and not PORTRAIT_RING_TEXTURES[ringName] then return Reject(ringError) end

    if frame then frameName = key; AddPackChoice(FRAME_TEXTURES, ns.FRAME_CHOICES, key, label, frame) end
    if background then backgroundName = key; AddPackChoice(BACKGROUND_TEXTURES, ns.BACKGROUND_TEXTURE_CHOICES, key, label, background) end
    if ring then ringName = key; AddPackChoice(PORTRAIT_RING_TEXTURES, ns.PORTRAIT_RING_CHOICES, key, label, ring) end
    local resolved = ResolveTheme(frameName, backgroundName, ringName, nil, key, label)
    resolved.appearance.bgOpacity = opacity
    resolved.appearance.customFontPath = font
    resolved.appearance.themeFontSizes = fontSizes
    resolved.appearance.themeFontSizeOffsets = fontOffsets
    resolved.appearance.themeFontSizeOffset = fontSizeOffset
    if customFont then
        themeFontLabels[font] = fontName or definition.font:gsub("\\", "/"):match("([^/]+)%.[^.]+$")
    end
    if customFont and LibStub then
        local media = LibStub("LibSharedMedia-3.0", true)
        if media then media:Register("font", addonName .. " - " .. label, font) end
    end
    THEME_DEFINITIONS[#THEME_DEFINITIONS + 1] = {
        value = key, label = label, frame = frameName, background = backgroundName, portraitRing = ringName,
        soundsEnabled = soundsEnabled, sounds = sounds, font = font, divider = divider,
    }
    ns.CUSTOM_BACKGROUND_THEMES[#ns.CUSTOM_BACKGROUND_THEMES + 1] = resolved
    ns.THEME_CHOICES[#ns.THEME_CHOICES + 1] = { value = key, label = label, literal = true }
    registeredPacks[key] = true
    if ns.db and ns.ApplyCurrentAppearance then ns.ApplyCurrentAppearance() end
    return key
end

GnomeLevelUpThemeAPI = { version = 1, RegisterTheme = RegisterTheme }
