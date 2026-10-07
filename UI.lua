local ADDON_NAME, ns = ...

-- Keep the panel readable at different animation speeds and resolutions.
local BASE_BG_FADE_DURATION = 0.25
local BASE_CONTENT_DELAY = 0.15
local BASE_CONTENT_FADE_DURATION = 0.30
local BASE_STAT_STAGGER_BASE = 0.30
local BASE_STAT_STAGGER_STEP = 0.08
local BASE_STAT_SLIDE_DURATION = 0.30
local STAT_SLIDE_DISTANCE_X = 50      -- pixels each stat line slides in from
local STAT_LINE_HEIGHT = 26
local DEFAULT_FONT_PATH = "Fonts\\FRIZQT__.TTF"
local SECTION_DIVIDER_HEIGHT = 3
local SEPARATOR_TEXTURE = "Interface\\AddOns\\GnomeLevelUp\\Textures\\seperator"
local DEFAULT_SECTION_PADDING = 8
local FRAME_BOTTOM_EXTENSION = 30

local FRAME_WIDTH = 460
local TEXT_WIDTH = FRAME_WIDTH - 60
local DEFAULT_TEXT_WIDTH = TEXT_WIDTH
local COMPACT_MAX_SKILLS = 5
local CLASS_ICON_SIZE = 60
local PLAYER_PORTRAIT_SIZE = CLASS_ICON_SIZE + 30
local PORTRAIT_RING_PADDING = 6

local function IsPlayerPortrait()
    return ns.db and ns.db.portraitMode == "player"
end

local function PortraitBaseSize()
    return IsPlayerPortrait() and PLAYER_PORTRAIT_SIZE or CLASS_ICON_SIZE
end

local function PortraitScale()
    local scale = tonumber(ns.db and ns.db.playerPortraitScale) or 1.0
    return math.max(0.5, math.min(2.0, scale))
end

local function PortraitIconSize()
    return IsPlayerPortrait() and PortraitBaseSize() * PortraitScale() or CLASS_ICON_SIZE
end

local function PortraitRingSize()
    return PortraitIconSize() + PORTRAIT_RING_PADDING
end

local function Speed()
    local mult = (ns.db and ns.db.animSpeedMultiplier) or 1.0
    if mult <= 0 then mult = 1.0 end
    return mult
end

local function SectionPadding()
    local padding = tonumber(ns.db and ns.db.sectionPadding) or DEFAULT_SECTION_PADDING
    return math.max(0, math.min(30, padding))
end

local function SectionGap()
    local padding = SectionPadding()
    return ns.db and ns.db.compactMode and math.max(2, padding - 2) or padding
end

local function AbilityIconGap()
    return ns.db and ns.db.compactMode and 6 or 10
end

local function UseHorizontalAbilityScroll()
    return ns.db and (ns.db.useHorizontalAbilityScroll == true or ns.db.compactMode == true)
end

local frame = CreateFrame("Frame", "GnomeLevelUpFrame", UIParent)
frame:SetSize(FRAME_WIDTH, 300) -- height is recomputed to fit the content on every show
frame:SetPoint("CENTER", UIParent, "CENTER", 0, 90)
frame:SetFrameStrata("HIGH")
frame:SetClampedToScreen(true)
frame:EnableMouse(true)
frame:SetMovable(true)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", function(self)
    if ns.db and ns.db.lockFramePosition then return end
    self:StartMoving()
end)
frame:SetScript("OnDragStop", function(self)
    if ns.db and ns.db.lockFramePosition then return end
    self:StopMovingOrSizing()
    if not ns.db then return end
    local point, _, relativePoint, x, y = self:GetPoint(1)
    if point and relativePoint and x and y then
        ns.db.framePosition = {
            point = point,
            relativePoint = relativePoint,
            x = x,
            y = y,
        }
    end
end)
frame:SetScript("OnMouseUp", function(self, button)
    if button == "RightButton" and ns.db and ns.db.rightClickClose then
        ns.CloseLevelUp()
    end
end)
ns.levelUpFrame = frame
frame:Hide()

local closeButton = CreateFrame("Button", nil, frame)
closeButton:SetSize(30, 30)
closeButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -8, -8)
closeButton:SetFrameLevel(frame:GetFrameLevel() + 10)
local closeText = closeButton:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
closeText:SetAllPoints()
closeText:SetJustifyH("CENTER")
closeText:SetJustifyV("MIDDLE")
closeText:SetText("X")
closeText:SetTextColor(1, 1, 1, 1)
closeButton:SetScript("OnClick", function() ns.CloseLevelUp() end)

function ns.ApplyFrameStrata(strata)
    local ok = pcall(frame.SetFrameStrata, frame, strata or "HIGH")
    if not ok then
        frame:SetFrameStrata("HIGH")
    end
end

function ns.ApplyFrameLock(locked)
    frame:SetMovable(locked ~= true)
end

function ns.ApplyClickThrough(enabled)
    -- A click-through popup must not consume mouse input from the game world.
    local interactive = enabled ~= true
    frame:EnableMouse(interactive)
    if closeButton and closeButton.EnableMouse then
        closeButton:EnableMouse(interactive)
    end
end

function ns.PositionFrame(f)
    local position = ns.db and ns.db.framePosition
    f:ClearAllPoints()
    if position and position.point and position.relativePoint then
        f:SetPoint(position.point, UIParent, position.relativePoint, position.x or 0, position.y or 90)
    else
        f:SetPoint("CENTER", UIParent, "CENTER", 0, 90)
    end
    return false
end

local BG_LAYERS = 28
local BG_FADE_FRACTION = 0.10 -- fade band thickness per side, as a fraction of that dimension
local backgroundWidth, backgroundHeight

local bg = CreateFrame("Frame", nil, frame)
bg:SetAllPoints(frame)
bg.layers = {}
for k = 1, BG_LAYERS do
    local layer = bg:CreateTexture(nil, "BACKGROUND")
    layer:SetColorTexture(0, 0, 0, 0)
    bg.layers[k] = layer
end

-- Custom backgrounds use a nine-slice so corners keep their shape while the
-- center can be scaled or tiled to fit the dynamically sized panel.
local BACKGROUND_PIECES = {
    "topLeft", "top", "topRight", "left", "center", "right",
    "bottomLeft", "bottom", "bottomRight",
}
bg.customPieces = {}
for _, name in ipairs(BACKGROUND_PIECES) do
    -- All nine authored slices sit above the backing fill.
    local texture = bg:CreateTexture(nil, "BACKGROUND", nil, -6)
    texture:Hide()
    bg.customPieces[name] = texture
end

-- The center/background must remain underneath the entire nine-slice, including
-- the corner squares. The edge textures also continue a short distance beneath
-- their adjacent corners. This is important for authored corner TGAs that use
-- alpha to feather into the surrounding background/edge art: transparent pixels
-- should reveal the neighboring theme textures, never the game world.
--
-- Draw order: center backing (-8) -> edge-under-corner pieces (-7) -> authored
-- nine-slice pieces (-6). The underlays are restricted to the corner squares so
-- the visible edge slices are not double-blended/darkened.
bg.customBackingPieces = {}
bg.customBackingPieces.center = bg:CreateTexture(nil, "BACKGROUND", nil, -8)
bg.customBackingPieces.center:Hide()

local CORNER_UNDERLAYS = {
    { key = "topLeftTop",      source = "top" },
    { key = "topRightTop",     source = "top" },
    { key = "bottomLeftBottom",  source = "bottom" },
    { key = "bottomRightBottom", source = "bottom" },
    { key = "topLeftLeft",     source = "left" },
    { key = "bottomLeftLeft",  source = "left" },
    { key = "topRightRight",   source = "right" },
    { key = "bottomRightRight",source = "right" },
}
for _, info in ipairs(CORNER_UNDERLAYS) do
    local texture = bg:CreateTexture(nil, "BACKGROUND", nil, -7)
    texture:Hide()
    bg.customBackingPieces[info.key] = texture
end

local function GetBackgroundTheme()
    local wanted = ns.db and ns.db.backgroundTheme
    for _, theme in ipairs(ns.CUSTOM_BACKGROUND_THEMES or {}) do
        if theme.value == wanted then return theme end
    end
