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
    if ns.GetCurrentFlavor and ns.GetCurrentFlavor() == "retail" then
        SyncControllerDefaults(false)
        return false
    end
    local detected = false
    -- Forever's visible Gamepad UI mode is exposed through this CVar. It is
    -- the same signal used by the options window when selecting its controller
    -- handling path, so prefer it over the lower-level device API.
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
    -- Some Forever builds expose the current value through C_CVar even when
    -- the legacy GetCVar call returns the previous interface style.
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
    -- Forever exposes the native mode through the same client cvar on builds
    -- where C_GamePad.IsEnabled is not available to addons.
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

local CONTROLLER_B_ATLASES = {
    xbox = { atlases = { "gamepad_ltr_b_64", "Gamepad_Ltr_B_64" }, file = "Interface\\Gamepad\\gamepadltr.blp" },
    playstation = { atlases = { "gamepad_shp_circle_64", "Gamepad_Shp_Circle_64" }, file = "Interface\\Gamepad\\gamepadshp.blp" },
    nintendo = { atlases = { "gamepad_rev_a_64", "Gamepad_Rev_A_64" }, file = "Interface\\Gamepad\\gamepadrev.blp" },
}

local function SetControllerGlyphTexture(texture, path)
    local ok = pcall(texture.SetTexture, texture, path)
    if not ok then return false end
    if texture.GetTextureFileID then
        local idOK, fileID = pcall(texture.GetTextureFileID, texture)
        if idOK then return fileID ~= nil and fileID ~= 0 end
    end
    return true
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

    local atlas = CONTROLLER_B_ATLASES[ControllerLabelStyle()] or CONTROLLER_B_ATLASES.xbox
    local atlasApplied = false
    if C_Texture and type(C_Texture.GetAtlasInfo) == "function" then
        for _, atlasName in ipairs(atlas.atlases or {}) do
            local infoOK, info = pcall(C_Texture.GetAtlasInfo, atlasName)
            if infoOK and info and (info.file or info.filename)
                and info.leftTexCoord and info.rightTexCoord
                and info.topTexCoord and info.bottomTexCoord then
                local textureOK = pcall(closeIcon.SetTexture, closeIcon, info.file or info.filename)
                if textureOK then
                    closeIcon:SetTexCoord(info.leftTexCoord, info.rightTexCoord,
                        info.topTexCoord, info.bottomTexCoord)
                    atlasApplied = true
                    break
                end
            end
        end
    end
    if not atlasApplied and closeIcon.SetAtlas then
        for _, atlasName in ipairs(atlas.atlases or {}) do
            -- Do not request the atlas's native size; the popup uses a compact
            -- 24-pixel controller hint regardless of the source region size.
            atlasApplied = pcall(closeIcon.SetAtlas, closeIcon, atlasName, false)
            if atlasApplied then break end
        end
    end
    if not atlasApplied then
        atlasApplied = SetControllerGlyphTexture(closeIcon, atlas.file)
        if atlasApplied then closeIcon:SetTexCoord(0, 1, 0, 1) end
    end
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
if (not ns.GetCurrentFlavor or ns.GetCurrentFlavor() ~= "retail")
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
    if ns.GetSelectedCompositeTheme then
        local selected = ns.GetSelectedCompositeTheme()
        if selected then return selected end
    end
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

