local ADDON_NAME, ns = ...

-- Keep the panel readable at different animation speeds and resolutions.
local BASE_BG_FADE_DURATION = 0.25
local BASE_CONTENT_FADE_DURATION = 0.30
local BASE_STAT_STAGGER_BASE = 0.30
local BASE_STAT_STAGGER_STEP = 0.08
local BASE_STAT_SLIDE_DURATION = 0.30
local STAT_SLIDE_DISTANCE_X = 50      -- pixels each stat line slides in from
local STAT_LINE_HEIGHT = 26
local DEFAULT_FONT_PATH = STANDARD_TEXT_FONT or "Fonts\\FRIZQT__.TTF"
local SECTION_DIVIDER_HEIGHT = 3
local SEPARATOR_TEXTURE = "Interface\\AddOns\\GnomeLevelUp\\Textures\\seperator"
local DEFAULT_SECTION_PADDING = 8
local FRAME_BOTTOM_EXTENSION = 30
local WHITE_COLOR = { 1, 1, 1 }
local BLACK_COLOR = { 0, 0, 0 }

local FRAME_WIDTH = 460
local TEXT_WIDTH = FRAME_WIDTH - 60
local DEFAULT_TEXT_WIDTH = TEXT_WIDTH
local COMPACT_MAX_SKILLS = 5
local PLAYER_PORTRAIT_SIZE = 90
local CLASS_ICON_SIZE = PLAYER_PORTRAIT_SIZE
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
    if ns.db and ns.db.portraitMode == "none" then return 0 end
    return PortraitIconSize() + PORTRAIT_RING_PADDING
end

local function PortraitRingScale()
    local scale = tonumber(ns.db and ns.db.portraitRingScale) or 1.0
    return math.max(0.5, math.min(2.0, scale))
end

local function PortraitRingOffset()
    local offset = ns.db and ns.db.portraitRingOffset
    return tonumber(offset and offset.x) or 0, tonumber(offset and offset.y) or 0
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

local function IsCompactLayout()
    return ns.db and ns.db.compactMode == true
end

local function SectionGap()
    local padding = SectionPadding()
    return IsCompactLayout() and math.max(2, padding - 2) or padding
end

local function AbilityIconGap()
    return IsCompactLayout() and 6 or 10
end

local function UseHorizontalAbilityScroll()
    return ns.db and (ns.db.useHorizontalAbilityScroll == true or IsCompactLayout())
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
closeText:SetTextColor(1, 1, 1, 1)
local closeIcon = closeButton:CreateTexture(nil, "OVERLAY")
closeIcon:SetPoint("CENTER")
closeIcon:SetSize(24, 24)

local lastControllerUIState
local function SyncControllerDefaults(active)
    if ns.db then
        if active and ns.db.ignoreMouseoverDelayUserSet ~= true then
            ns.db.ignoreMouseoverDelay = true
        elseif not active and lastControllerUIState == true
            and ns.db.ignoreMouseoverDelayUserSet ~= true then
            ns.db.ignoreMouseoverDelay = false
        end
    end
    lastControllerUIState = active == true
end

local function IsControllerUIActive()
    if ns.GetCurrentFlavor() == "retail" then
        SyncControllerDefaults(false)
        return false
    end
    local detected = false
    -- Match the controller mode used by the options window.
    local style
    local explicitKeyboardStyle = false
    if type(GetCVar) == "function" then
        local ok, value = pcall(GetCVar, "InputDeviceInterfaceStyle")
        if ok then
            style = value
            explicitKeyboardStyle = value == "0" or value == "keyboard"
        end
    end
    if style == "1" or style == "gamepad" then
        SyncControllerDefaults(true)
        return true
    end
    -- Prefer C_CVar; legacy GetCVar can return the previous interface style.
    if C_CVar and type(C_CVar.GetCVar) == "function" then
        local ok, value = pcall(C_CVar.GetCVar, "InputDeviceInterfaceStyle")
        if ok and (value == "1" or value == "gamepad") then
            SyncControllerDefaults(true)
            return true
        end
        if ok and (value == "0" or value == "keyboard") then explicitKeyboardStyle = true end
    end
    if explicitKeyboardStyle then
        SyncControllerDefaults(false)
        return false
    end
    if C_GamePad and type(C_GamePad.IsEnabled) == "function" then
        local ok, enabled = pcall(C_GamePad.IsEnabled)
        if ok and enabled == true then detected = true end
    end
    -- Fall back to the UI-mode CVar when C_GamePad.IsEnabled is unavailable.
    if not detected and type(GetCVarBool) == "function" then
        local ok, enabled = pcall(GetCVarBool, "GamePadEnable")
        if ok and enabled == true then detected = true end
    end
    if not detected and type(GetCVar) == "function" then
        local ok, enabled = pcall(GetCVar, "GamePadEnable")
        if ok and (enabled == "1" or enabled == "true") then detected = true end
    end
    SyncControllerDefaults(detected)
    return detected
end
ns.IsControllerUIActive = IsControllerUIActive

local function ControllerLabelStyle()
    -- Forever does not expose a stable controller-family API to addons. Let
    -- the player choose the glyph family once instead of guessing from CVars.
    local style = ns.db and ns.db.controllerGlyphStyle
    if style == "none" then return "none" end
    if style == "playstation" or style == "nintendo" then return style end
    return "xbox"
end

local function RefreshCloseButtonLabel()
    if not IsControllerUIActive() then
        closeIcon:Hide()
        closeText:SetFont(DEFAULT_FONT_PATH, 12, "")
        closeText:SetText("X")
        closeText:Show()
        return
    end

    if ControllerLabelStyle() == "none" then
        closeIcon:Hide()
        closeText:SetFont(DEFAULT_FONT_PATH, 12, "")
        closeText:SetText("X")
        closeText:Show()
        return
    end

    local atlasApplied = ns.ApplyControllerGlyph(closeIcon, "back", ControllerLabelStyle())
    if atlasApplied then
        closeIcon:SetSize(24, 24)
        closeText:Hide()
        closeIcon:Show()
    else
        -- The text fallback keeps controller mode usable on clients that have
        -- the gamepad API but do not expose the new atlas regions to addons.
        closeIcon:Hide()
        closeText:SetFont(DEFAULT_FONT_PATH, 12, "")
        closeText:SetText(ControllerLabelStyle() == "nintendo" and "A" or "B")
        closeText:Show()
    end
end
ns.RefreshControllerGlyph = RefreshCloseButtonLabel
ns.RefreshCloseButton = RefreshCloseButtonLabel

-- CVAR_UPDATE is not emitted consistently by Forever when a controller is
-- unplugged. Poll only while the popup is visible so the glyph disappears
-- promptly without adding a permanent update loop to the addon.
local controllerGlyphElapsed = 0
frame:SetScript("OnUpdate", function(_, elapsed)
    controllerGlyphElapsed = controllerGlyphElapsed + (elapsed or 0)
    if controllerGlyphElapsed < 0.20 then return end
    controllerGlyphElapsed = 0
    RefreshCloseButtonLabel()
end)

local function IsControllerBackButton(button)
    button = tostring(button or ""):upper()
    return button == "PAD2"
        or button == "PADB"
        or button == "PADBACK"
        or button == "GAMEPAD_BUTTON_B"
        or button == "GAMEPAD_B"
end

-- Forever's native controller UI can route the B/Back action directly to the
-- top-most gamepad-enabled frame. Keep this opt-in and feature-detected so
-- Retail and older clients retain the normal mouse-only close button.
if (ns.GetCurrentFlavor() ~= "retail")
    and type(closeButton.EnableGamePadButton) == "function" then
    closeButton:EnableGamePadButton(true)
    closeButton:SetScript("OnGamePadButtonDown", function(_, button)
        if IsControllerBackButton(button) then ns.CloseLevelUp() end
    end)
end
closeButton:SetScript("OnClick", function() ns.CloseLevelUp() end)
RefreshCloseButtonLabel()

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
-- Clip the repeated edge bands a few pixels inside the outside frame edge.
-- Their regions still run beneath the corner textures at both ends.
local EDGE_MASK_INSET = 5
local backgroundWidth, backgroundHeight
-- LayoutCustomBackground performs a large number of anchor and size updates.
-- Keep a small invalidation counter so repeated popup/layout refreshes do not
-- rebuild an unchanged nine-slice background.
local backgroundLayoutVersion = 0
local laidOutBackgroundVersion = -1

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
local EDGE_PIECES = {
    top = true,
    bottom = true,
    left = true,
    right = true,
}
bg.customPieces = {}
for _, name in ipairs(BACKGROUND_PIECES) do
    -- Edge bands sit below the corners, allowing their repeats to continue
    -- underneath the corner artwork without leaking over it.
    local subLevel = EDGE_PIECES[name] and -7 or -6
    local texture = bg:CreateTexture(nil, "BACKGROUND", nil, subLevel)
    texture:Hide()
    bg.customPieces[name] = texture
end

-- The center/background must remain underneath the entire nine-slice, including
-- the corner squares. Edge bands are drawn below corners so authored corner
-- alpha can reveal the neighboring edge art instead of the game world.
--
-- Draw order: center backing (-8) -> continuous edge bands (-7) -> authored
-- corner pieces (-6).
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
    local selected = ns.GetSelectedCompositeTheme()
    if selected then return selected end
    local wanted = ns.db and ns.db.backgroundTheme
    for _, theme in ipairs(ns.CUSTOM_BACKGROUND_THEMES or {}) do
        if theme.value == wanted then return theme end
    end
end

local function BackgroundPieceColor(name)
    local colors = ns.db and ns.db.backgroundTextureColors
    local color = colors and colors[name] or WHITE_COLOR
    local hue = ns.db and (name == "center" and ns.db.backgroundColor or ns.db.frameColor)
    -- The historical black background default means "no texture tint".
    if name == "center" and hue and hue[1] == 0 and hue[2] == 0 and hue[3] == 0 then
        return color
    end
    hue = hue or WHITE_COLOR
    return { color[1] * hue[1], color[2] * hue[2], color[3] * hue[3] }
end

local function SetBackgroundPieceColor(texture, name, alpha)
    local color = BackgroundPieceColor(name)
    texture:SetVertexColor(color[1] or 1, color[2] or 1, color[3] or 1, alpha)
end

local function BackgroundStyle()
    local style = ns.db and ns.db.backgroundStyle
    if style == "fill" or style == "tile" or style == "stretch" then return style end
    return ns.db and ns.db.backgroundFillMode == "tile" and "tile" or "stretch"
end

local function SetBackgroundPiece(texture, name, path, alpha, tileEdges)
    if not path or (type(path) == "string" and path == "") then
        texture:Hide()
        return
    end

    -- Edge strips are repeatable bands. Their texture regions are bounded by
    -- the outer-frame mask in LayoutCustomBackground, so the final tile is
    -- clipped before the frame edge instead of poking outside it.
    local style = BackgroundStyle()
    local tiledCenter = name == "center" and style == "tile"
    -- Edge strips are always tiled. The per-theme style applies only to the
    -- center/background layer; tileEdges=false is used by its corner underlays.
    local tiledEdges = tileEdges ~= false
    local tileHorizontal = tiledCenter
        or (tiledEdges and (name == "top" or name == "bottom"))
    local tileVertical = tiledCenter
        or (tiledEdges and (name == "left" or name == "right"))
    local isAtlas = type(path) == "table" and type(path.atlas) == "string"
    local applied, atlasLeft, atlasRight, atlasTop, atlasBottom =
        ns.ApplyTextureReference(texture, path, tileHorizontal, tileVertical)
    if not applied then
        texture:Hide()
        return
    end
    -- Make the TGA alpha channel explicit. This is especially important for
    -- corner slices, whose transparent pixels are intended to reveal the
    -- top/side edge pieces beneath them.
    if texture.SetBlendMode then texture:SetBlendMode("BLEND") end

    local transform = ns.db and ns.db.backgroundTextureTransforms
        and ns.db.backgroundTextureTransforms[name]
    local rotation = transform and tonumber(transform.rotation) or 0
    if texture.SetRotation then texture:SetRotation(math.rad(rotation)) end
    -- SetAtlas establishes the atlas region's coordinates internally. Do not
    -- overwrite them with full-texture coordinates; direct paths retain the
    -- older flip behavior used by the existing themes.
    if isAtlas and atlasLeft then
        local left = transform and transform.flipX and atlasRight or atlasLeft
        local right = transform and transform.flipX and atlasLeft or atlasRight
        local top = transform and transform.flipY and atlasBottom or atlasTop
        local bottom = transform and transform.flipY and atlasTop or atlasBottom
        texture:SetTexCoord(left, right, top, bottom)
    elseif not isAtlas then
        local left, right = transform and transform.flipX and 1 or 0, transform and transform.flipX and 0 or 1
        local top, bottom = transform and transform.flipY and 1 or 0, transform and transform.flipY and 0 or 1
        texture:SetTexCoord(left, right, top, bottom)
    end
    if texture.SetHorizTile then texture:SetHorizTile(tileHorizontal) end
    if texture.SetVertTile then texture:SetVertTile(tileVertical) end
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
    -- Edge strips run continuously behind the corner textures. The region
    -- boundary is inset from the outside frame edge, so the final partial
    -- tile is clipped there while the corners mask the strip at each join.
    local edgeMask = math.max(0, tonumber(theme.edgeMaskInset) or EDGE_MASK_INSET)
    local edgeSpanWidth = math.max(1, w - edgeMask * 2)
    local edgeSpanHeight = math.max(1, h - edgeMask * 2)

    local pieces = bg.customPieces
    local backing = bg.customBackingPieces
    local function Anchor(texture, point, relativePoint, x, y, width, height)
        texture:ClearAllPoints()
        texture:SetPoint(point, bg, relativePoint, x or 0, y or 0)
        texture:SetSize(math.max(1, width), math.max(1, height))
    end

    Anchor(pieces.topLeft, "TOPLEFT", "TOPLEFT", 0, 0, corner, corner)
    Anchor(pieces.top, "TOPLEFT", "TOPLEFT", edgeMask, 0, edgeSpanWidth, edge)
    Anchor(pieces.topRight, "TOPRIGHT", "TOPRIGHT", 0, 0, corner, corner)
    Anchor(pieces.left, "TOPLEFT", "TOPLEFT", 0, -edgeMask, edge, edgeSpanHeight)
    Anchor(pieces.center, "TOPLEFT", "TOPLEFT", corner, -corner, innerWidth, innerHeight)
    Anchor(pieces.right, "TOPRIGHT", "TOPRIGHT", 0, -edgeMask, edge, edgeSpanHeight)
    Anchor(pieces.bottomLeft, "BOTTOMLEFT", "BOTTOMLEFT", 0, 0, corner, corner)
    Anchor(pieces.bottom, "BOTTOMLEFT", "BOTTOMLEFT", edgeMask, 0, edgeSpanWidth, edge)
    Anchor(pieces.bottomRight, "BOTTOMRIGHT", "BOTTOMRIGHT", 0, 0, corner, corner)

    -- The center texture is the deepest backing layer and always covers the
    -- full frame. The authored edge pieces sit above it, so stretch fills the
    -- complete panel while tile can repeat beneath the entire nine-slice.
    Anchor(backing.center, "TOPLEFT", "TOPLEFT", 0, 0, w, h)

    -- The visible edge bands already run beneath the corners. Keep the old
    -- corner underlay objects hidden so they cannot double-blend the same art.
    for _, info in ipairs(CORNER_UNDERLAYS) do
        backing[info.key]:Hide()
    end

    local tiled = BackgroundStyle() == "tile"
    backing.center:SetHorizTile(tiled)
    backing.center:SetVertTile(tiled)