end

local function BackgroundPieceColor(name)
    local colors = ns.db and ns.db.backgroundTextureColors
    local color = colors and colors[name]
    return color or { 1, 1, 1 }
end

local function SetBackgroundPieceColor(texture, name, alpha)
    local color = BackgroundPieceColor(name)
    texture:SetVertexColor(color[1] or 1, color[2] or 1, color[3] or 1, alpha)
end

local function SetBackgroundPiece(texture, name, path, alpha)
    if not path or path == "" then
        texture:Hide()
        return
    end

    -- SetHorizTile/SetVertTile preserve native texel size, but the texture's
    -- wrap mode decides what appears outside the 0..1 coordinate range. The
    -- default CLAMP mode extends edge pixels and looks like a stretched fill.
    -- REPEAT is required for an actual tiled center texture.
    local tiledCenter = name == "center"
        and ns.db and ns.db.backgroundFillMode == "tile"
    if tiledCenter then
        texture:SetTexture(path, "REPEAT", "REPEAT")
    else
        texture:SetTexture(path, "CLAMP", "CLAMP")
    end

    local transform = ns.db and ns.db.backgroundTextureTransforms
        and ns.db.backgroundTextureTransforms[name]
    local rotation = transform and tonumber(transform.rotation) or 0
    if texture.SetRotation then texture:SetRotation(math.rad(rotation)) end
    local left, right = transform and transform.flipX and 1 or 0, transform and transform.flipX and 0 or 1
    local top, bottom = transform and transform.flipY and 1 or 0, transform and transform.flipY and 0 or 1
    texture:SetTexCoord(left, right, top, bottom)
    SetBackgroundPieceColor(texture, name, alpha)
    texture:Show()
end

local function LayoutCustomBackground(theme)
    local w, h = frame:GetWidth(), frame:GetHeight()
    local corner = math.max(1, math.min(tonumber(theme.cornerSize) or 48, w / 2, h / 2))
    -- Keep the authored border thickness independent from the remaining center
    -- width. Compact panels can be narrower than two corner slices; reducing
    -- the edge to that tiny center width makes the left/right textures vanish.
    -- The edge only needs to fit within one half of the frame and its corner.
    local edge = math.max(1, math.min(
        tonumber(theme.edgeSize) or corner,
        corner,
        w / 2,
        h / 2
    ))
    local innerWidth = math.max(1, w - corner * 2)
    local innerHeight = math.max(1, h - corner * 2)

    local pieces = bg.customPieces
    local backing = bg.customBackingPieces
    local function Anchor(texture, point, relativePoint, x, y, width, height)
        texture:ClearAllPoints()
        texture:SetPoint(point, bg, relativePoint, x or 0, y or 0)
        texture:SetSize(math.max(1, width), math.max(1, height))
    end

    Anchor(pieces.topLeft, "TOPLEFT", "TOPLEFT", 0, 0, corner, corner)
    Anchor(pieces.top, "TOPLEFT", "TOPLEFT", corner, 0, innerWidth, edge)
    Anchor(pieces.topRight, "TOPRIGHT", "TOPRIGHT", 0, 0, corner, corner)
    Anchor(pieces.left, "TOPLEFT", "TOPLEFT", 0, -corner, edge, innerHeight)
    Anchor(pieces.center, "TOPLEFT", "TOPLEFT", corner, -corner, innerWidth, innerHeight)
    Anchor(pieces.right, "TOPRIGHT", "TOPRIGHT", 0, -corner, edge, innerHeight)
    Anchor(pieces.bottomLeft, "BOTTOMLEFT", "BOTTOMLEFT", 0, 0, corner, corner)
    Anchor(pieces.bottom, "BOTTOMLEFT", "BOTTOMLEFT", corner, 0, innerWidth, edge)
    Anchor(pieces.bottomRight, "BOTTOMRIGHT", "BOTTOMRIGHT", 0, 0, corner, corner)

    -- The center texture is the deepest backing layer and covers the full frame.
    -- That prevents corner alpha from cutting through to the game world.
    Anchor(backing.center, "TOPLEFT", "TOPLEFT", 0, 0, w, h)

    -- Continue the horizontal edge artwork underneath the top/bottom corners.
    -- Only the corner portions are drawn here; the normal visible edge pieces
    -- remain between the corners at their usual size.
    Anchor(backing.topLeftTop, "TOPLEFT", "TOPLEFT", 0, 0, corner, edge)
    Anchor(backing.topRightTop, "TOPRIGHT", "TOPRIGHT", 0, 0, corner, edge)
    Anchor(backing.bottomLeftBottom, "BOTTOMLEFT", "BOTTOMLEFT", 0, 0, corner, edge)
    Anchor(backing.bottomRightBottom, "BOTTOMRIGHT", "BOTTOMRIGHT", 0, 0, corner, edge)

    -- If corners are larger than the edge thickness, continue the vertical edge
    -- artwork through the remaining part of each corner. The horizontal edge
    -- underlay owns the outer edge-sized strip, so these do not overlap it.
    local sideUnderlayHeight = math.max(0, corner - edge)
    if sideUnderlayHeight > 0 then
        Anchor(backing.topLeftLeft, "TOPLEFT", "TOPLEFT", 0, -edge, edge, sideUnderlayHeight)
        Anchor(backing.topRightRight, "TOPRIGHT", "TOPRIGHT", 0, -edge, edge, sideUnderlayHeight)
        Anchor(backing.bottomLeftLeft, "BOTTOMLEFT", "BOTTOMLEFT", 0, edge, edge, sideUnderlayHeight)
        Anchor(backing.bottomRightRight, "BOTTOMRIGHT", "BOTTOMRIGHT", 0, edge, edge, sideUnderlayHeight)
        backing.topLeftLeft:Show()
        backing.topRightRight:Show()
        backing.bottomLeftLeft:Show()
        backing.bottomRightRight:Show()
    else
        backing.topLeftLeft:Hide()
        backing.topRightRight:Hide()
        backing.bottomLeftLeft:Hide()
        backing.bottomRightRight:Hide()
    end

    local tiled = ns.db and ns.db.backgroundFillMode == "tile"
    backing.center:SetHorizTile(tiled)
    backing.center:SetVertTile(tiled)
end

local function LayoutBackground()
    local w, h = frame:GetWidth(), frame:GetHeight()
    if w == backgroundWidth and h == backgroundHeight then
        local theme = GetBackgroundTheme()
        if ns.db and ns.db.backgroundMode == "CUSTOM" and theme then LayoutCustomBackground(theme) end
        return
    end
    backgroundWidth, backgroundHeight = w, h
    local fadeX, fadeY = w * BG_FADE_FRACTION, h * BG_FADE_FRACTION
    for k, layer in ipairs(bg.layers) do
        local insetX = fadeX * (k - 1) / BG_LAYERS
        local insetY = fadeY * (k - 1) / BG_LAYERS
        layer:ClearAllPoints()
        layer:SetPoint("TOPLEFT", bg, "TOPLEFT", insetX, -insetY)
        layer:SetPoint("BOTTOMRIGHT", bg, "BOTTOMRIGHT", -insetX, insetY)
    end
    local theme = GetBackgroundTheme()
    if theme then LayoutCustomBackground(theme) end
end
LayoutBackground()

local function SmoothStep(t)
    return t * t * (3 - 2 * t)
end

    -- Keep the background opacity separate from the content animation.
