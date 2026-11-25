local _, pack = ...
local folder = "Textures/FEPathOfRadiance/"

pack.themes = pack.themes or {}
pack.themes[#pack.themes + 1] = {
    id = "fe_path_of_radiance",
    label = "FE Path of Radiance",
    soundsEnabled = true,
    font = "Fonts/FOT-ChiaroStd-B.otf",
    fontName = "FOT Chiaro Std Bold",
    opacity = 1,
    divider = { texture = folder .. "Divider.tga", height = 4 },
    portraitRing = {
        texture = folder .. "PortraitRing.tga",
        scale = 1.10,
        offsetX = 0,
        offsetY = 0,
        hue = { 1, 1, 1 },
        glintRadius = .45,
    },
    frame = {
        cornerSize = 32,
        edgeSize = 4,
        edgeMaskInset = 32,
        backgroundInset = 2,
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
        width = 256,
        height = 256,
        hue = { 1, 1, 1 },
        opacity = 1,
    },
}