local function ApplyTextureReference(texture, reference, wrapH, wrapV)
    local function SetTextureSafely(source)
        -- Keep wrapping separate from texture assignment. Retail and Forever
        -- both accept the one-argument form reliably; tile flags are applied
        -- by SetHorizTile/SetVertTile after the reference is loaded.
        return pcall(texture.SetTexture, texture, source)
    end

    if type(reference) == "table" and type(reference.atlas) == "string" then
        -- Resolve the atlas to its parent file when the client exposes the
        -- metadata. This preserves the atlas sub-rectangle while still
        -- allowing the existing repeat/flip/rotation code to work.
        if C_Texture and C_Texture.GetAtlasInfo then
            local ok, info = pcall(C_Texture.GetAtlasInfo, reference.atlas)
            local source = ok and info and (info.file or info.filename)
            if source and info.leftTexCoord and info.rightTexCoord
                and info.topTexCoord and info.bottomTexCoord then
                local setOK = SetTextureSafely(source)
                if setOK then
                    return true, info.leftTexCoord, info.rightTexCoord,
                        info.topTexCoord, info.bottomTexCoord
                end
            end
        end
        if texture.SetAtlas then
            local ok = pcall(texture.SetAtlas, texture, reference.atlas, reference.useAtlasSize == true)
            if ok then return true end
        end
        return false
    end
    if type(reference) == "string" and reference ~= "" then
        -- A tiled center must use a repeat wrap mode. Without it the client
        -- clamps the final texel and makes the texture look stretched at the
        -- right and bottom edges. Non-tiled pieces stay clamped.
        local horizontalWrap = wrapH and "REPEAT" or "CLAMP"
        local verticalWrap = wrapV and "REPEAT" or "CLAMP"
        local wrapped = pcall(texture.SetTexture, texture, reference, horizontalWrap, verticalWrap)
        if wrapped then return true end
        return SetTextureSafely(reference)
    end
    return false
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
        ApplyTextureReference(texture, path, tileHorizontal, tileVertical)
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
    for _, layer in ipairs(bg.layers) do
        layer:SetShown(not useCustom)
    end
    if not useCustom then theme = nil end
    for _, name in ipairs(BACKGROUND_PIECES) do
        local piece = bg.customPieces[name]
        if useCustom and name ~= "center" then
            SetBackgroundPiece(piece, name, theme.textures and theme.textures[name], (ns.db and ns.db.bgOpacity) or 0.70, true)
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
        SetBackgroundPiece(bg.customBackingPieces.center, "center", theme.textures and theme.textures.center, alpha, false)
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
            glow:SetAlpha((text.lineAlpha or 1) * alpha)
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
    if method == "SetText" or method == "SetWidth" or method == "SetWordWrap" then
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
    content.classRingGraphic:SetSize(ringSize * PortraitRingScale(), ringSize * PortraitRingScale())
    local ringOffsetX, ringOffsetY = PortraitRingOffset()
    content.classRingGraphic:ClearAllPoints()
    content.classRingGraphic:SetPoint("CENTER", content.classRing, "CENTER", ringOffsetX, ringOffsetY)

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
    local reference = db.portraitRingTexture
    if (type(reference) ~= "string" or reference == "")
        and db.portraitRingChoice and ns.GetPortraitRingReference then
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

    local applied = false
    if type(reference) == "table" and reference.atlas and content.classRingGraphic.SetAtlas then
        local ok = pcall(content.classRingGraphic.SetAtlas, content.classRingGraphic, reference.atlas, reference.useAtlasSize == true)
        applied = ok
    elseif type(reference) == "string" then
        -- Portrait rings are authored as complete circular images. Use the
        -- reliable one-argument form and leave wrapping completely disabled.
        applied = pcall(content.classRingGraphic.SetTexture, content.classRingGraphic, reference)
    end
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
content.levelText:SetPoint("TOP", content.classRing, "BOTTOM", 0, -6)
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
        return ns.L("Time to level: %dh %02dm", hours, minutes)
    elseif minutes > 0 then
        return ns.L("Time to level: %dm %02ds", minutes, remainingSeconds)
    end
    return ns.L("Time to level: %ds", remainingSeconds)
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

local function ApplyPopupWidth()
    local compact = IsCompactLayout()
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
    SyncTextGeometry(content.weaponSkillsText)
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

local function SetLineAlpha(fs, alpha)
    fs.lineAlpha = alpha
    fs:SetAlpha(alpha)
    for _, glow in ipairs(fs.glows) do
        glow:SetAlpha(alpha * CurrentShadowAlpha(fs))
    end
end

local function SetLineShown(fs, shown)
    ApplyToTextLayers(fs, "SetShown", shown)
end

-- Stat lines and ability icons use WoW AnimationGroups so entrance motion does
-- not need a Lua OnUpdate loop.
local ABILITY_POP_DISTANCE = 24  -- how far below its resting spot an icon starts

local function AbilityIconColumns()
    if IsCompactLayout() then return COMPACT_MAX_SKILLS end
    local gap = AbilityIconGap()
    return math.max(1, math.floor((TEXT_WIDTH + gap) / (ABILITY_ICON_SIZE + gap)))
end

local function StopLineAnimation(fs)
    activeLineAnims[fs] = nil
    if fs.animationGroup then fs.animationGroup:Stop() end
    for _, glow in ipairs(fs.glows) do
        if glow.animationGroup then glow.animationGroup:Stop() end
    end
end

