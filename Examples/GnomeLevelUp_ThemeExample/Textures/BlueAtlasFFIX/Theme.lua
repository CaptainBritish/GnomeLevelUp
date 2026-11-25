local _, pack = ...
local folder = "Textures/BlueAtlasFFIX/"

pack.themes = pack.themes or {}
pack.themes[#pack.themes + 1] = {
    id = "blue_atlas_ffix",
    label = "FFIX Blue Atlas",
    soundsEnabled = true,
    font = "Fonts/FinalFantasyIXfontcopy.ttf",
    fontName = "Final Fantasy IX",
    fontSizeOffset = 2,
    divider = { texture = folder .. "Divider.tga", height = 4 },
    opacity = 1,
    frame = {
        cornerSize = 32,
        edgeSize = 16,
        edgeMaskInset = 32,
        backgroundInset = 12, -- Keeps the fill inside the rounded outer corners.
        hue = { 1, 1, 1 },
        topLeft = folder .. "TopLeft.tga",
        top = folder .. "Top.tga",
        topRight = folder .. "TopRight.tga",
        left = folder .. "Left.tga",
        right = folder .. "Right.tga",
        bottomLeft = folder .. "BottomLeft.tga",
        bottom = folder .. "Bottom.tga",
        bottomRight = folder .. "BottomRight.tga",
    },
    background = {
        texture = folder .. "Background.tga",
        style = "tile",
        width = 128,
        height = 128,
        hue = { 1, 1, 1 },
        opacity = 1,
    },
    portraitRing = {
        texture = folder .. "PortraitRing.tga",
        scale = 1.10,
        offsetX = 0,
        offsetY = 0,
        hue = { 1, 1, 1 },
        glintRadius = .45,
    },
}
