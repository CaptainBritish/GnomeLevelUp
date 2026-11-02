local ADDON_NAME, ns = ...

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
        topLeft = frame.topLeft, top = frame.top, topRight = frame.topLeft,
        left = frame.left, center = background.center, right = frame.left,
        bottomLeft = frame.bottomLeft or frame.topLeft, bottom = frame.top,
        bottomRight = frame.bottomLeft or frame.topLeft,
    }
    local appearance = Appearance(ringName or "NONE", style or background.defaultStyle or "tile")
    appearance.backgroundTextureTransforms = ns.GetFrameTransforms(frameName)
    return {
        value = value or "CUSTOM", label = label or "Custom",
        frameName = frameName, backgroundName = backgroundName,
        cornerSize = frame.cornerSize, cornerSizes = Copy(frame.cornerSizes),
        edgeSize = frame.edgeSize, edgeMaskInset = 5,
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