local function EnsureLineAnimation(fs)
    if not fs.animationGroup then
        local group = fs:CreateAnimationGroup()
        local translation = group:CreateAnimation("Translation")
        local alpha = group:CreateAnimation("Alpha")
        group:SetScript("OnFinished", function()
            if fs.animationContainer then
                fs:ClearAllPoints()
                fs:SetPoint("TOP", fs.animationContainer, "TOP", 0, fs.animationY or 0)
            end
            SetLineAlpha(fs, 1)
            SetLineShown(fs, true)
            activeLineAnims[fs] = nil
        end)
        fs.animationGroup = group
        fs.animationTranslation = translation
        fs.animationAlpha = alpha
    end

    -- Region translations do not move sibling FontStrings anchored to them.
    -- Animate the glow layers with the same native timing as the main text.
    for _, glow in ipairs(fs.glows) do
        if not glow.animationGroup then
            local glowGroup = glow:CreateAnimationGroup()
            glow.animationTranslation = glowGroup:CreateAnimation("Translation")
            glow.animationAlpha = glowGroup:CreateAnimation("Alpha")
            glowGroup:SetScript("OnFinished", function()
                glow:SetAlpha(CurrentShadowAlpha(fs))
            end)
            glow.animationGroup = glowGroup
        end
    end
end

local function StartLineAnimation(fs, container, startX, y, delay, duration)
    EnsureLineAnimation(fs)
    StopLineAnimation(fs)
    if ns.db and ns.db.reducedMotion then
        fs:ClearAllPoints()
        fs:SetPoint("TOP", container, "TOP", 0, y)
        SetLineAlpha(fs, 1)
        SetLineShown(fs, true)
        return
    end
    activeLineAnims[fs] = true
    fs.animationContainer = container
    fs.animationY = y
    fs:ClearAllPoints()
    fs:SetPoint("TOP", container, "TOP", startX, y)
    SetLineAlpha(fs, 0)
    SetLineShown(fs, true)

    local translation = fs.animationTranslation
    translation:SetOffset(-startX, 0)
    translation:SetDuration(duration)
    translation:SetStartDelay(delay)
    translation:SetSmoothing("OUT")

    local alpha = fs.animationAlpha
    alpha:SetFromAlpha(0)
    alpha:SetToAlpha(1)
    alpha:SetDuration(duration)
    alpha:SetStartDelay(delay)
    alpha:SetSmoothing("IN")
    fs.animationGroup:Play()
    for _, glow in ipairs(fs.glows) do
        local glowTranslation = glow.animationTranslation
        glowTranslation:SetOffset(-startX, 0)
        glowTranslation:SetDuration(duration)
        glowTranslation:SetStartDelay(delay)
        glowTranslation:SetSmoothing("OUT")
        local glowAlpha = glow.animationAlpha
        glowAlpha:SetFromAlpha(0)
        glowAlpha:SetToAlpha(CurrentShadowAlpha(fs))
        glowAlpha:SetDuration(duration)
        glowAlpha:SetStartDelay(delay)
        glowAlpha:SetSmoothing("IN")
        glow.animationGroup:Play()
    end
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
    if ns.db and ns.db.reducedMotion then
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
        local spellID = spell.id
        local spellName = spell.name
        icon.spellID = spellID
        icon.spellName = spellName
        local formattedCost = ns.db and ns.db.showTrainerCosts and FormatTrainerCost(spell.cost)
        if formattedCost ~= icon.formattedCost then
            icon.costText:SetText(formattedCost or "")
            icon.formattedCost = formattedCost
            icon.costText:SetShown(formattedCost ~= nil)
        end
        local texture = spell.icon
        if not texture and icon.textureSpellID == spellID then
            texture = icon.texturePath
        elseif not texture then
            texture = spellID and (
                (C_Spell and C_Spell.GetSpellTexture and C_Spell.GetSpellTexture(spellID))
                or (GetSpellTexture and GetSpellTexture(spellID))
            )
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
        local x = startX + column * (ABILITY_ICON_SIZE + gap)
        local visibleCellHeight = formattedCost and cellHeight or ABILITY_ICON_SIZE
        local iconY = startY + (visibleCellHeight - ABILITY_ICON_SIZE) / 2
            - rowIndex * (cellHeight + gap)
        if formattedCost then iconY = iconY - ABILITY_COST_TOP_PADDING end
        local delay = staggerBase + (i - 1) * staggerStep
        StartIconPop(icon, row, x, iconY, delay, popDuration)
    end

    for i = count + 1, #pool do
        StopIconAnimation(pool[i])
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

local function BuildStatLineText(data, tracking)
    if not data then return "" end
    local spaces = string.rep(" ", math.max(0, tonumber(tracking) or 0))
    return string.format("%s: %d%s %s->%s %d|r",
        data.name, data.old, spaces, Hex(ColorOf("statNew")), spaces, data.new)
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
        target = math.max(target, MeasureStatText(content.statLinePool[1] or GetStatLine(1), BuildStatLineText(data, 0)))
    end
    for i, data in ipairs(statChanges) do
        local fs = content.statLinePool[i] or GetStatLine(i)
        local best, bestDelta = 0, math.huge
        for tracking = 0, 20 do
            local delta = math.abs(MeasureStatText(fs, BuildStatLineText(data, tracking)) - target)
            if delta < bestDelta then best, bestDelta = tracking, delta end
        end
        fs.statTracking = best
    end
