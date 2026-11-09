local _, pack = ...
local folder = "Textures/Moonstone/"

-- Keep the ID stable after publishing. The label is what players see in Options.
pack.themes = pack.themes or {}
pack.themes[#pack.themes + 1] = {
    id = "moonstone",
    label = "Moonstone (Example)",
    opacity = 0.95, -- Overall frame opacity, from 0 to 1.

    -- Supply textures relative to this addon, or use a built-in key such as "WOOD_PANEL".
    frame = {
        cornerSize = 32, -- Default corner width and height in UI pixels.
        edgeSize = 16, -- Edge thickness in UI pixels.
        edgeMaskInset = 5, -- How far the edge strips start in from each corner.
        hue = { 1, 1, 1 }, -- Red, green and blue multipliers, each from 0 to 1.
        topLeft = folder .. "Corner.tga",
        top = folder .. "Top.tga",
        left = folder .. "Left.tga",
        -- Omit these paths to reuse the other pieces with the default transforms.
        -- topRight = folder .. "TopRight.tga",
        -- right = folder .. "Right.tga",
        -- bottomLeft = folder .. "BottomLeft.tga",
        -- bottom = folder .. "Bottom.tga",
        -- bottomRight = folder .. "BottomRight.tga",
        cornerSizes = {
            -- topLeft = { width = 32, height = 32 },
            -- topRight = { width = 32, height = 32 },
            -- bottomLeft = { width = 32, height = 32 },
            -- bottomRight = { width = 32, height = 32 },
        },
        transforms = {
            -- Any edge or corner can override its rotation and flips.
            -- right = { rotation = 0, flipX = true, flipY = false },
        },
    },

    -- Use a table for your own background, or a built-in key such as "SCRATCHED_STONE".
    background = {
        texture = folder .. "Background.tga",
        style = "tile", -- "tile", "fill" or "stretch".
        -- Source image dimensions. Fill uses these to crop without stretching.
        width = 64,
        height = 64,
        hue = { 1, 1, 1 },
        opacity = 1, -- Multiplies the overall opacity for the background only.
    },

    -- Use "NONE" for a solid ring, "STEEL" for a built-in ring, or supply artwork.
    portraitRing = {
        texture = folder .. "Ring.tga",
        scale = 1.10,
        offsetX = 0,
        offsetY = 0,
        hue = { 1, 1, 1 },
        glintRadius = 0.45, -- Radius as a fraction of the ring texture width.
    },
}
