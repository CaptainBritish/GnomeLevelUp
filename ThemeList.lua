local ADDON_NAME, ns = ...

-- Theme assets are kept in one table so the layout below is easy to scan and edit.
local TEXTURE_ROOT = "Interface\\AddOns\\GnomeLevelUp\\Textures\\"

local function Texture(relativePath)
    return TEXTURE_ROOT .. relativePath:gsub("/", string.char(92))
end

-- These transforms mirror the texture layout used by the optimized corner and
-- edge files. Each theme receives its own copy when it is applied.
local SHARED_TRANSFORMS = {
    topLeft = { rotation = 0,   flipX = false, flipY = false },
    top = { rotation = 0,        flipX = false, flipY = false },
    topRight = { rotation = 0,   flipX = true,  flipY = false },
    left = { rotation = 0,       flipX = false, flipY = false },
    center = { rotation = 0,     flipX = false, flipY = false },
    right = { rotation = 0,      flipX = true,  flipY = false },
    bottomLeft = { rotation = 90, flipX = false, flipY = false },
    bottom = { rotation = 0,      flipX = false, flipY = true },
    bottomRight = { rotation = 180, flipX = false, flipY = false },
}

local function Appearance(ringTexture)
    return {
        -- Offsets are relative to the player portrait's existing top anchor.
        playerPortraitPosition = { x = 0, y = 0 },
        playerPortraitScale = 1.0,
        portraitRingEnabled = ringTexture ~= nil,
        portraitRingTexture = ringTexture or Texture("portrait-ring-placeholder.tga"),

        bgOpacity = 0.95,
        backgroundColor = { 0, 0, 0 },
        backgroundFillMode = "tile",
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
        backgroundTextureTransforms = SHARED_TRANSFORMS,
        customFontPath = false,
        frameStrata = "HIGH",
        framePosition = { point = "CENTER", relativePoint = "CENTER", x = 0, y = 90 },
        lockFramePosition = false,
        sectionPadding = 8,
        scale = 1.0,
        compactMode = false,
    }
end

local function Theme(value, label, cornerSize, edgeSize, textures, ringTexture)
    return {
        value = value,
        label = label,
        cornerSize = cornerSize,
        edgeSize = edgeSize,
        textures = textures,
        appearance = Appearance(ringTexture),
    }
end

ns.CUSTOM_BACKGROUND_THEMES = {
    Theme("Black Metal", "Black Metal", 40, 40, {
        topLeft = Texture("Backgrounds/Metal/metalblack-tl.tga"),
        top = Texture("Backgrounds/Metal/metalblack-top.tga"),
        topRight = Texture("Backgrounds/Metal/metalblack-tl.tga"),
        left = Texture("Backgrounds/Metal/metalblack-left.tga"),
        center = Texture("Backgrounds/Metal/warwithinbackground.tga"),
        right = Texture("Backgrounds/Metal/metalblack-left.tga"),
        bottomLeft = Texture("Backgrounds/Metal/metalblack-tl.tga"),
        bottom = Texture("Backgrounds/Metal/metalblack-top.tga"),
        bottomRight = Texture("Backgrounds/Metal/metalblack-tl.tga"),
    }),

    Theme("Wood Panel", "Wood Panel", 60, 27, {
        topLeft = Texture("Backgrounds/Wood/wood-tl.tga"),
        top = Texture("Backgrounds/Wood/wood-top.tga"),
        topRight = Texture("Backgrounds/Wood/wood-tl.tga"),
        left = Texture("Backgrounds/Wood/wood-left.tga"),
        center = Texture("Backgrounds/Wood/uiframehordebackground.tga"),
        right = Texture("Backgrounds/Wood/wood-left.tga"),
        bottomLeft = Texture("Backgrounds/Wood/wood-tl.tga"),
        bottom = Texture("Backgrounds/Wood/wood-top.tga"),
        bottomRight = Texture("Backgrounds/Wood/wood-tl.tga"),
    }),

    Theme("Alliance", "Alliance", 163, 28, {
        topLeft = Texture("Backgrounds/Alliance/allyframe-corner.tga"),
        top = Texture("Backgrounds/Alliance/allyframe-top.tga"),
        topRight = Texture("Backgrounds/Alliance/allyframe-corner.tga"),
        left = Texture("Backgrounds/Alliance/allyframe-side.tga"),
        center = Texture("Backgrounds/Alliance/allyframe-bg.tga"),
        right = Texture("Backgrounds/Alliance/allyframe-side.tga"),
        bottomLeft = Texture("Backgrounds/Alliance/allyframe-corner.tga"),
        bottom = Texture("Backgrounds/Alliance/allyframe-top.tga"),
        bottomRight = Texture("Backgrounds/Alliance/allyframe-corner.tga"),
    }, Texture("Backgrounds/ally-circle-frame.tga")),

    Theme("Horde", "Horde", 100, 28, {
        topLeft = Texture("Backgrounds/Horde/hordecorner.tga"),
        top = Texture("Backgrounds/Horde/hordetop.tga"),
        topRight = Texture("Backgrounds/Horde/hordecorner.tga"),
        left = Texture("Backgrounds/Horde/hordeside.tga"),
        center = Texture("Backgrounds/Wood/uiframehordebackground.tga"),
        right = Texture("Backgrounds/Horde/hordeside.tga"),
        bottomLeft = Texture("Backgrounds/Horde/hordecorner.tga"),
        bottom = Texture("Backgrounds/Horde/hordetop.tga"),
        bottomRight = Texture("Backgrounds/Horde/hordecorner.tga"),
    }, Texture("Backgrounds/horde-circle-frame.tga")),
}