end

local function LayoutBackground()
    local w, h = frame:GetWidth(), frame:GetHeight()
    local custom = ns.db and ns.db.backgroundMode == "CUSTOM"
    if w == backgroundWidth and h == backgroundHeight
        and (not custom or laidOutBackgroundVersion == backgroundLayoutVersion) then
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
    laidOutBackgroundVersion = backgroundLayoutVersion
end
LayoutBackground()

local function SmoothStep(t)
    return t * t * (3 - 2 * t)
end

    -- Keep the background opacity separate from the content animation.
function ns.ApplyBackgroundAppearance()
    backgroundLayoutVersion = backgroundLayoutVersion + 1
    local theme = GetBackgroundTheme()
    local useCustom = ns.db and ns.db.backgroundMode == "CUSTOM" and theme ~= nil
    local themeTextures = theme and theme.textures or nil
    for _, layer in ipairs(bg.layers) do
        layer:SetShown(not useCustom)
    end
    if not useCustom then themeTextures = nil end
    for _, name in ipairs(BACKGROUND_PIECES) do
        local piece = bg.customPieces[name]
        if useCustom and name ~= "center" then
            local texture = themeTextures and themeTextures[name]
            SetBackgroundPiece(piece, name, texture, (ns.db and ns.db.bgOpacity) or 0.70, true)
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
        local centerTexture = themeTextures and themeTextures.center
        SetBackgroundPiece(bg.customBackingPieces.center, "center", centerTexture, alpha, false)
        for _, info in ipairs(CORNER_UNDERLAYS) do
            bg.customBackingPieces[info.key]:Hide()
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
    local color = ns.db and ns.db.backgroundColor or BLACK_COLOR
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

-- Fade portrait artwork as one layer, hidden while textures are rebuilt.
content.portraitArtwork = CreateFrame("Frame", nil, frame)
content.portraitArtwork:SetAllPoints(content)
content.portraitArtwork:SetFrameLevel(content:GetFrameLevel())
content.portraitArtwork:Hide()
local portraitPreparing = false
local render = {}
local entranceTimeline

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
        if entry.fs.gluStatText then entry.fs.gluFixedStatHeight = nil end
    end
    if ns.RefreshVisualEffects then ns.RefreshVisualEffects() end
end

local GLOW_ALPHA = 0.15
local GLOW_DIRS = {
    { -1, 0 }, { 1, 0 }, { 0, -1 }, { 0, 1 },
    { -1, -1 }, { 1, 1 }, { -1, 1 }, { 1, -1 },
}

local function CurrentShadowAlpha(text)
    if ns.db and ns.db.showTextShadow == false then return 0 end
    return text and text.glowAlpha or GLOW_ALPHA
end

local function EnsureGlowLayers(main)
    if main.glowsReady then return end
    main.glowsReady = true
    main.glows = main.glows or {}
    local r, g, b = main:GetTextColor()
    local fontPath, fontSize, fontFlags = main:GetFont()
    -- Restore the authored coloured glow. A faint native drop shadow cannot
    -- reproduce the coverage of the original eight offset text layers.
    for i, dir in ipairs(GLOW_DIRS) do
        local glow = main:GetParent():CreateFontString(nil, "ARTWORK", main.template)
        if fontPath and fontSize then glow:SetFont(fontPath, fontSize, fontFlags or "") end
        local glowOffsetY = tonumber(main.glowOffsetY) or 0
        glow:SetPoint("TOPLEFT", main, "TOPLEFT", dir[1] * main.glowRadius, dir[2] * main.glowRadius + glowOffsetY)
        glow:SetPoint("TOPRIGHT", main, "TOPRIGHT", dir[1] * main.glowRadius, dir[2] * main.glowRadius + glowOffsetY)
        glow:SetText(main:GetText() or "")
        if main.GetJustifyH then glow:SetJustifyH(main:GetJustifyH()) end
        if main.GetJustifyV then glow:SetJustifyV(main:GetJustifyV()) end
        -- The level label has intrinsic sizing from its font template. Adding
        -- explicit width/height while it is still empty shifts its glow above
        -- the later populated text, so keep that one glow set intrinsically.
        if not main.glowUseIntrinsicSize then
            if main.GetWidth then glow:SetWidth(main:GetWidth()) end
            if main.GetHeight then glow:SetHeight(main:GetHeight()) end
            if main.GetWordWrap then glow:SetWordWrap(main:GetWordWrap()) end
        end
        -- Text colour has full alpha; only the region alpha fades the glow.
        glow:SetTextColor(r or 1, g or 1, b or 1, 1)
        glow:SetAlpha(CurrentShadowAlpha(main))
        glow:SetShown(main:IsShown())
        main.glows[i] = glow
        RegisterFontElement(glow)
    end
end

-- Wrapped text can grow after a compact-layout width change or after a long
-- weapon-skill list is assigned. Keep the main FontString and every glow copy
-- at the same measured height so neither gets clipped or visually detached.
local function SyncTextGeometry(main)
    if not main or main.glowUseIntrinsicSize then return end
    local width = main.GetWidth and main:GetWidth() or 0
    if not width or width <= 0 then return end
    local measured = main.GetStringHeight and main:GetStringHeight() or 0
    local requestedLines = tonumber(main.wrapLineCount) or 0
    local height = math.max(18, tonumber(measured) or 0, requestedLines * 14)
    main:SetHeight(height)
    if main.gluStatText then main.gluFixedStatHeight = true end
    for _, glow in ipairs(main.glows or {}) do
        glow:SetWidth(width)
        glow:SetHeight(height)
        if glow.SetWordWrap and main.GetWordWrap then glow:SetWordWrap(main:GetWordWrap()) end
    end
end

local function NewText(parent, template, radius)
    local main = parent:CreateFontString(nil, "OVERLAY", template)
    main.glows = {}
    main.template = template
    main.glowRadius = radius
    content.textLayers[#content.textLayers + 1] = main
    return main
end

function ns.ApplyTextShadow(enabled)
    for _, text in ipairs(content.textLayers) do
        if enabled ~= false then EnsureGlowLayers(text) end
        local alpha = enabled == false and 0 or (text.glowAlpha or GLOW_ALPHA)
        for _, glow in ipairs(text.glows) do
            glow:SetAlpha((text.slideFrame and 1 or (text.lineAlpha or 1)) * alpha)
            if glow.animationAlpha then glow.animationAlpha:SetToAlpha(alpha) end
        end
    end
end

    -- Apply the same property to the main text and its glow copies.
local function ApplyToTextLayers(text, method, ...)
    text[method](text, ...)
    for _, glow in ipairs(text.glows) do
        glow[method](glow, ...)
    end
    if method == "SetFont" and text.gluStatText then text.gluFixedStatHeight = nil end
    if method == "SetWidth" or method == "SetWordWrap"
        or (method == "SetText" and not (text.gluStatText and text.gluFixedStatHeight)) then
        SyncTextGeometry(text)
    end
end

local function RegisterGlowFont(main, size, flags)
    RegisterFontElement(main, size, flags)
end

local function EnsureAllTextGlows()
    if ns.db and ns.db.showTextShadow == false then return end
    for _, text in ipairs(content.textLayers) do EnsureGlowLayers(text) end
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
    animatedElements = true,
}

local function ActiveColor(key)
    if ns.db and ns.db.useClassColors and CLASS_COLOR_KEYS[key] then
        local _, classToken = UnitClass("player")
        local classColor = ns.CLASS_COLORS and ns.CLASS_COLORS[classToken]
        local overrides = ns.db.classColorOverrides and ns.db.classColorOverrides[classToken]
        if classColor then return overrides and overrides[key] or classColor end
    end
    return ColorOf(key)
end

function render.HexRGB(r, g, b)
    return string.format("|cff%02x%02x%02x", math.floor(r * 255 + 0.5), math.floor(g * 255 + 0.5), math.floor(b * 255 + 0.5))
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

content.portraitAnchor = CreateFrame("Frame", nil, content.portraitArtwork)
content.portraitAnchor:SetSize(PortraitRingSize(), PortraitRingSize())
content.portraitAnchor:SetPoint("TOP", content, "TOP", 0, -SectionPadding())

content.classRing = content.portraitArtwork:CreateTexture(nil, "ARTWORK", nil, 1)
content.classRing:SetSize(PortraitRingSize(), PortraitRingSize())
content.classRing:SetPoint("CENTER", content.portraitAnchor, "CENTER")
content.classRing:SetColorTexture(1, 0.82, 0.2, 1)

content.classIcon = content.portraitArtwork:CreateTexture(nil, "ARTWORK", nil, 2)
content.classIcon:SetSize(PortraitIconSize(), PortraitIconSize())
content.classIcon:SetPoint("CENTER", content.portraitAnchor, "CENTER", 0, 0)
content.classIcon:SetTexture(CLASS_ICON_SHEET)

-- Custom themes may provide an authored frame around the portrait. It sits
-- above the icon and replaces the normal colour-only ring when enabled.
content.classRingGraphic = content.portraitArtwork:CreateTexture(nil, "ARTWORK", nil, 3)
content.classRingGraphic:SetSize(PortraitRingSize(), PortraitRingSize())
content.classRingGraphic:SetPoint("CENTER", content.portraitAnchor, "CENTER", 0, 0)
content.classRingGraphic:Hide()

-- Desaturate spells/starburst_blue.blp before applying Animated Elements colour.
content.portraitStarburst = content:CreateTexture(nil, "ARTWORK", nil, -2)
content.portraitStarburst:SetTexture(405924)
content.portraitStarburst:SetDesaturated(true)
content.portraitStarburst:SetBlendMode("ADD")
content.portraitStarburst:SetPoint("CENTER", content.classRing, "CENTER")
content.portraitStarburst:Hide()

content.portraitPulse = content:CreateTexture(nil, "ARTWORK", nil, -1)
content.portraitPulse:SetTexture("Interface\\AddOns\\GnomeLevelUp\\Textures\\Backgrounds\\circle-frame.tga")
content.portraitPulse:SetDesaturated(true)
content.portraitPulse:SetBlendMode("ADD")
content.portraitPulse:SetPoint("CENTER", content.classRing, "CENTER")
content.portraitPulse:Hide()