end

local ApplyStatLineText
function ns.RefreshStatTextLayout()
    local changes = {}
    for _, fs in ipairs(content.statLinePool or {}) do
        if fs.statData then changes[#changes + 1] = fs.statData end
    end
    UpdateStatTracking(changes)
    for _, fs in ipairs(content.statLinePool or {}) do ApplyStatLineText(fs) end
end

ApplyStatLineText = function(fs)
    local d = fs.statData
    local text
    if d then
        text = BuildStatLineText(d, ns.db and ns.db.equalStatWidths and fs.statTracking or 0)
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
    if ns.RefreshStatTextLayout then
        ns.RefreshStatTextLayout()
    else
        for _, fs in ipairs(content.statLinePool) do ApplyStatLineText(fs) end
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

    if count > 0 then UpdateStatTracking(statChanges) end

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
        LayoutStatLine(1, nil, ns.L("No stat changes"))
        count = 1
    else
        for i = 1, count do
            LayoutStatLine(i, statChanges[i])
        end
    end

    for i = count + 1, #pool do
        StopLineAnimation(pool[i])
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

local function RefreshPopupLayoutNow()
    local perf = ns.PerfStart and ns.PerfStart("popup_layout")
    ApplyPopupWidth()
    ns.RefreshPortraitGeometry()
    UpdateTrainerAbilityIcons(content.currentTrainerAbilities or {})
    UpdateWarlockPetAbilityIcons(content.currentWarlockPetAbilities or {})
    PositionSections()
    local statCount = math.max(1, math.floor((content.statsContainer:GetHeight() or STAT_LINE_HEIGHT) / STAT_LINE_HEIGHT + 0.5))
    LayoutFrame(statCount)
    if ns.PerfEnd then ns.PerfEnd(perf) end
end

ns.RefreshPopupLayoutNow = RefreshPopupLayoutNow

-- Option changes, theme changes, and cache updates can all request a layout in
-- the same frame. Defer one refresh so those requests collapse into a single
-- icon rebuild and frame measurement.
local popupRefreshQueued = false
function ns.QueuePopupRefresh()
    if ns.PerfCount then ns.PerfCount("popup_refresh_requests") end
    if popupRefreshQueued then
        if ns.PerfCount then ns.PerfCount("popup_refresh_coalesced") end
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
local previewActive = false
local previewSuspended = false
local fadeDeadline
local remainingPreviewTime

local function ShouldSuspendPreview()
    return previewActive and ns.IsPreviewSuspensionRequested
        and ns.IsPreviewSuspensionRequested() == true
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
    contentAnim:Stop()
    if frame.fadeOutGroup:IsPlaying() then frame.fadeOutGroup:Stop() end
    -- The next level-up rebuilds these lists; release the previous preview
    -- data while the panel is hidden instead of retaining the last snapshot.
    content.currentTrainerAbilities = {}
    content.currentWarlockPetAbilities = {}
    for _, fs in ipairs(content.statLinePool) do
        fs.statData = nil
        fs.plainText = nil
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

    ApplyPopupWidth()
    frame:SetScale(db.scale or 1.0)
    EnsureAllTextGlows()
    ns.RefreshClassIcon()
    ApplyToTextLayers(content.levelText, "SetText", ns.L("Level %d", currentLevel))

    local statCount = UpdateStatLines(statChanges or {})

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
    RefreshCloseButtonLabel()
    frame:Show()

    ns.PlayLevelUpSound()
    ScheduleFadeOut(db.duration or 7)
end

function ns.ShowLevelUp(currentLevel, statChanges, trainerAbilities, unlearnedWeaponSkills, timePlayedThisLevel, warlockPetAbilities, isPreview)
    if ns.EnsureDatabase then ns.EnsureDatabase() end
    previewActive = isPreview == true
    previewSuspended = false
    remainingPreviewTime = nil
    local ok, err = pcall(ShowLevelUpImpl, currentLevel, statChanges, trainerAbilities, unlearnedWeaponSkills, timePlayedThisLevel, warlockPetAbilities)
    if not ok then
        print("|cffff4040GnomeLevelUp error:|r " .. tostring(err))
        print("|cffff4040GnomeLevelUp:|r the level-up screen failed to display (see above). Please report this error.")
    end
end
