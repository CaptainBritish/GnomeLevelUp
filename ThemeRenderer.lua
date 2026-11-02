local ADDON_NAME, ns = ...

-- Shared textured chrome for the popup, controller options and first-time setup.
-- The callers own their regions and visibility; this module owns geometry/paint.
local WHITE = { 1, 1, 1 }
local BLACK = { 0, 0, 0 }

function ns.GetBackgroundStyle()
    local style = ns.db and ns.db.backgroundStyle
    if style == "fill" or style == "tile" or style == "stretch" then return style end
    return ns.db and ns.db.backgroundFillMode == "tile" and "tile" or "stretch"
end

local function PieceColor(name)
    local db = ns.db or {}
    local color = db.backgroundTextureColors and db.backgroundTextureColors[name] or WHITE
    local hue = name == "center" and db.backgroundColor or db.frameColor
    if name == "center" and db.backgroundChoice == "SOLID" then
        hue = hue or BLACK
        return hue[1], hue[2], hue[3]
    end
    -- Historical black means an untinted texture, except for Solid Colour.
    if name == "center" and hue and hue[1] == 0 and hue[2] == 0 and hue[3] == 0 then
        return color[1], color[2], color[3]
    end
    hue = hue or WHITE
    return color[1] * hue[1], color[2] * hue[2], color[3] * hue[3]
end

function ns.PaintThemePiece(texture, name, reference, alpha, tileEdges)
    if not reference or reference == "" then texture:Hide(); return false end
    local style = ns.GetBackgroundStyle()
    local centerTile = name == "center" and style == "tile"
    local edgeTile = tileEdges ~= false
    local tileH = centerTile or edgeTile and (name == "top" or name == "bottom")
    local tileV = centerTile or edgeTile and (name == "left" or name == "right")
    if texture.SetHorizTile then texture:SetHorizTile(tileH) end
    if texture.SetVertTile then texture:SetVertTile(tileV) end
    local applied, left, right, top, bottom, sourceWidth, sourceHeight =
        ns.ApplyTextureReference(texture, reference, tileH, tileV)
    if not applied then texture:Hide(); return false end

    local isAtlas = type(reference) == "table" and type(reference.atlas) == "string"
    local transform = ns.db and ns.db.backgroundTextureTransforms and ns.db.backgroundTextureTransforms[name]
    local rotation = transform and tonumber(transform.rotation) or 0
    if texture.SetRotation then texture:SetRotation(math.rad(rotation)) end
    if texture.SetBlendMode then texture:SetBlendMode("BLEND") end
    if not isAtlas or left then
        left, right, top, bottom = left or 0, right or 1, top or 0, bottom or 1
        if transform and transform.flipX then left, right = right, left end
        if transform and transform.flipY then top, bottom = bottom, top end
        texture:SetTexCoord(left, right, top, bottom)
        if name == "center" and style == "fill" then
            local background = ns.GetBackgroundReference(ns.db and ns.db.backgroundChoice)
            ns.SetBackgroundFillCoords(texture, sourceWidth or background and background.width,
                sourceHeight or background and background.height, left, right, top, bottom)
        end
    end
    -- Native SetAtlas already applies its UVs if no metadata was available.
    local r, g, b = PieceColor(name)
    texture:SetVertexColor(r, g, b, alpha)
    texture:Show()
    return true
end

local function Anchor(texture, parent, point, x, y, width, height)
    if not texture then return end
    texture:ClearAllPoints()
    texture:SetPoint(point, parent, point, x, y)
    texture:SetSize(math.max(1, width), math.max(1, height))
end

local function Corner(theme, pieces, parent, name, point, fallback, width, height)
    local size = theme.cornerSizes and theme.cornerSizes[name]
    local w = math.max(1, size and tonumber(size.width) or fallback)
    local h = math.max(1, size and tonumber(size.height) or fallback)
    local scale = math.min(1, width / (w * 2), height / (h * 2))
    Anchor(pieces[name], parent, point, 0, 0, w * scale, h * scale)
end

function ns.LayoutThemeFrame(theme, parent, pieces, backing, width, height)
    local corner = math.max(1, math.min(tonumber(theme.cornerSize) or 48, width / 2, height / 2))
    local edge = math.max(1, math.min(tonumber(theme.edgeSize) or corner, corner, width / 2, height / 2))
    local inset = math.max(0, tonumber(theme.edgeMaskInset) or 5)
    local spanWidth, spanHeight = math.max(1, width - inset * 2), math.max(1, height - inset * 2)
    Corner(theme, pieces, parent, "topLeft", "TOPLEFT", corner, width, height)
    Corner(theme, pieces, parent, "topRight", "TOPRIGHT", corner, width, height)
    Corner(theme, pieces, parent, "bottomLeft", "BOTTOMLEFT", corner, width, height)
    Corner(theme, pieces, parent, "bottomRight", "BOTTOMRIGHT", corner, width, height)
    Anchor(pieces.top, parent, "TOPLEFT", inset, 0, spanWidth, edge)
    Anchor(pieces.bottom, parent, "BOTTOMLEFT", inset, 0, spanWidth, edge)
    Anchor(pieces.left, parent, "TOPLEFT", 0, -inset, edge, spanHeight)
    Anchor(pieces.right, parent, "TOPRIGHT", 0, -inset, edge, spanHeight)
    Anchor(pieces.center, parent, "TOPLEFT", corner, -corner,
        math.max(1, width - corner * 2), math.max(1, height - corner * 2))
    -- A single deepest backing fills the frame, including underneath corners.
    Anchor(backing, parent, "TOPLEFT", 0, 0, width, height)
    local tiled = ns.GetBackgroundStyle() == "tile"
    if backing.SetHorizTile then backing:SetHorizTile(tiled) end
    if backing.SetVertTile then backing:SetVertTile(tiled) end
end