if content.portraitArtwork.CreateMaskTexture then
    local ringMask = content.portraitArtwork:CreateMaskTexture()
    ringMask:SetAllPoints(content.classRing)
    ringMask:SetTexture(CIRCLE_MASK, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    content.classRing:AddMaskTexture(ringMask)

    local iconMask = content.portraitArtwork:CreateMaskTexture()
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
    local ringSize = math.max(1, PortraitRingSize())

    content.portraitAnchor:SetSize(ringSize, ringSize)
    content.portraitAnchor:ClearAllPoints()
    content.portraitAnchor:SetPoint("TOP", content, "TOP", x, -SectionPadding() + y)
    content.classRing:SetSize(ringSize, ringSize)
    content.classIcon:SetSize(iconSize, iconSize)
    content.classRingGraphic:SetSize(ringSize * PortraitRingScale(), ringSize * PortraitRingScale())
    local ringOffsetX, ringOffsetY = PortraitRingOffset()
    content.classRingGraphic:ClearAllPoints()
    content.classRingGraphic:SetPoint("CENTER", content.portraitAnchor, "CENTER", ringOffsetX, ringOffsetY)

    if content.levelText then
        content.levelText:ClearAllPoints()
        if ns.db and ns.db.portraitMode == "none" then
            content.levelText:SetPoint("TOP", content, "TOP", 0, -SectionPadding() - 6)
        else
            content.levelText:SetPoint("TOP", content.portraitAnchor, "BOTTOM", 0, -6)
        end
    end
    if content.title then
        content.title:ClearAllPoints()
        content.title:SetPoint("TOP", content, "TOP", 0, -(SectionPadding() + ringSize + 6))
    end
    if ns.RefreshVisualEffects then ns.RefreshVisualEffects() end
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
    -- None removes the portrait artwork and its reserved header space.
    local portraitMode = ns.db and ns.db.portraitMode or "class"
    if portraitMode == "none" then
        content.classIcon:Hide()
        content.classRing:Hide()
        content.classRingGraphic:Hide()
        return
    end
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
    if db.portraitMode == "none" then
        content.classRing:Hide()
        content.classRingGraphic:Hide()
        return
    end
    local reference = db.portraitRingTexture
    if (type(reference) ~= "string" or reference == "")
        and db.portraitRingChoice then
        reference = ns.GetPortraitRingReference(db.portraitRingChoice)
    end
    local enabled = db.portraitRingEnabled == true
        and ((type(reference) == "string" and reference ~= "")
            or (type(reference) == "table" and reference.atlas))
    local ringColor = enabled and (db.portraitRingColor or { 1, 1, 1 })
        or (db.colors and db.colors.portraitBorder) or { 1, 0.82, 0.20 }
    -- The solid ring uses Portrait Border; authored textures use Portrait Ring Hue.
    content.classRing:SetColorTexture(ringColor[1], ringColor[2], ringColor[3], 1)
    if not enabled then
        content.classRingGraphic:Hide()
        content.classRing:Show()
        return
    end

    local applied = ns.ApplyPortraitRingTexture(content.classRingGraphic, reference)
    if applied then
        local tint = ringColor
        content.classRingGraphic:SetVertexColor(tint[1], tint[2], tint[3], 1)
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
content.levelText:SetPoint("TOP", content.portraitAnchor, "BOTTOM", 0, -6)
content.levelText.glowUseIntrinsicSize = true
RegisterGlowFont(content.levelText)

content.statsHeader = NewText(content, "GameFontNormalLarge", 2)
content.statsHeader:SetPoint("TOP", content.levelText, "BOTTOM", 0, -22)
ApplyToTextLayers(content.statsHeader, "SetText", ns.L("Stats Gained"))
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
    divider.texture:SetPoint("CENTER", divider, "CENTER")
    divider.texture:SetSize(TEXT_WIDTH, SECTION_DIVIDER_HEIGHT)
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
ApplyToTextLayers(content.spellsHeader, "SetText", ns.L("Abilities"))
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
ApplyToTextLayers(content.levelTimeText, "SetShown", false)

local ABILITY_ICON_SIZE = 40
local NEW_ABILITY_ICON_SIZE = ABILITY_ICON_SIZE * 1.05
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
        if amount > 0 and #parts < 2 then
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
        return ns.L("Time to level: %dh %02dm", hours, minutes)
    elseif minutes > 0 then
        return ns.L("Time to level: %dm %02ds", minutes, remainingSeconds)
    end
    return ns.L("Time to level: %ds", remainingSeconds)
end

local function AbilityCellHeight(iconSize)
    iconSize = iconSize or ABILITY_ICON_SIZE
    if ns.db and ns.db.showTrainerCosts then
        return iconSize + ABILITY_COST_GAP + ABILITY_COST_HEIGHT + ABILITY_COST_TOP_PADDING
    end
    return iconSize
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
ApplyToTextLayers(content.petSpellsHeader, "SetText", ns.L("Warlock Grimoires"))
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
ApplyToTextLayers(content.weaponSkillsText, "SetShown", false)

content.noAbilitiesText = NewText(content.abilityRow, "GameFontHighlightSmall", 1.5)
content.noAbilitiesText:SetPoint("CENTER", content.abilityRow, "CENTER", 0, 0)
ApplyToTextLayers(content.noAbilitiesText, "SetJustifyH", "CENTER")
ApplyToTextLayers(content.noAbilitiesText, "SetJustifyV", "MIDDLE")
RegisterGlowFont(content.noAbilitiesText)
ApplyToTextLayers(content.noAbilitiesText, "SetText", ns.L("No unlearned skills available"))

-- These headings are created before SavedVariables load. Core refreshes them
-- after selecting the saved language, before any level-up can be displayed.
function ns.RefreshLocalizedPopupText()
    ApplyToTextLayers(content.statsHeader, "SetText", ns.L("Stats Gained"))
    ApplyToTextLayers(content.spellsHeader, "SetText", ns.L("Abilities"))
    ApplyToTextLayers(content.petSpellsHeader, "SetText", ns.L("Warlock Grimoires"))
    ApplyToTextLayers(content.noAbilitiesText, "SetText", ns.L("No unlearned skills available"))
end

local MeasureStatContentWidth
local FitStatFont
local function ApplyPopupWidth()
    local compact = IsCompactLayout()
    local gap = compact and 6 or 10
    local textWidth = compact
        and (COMPACT_MAX_SKILLS * NEW_ABILITY_ICON_SIZE + (COMPACT_MAX_SKILLS - 1) * gap)
        or DEFAULT_TEXT_WIDTH
    if compact and ns.db and ns.db.emphasizeStatGains then textWidth = textWidth + 40 end
    local fontChanged = FitStatFont and FitStatFont(textWidth, compact)
    if not compact then
        textWidth = math.max(textWidth, MeasureStatContentWidth and MeasureStatContentWidth() or 0)
    end
    if TEXT_WIDTH == textWidth then
        if fontChanged and ns.RefreshStatTextLayout then ns.RefreshStatTextLayout() end
        return
    end
    TEXT_WIDTH = textWidth
    FRAME_WIDTH = textWidth + 60
    frame:SetWidth(FRAME_WIDTH)
    content.statsContainer:SetWidth(TEXT_WIDTH)
    content.levelTimeText:SetWidth(TEXT_WIDTH)
    content.weaponSkillsText:SetWidth(TEXT_WIDTH)
    SyncTextGeometry(content.weaponSkillsText)
    for _, fs in ipairs(content.statLinePool) do
        ApplyToTextLayers(fs, "SetWidth", TEXT_WIDTH)
        fs.slideFrame:SetWidth(TEXT_WIDTH)
    end
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
    if ns.RefreshStatTextLayout then ns.RefreshStatTextLayout() end
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
    if mode == "none" then return 0 end
    if mode == "left" then return -1 end
    if mode == "right" then return 1 end
    return (index % 2 == 1) and -1 or 1
end

function render.Alpha(region, alpha)
    if region:GetAlpha() ~= alpha then region:SetAlpha(alpha) end
end

function render.Shown(region, shown)
    if region:IsShown() ~= shown then region:SetShown(shown) end
end

function render.Size(region, width, height)
    if region:GetWidth() ~= width or region:GetHeight() ~= height then region:SetSize(width, height) end
end

local ApplyStatLineText
local activeLineAnims = {}
local activeIconAnims = {}

local function SetLineAlpha(fs, alpha)
    fs.lineAlpha = alpha
    if fs.slideFrame then
        -- One parent alpha keeps rich text and all glow copies in lockstep.
        -- Hide zero-alpha rows so rebuilding them cannot expose stale glyphs.
        render.Alpha(fs.slideFrame, alpha)
        render.Shown(fs.slideFrame, alpha > 0)
        render.Alpha(fs, 1)
        for _, glow in ipairs(fs.glows) do render.Alpha(glow, CurrentShadowAlpha(fs)) end
    else
        render.Alpha(fs, alpha)
        for _, glow in ipairs(fs.glows) do render.Alpha(glow, alpha * CurrentShadowAlpha(fs)) end
    end
end

local function EntranceAlpha(stage, age, moving)
    if not moving or not stage then return 1 end
    local t = math.max(0, math.min(1, (age - stage.start) / math.max(0.001, stage.finish - stage.start)))
    return 1 - (1 - t) ^ 2
end

local function UpdateDividerEntrance(divider, stage, age, moving)
    local alpha = EntranceAlpha(stage, age, moving)
    local reveal = 1
    if ns.db and ns.db.dividerReveal and moving and stage then
        -- Let the full-opacity centre expand slowly enough to read as motion.
        local t = math.max(0, math.min(1, (age - stage.start) / (0.60 / Speed())))
        reveal = t * t * (3 - 2 * t)
        alpha = math.min(1, t * 6)
    end
    render.Alpha(divider, alpha)
    local width = math.max(0.001, TEXT_WIDTH * reveal)
    if divider.texture:GetWidth() ~= width then divider.texture:SetWidth(width) end
    if divider.lastReveal ~= reveal then
        divider.texture:SetTexCoord((1 - reveal) / 2, (1 + reveal) / 2, 0, 1)
        divider.lastReveal = reveal
    end
    render.Shown(divider.texture, reveal > 0)
end

local function UpdateSectionEntrance(age, moving)
    local plan = entranceTimeline
    if not plan or render.sectionComplete == plan then return false end
    SetLineAlpha(content.levelText, EntranceAlpha(plan.portrait, age, moving))
    SetLineAlpha(content.statsHeader, EntranceAlpha(plan.statsHeader, age, moving))
    SetLineAlpha(content.levelTimeText, EntranceAlpha(plan.levelTime, age, moving))
    SetLineAlpha(content.spellsHeader, EntranceAlpha(plan.abilitiesHeader, age, moving))
    SetLineAlpha(content.petSpellsHeader, EntranceAlpha(plan.petHeader, age, moving))
    SetLineAlpha(content.weaponSkillsText, EntranceAlpha(plan.weapon, age, moving))
    -- Viewports also gate empty messages, prices and scrollbars. Per-icon pop
    -- animations keep their own stagger inside the matching section's window.
    render.Alpha(content.abilityViewport, EntranceAlpha(plan.abilities, age, moving))
    render.Alpha(content.petAbilityViewport, EntranceAlpha(plan.petAbilities, age, moving))
    UpdateDividerEntrance(content.statsHeaderDivider, plan.statsHeader, age, moving)
    UpdateDividerEntrance(content.statsBottomDivider, plan.statsBottom, age, moving)
    UpdateDividerEntrance(content.timeBottomDivider, plan.levelTime, age, moving)
    UpdateDividerEntrance(content.abilitiesDivider, plan.abilitiesHeader, age, moving)
    UpdateDividerEntrance(content.petDivider, plan.petHeader, age, moving)
    UpdateDividerEntrance(content.petHeaderDivider, plan.petHeader, age, moving)
    UpdateDividerEntrance(content.weaponDivider, plan.weapon, age, moving)
    render.Alpha(closeButton, EntranceAlpha(plan.background, age, moving))
    if not moving or age >= plan.finish then render.sectionComplete = plan end
    return moving and age < plan.finish
end

local function SetLineShown(fs, shown)
    ApplyToTextLayers(fs, "SetShown", shown)
end

-- Ability icons keep native entrance animations. Stat rows move as one frame
-- so their text and glow cannot finish on different frames.
local ABILITY_POP_DISTANCE = 24
local statSlideDriver = CreateFrame("Frame", nil, content.statsContainer)

local function AbilityIconColumns(cellWidth)
    local gap = AbilityIconGap()
    local columns = math.max(1, math.floor((TEXT_WIDTH + gap) / (cellWidth + gap)))
    return IsCompactLayout() and math.min(COMPACT_MAX_SKILLS, columns) or columns
end

local function StopLineAnimation(fs)
    activeLineAnims[fs] = nil
    if not next(activeLineAnims) then statSlideDriver:SetScript("OnUpdate", nil) end
end

local function UpdateStatSlides(_, elapsed)
    for fs, motion in pairs(activeLineAnims) do
        motion.age = motion.age + elapsed
        local t = math.max(0, math.min(1, (motion.age - motion.delay) / motion.duration))
        if ns.db and ns.db.reducedMotion then t = 1 end
        local eased = 1 - (1 - t) ^ 3
        local startX = ns.db and ns.db.statSlideDirection == "none" and 0 or motion.startX
        local x = startX * (1 - eased)
        if x ~= motion.lastX then
            -- Keep the existing anchor while moving, so font geometry is not
            -- discarded during the fade.
            fs.slideFrame:SetPoint("TOP", motion.container, "TOP", x, motion.y)
            motion.lastX = x
        end
        local countFinished = true
        local countOpacity = 1
        if fs.statData then
            local target = fs.statData.new - fs.statData.old
            local count = ns.db and ns.db.emphasizeStatGains and not ns.db.reducedMotion
            -- Begin with the row's slide; keep counting after it lands so the
            -- changing main value remains readable at full opacity as well.
            local progress = math.max(0, math.min(1,
                (motion.age - motion.delay) / motion.countDuration))
            local amount = count and progress < 1
                and math.floor(math.abs(target) * (1 - (1 - progress) ^ 2) + 0.5) * (target < 0 and -1 or 1) or target
            countFinished = not count or progress >= 1 or target == 0
            if count and target ~= 0 then
                local easedOpacity = progress * progress * (3 - 2 * progress)
                countOpacity = 0.72 + 0.28 * easedOpacity
            end
            if fs.displayGain ~= amount then fs.displayGain = amount; ApplyStatLineText(fs) end
        end
        SetLineAlpha(fs, t * t * countOpacity)
        if t == 1 and countFinished then activeLineAnims[fs] = nil end
    end
    if not next(activeLineAnims) then statSlideDriver:SetScript("OnUpdate", nil) end
end

local function StartLineAnimation(fs, container, startX, y, delay, duration)
    StopLineAnimation(fs)
    fs.slideFrame:SetWidth(TEXT_WIDTH)
    fs.slideFrame:ClearAllPoints()
    fs.countFinishAt = fs.statData and fs.statData.new ~= fs.statData.old
        and ns.db and ns.db.emphasizeStatGains and not ns.db.reducedMotion
        and delay + 1.0 / Speed() or nil
    fs.displayGain = fs.statData and (ns.db and ns.db.emphasizeStatGains and not ns.db.reducedMotion and 0 or fs.statData.new - fs.statData.old) or nil
    ApplyStatLineText(fs)
    if ns.db and ns.db.reducedMotion then
        fs.slideFrame:SetPoint("TOP", container, "TOP", 0, y)
        SetLineAlpha(fs, 1)
    else
        fs.slideFrame:SetPoint("TOP", container, "TOP", startX, y)
        SetLineAlpha(fs, 0)
        activeLineAnims[fs] = {
            container = container, startX = startX, y = y,
            delay = delay, duration = duration, age = 0, lastX = startX,
            countDuration = 1.0 / Speed(),
        }
        statSlideDriver:SetScript("OnUpdate", UpdateStatSlides)
    end
    SetLineShown(fs, true)
end

-- Unused pooled rows must release their data as well as hiding the label.
-- Otherwise a later style refresh can show their separate gain suffix again.
local function ReleaseStatLine(fs)
    StopLineAnimation(fs)
    fs.statData, fs.plainText, fs.displayGain, fs.gainFlash = nil, nil, nil, 0
    fs.entranceEnd, fs.countFinishAt = nil, nil
    SetLineShown(fs, false)
    fs.slideFrame:Hide()
    if fs.gainCounter then ApplyToTextLayers(fs.gainCounter, "Hide") end
end

local function GetStatLine(index)
    local pool = content.statLinePool
    if pool[index] then return pool[index] end

    local fontPath = (ns.db and ns.db.customFontPath) or DEFAULT_FONT_PATH
    local holder = CreateFrame("Frame", nil, content.statsContainer)
    holder:SetSize(TEXT_WIDTH, STAT_LINE_HEIGHT)
    local fs = NewText(holder, "GameFontHighlight", 2)
    fs.slideFrame = holder
    fs.gluStatText = true
    fs:SetPoint("TOP", holder, "TOP")
    fs:SetWidth(TEXT_WIDTH)
    ApplyToTextLayers(fs, "SetJustifyH", "CENTER")
    ApplyToTextLayers(fs, "SetWordWrap", false)
    RegisterGlowFont(fs, 20, "")
    ApplyToTextLayers(fs, "SetFont", fontPath, 20, "")
    if not ns.db or ns.db.showTextShadow ~= false then EnsureGlowLayers(fs) end
    local counter = NewText(holder, "GameFontHighlight", 2)
    counter.slideFrame = holder
    counter.gluStatText = true
    counter:SetJustifyH("LEFT")
    counter:SetJustifyV("MIDDLE")
    counter:SetWordWrap(false)
    counter:SetHeight(STAT_LINE_HEIGHT)
    RegisterGlowFont(counter, 20, "")
    ApplyToTextLayers(counter, "SetFont", fontPath, 20, "")
    if not ns.db or ns.db.showTextShadow ~= false then EnsureGlowLayers(counter) end
    fs.gainCounter = counter
    ApplyToTextLayers(counter, "Hide")
    SetLineShown(fs, false)

    pool[index] = fs
    return fs
end

local function StartIconPop(icon, container, x, y, delay, duration, skipAnimation)
    if not icon.animationGroup then
        local group = icon:CreateAnimationGroup()
        local translation = group:CreateAnimation("Translation")
        local alpha = group:CreateAnimation("Alpha")
        group:SetScript("OnFinished", function()
            if icon.animationContainer then
                icon:ClearAllPoints()
                icon:SetPoint("CENTER", icon.animationContainer, "CENTER",
                    icon.animationX or 0, icon.animationY or 0)
            end
            icon:SetScale(1)
            icon:SetAlpha(1)
            icon:Show()
            activeIconAnims[icon] = nil
        end)
        icon.animationGroup = group
        icon.animationTranslation = translation
        icon.animationAlpha = alpha
    end
    activeIconAnims[icon] = nil
    if icon.animationGroup then icon.animationGroup:Stop() end
    icon.animationContainer, icon.animationX, icon.animationY = container, x, y
    if skipAnimation or (ns.db and ns.db.reducedMotion) then
        icon:ClearAllPoints()
        icon:SetPoint("CENTER", container, "CENTER", x, y)
        icon:SetScale(1)
        icon:SetAlpha(1)
        icon:Show()
        return
    end
    activeIconAnims[icon] = true
    icon.animationContainer = container
    icon.animationX = x
    icon.animationY = y
    icon:ClearAllPoints()
    icon:SetPoint("CENTER", container, "CENTER", x, y - ABILITY_POP_DISTANCE)
    icon:SetScale(1)
    icon:SetAlpha(0)
    icon:Show()

    local translation = icon.animationTranslation
    translation:SetOffset(0, ABILITY_POP_DISTANCE)
    translation:SetDuration(duration)
    translation:SetStartDelay(delay)
    translation:SetSmoothing("OUT")

    local alpha = icon.animationAlpha
    alpha:SetFromAlpha(0)
    alpha:SetToAlpha(1)
    alpha:SetDuration(duration)
    alpha:SetStartDelay(delay)
    alpha:SetSmoothing("IN")
    icon.animationGroup:Play()
end

local function StopIconAnimation(icon)
    activeIconAnims[icon] = nil
    if icon.animationGroup then icon.animationGroup:Stop() end
end

local function NewSparkTexture(parent, layer)
    local texture = parent:CreateTexture(nil, layer or "OVERLAY")
    texture:SetTexture("Interface\\Cooldown\\star4")
    texture:SetDesaturated(true)
    texture:SetBlendMode("ADD")
    texture:Hide()
    return texture
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
    costText:SetHeight(ABILITY_COST_HEIGHT)
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

    local glow = btn:CreateTexture(nil, "OVERLAY")
    glow:SetTexture("Interface\\Buttons\\UI-ActionButton-Border")
    glow:SetDesaturated(true)
    glow:SetBlendMode("ADD")
    glow:SetSize(ABILITY_ICON_SIZE * 1.85, ABILITY_ICON_SIZE * 1.85)
    glow:SetPoint("CENTER")
    glow:SetVertexColor(1, 0.82, 0.20)
    glow:Hide()
    btn.newAbilityGlow = glow
    btn.cornerSparkles = { NewSparkTexture(btn), NewSparkTexture(btn) }
    btn.ambientSparkle = NewSparkTexture(btn)
    btn.cornerSparkles[1]:SetPoint("CENTER", btn, "TOPLEFT", 1, -1)
    btn.cornerSparkles[2]:SetPoint("CENTER", btn, "BOTTOMRIGHT", -1, 1)

    btn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        if self.spellID and GameTooltip.SetSpellByID then
            GameTooltip:SetSpellByID(self.spellID)
        elseif self.spellName then
            GameTooltip:SetText(self.spellName, 1, 1, 1, 1)
        end
        if ns.db and ns.db.highlightNewAbilities and self.isNewAbility ~= nil then
            GameTooltip:AddLine(ns.L(self.isNewAbility and "New ability" or "Rank upgrade"), 1, 0.82, 0.20)
        end
        GameTooltip:Show()
    end)
    btn:SetScript("OnLeave", function() GameTooltip:Hide() end)
    btn:Hide()

    pool[index] = btn
    return btn