function ns.ApplyBackgroundAppearance()
    local useCustom = ns.db and ns.db.backgroundMode == "CUSTOM"
        and GetBackgroundTheme() ~= nil
    for _, layer in ipairs(bg.layers) do
        layer:SetShown(not useCustom)
    end
    local theme = useCustom and GetBackgroundTheme() or nil
    for _, name in ipairs(BACKGROUND_PIECES) do
        local piece = bg.customPieces[name]
        if useCustom and name ~= "center" then
            SetBackgroundPiece(piece, name, theme.textures and theme.textures[name], (ns.db and ns.db.bgOpacity) or 0.70)
        else
            -- The authored center slice is rendered by the dedicated backing
            -- layer so it is never double-blended. That backing extends beneath
            -- edges and corners; authored corner textures remain above it.
            piece:Hide()
        end
    end

    -- Deep center backing: use the center texture across the whole frame so
    -- transparent corner pixels reveal theme artwork instead of the world.
    local alpha = (ns.db and ns.db.bgOpacity) or 0.70
    if useCustom then
        SetBackgroundPiece(bg.customBackingPieces.center, "center", theme.textures and theme.textures.center, alpha)
        for _, info in ipairs(CORNER_UNDERLAYS) do
            local piece = bg.customBackingPieces[info.key]
            local path = theme.textures and theme.textures[info.source]
            SetBackgroundPiece(piece, info.source, path, alpha)
        end
    else
        for _, piece in pairs(bg.customBackingPieces) do
            piece:Hide()
        end
    end
    LayoutBackground()
end

function ns.ApplyBackgroundOpacity(opacity)
    opacity = math.max(0, math.min(0.995, opacity or 0.70))
    local color = ns.db and ns.db.backgroundColor or { 0.00, 0.00, 0.00 }
    local previousCumulative = 0
    for k = 1, BG_LAYERS do
        local target = opacity * SmoothStep(k / BG_LAYERS)
        local layerAlpha = 1 - (1 - target) / (1 - previousCumulative)
        if layerAlpha < 0 then layerAlpha = 0 end
        bg.layers[k]:SetColorTexture(color[1], color[2], color[3], layerAlpha)
        previousCumulative = target
    end
    ns.ApplyBackgroundAppearance()
end
ns.ApplyBackgroundOpacity(0.70)
ns.ApplyBackgroundAppearance()

local content = CreateFrame("Frame", nil, frame)
content:SetAllPoints(frame)

    -- Store every text layer so a font change updates the whole panel.
content.fontElements = {}
content.textLayers = {}
local function RegisterFontElement(fs, sizeOverride, flagsOverride)
    local _, size, flags = fs:GetFont()
    content.fontElements[#content.fontElements + 1] = {
        fs = fs,
        size = sizeOverride or size,
        flags = flagsOverride or flags or "",
    }
end

function ns.ApplyFont(fontPath)
    fontPath = fontPath or DEFAULT_FONT_PATH
    for _, entry in ipairs(content.fontElements) do
        entry.fs:SetFont(fontPath, entry.size, entry.flags)
    end
end

local GLOW_ALPHA = 0.15
local GLOW_DIRS = {
    { -1, 0 }, { 1, 0 }, { 0, -1 }, { 0, 1 },
    { -1, -1 }, { 1, 1 }, { -1, 1 }, { 1, -1 },
}