end

local function EmptyTrainerSkillsMessage()
    -- An empty unlearned list can also mean everything is already learned.
    -- Check the full class catalog before asking the player to scan a trainer.
    if ns.GetCurrentFlavor() == "forever" then
        local hasClassData = false
        for _, item in ipairs(ns.GetTrainerCatalogIndex()) do
            if type(item.entry) ~= "table" or not item.entry.profession then
                hasClassData = true
                break
            end
        end
        if not hasClassData then
            return ns.L("No trainer data for this class.\nVisit your class trainer."), 2
        end
    end
    return ns.L(ns.db and ns.db.showOnlyCurrentLevelSkills
        and "No new skills this level" or "No unlearned skills available")
end

local function UpdateAbilityIcons(row, pool, emptyText, abilities, showEmptyText, skipAnimation)
    local count = #abilities
    local speed = Speed()
    local staggerBase = BASE_STAT_STAGGER_BASE / speed
    local staggerStep = BASE_STAT_STAGGER_STEP / speed
    local popDuration = BASE_STAT_SLIDE_DURATION / speed

    if count == 0 then
        row.viewport:SetWidth(TEXT_WIDTH)
        row:SetWidth(TEXT_WIDTH)
        row:SetHeight(ABILITY_ICON_SIZE)
        row.viewport:SetHeight(ABILITY_ICON_SIZE)
        row.viewport:SetHorizontalScroll(0)
        row.viewport.slider:SetMinMaxValues(0, 0)
        row.viewport.slider:SetValue(0)
        row.viewport.slider:Hide()
        row.viewport.scrollTrack:Hide()
        for _, icon in ipairs(pool) do
            StopIconAnimation(icon)
            icon:Hide()
        end
        if emptyText then
            local message, lineCount = EmptyTrainerSkillsMessage()
            emptyText.wrapLineCount = lineCount or 0
            ApplyToTextLayers(emptyText, "SetWidth", TEXT_WIDTH)
            ApplyToTextLayers(emptyText, "SetWordWrap", true)
            ApplyToTextLayers(emptyText, "SetJustifyH", "CENTER")
            ApplyToTextLayers(emptyText, "SetText", message)
            local emptyHeight = math.max(ABILITY_ICON_SIZE, emptyText:GetHeight() or 0, emptyText:GetStringHeight() or 0)
            row:SetHeight(emptyHeight)
            row.viewport:SetHeight(emptyHeight)
            ApplyToTextLayers(emptyText, showEmptyText and "Show" or "Hide")
        end
        return
    end

    if emptyText then ApplyToTextLayers(emptyText, "Hide") end

    -- Measure the actual selected-font price before laying out the row. Labels
    -- may be wider than the icon; reserve that space instead of truncating or
    -- letting neighboring prices overlap (including compact/scroll layouts).
    local cellWidth = ABILITY_ICON_SIZE
    local rowIconSize = ABILITY_ICON_SIZE
    for i, spell in ipairs(abilities) do
        local icon = GetAbilityIcon(i, row, pool)
        local iconSize = spell.isNewAbility == true and NEW_ABILITY_ICON_SIZE or ABILITY_ICON_SIZE
        icon:SetSize(iconSize, iconSize)
        icon.newAbilityGlow:SetSize(iconSize * 1.85, iconSize * 1.85)
        cellWidth = math.max(cellWidth, iconSize)
        rowIconSize = math.max(rowIconSize, iconSize)
        local formattedCost = ns.db and ns.db.showTrainerCosts and FormatTrainerCost(spell.cost)
        if formattedCost ~= icon.formattedCost then
            icon.costText:SetText(formattedCost or "")
            icon.formattedCost = formattedCost
        end
        icon.costText:SetShown(formattedCost ~= nil and formattedCost ~= false)
        if formattedCost then
            icon.costText:SetWidth(0)
            local costWidth = math.ceil(icon.costText:GetStringWidth()) + 2
            icon.costText:SetWidth(costWidth)
            cellWidth = math.max(cellWidth, costWidth)
        end
    end
    local gap = AbilityIconGap()
    local viewportWidth = IsCompactLayout()
        and math.min(TEXT_WIDTH, COMPACT_MAX_SKILLS * cellWidth + (COMPACT_MAX_SKILLS - 1) * gap)
        or TEXT_WIDTH
    row.viewport:SetWidth(viewportWidth)
    local maxColumns = AbilityIconColumns(cellWidth)
    local shouldScroll = UseHorizontalAbilityScroll() and count > maxColumns
    local columns = shouldScroll and count or math.min(count, maxColumns)
    local rows = shouldScroll and 1 or math.ceil(count / maxColumns)
    local totalWidth = columns * cellWidth + (columns - 1) * gap
    local cellHeight = AbilityCellHeight(rowIconSize)
    local totalHeight = rows * cellHeight + (rows - 1) * gap
    local viewportHeight = totalHeight
    row:SetWidth(shouldScroll and totalWidth or viewportWidth)
    row:SetHeight(totalHeight)
    row:ClearAllPoints()
    row:SetPoint("TOPLEFT", row.viewport, "TOPLEFT", 0,
        shouldScroll and -(SCROLLBAR_HEIGHT / 2) or 0)
    row.viewport:SetHeight(viewportHeight + (shouldScroll and SCROLLBAR_HEIGHT or 0))
    if shouldScroll then
        local maximum = math.max(0, totalWidth - viewportWidth)
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
    local startX = -totalWidth / 2 + cellWidth / 2
    local startY = totalHeight / 2 - cellHeight / 2

    for i, spell in ipairs(abilities) do
        local icon = GetAbilityIcon(i, row, pool)
        local spellID = spell.id
        local spellName = spell.name
        icon.spellID = spellID
        icon.spellName = spellName
        icon.isNewAbility = spell.isNewAbility
        local formattedCost = icon.formattedCost
        local texture = spell.icon
        if not texture and icon.textureSpellID == spellID then
            texture = icon.texturePath
        elseif not texture then
            local spellTextureFunc = C_Spell and C_Spell.GetSpellTexture
            if not spellTextureFunc then
                spellTextureFunc = rawget(_G, "GetSpellTexture")
            end
            texture = spellID and spellTextureFunc and spellTextureFunc(spellID)
            icon.textureSpellID = spellID
        else
            icon.textureSpellID = nil
        end
        texture = texture or "Interface\\Icons\\INV_Misc_QuestionMark"
        if texture ~= icon.texturePath then
            icon.icon:SetTexture(texture)
            icon.texturePath = texture
        end

        local zeroIndex = i - 1
        local column = zeroIndex % columns
        local rowIndex = math.floor(zeroIndex / columns)
        local x = startX + column * (cellWidth + gap)
        local iconSize = spell.isNewAbility == true and NEW_ABILITY_ICON_SIZE or ABILITY_ICON_SIZE
        local visibleCellHeight = formattedCost and cellHeight or rowIconSize
        local iconY = startY + (visibleCellHeight - iconSize) / 2
            - rowIndex * (cellHeight + gap)
        if formattedCost then iconY = iconY - ABILITY_COST_TOP_PADDING end
        local delay = staggerBase + (i - 1) * staggerStep
        icon.entranceEnd = delay + popDuration
        StartIconPop(icon, row, x, iconY, delay, popDuration, skipAnimation or portraitPreparing)
    end

    for i = count + 1, #pool do
        StopIconAnimation(pool[i])
        pool[i]:Hide()
    end
end

-- Fill the main ability row with the current unlearned skills.
local function UpdateTrainerAbilityIcons(trainerAbilities, skipAnimation)
    content.currentTrainerAbilities = trainerAbilities or {}
    UpdateAbilityIcons(content.abilityRow, content.abilityIconPool, content.noAbilitiesText, trainerAbilities, true, skipAnimation)
end

local function UpdateWarlockPetAbilityIcons(petAbilities, skipAnimation)
    content.currentWarlockPetAbilities = petAbilities or {}
    local hasAbilities = type(petAbilities) == "table" and #petAbilities > 0
    if not hasAbilities then
        ApplyToTextLayers(content.petSpellsHeader, "Hide")
        content.petAbilityRow:Hide()
        UpdateAbilityIcons(content.petAbilityRow, content.petAbilityIconPool, nil, {}, false, skipAnimation)
        return
    end

    ApplyToTextLayers(content.petSpellsHeader, "Show")
    content.petAbilityRow:Show()
    UpdateAbilityIcons(content.petAbilityRow, content.petAbilityIconPool, nil, petAbilities, false, skipAnimation)
end

local function UpdateWeaponSkillText(unlearnedWeaponSkills)
    local enabled = ns.db and ns.db.showWeaponSkills ~= false
    if not enabled or type(unlearnedWeaponSkills) ~= "table" or #unlearnedWeaponSkills == 0 then
        ApplyToTextLayers(content.weaponSkillsText, "SetShown", false)
        ApplyToTextLayers(content.weaponSkillsText, "SetText", "")
        PositionSections()
        return false
    end

    local names = {}
    local compact = IsCompactLayout()
    local maxNames = compact and 5 or math.huge
    local totalNames = 0
    for _, skill in ipairs(unlearnedWeaponSkills) do
        local name
        if type(skill) == "table" and skill.name then
            name = skill.name
        elseif type(skill) == "string" then
            name = skill
        end
        if name then
            totalNames = totalNames + 1
            if #names < maxNames then names[#names + 1] = name end
        end
    end
    if #names == 0 then
        ApplyToTextLayers(content.weaponSkillsText, "SetShown", false)
        ApplyToTextLayers(content.weaponSkillsText, "SetText", "")
        PositionSections()
        return false
    end

    local more = totalNames > #names and " & more..." or ""
    local maxCharacters = compact and 30 or 54
    local maxItemsPerLine = compact and 2 or 3
    local lines, currentLine = {}, ""
    local currentItems = 0
    for _, name in ipairs(names) do
        local candidate = currentLine == "" and name or (currentLine .. ", " .. name)
        if currentLine ~= "" and (currentItems >= maxItemsPerLine or #candidate > maxCharacters) then
            lines[#lines + 1] = currentLine
            currentLine = name
            currentItems = 1
        else
            currentLine = candidate
            currentItems = currentItems + 1
        end
    end
    if currentLine ~= "" then lines[#lines + 1] = currentLine end
    if #lines == 0 then lines[1] = "" end
    lines[#lines] = lines[#lines] .. more
    local displayText = table.concat(lines, "\n")
    content.weaponSkillsText.wrapLineCount = #lines
    ApplyToTextLayers(content.weaponSkillsText, "SetText",
        ns.L("Weapon skills: %s", displayText))
    SetTextColorKey(content.weaponSkillsText, "statLabel")
    ApplyToTextLayers(content.weaponSkillsText, "SetShown", true)
    PositionSections()
    return true
end

local statMeasureFont
local function MeasureStatText(fs, text)
    statMeasureFont = statMeasureFont or content:CreateFontString(nil, "ARTWORK")
    local fontPath, fontSize, fontFlags = fs:GetFont()
    if fontPath and fontSize then statMeasureFont:SetFont(fontPath, fontSize, fontFlags or "") end
    statMeasureFont:SetText(text or "")
    return statMeasureFont:GetStringWidth() or 0
end

local function GainCounterWidth(fs, target)
    local path, size, flags = fs:GetFont()
    local digits = #tostring(math.floor(math.abs(target)))
    if fs.gainWidthPath ~= path or fs.gainWidthSize ~= size or fs.gainWidthFlags ~= flags or fs.gainWidthDigits ~= digits then
        local width = 0
        for digit = 0, 9 do
            local number = string.rep(tostring(digit), digits)
            width = math.max(width, MeasureStatText(fs, " (+" .. number .. ")"), MeasureStatText(fs, " (-" .. number .. ")"))
        end
        -- Native FontStrings can ellipsize a box sized exactly to glyph
        -- advances. Leave room for rounding, kerning and the glow outline.
        fs.gainWidthPath, fs.gainWidthSize, fs.gainWidthFlags, fs.gainWidthDigits = path, size, flags, digits
        fs.gainReservedWidth = math.ceil(width) + 12
    end
    return fs.gainReservedWidth
end

local function StatGainColor(flash)
    local color = ColorOf("statNew")
    flash = flash or 0
    -- Blend a white highlight over the normal gain colour, independent of tint.
    return color[1] + (1 - color[1]) * flash, color[2] + (1 - color[2]) * flash, color[3] + (1 - color[3]) * flash
end

local function BuildStatLineText(data, tracking, gainFlash, omitGain, displayValue)
    if not data then return "" end
    local spaces = string.rep(" ", math.max(0, tonumber(tracking) or 0))
    local value = displayValue == nil and data.new or displayValue
    if ns.db and ns.db.emphasizeStatGains then
        local label = ColorOf("statLabel")
        local r, g, b = StatGainColor(gainFlash)
        local gainHex = render.HexRGB(r, g, b)
        local base = string.format("%s%s: %d%s |r%s->%s %d|r",
            Hex(label),
            data.name, data.old, spaces, gainHex, spaces, value)
        return omitGain and base or (base .. gainHex .. string.format(" (%+d)|r", data.new - data.old))
    end
    local base = string.format("%s: %d%s %s->%s %d|r",
        data.name, data.old, spaces, Hex(ColorOf("statNew")), spaces, value)
    return base
end

-- Reserve the whole value column before counting. Left justification keeps
-- the label and old value fixed even when a proportional-font digit changes.
local function CountingBaseWidth(fs, data, tracking)
    local path, size, flags = fs:GetFont()
    if fs.countBasePath ~= path or fs.countBaseSize ~= size or fs.countBaseFlags ~= flags
        or fs.countBaseName ~= data.name or fs.countBaseOld ~= data.old or fs.countBaseNew ~= data.new
        or fs.countBaseTracking ~= tracking then
        local digits = math.max(#tostring(math.floor(math.abs(data.old))), #tostring(math.floor(math.abs(data.new))))
        local width = 0
        for digit = 0, 9 do
            local value = tonumber(string.rep(tostring(digit), digits)) or 0
            width = math.max(width, MeasureStatText(fs, BuildStatLineText(data, tracking, nil, true, value)))
            if math.min(data.old, data.new) < 0 then
                width = math.max(width, MeasureStatText(fs, BuildStatLineText(data, tracking, nil, true, -value)))
            end
        end
        fs.countBasePath, fs.countBaseSize, fs.countBaseFlags = path, size, flags
        fs.countBaseName, fs.countBaseOld, fs.countBaseNew = data.name, data.old, data.new
        fs.countBaseTracking, fs.countBaseWidth = tracking, width
    end
    return fs.countBaseWidth
end

local function StatTextWidth(fs, data, tracking)
    local counting = ns.db and ns.db.emphasizeStatGains
    local width = counting and CountingBaseWidth(fs, data, tracking)
        or MeasureStatText(fs, BuildStatLineText(data, tracking, nil, counting))
    return width + (counting and GainCounterWidth(fs, data.new - data.old) or 0)
end

-- Include the complete reserved count range and a small horizontal inset.
MeasureStatContentWidth = function()
    local width = 0
    for _, fs in ipairs(content.statLinePool) do
        if fs:IsShown() and fs.statData then
            local tracking = ns.db and ns.db.equalStatWidths and fs.statTracking or 0
            width = math.max(width, StatTextWidth(fs, fs.statData, tracking))
        end
    end
    return math.ceil(width) + 16
end

-- Compact mode fits the stat text to its existing width; regular mode keeps
-- the normal font and widens the panel instead. This runs only on layout/style
-- refresh, never on the animation tick, so counting cannot resize its own row.
FitStatFont = function(availableWidth, compact)
    local changed = false
    local function SetSize(size)
        for _, fs in ipairs(content.statLinePool) do
            for _, text in ipairs({ fs, fs.gainCounter }) do
                if text then
                    local path, current, flags = text:GetFont()
                    local needsSize = current ~= size
                    for _, glow in ipairs(text.glows) do
                        local _, glowSize = glow:GetFont()
                        if glowSize ~= size then needsSize = true; break end
                    end
                    if path and needsSize then
                        ApplyToTextLayers(text, "SetFont", path, size, flags or "")
                        changed = true
                    end
                end
            end
        end
    end
    local parts = { tostring(availableWidth), tostring(compact), tostring(ns.db and ns.db.emphasizeStatGains),
        tostring(ns.db and ns.db.equalStatWidths) }
    for _, fs in ipairs(content.statLinePool) do
        if fs:IsShown() and fs.statData then
            local path, _, flags = fs:GetFont()
            local d = fs.statData
            parts[#parts + 1] = table.concat({ tostring(path), tostring(flags), tostring(d.name), tostring(d.old), tostring(d.new), tostring(fs.statTracking) }, "\031")
        end
    end
    local key = table.concat(parts, "\030")
    if key == render.fitKey then SetSize(render.fitSize); return changed end
    -- Keep the smaller compact presentation for the whole popup so finishing
    -- a count never changes its font or frame width mid-display.
    local baseSize = compact and ns.db and ns.db.emphasizeStatGains and 19 or 20
    local fittedSize = baseSize
    SetSize(baseSize)
    if compact then
        local width = MeasureStatContentWidth()
        if width > availableWidth then
            local size = math.max(1, math.floor(baseSize * (availableWidth - 16) / math.max(1, width - 16) * 10) / 10)
            fittedSize = size
            SetSize(size)
            -- Recheck actual font metrics, including the fixed suffix padding.
            while size > 1 and MeasureStatContentWidth() > availableWidth do
                size = math.max(1, size - 0.5)
                SetSize(size)
                fittedSize = size
            end
        end
    end
    render.fitKey, render.fitSize = key, fittedSize
    return changed
end

local function UpdateStatTracking(statChanges)
    if not ns.db or ns.db.equalStatWidths ~= true then
        for i = 1, #statChanges do
            local fs = content.statLinePool[i]
            if fs then fs.statTracking = 0 end
        end
        return
    end

    local target = 0
    for _, data in ipairs(statChanges) do
        target = math.max(target, StatTextWidth(content.statLinePool[1] or GetStatLine(1), data, 0))
    end
    for i, data in ipairs(statChanges) do
        local fs = content.statLinePool[i] or GetStatLine(i)
        local best, bestDelta = 0, math.huge
        for tracking = 0, 20 do
            local delta = math.abs(StatTextWidth(fs, data, tracking) - target)
            if delta < bestDelta then best, bestDelta = tracking, delta end
        end
        fs.statTracking = best
    end
end

function ns.RefreshStatTextLayout()
    local changes = {}
    for _, fs in ipairs(content.statLinePool or {}) do
        if fs.statData then changes[#changes + 1] = fs.statData end
    end
    UpdateStatTracking(changes)
    for _, fs in ipairs(content.statLinePool or {}) do ApplyStatLineText(fs) end
end

function render.StatColor(text, r, g, b)
    if text.statR ~= r or text.statG ~= g or text.statB ~= b or text.statColorGlows ~= #text.glows then
        ApplyToTextLayers(text, "SetTextColor", r, g, b)
        text.statR, text.statG, text.statB, text.statColorGlows = r, g, b, #text.glows
    end
end

ApplyStatLineText = function(fs)
    local d = fs.statData
    local counting = d and ns.db and ns.db.emphasizeStatGains
    local tracking = ns.db and ns.db.equalStatWidths and fs.statTracking or 0
    local amount = d and (fs.displayGain == nil and d.new - d.old or fs.displayGain)
    local displayedValue = counting and d.old + amount or nil
    local text = d and BuildStatLineText(d, tracking, fs.gainFlash, counting, displayedValue)
        or (fs.plainText or "")
    if text ~= fs.renderedStatText then
        ApplyToTextLayers(fs, "SetText", text)
        fs.renderedStatText = text
    end
    local label = ActiveColor("statLabel")
    render.StatColor(fs, label[1], label[2], label[3])
    local path, size, flags = fs:GetFont()
    local geometryChanged = fs.layoutName ~= (d and d.name) or fs.layoutOld ~= (d and d.old)
        or fs.layoutNew ~= (d and d.new) or fs.layoutTracking ~= tracking or fs.layoutCounting ~= counting
        or fs.layoutPath ~= path or fs.layoutSize ~= size or fs.layoutFlags ~= flags
        or fs.layoutWidth ~= fs:GetWidth()
    local offset = fs.statTextOffset or 0
    if fs.countingLayout ~= (counting == true) then
        ApplyToTextLayers(fs, "SetJustifyH", counting and "LEFT" or "CENTER")
        fs.countingLayout = counting == true
    end
    if counting then
        local target = d.new - d.old
        if geometryChanged then
          local width = GainCounterWidth(fs, target)
          local baseWidth = CountingBaseWidth(fs, d, tracking)
          offset = (fs:GetWidth() - baseWidth - width) / 2
          if fs.counterBaseWidth ~= baseWidth or fs.counterWidth ~= width then
            fs.gainCounter:ClearAllPoints()
            fs.gainCounter:SetPoint("LEFT", fs, "LEFT", baseWidth, 0)
            ApplyToTextLayers(fs.gainCounter, "SetWidth", width)
            fs.counterBaseWidth, fs.counterWidth = baseWidth, width
          end
        end
        local counterText = string.format(" (%+d)", amount)
        if counterText ~= fs.renderedGainText then
            ApplyToTextLayers(fs.gainCounter, "SetText", counterText)
            fs.renderedGainText = counterText
        end
        local r, g, b = StatGainColor(fs.gainFlash)
        render.StatColor(fs.gainCounter, r, g, b)
    end
    if not counting then offset = 0 end
    if fs.gainCounter and fs.gainCounter:IsShown() ~= (counting == true) then ApplyToTextLayers(fs.gainCounter, "SetShown", counting == true) end
    if geometryChanged then
        fs.layoutName, fs.layoutOld, fs.layoutNew = d and d.name, d and d.old, d and d.new
        fs.layoutTracking, fs.layoutCounting = tracking, counting
        fs.layoutPath, fs.layoutSize, fs.layoutFlags, fs.layoutWidth = path, size, flags, fs:GetWidth()
        SyncTextGeometry(fs)
        if fs.gainCounter then SyncTextGeometry(fs.gainCounter) end
    end
    if fs.statTextOffset ~= offset then
        fs:ClearAllPoints()
        fs:SetPoint("TOP", fs.slideFrame, "TOP", offset, 0)
        fs.statTextOffset = offset
    end
end

-- Repeat the overlapping count-completion flashes using the same row offsets.
-- Reuse the existing text/glow layers so no clipping bar or glyph copies appear.
local function UpdateStatHighlights(cycleTime, enabled, age)
    local count = 0
    for _, fs in ipairs(content.statLinePool) do
        local visible = fs.statData and fs:IsShown()
        local value = 0
        if visible and fs.countFinishAt then
            count = count + 1
            local offset = fs.countFinishAt - entranceTimeline.statFlashStart
            local phase = (cycleTime - offset) / 0.40
            if enabled and cycleTime >= 0 and phase >= 0 and phase < 1 then
                value = 0.80 * math.sin(math.pi * phase)
            end
        end
        -- One completion flash per nonzero count, before the repeating sequence.
        local finishAge = visible and fs.countFinishAt and age and age - fs.countFinishAt
        if enabled and not activeLineAnims[fs] and finishAge and finishAge >= 0 and finishAge < 0.40 then
            value = math.max(value, 0.80 * math.sin(math.pi * finishAge / 0.40))
        end
        if value ~= (fs.gainFlash or 0) then
            fs.gainFlash = value
            ApplyStatLineText(fs)
        end
    end
    return enabled and count > 0
end

local function ClearStatHighlights()
    UpdateStatHighlights(-1, false)
end

-- A single visible-only driver handles the slow starburst and brief highlights.
-- Texture/animation objects are reused on subsequent previews and level-ups.
local effectDriver = CreateFrame("Frame", nil, frame)
local effectAge = 0
local fadeFinished = 0
local portraitStage = "waiting"
local starburstStartedAt = 0
local PORTRAIT_PULSE_GAP = 0.025
local STAR_GROW_DURATION = 0.75
local STAR_SETTLE_DURATION = 0.30
local SHIMMER_DELAY = 0.50
local SHIMMER_INTERVAL = 3.0
local abilityShimmerPeriod = 5.0

-- Bounded reusable pools share the existing visible-only driver. No particle engine
-- or timers are needed, and previews reuse these same texture objects.
content.portraitSparks, content.starburstMotes, content.backgroundEmbers, content.edgeGlows = {}, {}, {}, {}
render.abilityPools = { content.abilityIconPool, content.petAbilityIconPool }
render.portraitMotePools = { content.portraitSparks, content.starburstMotes }
render.particlePools = { content.portraitSparks, content.starburstMotes, content.backgroundEmbers }
render.smallEffectPools = { content.portraitSparks, content.starburstMotes, content.backgroundEmbers, content.edgeGlows }
content.portraitSparks[1] = NewSparkTexture(content)
for i = 1, 2 do content.starburstMotes[i] = NewSparkTexture(content) end
for i = 1, 40 do content.backgroundEmbers[i] = NewSparkTexture(content, "BACKGROUND") end
content.edgeLayer = CreateFrame("Frame", nil, frame)
content.edgeLayer:SetAllPoints(frame)
content.edgeLayer:SetFrameLevel(frame:GetFrameLevel() + 4)
content.edgeLayer:SetAlpha(0.30)
for _, side in ipairs({ "LEFT", "RIGHT", "TOP", "BOTTOM" }) do
    for layer = 1, 3 do
        local texture = NewSparkTexture(content.edgeLayer)
        texture:SetTexture("Interface\\Buttons\\WHITE8X8")
        texture.side, texture.softness = side, layer
        texture:SetPoint("CENTER", frame, side, 0, 0)
        content.edgeGlows[#content.edgeGlows + 1] = texture
    end
end

local function EnsureParticlePool(pool, parent, count, layer, corners)
    while #pool < count do
        local texture = NewSparkTexture(parent, layer)
        if corners then
            local corner = ({ "TOPLEFT", "BOTTOMRIGHT", "TOPRIGHT", "BOTTOMLEFT" })[(#pool % 4) + 1]
            texture:SetPoint("CENTER", parent, corner, corner:find("LEFT") and 1 or -1,
                corner:find("TOP") and -1 or 1)
        end
        pool[#pool + 1] = texture
    end
end

local function HideSmallEffects()
    for _, pool in ipairs(render.smallEffectPools) do
        for _, texture in ipairs(pool) do
            texture:Hide()
            if pool == content.portraitSparks or pool == content.starburstMotes then
                texture.cycleStartedAt = texture.releaseDelay
            end
        end
    end
    for _, pool in ipairs(render.abilityPools) do
        for _, icon in ipairs(pool) do
            for _, texture in ipairs(icon.cornerSparkles) do texture:Hide() end
            icon.ambientSparkle:Hide()
        end
    end
end

render.particleSettings = {}
for i = 1, #ns.PARTICLE_SETTINGS do render.particleSettings[i] = {} end

function render.RefreshParticleSettings()
    for i, spec in ipairs(ns.PARTICLE_SETTINGS) do
        local settings = render.particleSettings[i]
        settings.count = ns.GetParticleValue(spec, "count")
        settings.size = ns.GetParticleValue(spec, "size") / 100
        settings.opacity = ns.GetParticleValue(spec, "opacity") / 100
    end
    render.starburstOpacity = ns.GetParticleValue(ns.EFFECT_OPACITY_SETTINGS[1], "opacity") / 100
    render.pulseOpacity = ns.GetParticleValue(ns.EFFECT_OPACITY_SETTINGS[2], "opacity") / 100
    render.edgeOpacity = ns.GetParticleValue(ns.EFFECT_OPACITY_SETTINGS[3], "opacity") / 100
end

local function PositionContainedMote(texture, radius, distance, eased, width, height, centerX, centerY)
    local inset = math.min((texture.renderSize or texture.moteSize or 5) * 0.75 + 2, width / 2, height / 2)
    if not centerX or not centerY then texture:Hide(); return end
    local origin, heading = texture.originAngle, texture.driftAngle
    local x = math.max(inset, math.min(width - inset, centerX + math.cos(origin) * radius))
    local y = math.max(inset, math.min(height - inset, centerY + math.sin(origin) * radius))
    -- Clamp the endpoints rather than the animated position: no premature
    -- hard stop at an edge. Both endpoints include room for the rotated mote.
    local endX = math.max(inset, math.min(width - inset, x + math.cos(heading) * distance))
    local endY = math.min(y, math.max(inset, math.min(height - inset, y + math.sin(heading) * distance)))
    texture:SetPoint("CENTER", frame, "BOTTOMLEFT", x + (endX - x) * eased, y + (endY - y) * eased)
end

local function RandomMoteSize(base)
    return base * 1.10 * (0.90 + math.random() * 0.20)
end

local function RollPortraitMote(texture, contained)
    texture.driftDuration = 2.4 + math.random() * 1.2
    texture.driftDistance = 16 + math.random() * 26
    texture.originRadius = 14 + math.random() * 24
    texture.originAngle = math.random() * 2 * math.pi
    texture.driftAngle = math.random() * 2 * math.pi
    texture.moteSize = RandomMoteSize(4 + math.random() * 2.5)
    if contained then
        texture.originAngle = math.pi + math.random() * math.pi
        texture.driftAngle = math.pi + math.random() * math.pi
    end
end

local function RollBackgroundEmber(texture, index)
    texture.emberSpeed = 0.50 + math.random() * 0.50
    texture.emberDuration = (5.5 + ((index - 1) % 8 + 1) * 0.41) / (texture.emberSpeed * 0.85)
    texture.moteSize = RandomMoteSize((4 + index % 3) * 1.15)
    texture.wanderPhase = math.random() * 2 * math.pi
    texture.wanderRate = 0.65 + math.random() * 0.50
    texture.wanderWidth = 3 + math.random() * 6
end

local function RefreshAbilityEffectSchedule()
    local db = ns.db or {}
    local count = db.newAbilitySparkles and ns.GetParticleValue(ns.PARTICLE_SETTINGS[4], "count") or 0
    local burst = count > 0 and ((count - 1) * 0.22 + 0.42) or 0
    local spacing = math.max(0.90, burst) + 0.35
    local newAbilityCount = 0
    for _, pool in ipairs(render.abilityPools) do
        for _, icon in ipairs(pool) do
            icon.sparkleDelay = 0
            if icon:IsShown() and icon.isNewAbility == true then
                icon.sparkleDelay = newAbilityCount * spacing
                newAbilityCount = newAbilityCount + 1
            end
        end
    end
    abilityShimmerPeriod = math.max(5.0, newAbilityCount * spacing)
    content.abilityEffectSpacing, content.abilityEffectPeriod = spacing, abilityShimmerPeriod
end

local function AbilityShimmerTime(icon)
    local age = effectAge - fadeFinished - SHIMMER_DELAY - (icon.sparkleDelay or 0)
    return age >= 0 and age % abilityShimmerPeriod or -1, math.floor(age / abilityShimmerPeriod)
end

-- Skip idle bursts on the existing clock. Refresh/start clear these deadlines.
function render.NextAbilityWake(icon, duration)
    local age = effectAge - fadeFinished - SHIMMER_DELAY - (icon.sparkleDelay or 0)
    if age < 0 then return effectAge - age end
    if age % abilityShimmerPeriod < duration then return effectAge end
    return effectAge + abilityShimmerPeriod - age % abilityShimmerPeriod
end

-- Ambient twinkles use one reusable texture per icon. Flash bursts add the
-- configured corner sparkles without interrupting an ambient twinkle.
function render.PositionSparkle(icon, texture)
    local corner = math.random(4)
    local left, top = corner == 1 or corner == 4, corner <= 2
    texture:ClearAllPoints()
    texture:SetPoint("CENTER", icon, "CENTER",
        (left and -1 or 1) * icon:GetWidth() * (0.30 + math.random() * 0.18),
        (top and 1 or -1) * icon:GetHeight() * (0.30 + math.random() * 0.18))
end

function render.UpdateAmbientSparkles()
    if render.ambientWake and effectAge < render.ambientWake then return render.ambientActive end
    render.ambientWake, render.ambientActive = math.huge, false
    local settings = render.particleSettings[4]
    local enabled = ns.db.newAbilitySparkles and settings.count > 0
    for _, pool in ipairs(render.abilityPools) do
        for _, icon in ipairs(pool) do
            local texture = icon.ambientSparkle
            if enabled and icon:IsShown() and icon.isNewAbility == true then
                if not texture.sparkleStart then
                    texture.sparkleStart = fadeFinished + SHIMMER_DELAY + 0.25 + math.random() * 0.60
                    texture.positioned = false
                end
                local age = effectAge - texture.sparkleStart
                if age >= 0.42 then
                    texture.sparkleStart = effectAge + 0.30 + math.random() * 0.90
                    texture.positioned = false
                    age = -1
                end
                render.Shown(texture, age >= 0)
                if age >= 0 then
                    if not texture.positioned then
                        render.PositionSparkle(icon, texture)
                        texture.positioned = true
                    end
                    local phase = age / 0.42
                    local shine = math.sin(math.pi * phase)
                    local size = (6 + 8 * shine) * settings.size
                    render.Size(texture, size, size)
                    texture:SetAlpha(settings.opacity * 0.70 * shine ^ 2)
                    texture:SetRotation(phase * math.pi / 2)
                    render.ambientWake = effectAge
                else
                    render.ambientWake = math.min(render.ambientWake, texture.sparkleStart)
                end
                render.ambientActive = true
            else
                render.Shown(texture, false)
                texture.sparkleStart = nil
            end
        end
    end
    return render.ambientActive
end

local function UpdateSmallEffects(cycleTime, moving)
    local db = ns.db or {}
    if not moving or not frame:IsShown() then HideSmallEffects(); return false end
    local active = false
    local width, height = frame:GetWidth(), frame:GetHeight()
    local portraitScale = PortraitIconSize() / PLAYER_PORTRAIT_SIZE
    local centerX, centerY
    local motesEnabled = db.portraitSparks and db.portraitAnimation and IsPlayerPortrait()
    if motesEnabled and portraitStage == "starburst" then
        local x, y = content.classRing:GetCenter()
        local left, bottom = frame:GetLeft(), frame:GetBottom()
        if x and y and left and bottom then centerX, centerY = x - left, y - bottom end
    end
    local starAge = portraitStage == "starburst" and (effectAge - starburstStartedAt) or -1
    local releaseAge = starAge - (STAR_GROW_DURATION + STAR_SETTLE_DURATION) / (2 * Speed())
    for groupIndex, pool in ipairs(render.portraitMotePools) do
      local settings = render.particleSettings[groupIndex]
      local count = settings.count
      for index, texture in ipairs(pool) do
        local slotEnabled = motesEnabled and index <= count
        if not slotEnabled or portraitStage ~= "starburst" then
            texture.cycleStartedAt = texture.releaseDelay
        end
        local moteAge = releaseAge - (texture.cycleStartedAt or texture.releaseDelay or 0)
        local duration = texture.driftDuration or 3
        if slotEnabled and portraitStage == "starburst" and moteAge >= duration then
            -- Recycle the invisible, expired slot. A fresh path starts at zero
            -- alpha without exceeding the configured portrait particle counts.
            RollPortraitMote(texture, pool == content.starburstMotes)
            texture.cycleStartedAt = releaseAge
            moteAge, duration = 0, texture.driftDuration
        end
        local visible = slotEnabled and portraitStage == "starburst" and moteAge >= 0 and moteAge < duration
        render.Shown(texture, visible == true)
        if visible then
            local t = moteAge / duration
            local eased = 1 - (1 - t) ^ 3
            local scale = portraitScale
            local distance = (texture.driftDistance or 24) * scale
            local radius = (texture.originRadius or 20) * scale
            local origin = texture.originAngle or 0
            local heading = texture.driftAngle or 0
            local size = (texture.moteSize or 5) * settings.size
            texture.renderSize = size
            render.Size(texture, size, size)
            texture:ClearAllPoints()
            if pool == content.starburstMotes then
                PositionContainedMote(texture, radius, distance, eased, width, height, centerX, centerY)
            else
                texture:SetPoint("CENTER", content.classRing, "CENTER",
                    math.cos(origin) * radius + math.cos(heading) * distance * eased,
                    math.sin(origin) * radius + math.sin(heading) * distance * eased)
            end
            texture:SetRotation(heading + 0.25 * eased)
            -- Velocity and opacity both decay with (1-t)^2, reaching zero
            -- together. Briefly soften the initial appearance as each is born.
            texture:SetAlpha(settings.opacity * math.min(1, t / 0.12) * (1 - t) ^ 2)
        end
        if motesEnabled and count > 0 then active = true end
      end
    end

    local ambientAge = effectAge - fadeFinished
    for i, texture in ipairs(content.backgroundEmbers) do
        local settings = render.particleSettings[3]
        local visible = db.backgroundEmbers and i <= settings.count and ambientAge >= 0
        render.Shown(texture, visible == true)
        if visible then
            if texture.emberCycle == nil then
                RollBackgroundEmber(texture, i)
                texture.emberCycle = 0
                texture.emberStartedAt = -((i * 0.71) % texture.emberDuration)
            end
            if ambientAge - texture.emberStartedAt >= texture.emberDuration then
                RollBackgroundEmber(texture, i)
                texture.emberCycle = texture.emberCycle + 1
                texture.emberStartedAt = ambientAge
            end
            local t = math.max(0, math.min(1, (ambientAge - texture.emberStartedAt) / texture.emberDuration))
            -- Start at 50–100% of the old rise speed and finish 30% slower.
            -- The longer lifetime still lets every ember reach the top.
            local progress = (t - 0.15 * t * t) / 0.85
            local x = ((i * 0.61803398875) % 1 - 0.5) * math.max(1, width - 40)
            local size = texture.moteSize * settings.size
            render.Size(texture, size, size)
            texture:ClearAllPoints()
            local phase = texture.wanderPhase
            local drift = texture.wanderWidth * math.sin(phase + progress * math.pi * 2 * texture.wanderRate)
                + 2 * math.sin(phase * 1.7 + progress * math.pi * 3)
            local limit = math.max(0, width / 2 - size * 0.75 - 2)
            texture:SetPoint("CENTER", content, "BOTTOM", math.max(-limit, math.min(limit, x + drift)),
                18 + progress * math.max(1, height - 36))
            texture:SetRotation(progress * math.pi)
            texture:SetAlpha(settings.opacity * math.sin(math.pi * t) ^ 2 * math.min(1, ambientAge / 0.30))
        end
    end
    if db.backgroundEmbers and render.particleSettings[3].count > 0 then active = true end

    local edgeAge = effectAge
    local edgeEnabled = db.frameEdgeGlow and db.backgroundMode ~= "MODERN"
    local edgeVisible = edgeEnabled and edgeAge >= 0 and edgeAge < 1.25
    for _, texture in ipairs(content.edgeGlows) do
        render.Shown(texture, edgeVisible == true)
        if edgeVisible then
            local thickness = texture.softness == 1 and 1 or (texture.softness == 2 and 3 or 7)
            local strength = texture.softness == 1 and 0.70 or (texture.softness == 2 and 0.22 or 0.08)
            local vertical = texture.side == "LEFT" or texture.side == "RIGHT"
            render.Size(texture, vertical and thickness or width, vertical and math.max(1, height - 14) or thickness)
            texture:SetAlpha(strength * math.sin(math.pi * edgeAge / 1.25) ^ 0.7)
        end
    end
    if edgeEnabled and edgeAge < 1.25 then active = true end

    if not render.sparkleWake or effectAge >= render.sparkleWake then
        render.sparkleWake, render.sparkleActive = math.huge, false
        local sparkleCount = render.particleSettings[4].count
        local burst = sparkleCount > 0 and (sparkleCount - 1) * 0.22 + 0.42 or 0
        for _, pool in ipairs(render.abilityPools) do
            for _, icon in ipairs(pool) do
                local enabled = db.newAbilitySparkles and icon:IsShown() and icon.isNewAbility == true
                local sparkleTime, sparkleCycle = AbilityShimmerTime(icon)
                for i, texture in ipairs(icon.cornerSparkles) do
                    local settings = render.particleSettings[4]
                    local phase = (sparkleTime - (i - 1) * 0.22) / 0.42
                    local visible = enabled and i <= settings.count and sparkleTime >= 0 and phase >= 0 and phase < 1
                    render.Shown(texture, visible == true)
                    if visible then
                        if texture.sparkleCycle ~= sparkleCycle then
                            texture.sparkleCycle = sparkleCycle
                            render.PositionSparkle(icon, texture)
                        end
                        local shine = math.sin(math.pi * phase)
                        local size = (6 + 8 * shine) * settings.size
                        render.Size(texture, size, size)
                        texture:SetAlpha(settings.opacity * shine ^ 2)
                        texture:SetRotation(phase * math.pi / 2)
                    end
                end
                if enabled and sparkleCount > 0 then
                    render.sparkleActive = true
                    render.sparkleWake = math.min(render.sparkleWake, render.NextAbilityWake(icon, burst))
                end
            end
        end
    end
    if render.sparkleActive then active = true end
    if render.UpdateAmbientSparkles() then active = true end
    return active
end

local UpdateVisualEffects
local portraitPulseGroup = content.portraitPulse:CreateAnimationGroup()
---@type Scale
local pulseScale = portraitPulseGroup:CreateAnimation("Scale")
pulseScale:SetScaleFrom(1, 1)
pulseScale:SetScaleTo(1.4, 1.4)
pulseScale:SetSmoothing("OUT")
local pulseAlpha = portraitPulseGroup:CreateAnimation("Alpha")
pulseAlpha:SetFromAlpha(0.65)
pulseAlpha:SetToAlpha(0)
portraitPulseGroup:SetScript("OnFinished", function()
    content.portraitPulse:Hide()
    if portraitStage == "pulse" then
        portraitStage = "starburst"
        starburstStartedAt = effectAge
        UpdateVisualEffects()
    end
end)

local function StyleAbilityIcon(icon)
    local color = ActiveColor("abilityName")
    local _, classToken = UnitClass("player")
    local classColor = ns.CLASS_COLORS and ns.CLASS_COLORS[classToken] or WHITE_COLOR
    local effectColor = ActiveColor("animatedElements")
    icon.newAbilityGlow:SetVertexColor(effectColor[1], effectColor[2], effectColor[3])
    for _, texture in ipairs(icon.cornerSparkles) do texture:SetVertexColor(effectColor[1], effectColor[2], effectColor[3]) end
    icon.ambientSparkle:SetVertexColor(effectColor[1], effectColor[2], effectColor[3])
    local alpha = 0.9
    if ns.db and ns.db.highlightNewAbilities and icon.isNewAbility ~= nil then
        if icon.isNewAbility then
            color, alpha = classColor, 1
        else
            alpha = 0.55
        end
    end
    icon.border:SetColorTexture(color[1], color[2], color[3], alpha)
end

local function RunVisualEffects(_, elapsed)
    -- Visible motion updates every frame; idle bursts skip their pool scans.
    effectAge = effectAge + elapsed
    UpdateVisualEffects()
end

UpdateVisualEffects = function()
    local db = ns.db or {}
    local moving = not db.reducedMotion
    local speed = Speed()
    local active = UpdateSectionEntrance(effectAge, moving)
    if render.reducedFade then
        local t = math.max(0, math.min(1, effectAge / render.reducedFade))
        render.Alpha(frame, 1 - (1 - t) ^ 2)
        if t < 1 then active = true else render.reducedFade = nil end
    end
    local portraitEnabled = not db.reducedMotion and db.portraitAnimation and db.portraitMode ~= "none" and frame:IsShown()
    -- Keep the portrait hidden until setup and its entrance delay are complete.
    local portraitEntrance = entranceTimeline and entranceTimeline.portrait
    local ringAlpha = EntranceAlpha(portraitEntrance, effectAge, moving)
    if moving and portraitEntrance and db.portraitAnimation and IsPlayerPortrait() then
        local t = math.max(0, math.min(1, (effectAge - portraitEntrance.start) / (portraitEntrance.finish - portraitEntrance.start)))
        ringAlpha = t * t * (3 - 2 * t)
    end
    if moving and ringAlpha < 1 and db.portraitMode ~= "none" then active = true end
    local ringSettle = 1
    if moving and portraitEntrance and db.portraitRingSettle and db.portraitMode ~= "none" then
        local t = math.max(0, math.min(1, (effectAge - portraitEntrance.start) / (portraitEntrance.finish - portraitEntrance.start)))
        -- Keep the enlarged portrait through the dim part of its fade.
        local settle = math.max(0, math.min(1, (t - 0.35) / 0.65))
        ringSettle = 1 + 0.10 * (1 - settle * settle * (3 - 2 * settle))
    end
    local ringSize = math.max(1, PortraitRingSize())
    render.Size(content.classRing, ringSize * ringSettle, ringSize * ringSettle)
    render.Size(content.classIcon, PortraitIconSize() * ringSettle, PortraitIconSize() * ringSettle)
    render.Size(content.classRingGraphic, ringSize * PortraitRingScale() * ringSettle, ringSize * PortraitRingScale() * ringSettle)
    local ringOffsetX, ringOffsetY = PortraitRingOffset()
    local pointX, pointY = ringOffsetX * ringSettle, ringOffsetY * ringSettle
    if render.pointX ~= pointX or render.pointY ~= pointY then
        content.classRingGraphic:SetPoint("CENTER", content.portraitAnchor, "CENTER", pointX, pointY)
        render.pointX, render.pointY = pointX, pointY
    end
    render.Alpha(content.portraitArtwork, ringAlpha)
    render.Shown(content.portraitArtwork, not portraitPreparing and db.portraitMode ~= "none" and ringAlpha > 0)
    if portraitEnabled and moving and portraitStage == "waiting"
        and entranceTimeline and effectAge >= entranceTimeline.portrait.finish + PORTRAIT_PULSE_GAP then
        portraitStage = "pulse"
        content.portraitPulse:Show()
        portraitPulseGroup:Play()
    end
    if portraitEnabled and moving and portraitStage ~= "starburst" then active = true end
    local starburst = portraitEnabled and IsPlayerPortrait()
    local starTime = effectAge - starburstStartedAt
    local growDuration = STAR_GROW_DURATION / speed
    local settleDuration = STAR_SETTLE_DURATION / speed
    local starVisible = starburst and (not moving or portraitStage == "starburst")
    render.Shown(content.portraitStarburst, starVisible == true)
    if starburst then
        local grow = moving and (starVisible and math.max(0, math.min(1, starTime / growDuration)) or 0) or 1
        local scale = 0.18 + 0.82 * (1 - (1 - grow) ^ 3)
        local size = PortraitIconSize() * 2.2 * scale
        render.Size(content.portraitStarburst, size, size)
        local age = starVisible and math.max(0, starTime) or 0
        local opacity = render.starburstOpacity
        local alpha = moving and opacity * (0.95 + 0.05 * math.cos(age * 2 * math.pi / 7)) or opacity
        local settle = (starTime - growDuration) / settleDuration
        if moving and starVisible and settle >= 0 and settle < 1 then
            -- Keep two short brightness dips as the starburst settles.
            alpha = alpha * (0.45 + 0.55 * math.cos(settle * 2 * math.pi) ^ 2)
        end
        content.portraitStarburst:SetRotation(moving and (age * math.pi / 60) % (2 * math.pi) or 0)
        content.portraitStarburst:SetAlpha(alpha)
        active = moving
    end
    -- Stat waves follow the last count; abilities keep their own entrance clock.
    local statCountFinish = entranceTimeline and entranceTimeline.statCountFinish or fadeFinished
    local shimmerAge = effectAge - statCountFinish - 1.50
    local cycleTime = shimmerAge >= 0 and (shimmerAge % (entranceTimeline.statFlashPeriod or SHIMMER_INTERVAL)) or -1
    if not moving or not render.glowWake or effectAge >= render.glowWake then
        render.glowWake, render.glowActive = math.huge, false
        for _, pool in ipairs(render.abilityPools) do
            for _, icon in ipairs(pool) do
                local phase = AbilityShimmerTime(icon) / 0.60
                local shimmer = icon:IsShown() and db.highlightNewAbilities and icon.isNewAbility == true and moving
                render.Shown(icon.newAbilityGlow, shimmer and phase >= 0 and phase < 1 or false)
                if shimmer and phase >= 0 and phase < 1 then
                    icon.newAbilityGlow:SetAlpha(math.sin(math.pi * phase) ^ 0.5)
                end
                if shimmer then
                    render.glowActive = true
                    render.glowWake = math.min(render.glowWake, render.NextAbilityWake(icon, 0.60))
                end
            end
        end
    end
    if render.glowActive then active = true end
    local statsCounting = db.emphasizeStatGains and moving and next(activeLineAnims) ~= nil
    if statsCounting and frame:IsShown() then active = true end
    local statEnabled = db.emphasizeStatGains and moving and frame:IsShown()
    local completionPending = effectAge < statCountFinish + 0.40
    local statIdle = not statEnabled or (not completionPending and (cycleTime < 0 or cycleTime >= (entranceTimeline.statFlashDuration or 0)))
    -- Clear once after the overlapping wave; skip quiet frames until its repeat.
    if not statIdle or not render.statIdle or render.statEnabled ~= statEnabled then
        render.statActive = UpdateStatHighlights(statsCounting and -1 or cycleTime, statEnabled, effectAge)
    end
    render.statIdle, render.statEnabled = statIdle, statEnabled
    if statEnabled and render.statActive then active = true end
    if UpdateSmallEffects(cycleTime, moving) then active = true end
    effectDriver:SetScript("OnUpdate", active and frame:IsShown() and RunVisualEffects or nil)
end

function ns.RefreshVisualEffects()
    render.RefreshParticleSettings()
    render.glowWake, render.sparkleWake, render.statIdle = nil, nil, nil
    render.ambientWake = nil
    render.sectionComplete = nil
    render.pointX, render.pointY = nil, nil
    local db = ns.db or {}
    if not db.reducedMotion and render.reducedFade then
        render.reducedFade = nil
        frame:SetAlpha(1)
    end
    pulseAlpha:SetFromAlpha(render.pulseOpacity)
    content.edgeLayer:SetAlpha(render.edgeOpacity)
    RefreshAbilityEffectSchedule()
    for i, pool in ipairs(render.particlePools) do
        EnsureParticlePool(pool, content, ns.GetParticleValue(ns.PARTICLE_SETTINGS[i], "count"),
            i == 3 and "BACKGROUND" or nil)
    end
    for _, pool in ipairs(render.abilityPools) do
        for _, icon in ipairs(pool) do
            EnsureParticlePool(icon.cornerSparkles, icon, ns.GetParticleValue(ns.PARTICLE_SETTINGS[4], "count"), nil, true)
        end
    end
    local portraitColor = ActiveColor("animatedElements")
    content.portraitStarburst:SetSize(PortraitIconSize() * 2.2, PortraitIconSize() * 2.2)
    content.portraitPulse:SetSize(PortraitRingSize() * 1.1, PortraitRingSize() * 1.1)
    content.portraitStarburst:SetVertexColor(portraitColor[1], portraitColor[2], portraitColor[3])
    content.portraitPulse:SetVertexColor(portraitColor[1], portraitColor[2], portraitColor[3])
    for _, pool in ipairs(render.smallEffectPools) do
        for _, texture in ipairs(pool) do texture:SetVertexColor(portraitColor[1], portraitColor[2], portraitColor[3]) end
    end
    for _, pool in ipairs(render.portraitMotePools) do
        for i, texture in ipairs(pool) do
            if not texture.driftDuration then
                texture.releaseDelay = (i - 1) * 0.10
                texture.cycleStartedAt = texture.releaseDelay
                RollPortraitMote(texture, pool == content.starburstMotes)
            end
        end
    end
    UpdateStatSlides(nil, 0)
    if not db.portraitAnimation or db.portraitMode == "none" or db.reducedMotion then
        portraitPulseGroup:Stop()
        content.portraitPulse:Hide()
        portraitStage = db.reducedMotion and "starburst" or "waiting"
        starburstStartedAt = effectAge
    end
    for _, pool in ipairs(render.abilityPools) do
        for _, icon in ipairs(pool) do StyleAbilityIcon(icon) end
    end
    ns.RefreshStatTextLayout()
    if frame:IsShown() then
        local previousWidth = FRAME_WIDTH
        ApplyPopupWidth()
        if FRAME_WIDTH ~= previousWidth and ns.RefreshPopupLayout then ns.RefreshPopupLayout() end
    end
    UpdateVisualEffects()
end

local function StartVisualEffects()
    render.glowWake, render.sparkleWake, render.statIdle = nil, nil, nil
    render.ambientWake = nil
    effectAge = 0
    render.reducedFade = ns.db and ns.db.reducedMotion and BASE_BG_FADE_DURATION / Speed() or nil
    portraitStage, starburstStartedAt = "waiting", 0
    for _, pool in ipairs(render.abilityPools) do
        for _, icon in ipairs(pool) do
            for _, texture in ipairs(icon.cornerSparkles) do texture.sparkleCycle = nil end
            icon.ambientSparkle.sparkleStart = nil
        end
    end
    for _, texture in ipairs(content.backgroundEmbers) do texture.emberCycle = nil end
    -- Stagger the enabled slots. Each is recycled after fading out;
    -- parameters stay fixed throughout a lifetime and no textures are added.
    local slot = 0
    for groupIndex, pool in ipairs(render.portraitMotePools) do
      local count = ns.GetParticleValue(ns.PARTICLE_SETTINGS[groupIndex], "count")
      for i, texture in ipairs(pool) do
        texture.releaseDelay = slot * 0.10 + math.random() * 0.04
        texture.cycleStartedAt = texture.releaseDelay
        RollPortraitMote(texture, pool == content.starburstMotes)
        if i <= count then slot = slot + 1 end
      end
    end
    local db = ns.db or {}
    local speed = Speed()
    fadeFinished = entranceTimeline and entranceTimeline.finish or 0
    portraitPulseGroup:Stop()
    content.portraitPulse:Hide()
    pulseScale:SetDuration(0.65 / speed)
    pulseAlpha:SetDuration(0.65 / speed)
    ns.RefreshVisualEffects()
end

frame:HookScript("OnHide", function()
    HideSmallEffects()
    ClearStatHighlights()
    for _, fs in ipairs(content.statLinePool) do StopLineAnimation(fs) end
    effectDriver:SetScript("OnUpdate", nil)
    portraitPulseGroup:Stop()
    content.portraitPulse:Hide()
    for _, pool in ipairs(render.abilityPools) do
        for _, icon in ipairs(pool) do icon.newAbilityGlow:Hide() end
    end
end)

function ns.ApplyColors()
    SetTextColorKey(content.title, "title")
    SetTextColorKey(content.levelText, "level")
    SetTextColorKey(content.statsHeader, "statsHeader")
    SetTextColorKey(content.spellsHeader, "abilitiesHeader")
    SetTextColorKey(content.petSpellsHeader, "abilitiesHeader")
    SetTextColorKey(content.weaponSkillsText, "statLabel")
    ns.RefreshStatTextLayout()
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
    ns.RefreshVisualEffects()
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

    if count > 0 then UpdateStatTracking(statChanges) end

    local function LayoutStatLine(i, statChange, plainText)
        local fs = GetStatLine(i)
        fs.gainFlash, fs.displayGain = 0, nil
        fs.statData = statChange
        fs.plainText = plainText
        ApplyStatLineText(fs)
        local dir = LineDirection(i)
        local y = -((i - 1) * STAT_LINE_HEIGHT)
        local delay = staggerBase + (i - 1) * staggerStep
        fs.entranceEnd = delay + slideDuration
        StartLineAnimation(fs, content.statsContainer, dir * STAT_SLIDE_DISTANCE_X, y, delay, slideDuration)
    end

    if count == 0 then
        LayoutStatLine(1, nil, ns.L("No stat changes"))
        count = 1
    else
        for i = 1, count do
            LayoutStatLine(i, statChanges[i])
        end
    end

    for i = count + 1, #pool do
        ReleaseStatLine(pool[i])
    end

    content.statsContainer:SetHeight(count * STAT_LINE_HEIGHT)
    return count
end

local function BuildEntranceTimeline()
    local speed = Speed()
    local plan, cursor = {}, 0
    local function Add(key, duration)
        local stage = { start = cursor, finish = cursor + duration / speed }
        plan[key], cursor = stage, stage.finish
        return stage
    end
    Add("background", BASE_BG_FADE_DURATION)
    Add("portrait", ns.db and ns.db.portraitMode == "none" and 0.20 or BASE_CONTENT_FADE_DURATION)
    Add("statsHeader", 0.18)
    local statCount = 0
    for _, fs in ipairs(content.statLinePool) do if fs:IsShown() then statCount = statCount + 1 end end
    local stats = Add("stats", BASE_STAT_SLIDE_DURATION + math.max(0, statCount - 1) * BASE_STAT_STAGGER_STEP)
    local index = 0
    for _, fs in ipairs(content.statLinePool) do
        if fs:IsShown() then
            local delay = stats.start + index * BASE_STAT_STAGGER_STEP / speed
            local duration = BASE_STAT_SLIDE_DURATION / speed
            fs.entranceEnd = delay + duration
            StartLineAnimation(fs, content.statsContainer, LineDirection(index + 1) * STAT_SLIDE_DISTANCE_X,
                -index * STAT_LINE_HEIGHT, delay, duration)
            index = index + 1
        end
    end
    plan.statCountFinish = stats.finish
    for _, fs in ipairs(content.statLinePool) do
        if fs:IsShown() and fs.countFinishAt then
            plan.statCountFinish = math.max(plan.statCountFinish, fs.countFinishAt)
            plan.statFlashStart = math.min(plan.statFlashStart or fs.countFinishAt, fs.countFinishAt)
            plan.statFlashFinish = math.max(plan.statFlashFinish or fs.countFinishAt, fs.countFinishAt)
        end
    end
    plan.statFlashDuration = plan.statFlashStart and plan.statFlashFinish - plan.statFlashStart + 0.40 or 0
    plan.statFlashPeriod = plan.statFlashDuration + 3.00
    plan.statsBottom = { start = stats.finish - 0.12 / speed, finish = stats.finish }
    if content.levelTimeText:IsShown() then Add("levelTime", 0.18) end
    Add("abilitiesHeader", 0.18)
    local function AddIcons(key, pool)
        local count = 0
        for _, icon in ipairs(pool) do if icon:IsShown() then count = count + 1 end end
        local stage = Add(key, BASE_STAT_SLIDE_DURATION + math.max(0, count - 1) * BASE_STAT_STAGGER_STEP)
        local ordinal = 0
        for _, icon in ipairs(pool) do
            if icon:IsShown() then
                local delay = stage.start + ordinal * BASE_STAT_STAGGER_STEP / speed
                icon.entranceEnd = delay + BASE_STAT_SLIDE_DURATION / speed
                StartIconPop(icon, icon.animationContainer, icon.animationX, icon.animationY,
                    delay, BASE_STAT_SLIDE_DURATION / speed)
                ordinal = ordinal + 1
            end
        end
    end
    AddIcons("abilities", content.abilityIconPool)
    if content.petSpellsHeader:IsShown() then
        Add("petHeader", 0.18)
        AddIcons("petAbilities", content.petAbilityIconPool)
    end
    if content.weaponSkillsText:IsShown() then Add("weapon", 0.22) end
    plan.finish = cursor
    if ns.db and ns.db.emphasizeStatGains then
        for _, fs in ipairs(content.statLinePool) do
            if fs:IsShown() and fs.statData and fs.statData.new ~= fs.statData.old then
                plan.finish = math.max(plan.finish, fs.entranceEnd + (1.0 - BASE_STAT_SLIDE_DURATION) / speed)
            end
        end
    end
    if ns.db and ns.db.dividerReveal then
        for _, stage in ipairs({ plan.statsHeader, plan.statsBottom }) do
            plan.finish = math.max(plan.finish, stage.start + 0.60 / speed)
        end
        for _, key in ipairs({ "levelTime", "abilitiesHeader", "petHeader", "weapon" }) do
            if plan[key] then plan.finish = math.max(plan.finish, plan[key].start + 0.60 / speed) end
        end
    end
    entranceTimeline, content.entranceTimeline = plan, plan
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

local function RefreshPopupLayoutNow()
    local perf = ns.PerfStart("popup_layout")
    ApplyPopupWidth()
    ns.RefreshPortraitGeometry()
    UpdateTrainerAbilityIcons(content.currentTrainerAbilities or {}, true)
    UpdateWarlockPetAbilityIcons(content.currentWarlockPetAbilities or {}, true)
    ns.RefreshVisualEffects()
    PositionSections()
    local statCount = math.max(1, math.floor((content.statsContainer:GetHeight() or STAT_LINE_HEIGHT) / STAT_LINE_HEIGHT + 0.5))
    LayoutFrame(statCount)
    ns.PerfEnd(perf)
end

ns.RefreshPopupLayoutNow = RefreshPopupLayoutNow

-- Option changes, theme changes, and cache updates can all request a layout in
-- the same frame. Defer one refresh so those requests collapse into a single
-- icon rebuild and frame measurement.
local popupRefreshQueued = false
function ns.QueuePopupRefresh()
    ns.PerfCount("popup_refresh_requests")
    if popupRefreshQueued then
        ns.PerfCount("popup_refresh_coalesced")
        return
    end
    popupRefreshQueued = true
    local function Flush()
        popupRefreshQueued = false
        RefreshPopupLayoutNow()
    end
    if C_Timer and C_Timer.After then C_Timer.After(0, Flush) else Flush() end
end

function ns.RefreshPopupLayout()
    ns.QueuePopupRefresh()
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


local fadeOutGroup = frame:CreateAnimationGroup()
local fadeOut = fadeOutGroup:CreateAnimation("Alpha")
fadeOut:SetFromAlpha(1)
fadeOut:SetToAlpha(0)
fadeOut:SetDuration(0.5)
fadeOut:SetSmoothing("IN")
fadeOutGroup:SetScript("OnFinished", function() frame:Hide() end)
frame.fadeOutGroup = fadeOutGroup

local hideToken = 0
local previewActive = false
local previewSuspended = false
local fadeDeadline
local remainingPreviewTime

local function ShouldSuspendPreview()
    return previewActive and ns.IsPreviewSuspensionRequested() == true
end

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
    delay = math.max(0, delay or 0)
    fadeDeadline = GetTime() + delay
    if ShouldSuspendPreview() then
        previewSuspended = true
        remainingPreviewTime = delay
        return
    end
    if ns.db and ns.db.reducedMotion then
        C_Timer.After(delay, function()
            if token == hideToken and frame:IsShown() then frame:Hide() end
        end)
        return
    end
    C_Timer.After(delay, function() TryFadeOut(token) end)
end
ns.RescheduleFadeOut = ScheduleFadeOut

-- Only pause the timeout for a manually requested preview. Real level-ups
-- retain their usual timer, position, scale, animation, and layout.
function ns.RefreshPreviewSuspension()
    if not previewActive or not frame:IsShown() then return end
    if ShouldSuspendPreview() then
        if previewSuspended then return end
        remainingPreviewTime = math.max(0, (fadeDeadline or GetTime()) - GetTime())
        previewSuspended = true
        hideToken = hideToken + 1
        if frame.fadeOutGroup:IsPlaying() then frame.fadeOutGroup:Stop() end
        frame:SetAlpha(1)
    elseif previewSuspended then
        local remaining = remainingPreviewTime or 0
        previewSuspended = false
        remainingPreviewTime = nil
        ScheduleFadeOut(remaining)
    end
end

function ns.CloseLevelUp()
    previewActive = false
    previewSuspended = false
    remainingPreviewTime = nil
    hideToken = hideToken + 1
    for _, fs in ipairs(content.statLinePool) do StopLineAnimation(fs) end
    for _, icon in ipairs(content.abilityIconPool) do StopIconAnimation(icon) end
    for _, icon in ipairs(content.petAbilityIconPool) do StopIconAnimation(icon) end
    bgAnim:Stop()
    if frame.fadeOutGroup:IsPlaying() then frame.fadeOutGroup:Stop() end
    -- The next level-up rebuilds these lists; release the previous preview
    -- data while the panel is hidden instead of retaining the last snapshot.
    content.currentTrainerAbilities = {}
    content.currentWarlockPetAbilities = {}
    for _, fs in ipairs(content.statLinePool) do
        ReleaseStatLine(fs)
    end
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

    -- Hide the previous portrait before refreshing textures and anchors.
    portraitPreparing = true
    content.portraitArtwork:Hide()
    content:SetAlpha(0)
    ApplyPopupWidth()
    frame:SetScale(db.scale or 1.0)
    EnsureAllTextGlows()
    ns.RefreshClassIcon()
    ApplyToTextLayers(content.levelText, "SetText", ns.L("Level %d", currentLevel))

    local statCount = UpdateStatLines(statChanges or {})
    -- Current stats must be measured before the first visible frame.
    ApplyPopupWidth()

    if db.showLevelTime and tonumber(timePlayedThisLevel) then
        ApplyToTextLayers(content.levelTimeText, "SetText", FormatPlayedTime(timePlayedThisLevel))
        ApplyToTextLayers(content.levelTimeText, "SetShown", true)
    else
        ApplyToTextLayers(content.levelTimeText, "SetText", "")
        ApplyToTextLayers(content.levelTimeText, "SetShown", false)
    end

    UpdateTrainerAbilityIcons(trainerAbilities or {})
    UpdateWarlockPetAbilityIcons(warlockPetAbilities or {})
    UpdateWeaponSkillText(unlearnedWeaponSkills or {})

    LayoutFrame(statCount)

    BuildEntranceTimeline()
    bgFade:SetDuration(BASE_BG_FADE_DURATION / speed)

    bgAnim:Stop()
    if db.reducedMotion then
        bg:SetAlpha(1)
    else
        bgAnim:Play()
    end

    ns.PositionFrame(frame)

    frame:SetAlpha(1) -- undo any leftover fade-out alpha from a previous close
    if frame.fadeOutGroup:IsPlaying() then
        frame.fadeOutGroup:Stop()
    end
    RefreshCloseButtonLabel()
    -- Reset the previous popup's effect clock and portrait alpha before Show.
    StartVisualEffects()
    content:SetAlpha(1)
    frame:Show()
    portraitPreparing = false
    UpdateVisualEffects()

    ns.PlayLevelUpSound()
    local entranceDuration = db.reducedMotion and BASE_BG_FADE_DURATION / speed or entranceTimeline.finish
    ScheduleFadeOut(entranceDuration + (db.duration or 7))
end

function ns.ShowLevelUp(currentLevel, statChanges, trainerAbilities, unlearnedWeaponSkills, timePlayedThisLevel, warlockPetAbilities, isPreview)
    ns.EnsureDatabase()
    previewActive = isPreview == true
    previewSuspended = false
    remainingPreviewTime = nil
    local ok, err = pcall(ShowLevelUpImpl, currentLevel, statChanges, trainerAbilities, unlearnedWeaponSkills, timePlayedThisLevel, warlockPetAbilities)
    if not ok then
        print("|cffff4040GnomeLevelUp " .. ns.L("error:") .. "|r " .. tostring(err))
        print("|cffff4040GnomeLevelUp:|r " .. ns.L("The level-up screen failed to display (see above). Please report this error."))
    end
end