local function NewText(parent, template, radius)
    local main = parent:CreateFontString(nil, "OVERLAY", template)
    main.glows = {}
    for i, dir in ipairs(GLOW_DIRS) do
        local glow = parent:CreateFontString(nil, "ARTWORK", template)
        glow:SetPoint("TOPLEFT", main, "TOPLEFT", dir[1] * radius, dir[2] * radius)
        glow:SetPoint("TOPRIGHT", main, "TOPRIGHT", dir[1] * radius, dir[2] * radius)
        glow:SetAlpha(ns.db and ns.db.showTextShadow == false and 0 or GLOW_ALPHA)
        main.glows[i] = glow
    end
    content.textLayers[#content.textLayers + 1] = main
    return main
end

function ns.ApplyTextShadow(enabled)
    local alpha = enabled == false and 0 or GLOW_ALPHA
    for _, text in ipairs(content.textLayers) do
        local textAlpha = enabled == false and 0 or (text.glowAlpha or GLOW_ALPHA)
        for _, glow in ipairs(text.glows or {}) do glow:SetAlpha(textAlpha) end
    end
end

local function CurrentShadowAlpha()
    return ns.db and ns.db.showTextShadow == false and 0 or GLOW_ALPHA
end

    -- Apply the same property to the main text and its glow copies.
local function ApplyToTextLayers(text, method, ...)
    text[method](text, ...)
    for _, glow in ipairs(text.glows) do
        glow[method](glow, ...)
    end
end

local function RegisterGlowFont(main, size, flags)
    RegisterFontElement(main, size, flags)
    for _, glow in ipairs(main.glows) do
        RegisterFontElement(glow, size, flags)
    end
end

local function ColorOf(key)
    local c = ns.db and ns.db.colors and ns.db.colors[key]
    return c or ns.defaults.colors[key]
end

local CLASS_COLOR_KEYS = {
    title = true,
    level = true,
    statsHeader = true,
    abilitiesHeader = true,
    abilityName = true,
    portraitBorder = true,
}

local function ActiveColor(key)
    if ns.db and ns.db.useClassColors and CLASS_COLOR_KEYS[key] then
        local _, classToken = UnitClass("player")
        local classColor = ns.CLASS_COLORS and ns.CLASS_COLORS[classToken]
        if classColor then return classColor end
    end
    return ColorOf(key)
end

local function Hex(c)
    return string.format("|cff%02x%02x%02x",
        math.floor(c[1] * 255 + 0.5), math.floor(c[2] * 255 + 0.5), math.floor(c[3] * 255 + 0.5))
end

local function SetTextColorKey(main, key)
    local c = ActiveColor(key)
    ApplyToTextLayers(main, "SetTextColor", c[1], c[2], c[3])
end

local CIRCLE_MASK = "Interface\\CharacterFrame\\TempPortraitAlphaMask"
local CLASS_ICON_SHEET = "Interface\\GLUES\\CHARACTERCREATE\\UI-CHARACTERCREATE-CLASSES"

content.classRing = content:CreateTexture(nil, "ARTWORK", nil, 1)
content.classRing:SetSize(PortraitRingSize(), PortraitRingSize())
content.classRing:SetPoint("TOP", content, "TOP", 0, -SectionPadding())
content.classRing:SetColorTexture(1, 0.82, 0.2, 1)

content.classIcon = content:CreateTexture(nil, "ARTWORK", nil, 2)
content.classIcon:SetSize(PortraitIconSize(), PortraitIconSize())
content.classIcon:SetPoint("CENTER", content.classRing, "CENTER", 0, 0)
content.classIcon:SetTexture(CLASS_ICON_SHEET)

-- Custom themes may provide an authored frame around the portrait. It sits
-- above the icon and replaces the normal colour-only ring when enabled.
content.classRingGraphic = content:CreateTexture(nil, "ARTWORK", nil, 3)
content.classRingGraphic:SetSize(PortraitRingSize(), PortraitRingSize())
content.classRingGraphic:SetPoint("CENTER", content.classRing, "CENTER", 0, 0)
content.classRingGraphic:Hide()

if content.CreateMaskTexture then
    local ringMask = content:CreateMaskTexture()
    ringMask:SetAllPoints(content.classRing)
    ringMask:SetTexture(CIRCLE_MASK, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    content.classRing:AddMaskTexture(ringMask)

    local iconMask = content:CreateMaskTexture()
    iconMask:SetAllPoints(content.classIcon)
    iconMask:SetTexture(CIRCLE_MASK, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    content.classIcon:AddMaskTexture(iconMask)
end

function ns.RefreshPortraitGeometry()
    if not content.classRing or not content.classIcon or not content.classRingGraphic then return end

    local position = IsPlayerPortrait() and ns.db and ns.db.playerPortraitPosition or {}
    local x = IsPlayerPortrait() and (tonumber(position.x) or 0) or 0
    local y = IsPlayerPortrait() and (tonumber(position.y) or 0) or 0
    local iconSize = PortraitIconSize()
    local ringSize = iconSize + PORTRAIT_RING_PADDING

    content.classRing:SetSize(ringSize, ringSize)
    content.classRing:ClearAllPoints()
    content.classRing:SetPoint("TOP", content, "TOP", x, -SectionPadding() + y)
    content.classIcon:SetSize(iconSize, iconSize)
    content.classRingGraphic:SetSize(ringSize, ringSize)

    if content.title then
        content.title:ClearAllPoints()
        content.title:SetPoint("TOP", content, "TOP", 0, -(SectionPadding() + ringSize + 6))
    end
end

local FALLBACK_CLASS_COORDS = {
    WARRIOR = { 0, 0.25, 0, 0.25 },       MAGE = { 0.25, 0.5, 0, 0.25 },
    ROGUE = { 0.5, 0.75, 0, 0.25 },       DRUID = { 0.75, 1, 0, 0.25 },
    HUNTER = { 0, 0.25, 0.25, 0.5 },      SHAMAN = { 0.25, 0.5, 0.25, 0.5 },
    PRIEST = { 0.5, 0.75, 0.25, 0.5 },    WARLOCK = { 0.75, 1, 0.25, 0.5 },
    PALADIN = { 0, 0.25, 0.5, 0.75 },     DEATHKNIGHT = { 0.25, 0.5, 0.5, 0.75 },
    MONK = { 0.5, 0.75, 0.5, 0.75 },      DEMONHUNTER = { 0.75, 1, 0.5, 0.75 },
}

function ns.RefreshClassIcon()
    ns.RefreshPortraitGeometry()
    -- The portrait choice changes only the texture, not the layout.
    local portraitMode = ns.db and ns.db.portraitMode or "class"
    if portraitMode == "player" then
        content.classIcon:SetTexCoord(0, 1, 0, 1)
        if SetPortraitTexture then
            SetPortraitTexture(content.classIcon, "player")
        else
            content.classIcon:SetTexture("Interface\\CHARACTERFRAME\\TempPortrait")
        end
        content.classIcon:Show()
        content.classRing:Show()
        ns.RefreshPortraitRing()
        return
    end

    local _, classToken = UnitClass("player")
    local coords = (CLASS_ICON_TCOORDS and CLASS_ICON_TCOORDS[classToken])
        or FALLBACK_CLASS_COORDS[classToken]
    if coords then
        content.classIcon:SetTexture(CLASS_ICON_SHEET)
        content.classIcon:SetTexCoord(coords[1], coords[2], coords[3], coords[4])
        content.classIcon:Show()
        content.classRing:Show()
        ns.RefreshPortraitRing()
    else
        content.classIcon:Hide()
        content.classRing:Hide()
        content.classRingGraphic:Hide()
    end
end

function ns.RefreshPortraitRing()
    if not content.classRingGraphic then return end
    local db = ns.db or {}
    local enabled = db.portraitRingEnabled == true
        and type(db.portraitRingTexture) == "string"
        and db.portraitRingTexture ~= ""
    if enabled then
        content.classRingGraphic:SetTexture(db.portraitRingTexture, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
        content.classRingGraphic:SetTexCoord(0, 1, 0, 1)
        content.classRing:Hide()
        content.classRingGraphic:Show()
    else
        content.classRingGraphic:Hide()
        content.classRing:Show()
    end
end

-- The addon panel starts with the player's icon and level. Blizzard's own
-- congratulatory title is disabled separately in HideBlizzardLevelUp.lua.
content.title = NewText(content, "GameFontNormalHuge", 3)
content.title:SetPoint("TOP", content, "TOP", 0, -(SectionPadding() + PortraitRingSize() + 6))
ApplyToTextLayers(content.title, "SetText", "")
ApplyToTextLayers(content.title, "SetShown", false)
RegisterGlowFont(content.title)

content.levelText = NewText(content, "GameFontNormalLarge", 2)
content.levelText:SetPoint("TOP", content.classRing, "BOTTOM", 0, -6)
RegisterGlowFont(content.levelText)

content.statsHeader = NewText(content, "GameFontNormalLarge", 2)
content.statsHeader:SetPoint("TOP", content.levelText, "BOTTOM", 0, -22)
ApplyToTextLayers(content.statsHeader, "SetText", "Stats Gained")
RegisterGlowFont(content.statsHeader)

content.statsContainer = CreateFrame("Frame", nil, content)
content.statsContainer:SetWidth(TEXT_WIDTH)
content.statsContainer:SetHeight(1)
content.statLinePool = {}

-- Use the supplied alpha strip so the separator keeps the same soft fade on every client.
local function CreateSectionDivider(parent)
    local divider = CreateFrame("Frame", nil, parent)
    divider:SetSize(TEXT_WIDTH, SECTION_DIVIDER_HEIGHT)
    divider.texture = divider:CreateTexture(nil, "ARTWORK")
    divider.texture:SetTexture(SEPARATOR_TEXTURE)
    divider.texture:SetAllPoints(divider)
    divider.texture:SetTexCoord(0, 1, 0, 1)
    return divider
end

local function SetSectionDividerColor(divider, color)
    divider.texture:SetVertexColor(color[1], color[2], color[3], 1)
end

content.statsHeaderDivider = CreateSectionDivider(content)
content.statsBottomDivider = CreateSectionDivider(content)
content.timeBottomDivider = CreateSectionDivider(content)
content.abilitiesDivider = CreateSectionDivider(content)
content.petDivider = CreateSectionDivider(content)
content.petHeaderDivider = CreateSectionDivider(content)
content.weaponDivider = CreateSectionDivider(content)
content.statsHeaderDivider:SetPoint("TOP", content.statsHeader, "BOTTOM", 0, -SectionGap())
content.statsContainer:SetPoint("TOP", content.statsHeaderDivider, "BOTTOM", 0, -SectionGap())

content.spellsHeader = NewText(content, "GameFontNormal", 2)
ApplyToTextLayers(content.spellsHeader, "SetText", "Abilities")
RegisterGlowFont(content.spellsHeader)

content.levelTimeText = NewText(content, "GameFontHighlightSmall", 1.5)
content.levelTimeText.glowAlpha = 0.08
for _, glow in ipairs(content.levelTimeText.glows) do glow:SetAlpha(content.levelTimeText.glowAlpha) end
content.levelTimeText:SetWidth(TEXT_WIDTH)
content.levelTimeText:SetHeight(18)
ApplyToTextLayers(content.levelTimeText, "SetJustifyH", "CENTER")
ApplyToTextLayers(content.levelTimeText, "SetJustifyV", "MIDDLE")
ApplyToTextLayers(content.levelTimeText, "SetTextColor", 0.25, 1.0, 0.25)
RegisterGlowFont(content.levelTimeText)
content.levelTimeText:Hide()

local ABILITY_ICON_SIZE = 36
local ABILITY_COST_HEIGHT = 14
local ABILITY_COST_GAP = 1
local ABILITY_COST_TOP_PADDING = 8

local MONEY_ICON_PATHS = {
    gold = "Interface\\MoneyFrame\\UI-GoldIcon",
    silver = "Interface\\MoneyFrame\\UI-SilverIcon",
    copper = "Interface\\MoneyFrame\\UI-CopperIcon",
}

local function FormatTrainerCost(cost)
    cost = tonumber(cost)
    if not cost or cost <= 0 then return nil end

    local gold = math.floor(cost / 10000)
    local silver = math.floor((cost % 10000) / 100)
    local copper = cost % 100
    local parts = {}
    local function AddPart(amount, currency)
        if amount > 0 then
            parts[#parts + 1] = string.format("%d|T%s:10:10:0:0|t", amount, MONEY_ICON_PATHS[currency])
        end
    end
    AddPart(gold, "gold")
    AddPart(silver, "silver")
    AddPart(copper, "copper")
    return #parts > 0 and table.concat(parts, " ") or nil
end

local function FormatPlayedTime(seconds)
    seconds = math.max(0, math.floor(tonumber(seconds) or 0))
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local remainingSeconds = seconds % 60
    if hours > 0 then
        return string.format("Time to level: %dh %02dm", hours, minutes)
    elseif minutes > 0 then
        return string.format("Time to level: %dm %02ds", minutes, remainingSeconds)
    end
    return string.format("Time to level: %ds", remainingSeconds)
end

local function AbilityCellHeight()
    if ns.db and ns.db.showTrainerCosts then
        return ABILITY_ICON_SIZE + ABILITY_COST_GAP + ABILITY_COST_HEIGHT + ABILITY_COST_TOP_PADDING
    end
    return ABILITY_ICON_SIZE
end

local SCROLLBAR_HEIGHT = 10

local function CreateAbilityViewport()
    local viewport = CreateFrame("ScrollFrame", nil, content)
    viewport:SetWidth(TEXT_WIDTH)
    if viewport.SetClipsChildren then viewport:SetClipsChildren(true) end

    local track = viewport:CreateTexture(nil, "BACKGROUND")
    track:SetColorTexture(1, 1, 1, 0.15)
    track:SetPoint("BOTTOMLEFT", viewport, "BOTTOMLEFT", 0, 0)
    track:SetPoint("BOTTOMRIGHT", viewport, "BOTTOMRIGHT", 0, 0)
    track:SetHeight(2)
    viewport.scrollTrack = track

    local slider = CreateFrame("Slider", nil, viewport)
    slider:SetOrientation("HORIZONTAL")
    slider:SetPoint("BOTTOMLEFT", viewport, "BOTTOMLEFT", 0, 0)
    slider:SetPoint("BOTTOMRIGHT", viewport, "BOTTOMRIGHT", 0, 0)
    slider:SetHeight(SCROLLBAR_HEIGHT)
    slider:SetMinMaxValues(0, 0)
    slider:SetValue(0)
    slider:SetValueStep(1)
    slider:SetThumbTexture("Interface\\Buttons\\WHITE8X8")
    local thumb = slider.GetThumbTexture and slider:GetThumbTexture()
    if thumb then thumb:SetVertexColor(1, 1, 1, 0.8) end
    slider:SetScript("OnValueChanged", function(self, value)
        if viewport.SetHorizontalScroll then viewport:SetHorizontalScroll(value or 0) end
    end)
    slider:Hide()
    viewport.slider = slider
    viewport.scrollTrack:Hide()

    local row = CreateFrame("Frame", nil, viewport)
    row:SetSize(TEXT_WIDTH, ABILITY_ICON_SIZE)
    row:SetPoint("TOPLEFT", viewport, "TOPLEFT", 0, 0)
    viewport:SetScrollChild(row)
    viewport.row = row
    row.viewport = viewport
    viewport:Hide()
    return viewport, row
end

content.abilityViewport, content.abilityRow = CreateAbilityViewport()
content.abilityIconPool = {}
content.currentTrainerAbilities = {}

content.petSpellsHeader = NewText(content, "GameFontNormal", 2)
ApplyToTextLayers(content.petSpellsHeader, "SetText", "Warlock Grimoires")
RegisterGlowFont(content.petSpellsHeader)
content.petAbilityViewport, content.petAbilityRow = CreateAbilityViewport()
content.petAbilityIconPool = {}
content.currentWarlockPetAbilities = {}
ApplyToTextLayers(content.petSpellsHeader, "Hide")
content.petAbilityViewport:Hide()

content.weaponSkillsText = NewText(content, "GameFontHighlightSmall", 1.5)
content.weaponSkillsText:SetWidth(TEXT_WIDTH)
content.weaponSkillsText:SetHeight(36)
ApplyToTextLayers(content.weaponSkillsText, "SetJustifyH", "CENTER")
ApplyToTextLayers(content.weaponSkillsText, "SetJustifyV", "TOP")
ApplyToTextLayers(content.weaponSkillsText, "SetWordWrap", true)
RegisterGlowFont(content.weaponSkillsText)
content.weaponSkillsText:Hide()

content.noAbilitiesText = NewText(content.abilityRow, "GameFontHighlightSmall", 1.5)
content.noAbilitiesText:SetPoint("CENTER", content.abilityRow, "CENTER", 0, 0)
RegisterGlowFont(content.noAbilitiesText)
ApplyToTextLayers(content.noAbilitiesText, "SetText", "No unlearned skills available")

local function ApplyPopupWidth()
    local compact = ns.db and ns.db.compactMode == true
    local gap = compact and 6 or 10
    local textWidth = compact
        and (COMPACT_MAX_SKILLS * ABILITY_ICON_SIZE + (COMPACT_MAX_SKILLS - 1) * gap)
        or DEFAULT_TEXT_WIDTH
    TEXT_WIDTH = textWidth
    FRAME_WIDTH = textWidth + 60
    frame:SetWidth(FRAME_WIDTH)
    content.statsContainer:SetWidth(TEXT_WIDTH)
    content.levelTimeText:SetWidth(TEXT_WIDTH)
    content.weaponSkillsText:SetWidth(TEXT_WIDTH)
    for _, fs in ipairs(content.statLinePool) do fs:SetWidth(TEXT_WIDTH) end
    for _, divider in ipairs({
        content.statsHeaderDivider, content.statsBottomDivider, content.timeBottomDivider,
        content.abilitiesDivider, content.petDivider, content.petHeaderDivider, content.weaponDivider,
    }) do
        divider:SetWidth(TEXT_WIDTH)
    end
    for _, viewport in ipairs({ content.abilityViewport, content.petAbilityViewport }) do
        viewport:SetWidth(TEXT_WIDTH)
        viewport.row:SetWidth(TEXT_WIDTH)
    end
end

local function AnchorBelow(frame, anchor, gap)
    frame:ClearAllPoints()
    frame:SetPoint("TOP", anchor, "BOTTOM", 0, -gap)
end

local function PositionSections()
    local current = content.statsContainer
    local gap = SectionGap()
    AnchorBelow(content.statsHeaderDivider, content.statsHeader, gap)
    AnchorBelow(content.statsContainer, content.statsHeaderDivider, gap)
    AnchorBelow(content.statsBottomDivider, current, gap)
    current = content.statsBottomDivider

    if content.levelTimeText:IsShown() then
        AnchorBelow(content.levelTimeText, current, gap + 2)
        AnchorBelow(content.timeBottomDivider, content.levelTimeText, gap)
        content.timeBottomDivider:Show()
        current = content.timeBottomDivider
    else
        content.levelTimeText:ClearAllPoints()
        content.timeBottomDivider:Hide()
    end

    AnchorBelow(content.spellsHeader, current, gap)
    AnchorBelow(content.abilitiesDivider, content.spellsHeader, gap)
    AnchorBelow(content.abilityViewport, content.abilitiesDivider, gap)
    content.abilityViewport:Show()
    current = content.abilityViewport

    if content.petSpellsHeader:IsShown() then
        content.petDivider:Show()
        content.petHeaderDivider:Show()
        AnchorBelow(content.petDivider, current, gap)
        AnchorBelow(content.petSpellsHeader, content.petDivider, gap)
        AnchorBelow(content.petHeaderDivider, content.petSpellsHeader, gap)
        AnchorBelow(content.petAbilityViewport, content.petHeaderDivider, gap)
        content.petAbilityViewport:Show()
        current = content.petAbilityViewport
    else
        content.petDivider:Hide()
        content.petHeaderDivider:Hide()
        content.petAbilityViewport:Hide()
        content.petAbilityViewport:ClearAllPoints()
    end

    if content.weaponSkillsText:IsShown() then
        content.weaponDivider:Show()
        AnchorBelow(content.weaponDivider, current, gap)
        AnchorBelow(content.weaponSkillsText, content.weaponDivider, gap)
    else
        content.weaponDivider:Hide()
        content.weaponSkillsText:ClearAllPoints()
    end
end

-- Choose the direction used by each stat line animation.
local function LineDirection(index)
    local mode = (ns.db and ns.db.statSlideDirection) or "alternate"
    if mode == "left" then return -1 end
    if mode == "right" then return 1 end
    return (index % 2 == 1) and -1 or 1
end

local activeLineAnims = {}
local activeIconAnims = {}
local animationDriver = CreateFrame("Frame")
animationDriver:Hide()

local function EaseOutQuad(p) return 1 - (1 - p) * (1 - p) end
local function EaseInQuad(p) return p * p end

local function SetLineAlpha(fs, alpha)
    fs:SetAlpha(alpha)
    for _, glow in ipairs(fs.glows) do
        glow:SetAlpha(alpha * CurrentShadowAlpha())
    end
end

local function SetLineShown(fs, shown)
    ApplyToTextLayers(fs, "SetShown", shown)
end

-- Ability icons share the same update driver as stat lines so the panel uses
-- one animation loop instead of two independent OnUpdate handlers.
local ABILITY_POP_DISTANCE = 24  -- how far below its resting spot an icon starts
local ABILITY_POP_START_SCALE = 0.4

local function AbilityIconColumns()
    if ns.db and ns.db.compactMode then return COMPACT_MAX_SKILLS end
    local gap = AbilityIconGap()
    return math.max(1, math.floor((TEXT_WIDTH + gap) / (ABILITY_ICON_SIZE + gap)))
end

local function UpdateLineAnimations(elapsed)
    local stillActive = false
    for fs, anim in pairs(activeLineAnims) do
        anim.t = anim.t + elapsed
        if anim.t < anim.delay then
            stillActive = true
        else
            if not anim.started then
                anim.started = true
                SetLineAlpha(fs, 0)
                SetLineShown(fs, true)
            end
            local p = (anim.t - anim.delay) / anim.duration
            if p >= 1 then
                p = 1
                activeLineAnims[fs] = nil
            else
                stillActive = true
            end
            local x = anim.startX * (1 - EaseOutQuad(p))
            fs:ClearAllPoints()
            fs:SetPoint("TOP", anim.container, "TOP", x, anim.y)
            SetLineAlpha(fs, EaseInQuad(p))
        end
    end
    return stillActive
end

local function UpdateIconAnimations(elapsed)
    local stillActive = false
    for icon, anim in pairs(activeIconAnims) do
        anim.t = anim.t + elapsed
        if anim.t < anim.delay then
            stillActive = true
        else
            if not anim.started then
                anim.started = true
                icon:Show()
            end
            local p = (anim.t - anim.delay) / anim.duration
            if p >= 1 then
                p = 1
                activeIconAnims[icon] = nil
            else
                stillActive = true
            end
            local eased = EaseOutQuad(p)
            icon:ClearAllPoints()
            icon:SetPoint("CENTER", anim.container, "CENTER", anim.x,
                anim.y - anim.startY * (1 - eased))
            icon:SetScale(ABILITY_POP_START_SCALE + (1 - ABILITY_POP_START_SCALE) * eased)
            icon:SetAlpha(EaseInQuad(p))
        end
    end
    return stillActive
end

animationDriver:SetScript("OnUpdate", function(self, elapsed)
    local linesActive = UpdateLineAnimations(elapsed)
    local iconsActive = UpdateIconAnimations(elapsed)
    if not linesActive and not iconsActive then self:Hide() end
end)

local function StartLineAnimation(fs, container, startX, y, delay, duration)
    if ns.db and ns.db.reducedMotion then
        activeLineAnims[fs] = nil
        fs:ClearAllPoints()
        fs:SetPoint("TOP", container, "TOP", 0, y)
        SetLineAlpha(fs, 1)
        SetLineShown(fs, true)
        return
    end
    activeLineAnims[fs] = { t = 0, delay = delay, duration = duration, startX = startX, container = container, y = y }
    fs:ClearAllPoints()
    fs:SetPoint("TOP", container, "TOP", startX, y)
    SetLineAlpha(fs, 0)
    SetLineShown(fs, false)
    animationDriver:Show()
end

local function GetStatLine(index)
    local pool = content.statLinePool
    if pool[index] then return pool[index] end

    local fontPath = (ns.db and ns.db.customFontPath) or DEFAULT_FONT_PATH
    local fs = NewText(content.statsContainer, "GameFontHighlight", 2)
    fs:SetWidth(TEXT_WIDTH)
    ApplyToTextLayers(fs, "SetJustifyH", "CENTER")
    RegisterGlowFont(fs, 20, "")
    ApplyToTextLayers(fs, "SetFont", fontPath, 20, "")
    SetLineShown(fs, false)

    pool[index] = fs
    return fs
end

local function StartIconPop(icon, container, x, y, delay, duration)
    if ns.db and ns.db.reducedMotion then
        activeIconAnims[icon] = nil
        icon:ClearAllPoints()
        icon:SetPoint("CENTER", container, "CENTER", x, y)
        icon:SetScale(1)
        icon:SetAlpha(1)
        icon:Show()
        return
    end
    activeIconAnims[icon] = {
        t = 0, delay = delay, duration = duration, container = container,
        x = x, y = y, startY = ABILITY_POP_DISTANCE,
    }
    icon:ClearAllPoints()
    icon:SetPoint("CENTER", container, "CENTER", x, y - ABILITY_POP_DISTANCE)
    icon:SetScale(ABILITY_POP_START_SCALE)
    icon:SetAlpha(0)
    icon:Hide()
    animationDriver:Show()
end

local function GetAbilityIcon(index, row, pool)
    row = row or content.abilityRow
    pool = pool or content.abilityIconPool
    if pool[index] then return pool[index] end

    local btn = CreateFrame("Button", nil, row)
    btn:SetSize(ABILITY_ICON_SIZE, ABILITY_ICON_SIZE)

    local tex = btn:CreateTexture(nil, "ARTWORK")
    tex:SetAllPoints()
    tex:SetTexCoord(0.08, 0.92, 0.08, 0.92) -- trim the default spell-icon border
    btn.icon = tex

    local costText = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    costText:SetSize(ABILITY_ICON_SIZE, ABILITY_COST_HEIGHT)
    costText:SetPoint("TOP", btn, "BOTTOM", 0, -ABILITY_COST_GAP)
    costText:SetJustifyH("CENTER")
    costText:SetJustifyV("TOP")
    costText:SetWordWrap(false)
    RegisterFontElement(costText, 10)
    costText:SetTextColor(1, 1, 1, 1)
    costText:Hide()
    btn.costText = costText

    local border = btn:CreateTexture(nil, "OVERLAY")
    border:SetAllPoints()
    border:SetColorTexture(1, 0.82, 0.2, 0.9)
    border:SetPoint("TOPLEFT", -1, 1)
    border:SetPoint("BOTTOMRIGHT", 1, -1)
    border:SetDrawLayer("BORDER")
    btn.border = border

    btn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        if self.spellID and GameTooltip.SetSpellByID then
            GameTooltip:SetSpellByID(self.spellID)
        elseif self.spellName then
            GameTooltip:SetText(self.spellName)
        end
        GameTooltip:Show()
    end)
    btn:SetScript("OnLeave", function() GameTooltip:Hide() end)
    btn:Hide()

    pool[index] = btn
    return btn
end

local function UpdateAbilityIcons(row, pool, emptyText, abilities, showEmptyText)
    local count = #abilities
    local speed = Speed()
    local staggerBase = BASE_STAT_STAGGER_BASE / speed
    local staggerStep = BASE_STAT_STAGGER_STEP / speed
    local popDuration = BASE_STAT_SLIDE_DURATION / speed

    if count == 0 then
        row:SetWidth(TEXT_WIDTH)
        row:SetHeight(ABILITY_ICON_SIZE)
        row.viewport:SetHeight(ABILITY_ICON_SIZE)
        row.viewport:SetHorizontalScroll(0)
        row.viewport.slider:SetMinMaxValues(0, 0)
        row.viewport.slider:SetValue(0)
        row.viewport.slider:Hide()
        row.viewport.scrollTrack:Hide()
        for _, icon in ipairs(pool) do
            activeIconAnims[icon] = nil
            icon:Hide()
        end
        if emptyText then
            ApplyToTextLayers(emptyText, "SetText",
                ns.db and ns.db.showOnlyCurrentLevelSkills
                    and "No new skills this level"
                    or "No unlearned skills available")
            ApplyToTextLayers(emptyText, showEmptyText and "Show" or "Hide")
        end
        return
    end

    if emptyText then ApplyToTextLayers(emptyText, "Hide") end

    local gap = AbilityIconGap()
    local maxColumns = AbilityIconColumns()
    local shouldScroll = UseHorizontalAbilityScroll() and count > maxColumns
    local columns = shouldScroll and count or math.min(count, maxColumns)
    local rows = shouldScroll and 1 or math.ceil(count / maxColumns)
    local totalWidth = columns * ABILITY_ICON_SIZE + (columns - 1) * gap
    local cellHeight = AbilityCellHeight()
    local totalHeight = rows * cellHeight + (rows - 1) * gap
    local viewportHeight = totalHeight
    row:SetWidth(shouldScroll and totalWidth or TEXT_WIDTH)
    row:SetHeight(totalHeight)
    row:ClearAllPoints()
    row:SetPoint("TOPLEFT", row.viewport, "TOPLEFT", 0,
        shouldScroll and -(SCROLLBAR_HEIGHT / 2) or 0)
    row.viewport:SetHeight(viewportHeight + (shouldScroll and SCROLLBAR_HEIGHT or 0))
    if shouldScroll then
        local maximum = math.max(0, totalWidth - TEXT_WIDTH)
        row.viewport.slider:SetMinMaxValues(0, maximum)
        row.viewport.slider:SetValue(0)
        row.viewport.slider:Show()
        row.viewport.scrollTrack:Show()
    else
        row.viewport:SetHorizontalScroll(0)
        row.viewport.slider:SetMinMaxValues(0, 0)
        row.viewport.slider:SetValue(0)
        row.viewport.slider:Hide()
        row.viewport.scrollTrack:Hide()
    end
    local startX = -totalWidth / 2 + ABILITY_ICON_SIZE / 2
    local startY = totalHeight / 2 - cellHeight / 2

    for i, spell in ipairs(abilities) do
        local icon = GetAbilityIcon(i, row, pool)
        icon.spellID = spell.id
        icon.spellName = spell.name
        local formattedCost = ns.db and ns.db.showTrainerCosts and FormatTrainerCost(spell.cost)
        if formattedCost then
            icon.costText:SetText(formattedCost)
            icon.costText:Show()
        else
            icon.costText:SetText("")
            icon.costText:Hide()
        end
        local texture = spell.icon or (spell.id and (
            (C_Spell and C_Spell.GetSpellTexture and C_Spell.GetSpellTexture(spell.id))
            or (GetSpellTexture and GetSpellTexture(spell.id))
        ))
        icon.icon:SetTexture(texture or "Interface\\Icons\\INV_Misc_QuestionMark")

        local zeroIndex = i - 1
        local column = zeroIndex % columns
        local rowIndex = math.floor(zeroIndex / columns)
        local x = startX + column * (ABILITY_ICON_SIZE + gap)
        local visibleCellHeight = formattedCost and cellHeight or ABILITY_ICON_SIZE
        local iconY = startY + (visibleCellHeight - ABILITY_ICON_SIZE) / 2
            - rowIndex * (cellHeight + gap)
        if formattedCost then iconY = iconY - ABILITY_COST_TOP_PADDING end
        local delay = staggerBase + (i - 1) * staggerStep
        StartIconPop(icon, row, x, iconY, delay, popDuration)
    end

    for i = count + 1, #pool do
        activeIconAnims[pool[i]] = nil
        pool[i]:Hide()
    end
end

-- Fill the main ability row with the current unlearned skills.
local function UpdateTrainerAbilityIcons(trainerAbilities)
    content.currentTrainerAbilities = trainerAbilities or {}
    UpdateAbilityIcons(content.abilityRow, content.abilityIconPool, content.noAbilitiesText, trainerAbilities, true)
end

local function UpdateWarlockPetAbilityIcons(petAbilities)
    content.currentWarlockPetAbilities = petAbilities or {}
    local hasAbilities = type(petAbilities) == "table" and #petAbilities > 0
    if not hasAbilities then
        ApplyToTextLayers(content.petSpellsHeader, "Hide")
        content.petAbilityRow:Hide()
        UpdateAbilityIcons(content.petAbilityRow, content.petAbilityIconPool, nil, {}, false)
        return
    end

    ApplyToTextLayers(content.petSpellsHeader, "Show")
    content.petAbilityRow:Show()
    UpdateAbilityIcons(content.petAbilityRow, content.petAbilityIconPool, nil, petAbilities, false)
end

local function UpdateWeaponSkillText(unlearnedWeaponSkills)
    local enabled = ns.db and ns.db.showWeaponSkills ~= false
    if not enabled or type(unlearnedWeaponSkills) ~= "table" or #unlearnedWeaponSkills == 0 then
        content.weaponSkillsText:Hide()
        ApplyToTextLayers(content.weaponSkillsText, "SetText", "")
        PositionSections()
        return false
    end

    local names = {}
    for _, skill in ipairs(unlearnedWeaponSkills) do
        if type(skill) == "table" and skill.name then
            names[#names + 1] = skill.name
        elseif type(skill) == "string" then
            names[#names + 1] = skill
        end
    end
    if #names == 0 then
        content.weaponSkillsText:Hide()
        ApplyToTextLayers(content.weaponSkillsText, "SetText", "")
        PositionSections()
        return false
    end

    ApplyToTextLayers(content.weaponSkillsText, "SetText", "Weapon skills: " .. table.concat(names, ", "))
    SetTextColorKey(content.weaponSkillsText, "statLabel")
    content.weaponSkillsText:Show()
    PositionSections()
    return true
end

local function ApplyStatLineText(fs)
    local d = fs.statData
    local text
    if d then
        text = string.format("%s: %d %s-> %d|r", d.name, d.old, Hex(ColorOf("statNew")), d.new)
    else
        text = fs.plainText or ""
    end
    ApplyToTextLayers(fs, "SetText", text)
    SetTextColorKey(fs, "statLabel")
end

function ns.ApplyColors()
    SetTextColorKey(content.title, "title")
    SetTextColorKey(content.levelText, "level")
    SetTextColorKey(content.statsHeader, "statsHeader")
    SetTextColorKey(content.spellsHeader, "abilitiesHeader")
    SetTextColorKey(content.petSpellsHeader, "abilitiesHeader")
    SetTextColorKey(content.weaponSkillsText, "statLabel")
    for _, fs in ipairs(content.statLinePool) do
        ApplyStatLineText(fs)
    end
    local borderColor = ActiveColor("abilityName")
    for _, icon in ipairs(content.abilityIconPool) do
        icon.border:SetColorTexture(borderColor[1], borderColor[2], borderColor[3], 0.9)
    end
    for _, icon in ipairs(content.petAbilityIconPool) do
        icon.border:SetColorTexture(borderColor[1], borderColor[2], borderColor[3], 0.9)
    end
    local portraitColor = ActiveColor("portraitBorder")
    content.classRing:SetColorTexture(portraitColor[1], portraitColor[2], portraitColor[3], 1)
    ns.RefreshPortraitRing()
    local dividerColor = ColorOf("divider")
    for _, divider in ipairs({
        content.statsHeaderDivider, content.statsBottomDivider, content.timeBottomDivider,
        content.abilitiesDivider, content.petDivider, content.petHeaderDivider, content.weaponDivider,
    }) do
        SetSectionDividerColor(divider, dividerColor)
    end
end
ns.ApplyColors()

local function UpdateStatLines(statChanges)
    local pool = content.statLinePool
    local count = #statChanges
    local speed = Speed()
    local staggerBase = BASE_STAT_STAGGER_BASE / speed
    local staggerStep = BASE_STAT_STAGGER_STEP / speed
    local slideDuration = BASE_STAT_SLIDE_DURATION / speed

    local function LayoutStatLine(i, statChange, plainText)
        local fs = GetStatLine(i)
        fs.statData = statChange
        fs.plainText = plainText
        ApplyStatLineText(fs)
        local dir = LineDirection(i)
        local y = -((i - 1) * STAT_LINE_HEIGHT)
        local delay = staggerBase + (i - 1) * staggerStep
        StartLineAnimation(fs, content.statsContainer, dir * STAT_SLIDE_DISTANCE_X, y, delay, slideDuration)
    end

    if count == 0 then
        LayoutStatLine(1, nil, "No stat changes")
        count = 1
    else
        for i = 1, count do
            LayoutStatLine(i, statChanges[i])
        end
    end

    for i = count + 1, #pool do
        activeLineAnims[pool[i]] = nil
        SetLineShown(pool[i], false)
    end

    content.statsContainer:SetHeight(count * STAT_LINE_HEIGHT)
    return count
end

local function TextHeight(fs, fallback)
    local h = fs:GetStringHeight()
    if not h or h < 1 then h = fallback end
    return h
end

-- Fit the frame to its content so empty sections do not leave excess space.
local function LayoutFrame(statCount)
    local gap = SectionGap()
    local h = SectionPadding() + PortraitRingSize() + 6
    h = h + 4 + TextHeight(content.levelText, 18)
    h = h + 22 + TextHeight(content.statsHeader, 18)
    h = h + gap + SECTION_DIVIDER_HEIGHT + gap
        + statCount * STAT_LINE_HEIGHT
    h = h + gap + SECTION_DIVIDER_HEIGHT + gap
    if content.levelTimeText:IsShown() then
        h = h + TextHeight(content.levelTimeText, 18)
        h = h + gap + SECTION_DIVIDER_HEIGHT + gap
    end
    h = h + TextHeight(content.spellsHeader, 16)
    h = h + gap + SECTION_DIVIDER_HEIGHT + gap
        + (content.abilityViewport:GetHeight() or ABILITY_ICON_SIZE)
    if content.petSpellsHeader:IsShown() then
        h = h + gap + SECTION_DIVIDER_HEIGHT + gap
        h = h + TextHeight(content.petSpellsHeader, 16)
        h = h + gap + SECTION_DIVIDER_HEIGHT + gap
            + (content.petAbilityViewport:GetHeight() or ABILITY_ICON_SIZE)
    end
    if content.weaponSkillsText:IsShown() then
        h = h + gap + SECTION_DIVIDER_HEIGHT + gap
            + math.max(18, TextHeight(content.weaponSkillsText, 18))
    end
    h = h + SectionPadding() + FRAME_BOTTOM_EXTENSION
    frame:SetHeight(h)
    LayoutBackground()
end

function ns.RefreshPopupLayout()
    ApplyPopupWidth()
    ns.RefreshPortraitGeometry()
    UpdateTrainerAbilityIcons(content.currentTrainerAbilities or {})
    UpdateWarlockPetAbilityIcons(content.currentWarlockPetAbilities or {})
    PositionSections()
    local statCount = math.max(1, math.floor((content.statsContainer:GetHeight() or STAT_LINE_HEIGHT) / STAT_LINE_HEIGHT + 0.5))
    LayoutFrame(statCount)
end


frame:SetAlpha(1)
bg:SetAlpha(0)
content:SetAlpha(0)

local bgAnim = bg:CreateAnimationGroup()
local bgFade = bgAnim:CreateAnimation("Alpha")
bgFade:SetFromAlpha(0)
bgFade:SetToAlpha(1)
bgFade:SetSmoothing("OUT")
bgAnim:SetScript("OnPlay", function() bg:SetAlpha(0) end)
bgAnim:SetScript("OnFinished", function() bg:SetAlpha(1) end)

local contentAnim = content:CreateAnimationGroup()
local contentFade = contentAnim:CreateAnimation("Alpha")
contentFade:SetFromAlpha(0)
contentFade:SetToAlpha(1)
contentFade:SetSmoothing("OUT")
contentAnim:SetScript("OnPlay", function() content:SetAlpha(0) end)
contentAnim:SetScript("OnFinished", function() content:SetAlpha(1) end)

local fadeOutGroup = frame:CreateAnimationGroup()
local fadeOut = fadeOutGroup:CreateAnimation("Alpha")
fadeOut:SetFromAlpha(1)
fadeOut:SetToAlpha(0)
fadeOut:SetDuration(0.5)
fadeOut:SetSmoothing("IN")
fadeOutGroup:SetScript("OnFinished", function() frame:Hide() end)
frame.fadeOutGroup = fadeOutGroup

local hideToken = 0

local function IsHovered()
    if frame.IsMouseOver and frame:IsMouseOver() then return true end
    return MouseIsOver and MouseIsOver(frame) or false
end

local function TryFadeOut(token)
    if token ~= hideToken or not frame:IsShown() then return end
    if not (ns.db and ns.db.ignoreMouseoverDelay == true) and IsHovered() then
        C_Timer.After(0.15, function() TryFadeOut(token) end)
        return
    end
    frame.fadeOutGroup:Play()
end

local function ScheduleFadeOut(delay)
    hideToken = hideToken + 1
    local token = hideToken
    if ns.db and ns.db.reducedMotion then
        C_Timer.After(delay, function()
            if token == hideToken and frame:IsShown() then frame:Hide() end
        end)
        return
    end
    C_Timer.After(delay, function() TryFadeOut(token) end)
end
ns.RescheduleFadeOut = ScheduleFadeOut

function ns.CloseLevelUp()
    hideToken = hideToken + 1
    activeLineAnims = {}
    activeIconAnims = {}
    animationDriver:Hide()
    bgAnim:Stop()
    contentAnim:Stop()
    if frame.fadeOutGroup:IsPlaying() then frame.fadeOutGroup:Stop() end
    frame:SetAlpha(1)
    frame:Hide()
end


frame:SetScript("OnEnter", function()
    if ns.db and ns.db.ignoreMouseoverDelay == true then return end
    if frame.fadeOutGroup:IsPlaying() then
        frame.fadeOutGroup:Stop()
        frame:SetAlpha(1)
        ScheduleFadeOut(0.15) -- polls until the mouse leaves, then fades
    end
end)


local function ShowLevelUpImpl(currentLevel, statChanges, trainerAbilities, unlearnedWeaponSkills, timePlayedThisLevel, warlockPetAbilities)
    -- Prepare the content, play the animations, and show the panel.
    local db = ns.db or {}
    if db.enabled == false then return end

    local speed = Speed()

    ApplyPopupWidth()
    frame:SetScale(db.scale or 1.0)
    ns.RefreshClassIcon()
    ApplyToTextLayers(content.levelText, "SetText", string.format("Level %d", currentLevel))

    local statCount = UpdateStatLines(statChanges or {})

    if db.showLevelTime and tonumber(timePlayedThisLevel) then
        ApplyToTextLayers(content.levelTimeText, "SetText", FormatPlayedTime(timePlayedThisLevel))
        content.levelTimeText:Show()
    else
        ApplyToTextLayers(content.levelTimeText, "SetText", "")
        content.levelTimeText:Hide()
    end

    UpdateTrainerAbilityIcons(trainerAbilities or {})
    UpdateWarlockPetAbilityIcons(warlockPetAbilities or {})
    UpdateWeaponSkillText(unlearnedWeaponSkills or {})

    LayoutFrame(statCount)

    bgFade:SetDuration(BASE_BG_FADE_DURATION / speed)
    contentFade:SetDuration(BASE_CONTENT_FADE_DURATION / speed)
    contentFade:SetStartDelay(BASE_CONTENT_DELAY / speed)

    bgAnim:Stop()
    contentAnim:Stop()
    if db.reducedMotion then
        bg:SetAlpha(1)
        content:SetAlpha(1)
    else
        bgAnim:Play()
        contentAnim:Play()
    end

    ns.PositionFrame(frame)

    frame:SetAlpha(1) -- undo any leftover fade-out alpha from a previous close
    if frame.fadeOutGroup:IsPlaying() then
        frame.fadeOutGroup:Stop()
    end
    frame:Show()

    ns.PlayLevelUpSound()
    ScheduleFadeOut(db.duration or 7)
end

function ns.ShowLevelUp(currentLevel, statChanges, trainerAbilities, unlearnedWeaponSkills, timePlayedThisLevel, warlockPetAbilities)
    if ns.EnsureDatabase then ns.EnsureDatabase() end
    local ok, err = pcall(ShowLevelUpImpl, currentLevel, statChanges, trainerAbilities, unlearnedWeaponSkills, timePlayedThisLevel, warlockPetAbilities)
    if not ok then
        print("|cffff4040GnomeLevelUp error:|r " .. tostring(err))
        print("|cffff4040GnomeLevelUp:|r the level-up screen failed to display (see above). Please report this error.")
    end
end
