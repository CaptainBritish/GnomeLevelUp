local ADDON_NAME, ns = ...

-- Keep the panel readable at different animation speeds and resolutions.
local BASE_BG_FADE_DURATION = 0.25
local BASE_CONTENT_FADE_DURATION = 0.30
local BASE_STAT_STAGGER_BASE = 0.30
local BASE_STAT_STAGGER_STEP = 0.08
local BASE_STAT_SLIDE_DURATION = 0.30
local STAT_SLIDE_DISTANCE_X = 50      -- pixels each stat line slides in from
local UI_METRICS = {
    statLineHeight = 26, minimumStatLineHeight = 18,
    abilityTopGap = 8, modernAbilityPadding = 12, texturedAbilityPadding = 24,
    texturedVerticalBottomPadding = 24, texturedHorizontalMaxBottomPadding = 8,
    automaticCloseSpeed = .85, manualCloseSpeed = 2,
    modernCloseSeconds = .60, texturedCloseSeconds = .5,
    textMeasurementLimit = 512,
    verticalPortraitGrowth = 1.25,
    modernVerticalFadeTail = 20, modernVerticalBottomLineGap = 8,
}
local STAT_LINE_HEIGHT = UI_METRICS.statLineHeight
local DEFAULT_FONT_PATH = ns.DEFAULT_FONT_PATH or "Fonts\\FRIZQT__.TTF"
local SECTION_DIVIDER_HEIGHT = 3
local SEPARATOR_TEXTURE = "Interface\\AddOns\\GnomeLevelUp\\Textures\\seperator"
local DEFAULT_SECTION_PADDING = 8
local WHITE_COLOR = { 1, 1, 1 }
local BLACK_COLOR = { 0, 0, 0 }
local content

local FRAME_WIDTH = 460
local TEXT_WIDTH = FRAME_WIDTH - 60
local DEFAULT_TEXT_WIDTH = TEXT_WIDTH
local COMPACT_MAX_SKILLS = 5
local MODEL_VIEWPORT_RATIO = 0.952 -- 40% larger than the earlier 0.68 viewport
local PLAYER_PORTRAIT_SIZE = 90
local CLASS_ICON_SIZE = PLAYER_PORTRAIT_SIZE
local PORTRAIT_RING_PADDING = 6

local function IsPlayerPortrait()
    return ns.db and (ns.db.portraitMode == "player" or ns.db.portraitMode == "player3d")
end

local function PortraitBaseSize()
    return IsPlayerPortrait() and PLAYER_PORTRAIT_SIZE or CLASS_ICON_SIZE
end

local function PortraitScale()
    local scale = tonumber(ns.db and ns.db.playerPortraitScale) or 1.0
    return math.max(0.5, math.min(2.0, scale))
end

local function PortraitIconSize()
    return IsPlayerPortrait() and PortraitBaseSize() * PortraitScale()
        * (ns.db and ns.db.horizontalMode and 1.6 * (content and content.portraitFit or 1) or UI_METRICS.verticalPortraitGrowth) or CLASS_ICON_SIZE
end

local function PortraitArtworkSize()
    return PortraitIconSize() * (ns.db and ns.db.portraitMode == "player" and 0.95 or 1)
end

local function PortraitRingSize()
    if ns.db and ns.db.portraitMode == "none" then return 0 end
    local padding = PORTRAIT_RING_PADDING
    if IsPlayerPortrait() and ns.db and not ns.db.horizontalMode then
        padding = padding * UI_METRICS.verticalPortraitGrowth
    end
    return PortraitIconSize() + padding
end

local function PortraitRingScale()
    local scale = tonumber(ns.db and ns.db[ns.GetPortraitRingSettingKey("Scale")]) or 1.0
    return math.max(0.5, math.min(2.0, scale))
end

local function ModelPortraitDiameter()
    local size = PortraitIconSize()
    if ns.db and ns.db.portraitRingEnabled then
        size = math.min(size, PortraitRingSize() * PortraitRingScale() * 0.90)
    end
    return math.max(1, size)
end

local function ModelViewportRatio()
    local size = math.max(25, math.min(300, ns.GetPlayerModelSetting("portraitModelViewportSize")))
    return MODEL_VIEWPORT_RATIO * size / 100
end

-- Model-depth masking adapted from Animated Default Portraits by dvd (2026).
-- See THIRD_PARTY_NOTICES.md. Texture masks alone cannot clip PlayerModel.
local modelMaskState
local function UpdateModelMaskGeometry(diameter)
    if not modelMaskState then return end
    local model = content.playerModel
    local opening = diameter * math.max(25, math.min(300,
        ns.GetPlayerModelSetting("portraitModelMaskSize"))) / 100
    local inset = (model:GetWidth() - opening) / 2 - 130 * opening
    if modelMaskState.inset ~= inset then
        for _, mask in ipairs(modelMaskState.models) do mask:SetViewInsets(inset, inset, inset, inset) end
        modelMaskState.inset = inset
    end
    local scale = 0.6 / math.max(0.01, model:GetEffectiveScale())
    if modelMaskState.scale ~= scale then
        for _, mask in ipairs(modelMaskState.models) do mask:SetModelScale(scale) end
        modelMaskState.scale = scale
    end
end

local function CreateModelMask()
    local model = content.playerModel
    local models = {}
    for i = 1, 2 do
        local mask = CreateFrame("Model", nil, model)
        mask:SetFrameStrata("BACKGROUND")
        mask:SetFixedFrameStrata(true)
        mask:SetFrameLevel(0)
        mask:SetFixedFrameLevel(true)
        mask:SetAllPoints(model)
        mask:SetModel(587744) -- Built-in gears model with a circular opening.
        mask:SetPaused(true)
        mask:MakeCurrentCameraCustom()
        mask:SetCameraFacing(math.pi / 2)
        mask:SetPosition(0.1118, 0, -0.2837)
        mask:SetCameraPosition(0, 14 * 0.6, 0)
        mask:SetCameraRoll(-0.17 + (i - 1) * math.pi / 12)
        -- Nonzero alpha keeps depth occlusion active without a visible cover.
        mask:SetIgnoreParentAlpha(true)
        mask:SetAlpha(0.0001)
        mask:SetModelAlpha(0.0001)
        models[i] = mask
    end
    modelMaskState = { models = models }
    content.modelMasks = models
    UpdateModelMaskGeometry(ModelPortraitDiameter())
end

local function PortraitRingOffset()
    local offset = ns.db and ns.db[ns.GetPortraitRingSettingKey("Offset")]
    return tonumber(offset and offset.x) or 0, tonumber(offset and offset.y) or 0
end

local function Speed()
    local mult = (ns.db and ns.db.animSpeedMultiplier) or 1.0
    if mult <= 0 then mult = 1.0 end
    return mult
end

local function SectionPadding()
    local padding = ns.GetSectionPadding and ns.GetSectionPadding() or DEFAULT_SECTION_PADDING
    return math.max(0, math.min(30, padding))
end

local function IsCompactLayout()
    return ns.db and (ns.db.horizontalMode == true or ns.db.compactMode == true)
end

local function IsHorizontalLayout()
    return ns.db and ns.db.horizontalMode == true
end

local function PortraitColumnWidth()
    if ns.db and ns.db.portraitMode == "none" then return IsCompactLayout() and 110 or 140 end
    local offsetX = PortraitRingOffset()
    return math.max(IsCompactLayout() and 140 or 176, PortraitRingSize() * PortraitRingScale() + math.abs(offsetX) * 2 + 24)
end

local function HorizontalColumnCount()
    if ns.GetCurrentFlavor() == "retail" and content and #(content.currentTrainerAbilities or {}) == 0 then return 1 end
    return content and #(content.currentWarlockPetAbilities or {}) > 0 and 3 or 2
end

local function TrainingWidth(viewport)
    return math.max(1, (viewport.horizontalWidth or TEXT_WIDTH) * (viewport.layoutScale or 1))
end

local function SectionGap()
    local padding = SectionPadding()
    if IsCompactLayout() and IsHorizontalLayout() then return padding end
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
frame:SetMovable(true)
-- SavedVariables own both layout positions; do not also restore WoW's layout cache.
if type(frame.SetDontSavePosition) == "function" then frame:SetDontSavePosition(true) end
if type(frame.SetUserPlaced) == "function" then frame:SetUserPlaced(false) end
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", function(self)
    if ns.db and ns.db.lockFramePosition then return end
    self:StartMoving()
end)
frame:SetScript("OnDragStop", function(self)
    if ns.db and ns.db.lockFramePosition then return end
    self:StopMovingOrSizing()
    -- StartMoving marks the frame user-placed even when native saving is disabled.
    if type(self.SetUserPlaced) == "function" and self:IsMovable() then self:SetUserPlaced(false) end
    if not ns.db then return end
    local point, _, relativePoint, x, y = self:GetPoint(1)
    if point and relativePoint and x and y then
        ns.db[IsHorizontalLayout() and "horizontalFramePosition" or "framePosition"] = {
            point = point,
            relativePoint = relativePoint,
            x = x,
            y = y,
        }
    end
end)
frame:SetScript("OnMouseUp", function(self, button)
    if button == "RightButton" and ns.db and ns.db.rightClickClose then
        ns.DismissLevelUp()
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
        if IsControllerBackButton(button) then ns.DismissLevelUp() end
    end)
end
closeButton:SetScript("OnClick", function() ns.DismissLevelUp() end)
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

local closingInputState

function ns.SetClosingClickThrough(active)
    if active then
        if closingInputState then return end
        closingInputState = {}
        frame.closingInputSuppressed = true
        local function Suppress(widget)
            closingInputState[#closingInputState + 1] = {
                widget = widget,
                mouse = widget.IsMouseEnabled and widget:IsMouseEnabled() or false,
                wheel = widget.IsMouseWheelEnabled and widget:IsMouseWheelEnabled() or false,
            }
            if widget.EnableMouse then widget:EnableMouse(false) end
            if widget.EnableMouseWheel then widget:EnableMouseWheel(false) end
            if widget.GetChildren then for _, child in ipairs({widget:GetChildren()}) do Suppress(child) end end
        end
        Suppress(frame)
        if GameTooltip then GameTooltip:Hide() end
    else
        frame.closingInputSuppressed = nil
        if not closingInputState then return end
        for _, state in ipairs(closingInputState) do
            if state.widget.EnableMouse then state.widget:EnableMouse(state.mouse) end
            if state.widget.EnableMouseWheel then state.widget:EnableMouseWheel(state.wheel) end
        end
        closingInputState = nil
        ns.ApplyClickThrough(ns.db and ns.db.clickThrough)
    end
end

function ns.ApplyClickThrough(enabled)
    -- A click-through popup must not consume mouse input from the game world.
    local interactive = enabled ~= true and not frame.closingInputSuppressed
    frame:EnableMouse(interactive)
    if closeButton and closeButton.EnableMouse then
        closeButton:EnableMouse(interactive)
    end
end

function ns.PositionFrame(f)
    local horizontal = IsHorizontalLayout()
    local key = horizontal and "horizontalFramePosition" or "framePosition"
    local fallback = horizontal and ns.defaults.horizontalFramePosition or ns.defaults.framePosition
    local position = ns.db and ns.db[key]
    -- Older profiles sometimes carried the vertical default into this slot.
    local legacyCenter = horizontal and type(position) == "table"
        and position.point == "CENTER" and position.relativePoint == "CENTER"
        and (position.x or 0) == 0 and (position.y or 90) == 90
    if type(position) ~= "table" or not position.point or not position.relativePoint or legacyCenter then
        position = fallback
    end
    f:ClearAllPoints()
    f:SetPoint(position.point, UIParent, position.relativePoint, position.x or fallback.x, position.y or fallback.y)
    return false
end

-- Clip the repeated edge bands a few pixels inside the outside frame edge.
-- Their regions still run beneath the corner textures at both ends.
local EDGE_MASK_INSET = 5
local backgroundWidth, backgroundHeight, backgroundHorizontal, backgroundHasPet
-- LayoutCustomBackground performs a large number of anchor and size updates.
-- Keep a small invalidation counter so repeated popup/layout refreshes do not
-- rebuild an unchanged nine-slice background.
local backgroundLayoutVersion = 0
local laidOutBackgroundVersion = -1

local bg = CreateFrame("Frame", nil, frame)
bg:SetAllPoints(frame)
bg.modern = bg:CreateTexture(nil, "BACKGROUND", nil, -8)
bg.modern:SetTexture("Interface\\AddOns\\GnomeLevelUp\\Textures\\modern-veil.tga")
bg.modern:SetPoint("CENTER", bg, "CENTER")
bg.modern:SetSize(FRAME_WIDTH, 300)
if bg.CreateMaskTexture then
    local softEdge = bg:CreateMaskTexture()
    softEdge:SetAllPoints(bg.modern)
    softEdge:SetTexture("Interface\\AddOns\\GnomeLevelUp\\Textures\\modern-veil.tga", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    bg.modern:AddMaskTexture(softEdge)
    bg.modernMask = softEdge
end
function bg.HideModernBackgroundFlash()
    if bg.modernFlashLeft then
        bg.modernFlashLeft:Hide()
        bg.modernFlashRight:Hide()
    end
    bg.modern:SetAlpha(1)
end

function bg.ShowModernBackgroundFlash(color, hue, strength, opacity, coverage)
    if not bg.modernFlashLeft then
        for _, side in ipairs({"Left", "Right"}) do
            local texture = bg:CreateTexture(nil, "BACKGROUND", nil, -8)
            texture:SetTexture("Interface\\AddOns\\GnomeLevelUp\\Textures\\modern-veil.tga")
            if bg.modernMask then texture:AddMaskTexture(bg.modernMask) end
            bg["modernFlash" .. side] = texture
        end
    end
    local left, right = bg.modernFlashLeft, bg.modernFlashRight
    local width = bg.modern:GetWidth()
    left:SetTexCoord(0, coverage, 0, 1)
    right:SetTexCoord(coverage, 1, 0, 1)
    left:SetPoint("TOPLEFT", bg.modern, "TOPLEFT", 0, 0)
    left:SetPoint("BOTTOMRIGHT", bg.modern, "BOTTOMRIGHT", -width * (1 - coverage), 0)
    right:SetPoint("TOPLEFT", bg.modern, "TOPLEFT", width * coverage, 0)
    right:SetPoint("BOTTOMRIGHT", bg.modern, "BOTTOMRIGHT", 0, 0)
    local r, g, b = hue[1] + (color[1] - hue[1]) * strength,
        hue[2] + (color[2] - hue[2]) * strength, hue[3] + (color[3] - hue[3]) * strength
    left:SetVertexColor(1, 1, 1, 1)
    if left.SetGradient and type(CreateColor) == "function" then
        left:SetGradient("HORIZONTAL", CreateColor(r, g, b, opacity), CreateColor(hue[1], hue[2], hue[3], opacity))
    else
        -- Forever retains the gradient API removed from current Retail definitions.
        ---@cast left { SetGradientAlpha: fun(self: Texture, orientation: string, ...: number) }
        left.SetGradientAlpha(bg.modernFlashLeft, "HORIZONTAL", r, g, b, opacity, hue[1], hue[2], hue[3], opacity)
    end
    right:SetVertexColor(hue[1], hue[2], hue[3], opacity)
    -- Replacing both halves keeps the veil's original opacity and mask. The
    -- gradient covers the celebration's chosen width; the remainder retains its hue.
    bg.modern:SetAlpha(0)
    bg.modernFlashLeft:Show()
    right:Show()
end

bg.modernAccents = {}
for _, edge in ipairs({ "TOP", "BOTTOM" }) do
    local line = bg:CreateTexture(nil, "BACKGROUND", nil, -5)
    line:SetTexture(SEPARATOR_TEXTURE)
    line:SetSize(FRAME_WIDTH * 0.94, 2)
    line:SetPoint(edge, bg, edge, 0, edge == "TOP" and -20 or 20)
    bg.modernAccents[#bg.modernAccents + 1] = line
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

-- Textured themes use a fixed content inset, independent of border artwork.
local function ThemeContentInset()
    return ns.db and ns.db.backgroundMode ~= "MODERN" and ns.GetParticleValue(ns.FRAME_INSET_SETTING, "value") or 0
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

local function ModernBackdropWidth(width)
    local hasPet = IsHorizontalLayout() and content.petSpellsHeader and content.petSpellsHeader:IsShown()
    return width + (hasPet and 48 or 0)
end

local function LayoutBackground()
    local w, h = frame:GetWidth(), frame:GetHeight()
    local custom = ns.db and ns.db.backgroundMode == "CUSTOM"
    local horizontal = IsHorizontalLayout()
    local hasPet = horizontal and content.petSpellsHeader and content.petSpellsHeader:IsShown() or false
    if w == backgroundWidth and h == backgroundHeight and horizontal == backgroundHorizontal and hasPet == backgroundHasPet
        and (not custom or laidOutBackgroundVersion == backgroundLayoutVersion) then
        return
    end
    backgroundWidth, backgroundHeight, backgroundHorizontal, backgroundHasPet = w, h, horizontal, hasPet
    bg.modern:ClearAllPoints()
    bg.modern:SetPoint("CENTER", bg, "CENTER", 0, horizontal and 0 or -UI_METRICS.modernVerticalFadeTail / 2)
    bg.modern:SetSize(ModernBackdropWidth(w), h + (horizontal and 0 or UI_METRICS.modernVerticalFadeTail))
    for i, line in ipairs(bg.modernAccents) do
        line:SetWidth(w * 0.94)
        line:ClearAllPoints()
        if i == 1 then line:SetPoint("TOP", bg, "TOP", 0, -20)
        else line:SetPoint("BOTTOM", bg, "BOTTOM", 0, horizontal and 20 or -UI_METRICS.modernVerticalBottomLineGap) end
    end
    local theme = GetBackgroundTheme()
    if theme then LayoutCustomBackground(theme) end
    laidOutBackgroundVersion = backgroundLayoutVersion
end
LayoutBackground()

-- Keep background opacity separate from the content animation.
function ns.ApplyBackgroundAppearance(opacityOverride)
    backgroundLayoutVersion = backgroundLayoutVersion + 1
    local theme = GetBackgroundTheme()
    local useCustom = ns.db and ns.db.backgroundMode == "CUSTOM" and theme ~= nil
    local themeTextures = theme and theme.textures or nil
    bg.modern:SetShown(not useCustom)
    local modernColor = ns.db and ns.db.backgroundColor or BLACK_COLOR
    local opacity = opacityOverride or (ns.db and ns.db.bgOpacity) or 0.70
    bg.appliedOpacity = opacity
    bg.HideModernBackgroundFlash()
    bg.modern:SetVertexColor(modernColor[1], modernColor[2], modernColor[3], opacity)
    local accent = ns.db and ns.db.colors and ns.db.colors.animatedElements or WHITE_COLOR
    for _, line in ipairs(bg.modernAccents) do
        line:SetShown(not useCustom)
        line:SetVertexColor(accent[1], accent[2], accent[3], opacity * 0.65)
    end
    if not useCustom then themeTextures = nil end
    for _, name in ipairs(BACKGROUND_PIECES) do
        local piece = bg.customPieces[name]
        if useCustom and name ~= "center" then
            local texture = themeTextures and themeTextures[name]
            SetBackgroundPiece(piece, name, texture, opacity, true)
        else
            -- The authored center slice is rendered by the dedicated backing
            -- layer so it is never double-blended. That backing extends beneath
            -- edges and corners; authored corner textures remain above it.
            piece:Hide()
        end
    end

    -- Deep center backing: use the center texture across the whole frame so
    -- transparent corner pixels reveal theme artwork instead of the world.
    local alpha = opacity
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
    if ns.RefreshMaxBackgroundTint then ns.RefreshMaxBackgroundTint(true) end
end

function ns.ApplyBackgroundOpacity(opacity)
    opacity = math.max(0, math.min(0.995, opacity or 0.70))
    ns.ApplyBackgroundAppearance(opacity)
end
ns.ApplyBackgroundOpacity(0.70)
ns.ApplyBackgroundAppearance()

content = CreateFrame("Frame", nil, frame)
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
    if type(fontPath) ~= "string" or fontPath == "" then fontPath = DEFAULT_FONT_PATH end
    for _, entry in ipairs(content.fontElements) do
        local scale = entry.fs.gluFontScaleKey and ns.GetTextScale(entry.fs.gluFontScaleKey) or 1
        entry.fs:SetFont(fontPath, entry.size * scale, entry.flags)
        if entry.fs.gluStatText then entry.fs.gluFixedStatHeight = nil end
    end
    local statScale = ns.GetTextScale("statTextScale")
    local statSizeChanged = render.appliedStatScale ~= statScale
    render.appliedStatScale = statScale
    STAT_LINE_HEIGHT = math.max(UI_METRICS.minimumStatLineHeight, math.ceil(UI_METRICS.statLineHeight * statScale))
    render.fitKey, render.headingFitKey = nil, nil
    for _, fs in ipairs(content.statLinePool or {}) do
        fs.statWordLayoutKey = nil
        fs.slideFrame:SetHeight(STAT_LINE_HEIGHT)
    end
    if render.SyncScaledText then render.SyncScaledText() end
    if statSizeChanged and render.ReflowStatsForFont and frame:IsShown() then render.ReflowStatsForFont() end
    content.levelTimeMetricKey = nil
    if render.MeasureLevelTime then render.MeasureLevelTime() end
    if render.StylePaceRecord then render.StylePaceRecord() end
    if ns.RefreshVisualEffects then ns.RefreshVisualEffects() end
    if frame:IsShown() and ns.RefreshPopupLayout then ns.RefreshPopupLayout() end
end

local GLOW_ALPHA = 0.15
local GLOW_DIRS = {
    { -1, 0 }, { 1, 0 }, { 0, -1 }, { 0, 1 },
    { -1, -1 }, { 1, 1 }, { -1, 1 }, { 1, -1 },
}

local function CurrentShadowAlpha(text)
    if text and text.wordLayoutActive then return 0 end
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
        glow.gluFontScaleKey = main.gluFontScaleKey
        RegisterFontElement(glow, main.gluStatText and 20 or main.gluFontBaseSize)
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
        local alpha = (enabled == false or text.wordLayoutActive) and 0 or (text.glowAlpha or GLOW_ALPHA)
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
    main.gluFontBaseSize = size or select(2, main:GetFont())
    main.gluFontScaleKey = main.gluStatText and "statTextScale"
        or main == content.levelTimeText and "timeTextScale"
        or (main == content.levelText or main == content.statsHeader or main == content.spellsHeader
            or main == content.petSpellsHeader) and "headingTextScale" or nil
    for _, glow in ipairs(main.glows) do glow.gluFontScaleKey = main.gluFontScaleKey end
    RegisterFontElement(main, size, flags)
end

function render.SyncScaledText()
    for _, text in ipairs(content.textLayers) do
        if text.gluFontScaleKey == "headingTextScale" or text.gluStatText then SyncTextGeometry(text) end
    end
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
    divider = true,
}

local function ActiveColor(key)
    if ns.db and ns.db.useClassColors and CLASS_COLOR_KEYS[key] then
        local color = ns.GetClassColor(key)
        if color then return color end
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
content.classIcon:SetSize(PortraitArtworkSize(), PortraitArtworkSize())
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

function render.PortraitLevelGap()
    if not IsHorizontalLayout() and IsPlayerPortrait() and ns.db.portraitRingEnabled then
        local _, offsetY = PortraitRingOffset()
        return 9 + math.max(0, PortraitRingSize() * (PortraitRingScale() - 1) / 2 - offsetY)
    end
    return 9
end

function ns.RefreshPortraitGeometry(skipEffects)
    if not content.classRing or not content.classIcon or not content.classRingGraphic then return end

    local position = IsPlayerPortrait() and ns.db and ns.db.playerPortraitPosition or {}
    local x = IsPlayerPortrait() and (tonumber(position.x) or 0) or 0
    local y = IsPlayerPortrait() and (tonumber(position.y) or 0) or 0
    local ringSize = math.max(1, PortraitRingSize())

    content.portraitAnchor:SetSize(ringSize, ringSize)
    content.portraitAnchor:ClearAllPoints()
    if IsHorizontalLayout() then
        content.portraitAnchor:SetPoint("CENTER", content, "LEFT", 24 + PortraitColumnWidth() / 2 + x, y)
    else
        content.portraitAnchor:SetPoint("TOP", content, "TOP", x, -SectionPadding() + y)
    end
    content.classRing:SetSize(ringSize, ringSize)
    content.classIcon:SetSize(PortraitArtworkSize(), PortraitArtworkSize())
    if content.playerModel and ns.db and ns.db.portraitMode == "player3d" then
        local diameter = ModelPortraitDiameter()
        -- Leave room for the full portrait; the depth mask trims its outer edge.
        content.playerModel:SetSize(diameter * ModelViewportRatio(), diameter * ModelViewportRatio())
        content.modelBacking:SetSize(diameter, diameter)
        UpdateModelMaskGeometry(diameter)
        local anchor = ns.db and ns.db.portraitRingEnabled and content.classRingGraphic or content.portraitAnchor
        for _, region in ipairs({content.playerModel, content.modelBacking}) do
            region:ClearAllPoints()
            region:SetPoint("CENTER", anchor, "CENTER")
        end
    end
    content.classRingGraphic:SetSize(ringSize * PortraitRingScale(), ringSize * PortraitRingScale())
    local ringOffsetX, ringOffsetY = PortraitRingOffset()
    content.classRingGraphic:ClearAllPoints()
    content.classRingGraphic:SetPoint("CENTER", content.portraitAnchor, "CENTER", ringOffsetX, ringOffsetY)

    if content.levelText then
        content.levelText:ClearAllPoints()
        if ns.db and ns.db.portraitMode == "none" then
            if IsHorizontalLayout() then
                content.levelText:SetPoint("CENTER", content, "LEFT", 24 + PortraitColumnWidth() / 2, 0)
            else
                content.levelText:SetPoint("TOP", content, "TOP", 0, -SectionPadding() - 6)
            end
        else
            content.levelText:SetPoint("TOP", content.portraitAnchor, "BOTTOM", 0, -render.PortraitLevelGap())
        end
    end
    if content.title then
        content.title:ClearAllPoints()
        content.title:SetPoint("TOP", content, "TOP", 0, -(SectionPadding() + ringSize + 6))
    end
    if not skipEffects and ns.RefreshVisualEffects then ns.RefreshVisualEffects() end
end

local FALLBACK_CLASS_COORDS = {
    WARRIOR = { 0, 0.25, 0, 0.25 },       MAGE = { 0.25, 0.5, 0, 0.25 },
    ROGUE = { 0.5, 0.75, 0, 0.25 },       DRUID = { 0.75, 1, 0, 0.25 },
    HUNTER = { 0, 0.25, 0.25, 0.5 },      SHAMAN = { 0.25, 0.5, 0.25, 0.5 },
    PRIEST = { 0.5, 0.75, 0.25, 0.5 },    WARLOCK = { 0.75, 1, 0.25, 0.5 },
    PALADIN = { 0, 0.25, 0.5, 0.75 },     DEATHKNIGHT = { 0.25, 0.5, 0.5, 0.75 },
    MONK = { 0.5, 0.75, 0.5, 0.75 },      DEMONHUNTER = { 0.75, 1, 0.5, 0.75 },
}

-- Rebuild the camera before applying offsets, whether loading or editing live.
-- PlayerModel caches its projection when the viewport changes size or scale.
function render.ApplyPlayerModelCamera(model)
    model = model or content.playerModel
    if not model or model.applyingCamera then return end
    model.applyingCamera = true
    ns.RefreshPlayerModelIdentity()
    model:SetModelScale(ns.GetPlayerModelSetting("portraitModelScale") / 100)
    -- Do not let the previous pose/offset become the next camera's baseline.
    model:SetFacing(0)
    model:SetPosition(0, 0, 0)
    model:RefreshCamera()
    model:SetPortraitZoom(1)
    model:SetCamDistanceScale(0.68)
    model:SetFacing(math.rad(ns.GetPlayerModelSetting("portraitModelRotation")))
    model:SetPosition(ns.GetPlayerModelSetting("portraitModelX"), ns.GetPlayerModelSetting("portraitModelY"), ns.GetPlayerModelSetting("portraitModelZ"))
    model:SetPaused(ns.db and (ns.db.backgroundAnimations == false) or false)
    model.cameraWidth, model.cameraHeight, model.cameraScale = model:GetWidth(), model:GetHeight(), model:GetEffectiveScale()
    model.applyingCamera = nil
end

function render.SyncPlayerModelCamera()
    local model = content.playerModel
    if not model or not ns.db or ns.db.portraitMode ~= "player3d" then return end
    if model.cameraWidth ~= model:GetWidth() or model.cameraHeight ~= model:GetHeight()
        or model.cameraScale ~= model:GetEffectiveScale() then
        render.ApplyPlayerModelCamera(model)
    end
end

function ns.ApplyPlayerModelSettings()
    ns.RefreshPlayerModelIdentity()
    ns.RefreshPortraitGeometry(true)
    render.ApplyPlayerModelCamera()
end

function ns.RefreshClassIcon()
    ns.RefreshPlayerModelIdentity()
    ns.RefreshPortraitGeometry()
    -- None removes the portrait artwork and its reserved header space.
    local portraitMode = ns.db and ns.db.portraitMode or "class"
    if content.playerModel and portraitMode ~= "player3d" then
        content.playerModel:Hide()
        content.modelBacking:Hide()
    end
    if portraitMode == "player3d" then
        if not content.playerModel then
            local model = CreateFrame("PlayerModel", nil, content.portraitArtwork)
            model:Hide()
            model:SetFrameLevel(content.portraitArtwork:GetFrameLevel() + 1)
            model:SetPoint("CENTER", content.portraitAnchor, "CENTER")
            model:SetSize(ModelPortraitDiameter() * ModelViewportRatio(), ModelPortraitDiameter() * ModelViewportRatio())
            model:EnableMouse(false)
            model:SetClipsChildren(true)
            model:SetModelDrawLayer("ARTWORK")
            model:SetFlattensRenderLayers(true)
            model:SetIsFrameBuffer(true)
            model:SetScript("OnModelLoaded", render.ApplyPlayerModelCamera)
            model:SetScript("OnShow", function(self) self:SetUnit("player"); ns.ApplyPlayerModelSettings() end)
            model:SetScript("OnHide", function(self) self:ClearModel() end)
            model:RegisterUnitEvent("UNIT_PORTRAIT_UPDATE", "player")
            model:RegisterUnitEvent("UNIT_MODEL_CHANGED", "player")
            model:SetScript("OnEvent", function(self)
                local identityChanged = ns.RefreshPlayerModelIdentity()
                if self:IsShown() then self:SetUnit("player"); ns.ApplyPlayerModelSettings() end
                if identityChanged and ns.optionsPanel and ns.optionsPanel:IsShown() and ns.RefreshOptionsPanel then
                    ns.RefreshOptionsPanel()
                end
            end)
            content.playerModel = model
            -- The authored ring stays above the model, sharing its parent fade.
            local overlay = CreateFrame("Frame", nil, content.portraitArtwork)
            overlay:SetAllPoints(content.portraitArtwork)
            overlay:SetFrameLevel(model:GetFrameLevel() + 1)
            content.classRingGraphic:SetParent(overlay)
            content.modelBacking = content.portraitArtwork:CreateTexture(nil, "ARTWORK", nil, 2)
            content.modelBacking:SetSize(ModelPortraitDiameter(), ModelPortraitDiameter())
            content.modelBacking:SetPoint("CENTER", content.portraitAnchor, "CENTER")
            content.modelBacking:SetColorTexture(0.025, 0.025, 0.03, 1)
            local mask = content.portraitArtwork:CreateMaskTexture()
            mask:SetAllPoints(content.modelBacking)
            mask:SetTexture(CIRCLE_MASK, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
            content.modelBacking:AddMaskTexture(mask)
            CreateModelMask()

        end
        content.classIcon:Hide()
        content.classRing:Show()
        content.playerModel:SetAlpha(portraitPreparing and 0 or content.portraitArtwork:GetAlpha())
        content.playerModel:SetShown(not portraitPreparing and content.portraitArtwork:IsShown())
        content.modelBacking:Show()
        ns.RefreshPortraitRing()
        return
    end
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
    render.portraitGlintRadius = .5
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
        -- Metal artwork has transparent padding; follow the visible ring rather
        -- than the outer texture bounds. Match the actual applied reference.
        for _, ring in pairs(ns.PORTRAIT_RING_TEXTURES or {}) do
            if ring.texture == reference then
                render.portraitGlintRadius = ring.glintRadius or .5
                break
            end
        end
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
content.levelText:SetPoint("TOP", content.portraitAnchor, "BOTTOM", 0, -render.PortraitLevelGap())
content.levelText.glowUseIntrinsicSize = true
RegisterGlowFont(content.levelText)

content.statsHeader = NewText(content, "GameFontNormalLarge", 2)
content.statsHeader:SetPoint("TOP", content.levelText, "BOTTOM", 0, -22)
ApplyToTextLayers(content.statsHeader, "SetText", ns.L(content.statPage == "secondary" and "Secondary Stats" or "Stats Gained"))
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
    divider.texture:SetVertexColor(color[1], color[2], color[3], ns.db and ns.db.useClassColors and .7 or 1)
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

content.spellsHeader = NewText(content, "GameFontNormalLarge", 2)
ApplyToTextLayers(content.spellsHeader, "SetText", ns.L("Abilities"))
RegisterGlowFont(content.spellsHeader)

content.levelTimeText = NewText(content, "GameFontHighlightSmall", 1.5)
content.levelTimeText.glowAlpha = 0.08
for _, glow in ipairs(content.levelTimeText.glows) do glow:SetAlpha(content.levelTimeText.glowAlpha) end
content.levelTimeText:SetWidth(TEXT_WIDTH)
content.levelTimeText:SetHeight(18)
ApplyToTextLayers(content.levelTimeText, "SetJustifyH", "CENTER")
ApplyToTextLayers(content.levelTimeText, "SetJustifyV", "BOTTOM")
ApplyToTextLayers(content.levelTimeText, "SetTextColor", 0.25, 1.0, 0.25)
RegisterGlowFont(content.levelTimeText)
content.levelTimeBaseFontSize = select(2, content.levelTimeText:GetFont())
ApplyToTextLayers(content.levelTimeText, "SetShown", false)

function render.LevelTimeFontSize()
    return (content.levelTimeBaseFontSize + (IsHorizontalLayout() and 2 or 1)) * ns.GetTextScale("timeTextScale")
end

function render.MeasureLevelTime()
    local horizontal = IsHorizontalLayout()
    local size = render.LevelTimeFontSize()
    local path = ns.db and ns.db.customFontPath or DEFAULT_FONT_PATH
    if type(path) ~= "string" or path == "" then path = DEFAULT_FONT_PATH end
    local text = content.levelTimeText:GetText() or ""
    local key = path .. ":" .. size .. ":" .. TEXT_WIDTH .. ":" .. text
    if content.levelTimeMetricKey ~= key then
        ApplyToTextLayers(content.levelTimeText, "SetFont", path, size, "")
        ApplyToTextLayers(content.levelTimeText, "SetWidth", TEXT_WIDTH)
        ApplyToTextLayers(content.levelTimeText, "SetWordWrap", true)
        ApplyToTextLayers(content.levelTimeText, "SetHeight", 0)
        local lines = text:find("\n", 1, true) and 2 or 1
        content.levelTimeNaturalHeight = math.max((size + 4) * lines, content.levelTimeText:GetStringHeight() or 0)
        content.levelTimeMetricKey = key
    end
    ApplyToTextLayers(content.levelTimeText, "SetJustifyV", horizontal and "BOTTOM" or "MIDDLE")
    ApplyToTextLayers(content.levelTimeText, "SetHeight", (content.levelTimeNaturalHeight or 18) + (content.paceRowExtra or 0))
end

local ABILITY_ICON_SIZE = 40
local function NewAbilityIconSize()
    return ns.GetCurrentFlavor() == "retail" and 48 or ABILITY_ICON_SIZE * 1.05
end
local ABILITY_COST_HEIGHT = 14
local ABILITY_COST_GAP = 1
local ABILITY_COST_TOP_PADDING = 0

function render.AbilitySectionPadding()
    return math.min(6, SectionGap())
end

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

function render.FormatLevelClock(seconds)
    seconds = math.max(0, math.floor(tonumber(seconds) or 0))
    return string.format("%02d:%02d", math.floor(seconds / 60), seconds % 60)
end

function render.FormatPaceTime(seconds)
    seconds = math.floor(seconds)
    local hours, minutes, remaining = math.floor(seconds / 3600), math.floor(seconds % 3600 / 60), seconds % 60
    if hours > 0 then return ns.L("%dh %02dm %02ds", hours, minutes, remaining) end
    if minutes > 0 then return ns.L("%dm %02ds", minutes, remaining) end
    return ns.L("%ds", remaining)
end

local function AbilityCellHeight(iconSize)
    iconSize = iconSize or ABILITY_ICON_SIZE
    if ns.db and ns.db.showTrainerCosts then
        if IsHorizontalLayout() then return iconSize + ABILITY_COST_GAP + ABILITY_COST_HEIGHT end
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
    slider:EnableMouse(true)
    slider:SetHitRectInsets(-5, -5, -4, -4)
    slider:SetFrameLevel(content:GetFrameLevel() + 12)
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
        if viewport.verticalLayout then
            if viewport.sharedScroll then
                for _, target in ipairs({content.abilityViewport, content.petAbilityViewport}) do
                    target:SetVerticalScroll(math.min(value or 0, target.scrollMaximum or 0))
                end
            else
                viewport:SetVerticalScroll(value or 0)
            end
        else
            viewport:SetHorizontalScroll(value or 0)
        end
    end)
    slider:SetObeyStepOnDrag(false)
    viewport:EnableMouseWheel(true)
    local function ScrollWithWheel(_, delta)
        local controller = viewport.scrollController or slider
        local maximum = viewport.scrollController and content.abilityViewport.sharedMaximum or viewport.scrollMaximum or 0
        if maximum <= 0 then return end
        local value = controller:GetValue() - delta * (viewport.scrollStep or 40)
        controller:SetValue(math.max(0, math.min(maximum, value)))
    end
    viewport:SetScript("OnMouseWheel", ScrollWithWheel)
    slider:EnableMouseWheel(true)
    slider:SetScript("OnMouseWheel", ScrollWithWheel)
    slider:Hide()
    viewport.slider = slider
    viewport.scrollTrack:Hide()

    local row = CreateFrame("Frame", nil, viewport)
    row:SetSize(TEXT_WIDTH, ABILITY_ICON_SIZE)
    row:SetPoint("TOPLEFT", viewport, "TOPLEFT", 0, 0)
    viewport:SetScrollChild(row)
    viewport.row = row
    row.viewport = viewport
    row:EnableMouseWheel(true)
    row:SetScript("OnMouseWheel", ScrollWithWheel)
    viewport:Hide()
    return viewport, row
end

content.abilityViewport, content.abilityRow = CreateAbilityViewport()
content.abilityIconPool = {}
content.currentTrainerAbilities = {}

content.petSpellsHeader = NewText(content, "GameFontNormalLarge", 2)
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

function render.RefreshAbilityHeader()
    ApplyToTextLayers(content.spellsHeader, "SetText", ns.L("Abilities"))
end

-- These headings are created before SavedVariables load. Core refreshes them
-- after selecting the saved language, before any level-up can be displayed.
function ns.RefreshLocalizedPopupText()
    if content.currentReachedLevel then
        ApplyToTextLayers(content.levelText, "SetText", content.levelRangeStart
            and ns.L("Level %d - %d", content.levelRangeStart, content.currentReachedLevel)
            or ns.L("Level %d", content.currentReachedLevel))
    end
    ApplyToTextLayers(content.statsHeader, "SetText", ns.L(content.statPage == "secondary" and "Secondary Stats" or "Stats Gained"))
    render.RefreshAbilityHeader()
    ApplyToTextLayers(content.petSpellsHeader, "SetText", ns.L("Warlock Grimoires"))
    ApplyToTextLayers(content.noAbilitiesText, "SetText", ns.L("No unlearned skills available"))
end

-- Match the right column edge to the portrait/level column's visible left edge.
function render.HorizontalEndPadding()
    local mode = ns.db and ns.db.portraitMode
    local x = IsPlayerPortrait() and tonumber(ns.db.playerPortraitPosition and ns.db.playerPortraitPosition.x) or 0
    local centre = 24 + PortraitColumnWidth() / 2 + (x or 0)
    local left = centre - content.levelText:GetStringWidth() / 2
    if mode ~= "none" then
        left = math.min(left, centre - PortraitRingSize() / 2)
        if ns.db and ns.db.portraitRingEnabled then
            local offsetX = PortraitRingOffset()
            left = math.min(left, centre + offsetX - PortraitRingSize() * PortraitRingScale() / 2)
        end
    end
    return math.max(0, left)
end

function render.HorizontalTrailingWidth()
    -- Without Grimoires the shared scrollbar sits beyond the last column.
    return HorizontalColumnCount() == 2 and (content.abilityViewport.scrollMaximum or 0) > 0
        and (10 + SCROLLBAR_HEIGHT / 2) or 0
end

local MeasureStatContentWidth
local FitStatFont
local function ApplyPopupWidth()
    local compact = IsCompactLayout()
    local gap = compact and 6 or 10
    local textWidth = compact
        and (COMPACT_MAX_SKILLS * NewAbilityIconSize() + (COMPACT_MAX_SKILLS - 1) * gap)
        or DEFAULT_TEXT_WIDTH
    if compact and ns.db and ns.db.emphasizeStatGains then textWidth = textWidth + 40 end
    local horizontal = IsHorizontalLayout()
    local fontChanged
    if not horizontal and FitStatFont then fontChanged = FitStatFont(textWidth, compact) end
    if not compact then
        textWidth = math.max(textWidth, MeasureStatContentWidth and MeasureStatContentWidth() or 0)
    end
    if horizontal then
        textWidth = math.max(420, compact and textWidth or (MeasureStatContentWidth and MeasureStatContentWidth() or 0))
        local scale = ns.GetPopupScale()
        local columnCount = HorizontalColumnCount()
        local trainingWidth = columnCount == 1 and 0 or TrainingWidth(content.abilityViewport)
        if columnCount == 3 then trainingWidth = trainingWidth + TrainingWidth(content.petAbilityViewport) + 28 end
        local available = UIParent:GetWidth() / scale - PortraitColumnWidth() - trainingWidth - 88 - render.HorizontalEndPadding() - render.HorizontalTrailingWidth()
        textWidth = math.max(160, math.min(textWidth, available))
        if FitStatFont then fontChanged = FitStatFont(textWidth, true) or fontChanged end
    end
    if not horizontal then
        local available = math.max(160, UIParent:GetWidth() / ns.GetPopupScale() - 60)
        if textWidth > available then
            textWidth = available
            if FitStatFont then fontChanged = FitStatFont(textWidth, true) or fontChanged end
        end
    end
    local columnCount = HorizontalColumnCount()
    local trainingWidth = columnCount == 1 and 0 or TrainingWidth(content.abilityViewport)
    if columnCount == 3 then trainingWidth = trainingWidth + TrainingWidth(content.petAbilityViewport) + 28 end
    local sidePadding = 30
    -- Balance both ends without moving the existing column anchors.
    local frameWidth = (horizontal and (PortraitColumnWidth() + textWidth + trainingWidth + 60 + render.HorizontalEndPadding() + render.HorizontalTrailingWidth())
        or (textWidth + sidePadding * 2))
    if TEXT_WIDTH == textWidth and FRAME_WIDTH == frameWidth then
        if fontChanged and ns.RefreshStatTextLayout then ns.RefreshStatTextLayout() end
        return
    end
    TEXT_WIDTH = textWidth
    FRAME_WIDTH = frameWidth
    frame:SetWidth(FRAME_WIDTH)
    content.statsContainer:SetWidth(TEXT_WIDTH)
    render.MeasureLevelTime()
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
        local width = horizontal and (viewport.horizontalWidth or TEXT_WIDTH) or TEXT_WIDTH
        viewport:SetWidth(width)
        viewport.row:SetWidth(width)
    end
    if ns.RefreshStatTextLayout then ns.RefreshStatTextLayout() end
end

local function AnchorBelow(frame, anchor, gap)
    frame:ClearAllPoints()
    frame:SetPoint("TOP", anchor, "BOTTOM", 0, -gap)
end

function render.FitSectionHeadings()
    local scale = ns.GetTextScale("headingTextScale")
    if scale == 1 then return end
    local horizontal = IsHorizontalLayout()
    local specs = {{content.statsHeader, TEXT_WIDTH}}
    if ns.GetCurrentFlavor() ~= "retail" or #(content.currentTrainerAbilities or {}) > 0 then
        specs[#specs + 1] = {content.spellsHeader, horizontal and TrainingWidth(content.abilityViewport) or TEXT_WIDTH}
    end
    if ns.GetCurrentFlavor() ~= "retail" and #(content.currentWarlockPetAbilities or {}) > 0 then
        specs[#specs + 1] = {content.petSpellsHeader, horizontal and TrainingWidth(content.petAbilityViewport) or TEXT_WIDTH}
    end
    local parts = {tostring(scale)}
    for _, spec in ipairs(specs) do
        local path, _, flags = spec[1]:GetFont()
        parts[#parts + 1] = table.concat({path or DEFAULT_FONT_PATH, flags or "", spec[1]:GetText(), tostring(spec[2])}, "\031")
    end
    local key = table.concat(parts, "\030")
    if render.headingFitKey == key then return end
    local fit = 1
    for _, spec in ipairs(specs) do
        local text, width = spec[1], spec[2]
        local path, _, flags = text:GetFont()
        local naturalWidth = render.MeasureTextWidth(path, text.gluFontBaseSize * scale, flags, text:GetText())
        fit = math.min(fit, math.max(1, width - 8) / math.max(1, naturalWidth))
    end
    -- One fit factor keeps all section headings the same size.
    for _, text in ipairs({content.statsHeader, content.spellsHeader, content.petSpellsHeader}) do
        local path, _, flags = text:GetFont()
        ApplyToTextLayers(text, "SetFont", path or DEFAULT_FONT_PATH, math.max(1, text.gluFontBaseSize * scale * fit), flags or "")
        SyncTextGeometry(text)
    end
    render.headingFitKey = key
end

local function PositionSections()
    render.FitSectionHeadings()
    local current = content.statsContainer
    local gap = SectionGap()
    content.statsHeader:ClearAllPoints()
    if IsHorizontalLayout() then
        local statsX = 24 + PortraitColumnWidth() + 18 + TEXT_WIDTH / 2
        content.statsHeader:SetPoint("TOP", content, "TOPLEFT", statsX, -24)
    else
        content.statsHeader:SetPoint("TOP", content.levelText, "BOTTOM", 0, -22)
    end
    AnchorBelow(content.statsHeaderDivider, content.statsHeader, gap)
    local topGap = IsHorizontalLayout() and 8 / math.max(.001, content:GetScale()) or gap
    AnchorBelow(content.statsContainer, content.statsHeaderDivider, topGap)
    AnchorBelow(content.statsBottomDivider, current, gap)
    content.statsBottomDivider:SetShown(not IsHorizontalLayout())
    current = IsHorizontalLayout() and content.statsContainer or content.statsBottomDivider

    if content.levelTimeText:IsShown() then
        if IsHorizontalLayout() then
            -- Section refreshes must preserve the footer anchor too.
            content.levelTimeText:ClearAllPoints()
            content.levelTimeText:SetPoint("BOTTOM", content, "BOTTOMLEFT",
                24 + PortraitColumnWidth() + 18 + TEXT_WIDTH / 2, 26 / math.max(.001, content:GetScale()))
        else
            AnchorBelow(content.levelTimeText, current, gap + 2)
        end
        if IsHorizontalLayout() then
            content.timeBottomDivider:Hide()
            current = content.levelTimeText
        else
            AnchorBelow(content.timeBottomDivider, content.levelTimeText, gap)
            content.timeBottomDivider:Show()
            current = content.timeBottomDivider
        end
    else
        content.levelTimeText:ClearAllPoints()
        content.timeBottomDivider:Hide()
    end

    local showAbilities = ns.GetCurrentFlavor() ~= "retail" or #(content.currentTrainerAbilities or {}) > 0
    ApplyToTextLayers(content.spellsHeader, "SetShown", showAbilities)
    content.abilitiesDivider:SetShown(showAbilities)
    content.abilityViewport:SetShown(showAbilities)
    if showAbilities then
        if IsHorizontalLayout() then
            content.spellsHeader:ClearAllPoints()
            content.spellsHeader:SetPoint("TOP", content, "TOPLEFT", 24 + PortraitColumnWidth() + 36 + TEXT_WIDTH + TrainingWidth(content.abilityViewport) / 2, -24)
        else
            AnchorBelow(content.spellsHeader, current, gap)
        end
        AnchorBelow(content.abilitiesDivider, content.spellsHeader, gap)
        AnchorBelow(content.abilityViewport, content.abilitiesDivider, IsHorizontalLayout() and topGap or render.AbilitySectionPadding())
        current = content.abilityViewport
    end

    if content.petSpellsHeader:IsShown() then
        content.petDivider:Show()
        content.petHeaderDivider:Show()
        if IsHorizontalLayout() then
            content.petDivider:Hide()
            content.petSpellsHeader:ClearAllPoints()
            content.petSpellsHeader:SetPoint("TOP", content, "TOPLEFT", 24 + PortraitColumnWidth() + 36 + TEXT_WIDTH + TrainingWidth(content.abilityViewport) + 28 + TrainingWidth(content.petAbilityViewport) / 2, -24)
        else
            AnchorBelow(content.petDivider, current, gap)
            AnchorBelow(content.petSpellsHeader, content.petDivider, gap)
        end
        AnchorBelow(content.petHeaderDivider, content.petSpellsHeader, gap)
        AnchorBelow(content.petAbilityViewport, content.petHeaderDivider, IsHorizontalLayout() and topGap or render.AbilitySectionPadding())
        content.petAbilityViewport:Show()
        if not IsHorizontalLayout() then current = content.petAbilityViewport end
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

-- Animated particles keep one anchor. Rebuild it only when the target changes;
-- positions still update each frame, without clearing the native anchor first.
function render.ParticlePoint(texture, relative, relativePoint, x, y)
    if texture.gluPointTarget ~= relative or texture.gluPointName ~= relativePoint then
        texture:ClearAllPoints()
        texture.gluPointTarget, texture.gluPointName = relative, relativePoint
        texture.gluPointX, texture.gluPointY = nil, nil
    end
    if texture.gluPointX ~= x or texture.gluPointY ~= y then
        texture:SetPoint("CENTER", relative, relativePoint, x, y)
        texture.gluPointX, texture.gluPointY = x, y
    end
end

-- Particle dimensions are owned by this renderer. Cache logical sizes in Lua
-- instead of querying two native dimensions for every moving texture/frame.
-- General layout regions keep render.Size, since other code can resize them.
function render.ParticleSize(texture, width, height)
    if texture.gluParticleWidth ~= width or texture.gluParticleHeight ~= height then
        texture:SetSize(width, height)
        texture.gluParticleWidth, texture.gluParticleHeight = width, height
    end
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
        render.Alpha(fs, fs.wordLayoutActive and 0 or 1)
        for _, glow in ipairs(fs.glows) do render.Alpha(glow, CurrentShadowAlpha(fs)) end
    else
        render.Alpha(fs, alpha)
        for _, glow in ipairs(fs.glows) do render.Alpha(glow, alpha * CurrentShadowAlpha(fs)) end
    end
end

local function EntranceAlpha(stage, age, moving)
    if not moving or not stage then return 1 end
    local duration = math.max(0.001, stage.finish - stage.start)
    local t = math.max(0, math.min(1, (age - stage.start) / duration))
    if render.closing then
        -- All stages reverse together, preserving any partially completed entrance.
        local closing = render.closing
        t = math.max(0, math.min(1, (closing.startAge - stage.start) / duration))
        if stage == entranceTimeline.abilities or stage == entranceTimeline.petAbilities then
            duration = BASE_STAT_SLIDE_DURATION / closing.speed
        end
        t = math.max(0, t - closing.age / duration)
    end
    return 1 - (1 - t) ^ 2
end

local function UpdateDividerEntrance(divider, stage, age, moving, fullWidth, isAccent)
    local texture = isAccent and divider or divider.texture
    local alpha = EntranceAlpha(stage, age, moving)
    local reveal = 1
    if ns.db and moving and stage and (isAccent and ns.db.backgroundMode == "MODERN"
        or ns.db.backgroundAnimations ~= false and not ns.db.reducedMotion and ns.db.dividerReveal) then
        -- Let the full-opacity centre expand slowly enough to read as motion.
        local duration = .60 / (render.closing and render.closing.speed or Speed())
        local t = math.max(0, math.min(1, (age - stage.start) / duration))
        if render.closing then
            t = math.max(0, math.min(1, (render.closing.startAge - stage.start) / duration) - render.closing.age / duration)
        end
        reveal = t * t * (3 - 2 * t)
        alpha = math.min(1, t * 6)
    end
    render.Alpha(divider, alpha)
    local width = math.max(0.001, (fullWidth or TEXT_WIDTH) * reveal)
    if texture:GetWidth() ~= width then texture:SetWidth(width) end
    if divider.lastReveal ~= reveal then
        texture:SetTexCoord((1 - reveal) / 2, (1 + reveal) / 2, 0, 1)
        divider.lastReveal = reveal
    end
    render.Shown(texture, reveal > 0)
    return reveal
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
    if IsHorizontalLayout() then
        render.Alpha(content.abilityViewport.slider, EntranceAlpha(plan.abilities, age, moving))
        render.Alpha(content.abilityViewport.scrollTrack, EntranceAlpha(plan.abilities, age, moving))
    end
    UpdateDividerEntrance(content.statsHeaderDivider, plan.statsHeader, age, moving)
    UpdateDividerEntrance(content.statsBottomDivider, plan.statsBottom, age, moving)
    UpdateDividerEntrance(content.timeBottomDivider, plan.levelTime, age, moving)
    UpdateDividerEntrance(content.abilitiesDivider, plan.abilitiesHeader, age, moving, IsHorizontalLayout() and TrainingWidth(content.abilityViewport) or nil)
    UpdateDividerEntrance(content.petDivider, plan.petHeader, age, moving)
    UpdateDividerEntrance(content.petHeaderDivider, plan.petHeader, age, moving, IsHorizontalLayout() and TrainingWidth(content.petAbilityViewport) or nil)
    UpdateDividerEntrance(content.weaponDivider, plan.weapon, age, moving)
    if ns.db and ns.db.backgroundMode == "MODERN" then
        for i, line in ipairs(bg.modernAccents) do
            local reveal = UpdateDividerEntrance(line, plan.background, age, moving, FRAME_WIDTH * 0.94, true)
            if i == 1 then
                render.Size(bg.modern, math.max(0.001, ModernBackdropWidth(FRAME_WIDTH) * reveal), frame:GetHeight() + (IsHorizontalLayout() and 0 or UI_METRICS.modernVerticalFadeTail))
                bg.modern:SetTexCoord((1 - reveal) / 2, (1 + reveal) / 2, 0, 1)
            end
        end
    end
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
    local perf = ns.PerfStart("stat_animation_frame")
    for fs, motion in pairs(activeLineAnims) do
        motion.age = motion.age + elapsed
        local t = math.max(0, math.min(1, (motion.age - motion.delay) / motion.duration))
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
    ns.PerfEnd(perf)
end

local function StartLineAnimation(fs, container, startX, y, delay, duration, timingScale)
    StopLineAnimation(fs)
    timingScale = timingScale or 1
    fs.slideFrame:SetWidth(TEXT_WIDTH)
    fs.slideFrame:ClearAllPoints()
    fs.countFinishAt = fs.statData and fs.statData.new ~= fs.statData.old
        and ns.db and ns.db.emphasizeStatGains and not ns.db.reducedMotion
        and delay + timingScale / Speed() or nil
    fs.displayGain = fs.statData and (ns.db and ns.db.emphasizeStatGains and not ns.db.reducedMotion and 0 or fs.statData.new - fs.statData.old) or nil
    ApplyStatLineText(fs)
    fs.slideFrame:SetPoint("TOP", container, "TOP", startX, y)
    SetLineAlpha(fs, 0)
    fs.entranceMotion = { container = container, startX = startX, y = y, delay = delay, duration = duration }
    activeLineAnims[fs] = {
        container = container, startX = startX, y = y,
        delay = delay, duration = duration, age = 0, lastX = startX,
        countDuration = timingScale / Speed(),
    }
    statSlideDriver:SetScript("OnUpdate", UpdateStatSlides)
    SetLineShown(fs, true)
end

-- Unused pooled rows must release their data as well as hiding the label.
-- Otherwise a later style refresh can show their separate gain suffix again.
local function ReleaseStatLine(fs)
    StopLineAnimation(fs)
    fs.statData, fs.plainText, fs.displayGain, fs.gainFlash = nil, nil, nil, 0
    fs.entranceEnd, fs.countFinishAt = nil, nil
    if fs.statTextCache then fs.statTextCache.name, fs.statTextCache.plain = nil, nil end
    SetLineShown(fs, false)
    fs.slideFrame:Hide()
    if fs.gainCounter then ApplyToTextLayers(fs.gainCounter, "Hide") end
    for _, word in ipairs(fs.statWords or {}) do ApplyToTextLayers(word, "Hide") end
end

local function GetStatLine(index)
    local pool = content.statLinePool
    if pool[index] then return pool[index] end

    local fontPath = ns.db and ns.db.customFontPath
    if type(fontPath) ~= "string" or fontPath == "" then fontPath = DEFAULT_FONT_PATH end
    local holder = CreateFrame("Frame", nil, content.statsContainer)
    holder.modernShade = holder:CreateTexture(nil, "BACKGROUND")
    holder.modernShade:SetAllPoints(holder)
    holder.modernShade:SetTexture("Interface\\AddOns\\GnomeLevelUp\\Textures\\modern-row.tga")
    holder.modernShade:SetVertexColor(0.24, 0.21, 0.16, 0.42)
    holder:SetSize(TEXT_WIDTH, STAT_LINE_HEIGHT)
    local fs = NewText(holder, "GameFontHighlight", 2)
    fs.slideFrame = holder
    fs.gluStatText = true
    fs:SetPoint("TOP", holder, "TOP")
    fs:SetWidth(TEXT_WIDTH)
    ApplyToTextLayers(fs, "SetJustifyH", "CENTER")
    ApplyToTextLayers(fs, "SetWordWrap", false)
    RegisterGlowFont(fs, 20, "")
    ApplyToTextLayers(fs, "SetFont", fontPath, 20 * ns.GetTextScale("statTextScale"), "")
    if not ns.db or ns.db.showTextShadow ~= false then EnsureGlowLayers(fs) end
    local counter = NewText(holder, "GameFontHighlight", 2)
    counter.slideFrame = holder
    counter.gluStatText = true
    counter:SetJustifyH("LEFT")
    counter:SetJustifyV("MIDDLE")
    counter:SetWordWrap(false)
    counter:SetHeight(STAT_LINE_HEIGHT)
    RegisterGlowFont(counter, 20, "")
    ApplyToTextLayers(counter, "SetFont", fontPath, 20 * ns.GetTextScale("statTextScale"), "")
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
    icon.entranceMotion = { delay = delay, duration = duration, skip = skipAnimation }
    activeIconAnims[icon] = nil
    if icon.animationGroup then icon.animationGroup:Stop() end
    icon.animationContainer, icon.animationX, icon.animationY = container, x, y
    if skipAnimation then
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
    btn:EnableMouseWheel(true)
    btn:SetScript("OnMouseWheel", function(_, delta)
        local viewport = row.viewport
        local scroll = viewport:GetScript("OnMouseWheel")
        if scroll then scroll(viewport, delta) end
    end)

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
    btn.cornerSparkles = {}
    btn.ambientSparkle = NewSparkTexture(btn)

    btn:SetScript("OnEnter", function(self)
        if frame.closingInputSuppressed then return end
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
    local newIconSize = NewAbilityIconSize()
    local count = #abilities
    row.viewport.abilityCount = count
    local speed = Speed()
    local staggerBase = BASE_STAT_STAGGER_BASE / speed
    local staggerStep = BASE_STAT_STAGGER_STEP / speed
    local popDuration = BASE_STAT_SLIDE_DURATION / speed
    local vertical = IsHorizontalLayout()
    local controller = row.viewport.scrollController or row.viewport.slider
    local previousValue = skipAnimation and row.viewport.verticalLayout == vertical and controller:GetValue() or 0
    row.viewport.requestedScroll = previousValue
    row.viewport.cellHeight = AbilityCellHeight(NewAbilityIconSize())
    row.viewport.layoutScale = 1
    row.viewport.sharedScroll, row.viewport.scrollController = nil, nil
    row.viewport.slider:SetParent(row.viewport)
    row.viewport.scrollTrack:SetParent(row.viewport)
    render.Alpha(row.viewport.slider, 1)
    render.Alpha(row.viewport.scrollTrack, 1)
    row.viewport:SetScale(1)
    row.viewport.verticalLayout = vertical
    row.viewport.scrollMaximum = 0
    row.viewport:SetHorizontalScroll(0)
    row.viewport:SetVerticalScroll(0)

    if count == 0 then
        local emptyWidth = showEmptyText and (NewAbilityIconSize() * 3 + AbilityIconGap() * 2 + 16) or 120
        row.viewport.horizontalWidth = emptyWidth
        row.viewport:SetWidth(vertical and emptyWidth or TEXT_WIDTH)
        row:SetWidth(vertical and emptyWidth or TEXT_WIDTH)
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
        local iconSize = spell.isNewAbility == true and newIconSize or ABILITY_ICON_SIZE
        icon:SetSize(iconSize, iconSize)
        icon.newAbilityGlow:SetSize(iconSize * 1.85, iconSize * 1.85)
        cellWidth = math.max(cellWidth, iconSize)
        rowIconSize = math.max(rowIconSize, iconSize)
        local formattedCost = ns.GetCurrentFlavor() ~= "retail" and ns.db and ns.db.showTrainerCosts and FormatTrainerCost(spell.cost)
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
    local viewportWidth = not vertical and IsCompactLayout()
        and math.min(TEXT_WIDTH, COMPACT_MAX_SKILLS * cellWidth + (COMPACT_MAX_SKILLS - 1) * gap)
        or TEXT_WIDTH
    row.viewport:SetWidth(viewportWidth)
    local horizontalGrid = vertical
    local maxColumns = vertical and (horizontalGrid and 3 or 1) or AbilityIconColumns(cellWidth)
    local shouldScroll = not vertical and UseHorizontalAbilityScroll() and count > maxColumns
    local columns = shouldScroll and count or math.min(count, maxColumns)
    local rows = shouldScroll and 1 or math.ceil(count / maxColumns)
    if horizontalGrid then
        columns = 3
        rows = math.min(count, 3) + math.ceil(math.max(0, count - 9) / 3)
    end
    local totalWidth = columns * cellWidth + (columns - 1) * gap
    local cellHeight = AbilityCellHeight(rowIconSize)
    local verticalGap = vertical and 0 or gap
    row.viewport.cellHeight = cellHeight
    local totalHeight = rows * cellHeight + (rows - 1) * verticalGap
    row.viewport.rowContentHeight = totalHeight
    local viewportHeight = totalHeight
    if vertical then
        -- Keep a fixed viewport height while additional entries scroll vertically.
        local visibleRows = 3
        viewportHeight = math.min(totalHeight, visibleRows * cellHeight + (visibleRows - 1) * verticalGap)
        shouldScroll = count >= 10 and totalHeight > viewportHeight
    end
    if vertical then
        viewportWidth = totalWidth + 16
        row.viewport.horizontalWidth = viewportWidth
        row.viewport:SetWidth(viewportWidth)
    end
    row:SetWidth(vertical and viewportWidth or (shouldScroll and totalWidth or viewportWidth))
    row:SetHeight(totalHeight)
    row:ClearAllPoints()
    row:SetPoint("TOPLEFT", row.viewport, "TOPLEFT", 0,
        not vertical and shouldScroll and -(SCROLLBAR_HEIGHT / 2) or 0)
    row.viewport:SetHeight(viewportHeight + (not vertical and shouldScroll and SCROLLBAR_HEIGHT or 0))
    local slider, track = row.viewport.slider, row.viewport.scrollTrack
    slider:ClearAllPoints()
    track:ClearAllPoints()
    slider:SetOrientation(vertical and "VERTICAL" or "HORIZONTAL")
    slider:SetValueStep(0.01)
    if vertical then
        slider:SetPoint("TOPRIGHT", row.viewport, "TOPRIGHT", -2, 0)
        slider:SetPoint("BOTTOMRIGHT", row.viewport, "BOTTOMRIGHT", -2, 0)
        slider:SetWidth(SCROLLBAR_HEIGHT)
        track:SetPoint("TOPRIGHT", row.viewport, "TOPRIGHT", -6, 0)
        track:SetPoint("BOTTOMRIGHT", row.viewport, "BOTTOMRIGHT", -6, 0)
        track:SetWidth(2)
    else
        slider:SetPoint("BOTTOMLEFT", row.viewport, "BOTTOMLEFT", 0, 0)
        slider:SetPoint("BOTTOMRIGHT", row.viewport, "BOTTOMRIGHT", 0, 0)
        slider:SetHeight(SCROLLBAR_HEIGHT)
        track:SetPoint("BOTTOMLEFT", row.viewport, "BOTTOMLEFT", 0, 0)
        track:SetPoint("BOTTOMRIGHT", row.viewport, "BOTTOMRIGHT", 0, 0)
        track:SetHeight(2)
    end
    local thumb = slider:GetThumbTexture()
    if thumb then
        if vertical then thumb:SetSize(8, math.max(20, viewportHeight * viewportHeight / totalHeight))
        else thumb:SetSize(24, 8) end
    end
    local maximum = shouldScroll and math.max(0, vertical and totalHeight - viewportHeight or totalWidth - viewportWidth) or 0
    row.viewport.scrollMaximum = maximum
    row.viewport.scrollStep = vertical and cellHeight + verticalGap or cellWidth + gap
    slider:SetMinMaxValues(0, maximum)
    local value = math.max(0, math.min(maximum, previousValue))
    slider:SetValue(value)
    -- A same-value SetValue need not emit OnValueChanged after a rebuild.
    slider:GetScript("OnValueChanged")(slider, value)
    slider:SetShown(shouldScroll)
    track:SetShown(shouldScroll)
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
        if horizontalGrid and i <= 9 then
            column = math.floor(zeroIndex / 3)
            rowIndex = zeroIndex % 3
        elseif horizontalGrid then
            column = (i - 10) % 3
            rowIndex = 3 + math.floor((i - 10) / 3)
        end
        local x = startX + column * (cellWidth + gap)
        if horizontalGrid and count <= 6 then
            local occupiedColumns = math.ceil(count / 3)
            x = x + (3 - occupiedColumns) * (cellWidth + gap) / 2
        end
        if not vertical and not shouldScroll then
            local rowColumns = math.min(columns, count - rowIndex * columns)
            x = -(rowColumns * cellWidth + (rowColumns - 1) * gap) / 2
                + cellWidth / 2 + column * (cellWidth + gap)
        end
        local iconSize = spell.isNewAbility == true and newIconSize or ABILITY_ICON_SIZE
        local visibleCellHeight = formattedCost and cellHeight or rowIconSize
        local iconY = startY + (visibleCellHeight - iconSize) / 2
            - rowIndex * (cellHeight + verticalGap)
        if formattedCost and not vertical then iconY = iconY - ABILITY_COST_TOP_PADDING end
        local delay = staggerBase + (i - 1) * staggerStep
        icon.skipEntrance = count > 9 and shouldScroll and (vertical
            and rowIndex * (cellHeight + verticalGap) >= viewportHeight
            or not vertical and column * (cellWidth + gap) >= viewportWidth)
        icon.entranceEnd = delay + popDuration
        StartIconPop(icon, row, x, iconY, delay, popDuration, skipAnimation or portraitPreparing)
    end

    for i = count + 1, #pool do
        StopIconAnimation(pool[i])
        pool[i]:Hide()
    end
end

-- Fit visible icon groups after the normal frame geometry has been finalized.
-- must never feed back into column widths, row heights or the popup's scale.
function render.FitSparseAbilityIcons(viewport, pool)
    local count = viewport.abilityCount or 0
    local vertical = IsHorizontalLayout()
    if count < 1 or count > 3 or (viewport.scrollMaximum or 0) > 0 then return end
    local gap = AbilityIconGap()
    local width, height = viewport:GetWidth(), viewport:GetHeight()
    local base = NewAbilityIconSize()
    local function IconSize(icon, size)
        return icon.isNewAbility == true and size or math.min(ABILITY_ICON_SIZE, ABILITY_ICON_SIZE * size / base)
    end
    local function Measure(size, position)
        local columns, rows = {}, {}
        for i = 1, count do
            local icon = pool[i]
            local iconSize = IconSize(icon, size)
            local column = vertical and math.floor((i - 1) / 3) + 1 or i
            local row = vertical and (i - 1) % 3 + 1 or 1
            local cellWidth = math.max(iconSize, icon.formattedCost and icon.costText:GetWidth() or 0)
            local cellHeight = iconSize + (icon.formattedCost and ABILITY_COST_GAP + ABILITY_COST_HEIGHT or 0)
            columns[column] = math.max(columns[column] or 0, cellWidth)
            rows[row] = math.max(rows[row] or 0, cellHeight)
        end
        local groupWidth, groupHeight = gap * (#columns - 1), gap * (#rows - 1)
        for _, value in ipairs(columns) do groupWidth = groupWidth + value end
        for _, value in ipairs(rows) do groupHeight = groupHeight + value end
        if position then
            for i = 1, count do
                local icon = pool[i]
                local iconSize = IconSize(icon, size)
                local column = vertical and math.floor((i - 1) / 3) + 1 or i
                local row = vertical and (i - 1) % 3 + 1 or 1
                local x, y = -groupWidth / 2 + columns[column] / 2, (vertical and viewport.row:GetHeight() or groupHeight) / 2 - iconSize / 2
                if vertical and count == 1 then
                    local lift = 18 / math.max(.001, content:GetScale() * viewport:GetScale())
                    y = math.min(lift, math.max(0, (viewport.row:GetHeight() - iconSize) / 2))
                end
                for j = 1, column - 1 do x = x + columns[j] + gap end
                for j = 1, row - 1 do y = y - rows[j] - gap end
                render.Size(icon, iconSize, iconSize)
                render.Size(icon.newAbilityGlow, iconSize * 1.85, iconSize * 1.85)
                icon.animationX, icon.animationY = x, y
                icon:ClearAllPoints()
                icon:SetPoint("CENTER", viewport.row, "CENTER", x, y - (activeIconAnims[icon] and ABILITY_POP_DISTANCE or 0))
            end
        end
        local centeredCost = vertical and count == 1 and pool[1].formattedCost and ABILITY_COST_GAP + ABILITY_COST_HEIGHT or 0
        return groupWidth + (vertical and 16 or 0), groupHeight + centeredCost
    end
    local low, high = base, base * (count <= 3 and 1.5 or 1)
    local baseWidth, baseHeight = Measure(base)
    if baseWidth > width or baseHeight > height then low = 0 end
    local capWidth, capHeight = Measure(high)
    if capWidth <= width and capHeight <= height then
        low = high
    else
        for _ = 1, 18 do
            local mid = (low + high) / 2
            local neededWidth, neededHeight = Measure(mid)
            if neededWidth <= width and neededHeight <= height then low = mid else high = mid end
        end
    end
    Measure(math.max(.1, math.floor(low * 100) / 100), true)
end

-- Fill the main ability row with the current unlearned skills.
local function UpdateTrainerAbilityIcons(trainerAbilities, skipAnimation)
    content.currentTrainerAbilities = trainerAbilities or {}
    UpdateAbilityIcons(content.abilityRow, content.abilityIconPool, content.noAbilitiesText, trainerAbilities, true, skipAnimation)
    if ns.GetCurrentFlavor() == "retail" then
        ApplyToTextLayers(content.noAbilitiesText, "Hide")
    end
    render.RefreshAbilityHeader()
end

local function UpdateWarlockPetAbilityIcons(petAbilities, skipAnimation)
    if ns.GetCurrentFlavor() == "retail" then petAbilities = {} end
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
    if ns.GetCurrentFlavor() == "retail" then unlearnedWeaponSkills = {} end
    content.currentWeaponSkills = unlearnedWeaponSkills or {}
    local enabled = ns.db and ns.db.showWeaponSkills ~= false and not IsHorizontalLayout()
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

-- Cache unconstrained glyph widths, not fitted boxes. The font tuple and locale
-- invalidate measurements naturally; changing column width still reruns fitting.
-- Bounding the cache prevents previews/counters from retaining unlimited strings.
function render.MeasureTextWidth(fontPath, fontSize, fontFlags, text)
    fontPath, fontFlags, text = fontPath or DEFAULT_FONT_PATH, fontFlags or "", text or ""
    local locale = ns.GetLocale()
    local cache = render.textMeasurements
    if not cache or cache.locale ~= locale then
        cache = { locale = locale, count = 0, widths = {} }
        render.textMeasurements = cache
    end
    local key = table.concat({fontPath, tostring(fontSize), fontFlags, text}, "\031")
    local cached = cache.widths[key]
    if cached then return cached end
    if not render.textMeasureFont then
        -- This region must remain measurable while the popup is hidden.
        local measure = UIParent:CreateFontString(nil, "ARTWORK")
        measure:SetAlpha(0)
        measure:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", 0, -64)
        measure:SetWordWrap(false)
        measure:Show()
        render.textMeasureFont = measure
    end
    local measure = render.textMeasureFont
    measure:SetFont(fontPath, fontSize, fontFlags)
    measure:SetWidth(0)
    measure:SetHeight(0)
    measure:SetText(text)
    local width = measure:GetStringWidth() or 0
    if cache.count >= UI_METRICS.textMeasurementLimit then cache.widths, cache.count = {}, 0 end
    cache.widths[key], cache.count = width, cache.count + 1
    return width
end

local function MeasureStatText(textRegion, text)
    local fontPath, fontSize, fontFlags = textRegion:GetFont()
    return render.MeasureTextWidth(fontPath, fontSize, fontFlags, text)
end

local function GainCounterWidth(fs, target, stat)
    local path, size, flags = fs:GetFont()
    local digits = #ns.FormatStatInteger(math.abs(target))
    if fs.gainWidthPath ~= path or fs.gainWidthSize ~= size or fs.gainWidthFlags ~= flags or fs.gainWidthDigits ~= digits or fs.gainWidthUnit ~= (stat and stat.unit) then
        local width = 0
        for digit = 0, 9 do
            local number = string.rep(tostring(digit), digits)
            width = math.max(width, MeasureStatText(fs, ns.FormatStatGain(tonumber(number), stat)), MeasureStatText(fs, ns.FormatStatGain(-tonumber(number), stat)))
        end
        -- Native FontStrings can ellipsize a box sized exactly to glyph
        -- advances. Leave room for rounding, kerning and the glow outline.
        fs.gainWidthPath, fs.gainWidthSize, fs.gainWidthFlags, fs.gainWidthDigits = path, size, flags, digits
        fs.gainWidthUnit = stat and stat.unit
        fs.gainReservedWidth = math.ceil(width) + 12
    end
    return fs.gainReservedWidth
end

function render.StatWordMetrics(fs, data)
    local path, size, flags = fs:GetFont()
    local counting = ns.db and ns.db.emphasizeStatGains == true
    local threshold = ns.GetStatAbbreviationThreshold()
    local label = ns.GetStatDisplayLabel(data)
    local key = table.concat({tostring(path),tostring(size),tostring(flags),label,tostring(data.unit),tostring(data.old),tostring(data.new),tostring(counting),tostring(threshold),ns.GetLocale()}, "\031")
    if fs.statWordMetricKey == key then return fs.statWordWidths, fs.statWordNatural end
    local widths = {MeasureStatText(fs, label .. ":")+12, MeasureStatText(fs, ns.FormatStatTotal(data.old, data))+12,
        MeasureStatText(fs, "->")+12, MeasureStatText(fs, ns.FormatStatTotal(data.new, data)) + 12}
    if counting then
        widths[4] = math.max(widths[4], MeasureStatText(fs, ns.FormatStatTotal(data.old, data)) + 12)
        local digits = math.max(#ns.FormatStatInteger(math.abs(data.old)), #ns.FormatStatInteger(math.abs(data.new)))
        for digit = 0, 9 do
            local value = tonumber(string.rep(tostring(digit), digits)) or 0
            widths[4] = math.max(widths[4], MeasureStatText(fs, ns.FormatStatTotal(value, data)) + 12)
            if math.min(data.old,data.new) < 0 then widths[4] = math.max(widths[4],MeasureStatText(fs,ns.FormatStatTotal(-value, data))+12) end
        end
        if threshold and math.min(data.old,data.new)<threshold and math.max(data.old,data.new)>=threshold then
            widths[4] = math.max(widths[4],MeasureStatText(fs,ns.FormatStatTotal(threshold-1, data))+12)
        end
        widths[5] = GainCounterWidth(fs, data.new-data.old, data)
    end
    if counting and threshold and math.max(math.abs(data.old),math.abs(data.new)) >= 1100000
        and math.min(math.abs(data.old),math.abs(data.new)) < 1000000000 then
        local millions = math.min(999, math.max(1, math.floor(math.max(math.abs(data.old),math.abs(data.new))/1000000)))
        for digit=0,9 do
            widths[4]=math.max(widths[4],MeasureStatText(fs,ns.FormatStatTotal(millions*1000000+digit*111000, data))+12)
        end
    end
    local space = MeasureStatText(fs," ")
    local natural = space * (#widths-1)
    for _, width in ipairs(widths) do natural = natural + width end
    fs.statWordEndWidth = MeasureStatText(fs, counting and ns.FormatStatGain(data.new-data.old, data) or ns.FormatStatTotal(data.new, data))
    fs.statWordMetricKey, fs.statWordWidths, fs.statWordNatural = key, widths, natural
    fs.statWordSpace=space
    return widths, natural
end

function render.UpdateStatWordTargets(changes)
    local columns, space, endWidth = {}, 0, 0
    local function Include(fs,data)
        local widths=render.StatWordMetrics(fs,data)
        for i,width in ipairs(widths) do columns[i]=math.max(columns[i] or 0,width) end
        space=math.max(space,fs.statWordSpace or 0)
        endWidth=math.max(endWidth,fs.statWordEndWidth or 0)
    end
    if changes then
        for i,data in ipairs(changes) do
            local fs = content.statLinePool[i] or GetStatLine(i)
            Include(fs,data)
        end
    else
        for _,fs in ipairs(content.statLinePool) do
            if fs.statData then Include(fs,fs.statData) end
        end
    end
    local target=space*math.max(0,#columns-1)
    for _,width in ipairs(columns) do target=target+width end
    local trailing=math.max(0,(columns[#columns] or 0)-endWidth)
    local key=table.concat(columns,",")..":"..trailing
    for i,fs in ipairs(content.statLinePool) do
        if changes and i<=#changes or not changes and fs.statData then
            fs.statWordTarget,fs.statWordColumns,fs.statWordColumnKey,fs.statWordTrailing=target,columns,key,trailing
            fs.statTracking=0
        end
    end
end

local function StatGainColor(flash, data)
    local color = data and data.new < data.old and {1, .2, .2} or ColorOf("statNew")
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
        local r, g, b = StatGainColor(gainFlash, data)
        local gainHex = render.HexRGB(r, g, b)
        local base = string.format("%s%s: %s%s |r%s->%s %s|r",
            Hex(label),
            ns.GetStatDisplayLabel(data), ns.FormatStatTotal(data.old, data), spaces, gainHex, spaces, ns.FormatStatTotal(value, data))
        return omitGain and base or (base .. gainHex .. (ns.FormatStatGain(data.new - data.old, data) .. "|r"))
    end
    local base = string.format("%s: %s%s %s->%s %s|r",
        ns.GetStatDisplayLabel(data), ns.FormatStatTotal(data.old, data), spaces, Hex(ColorOf("statNew")), spaces, ns.FormatStatTotal(value, data))
    return base
end

-- Reserve the whole value column before counting. Left justification keeps
-- the label and old value fixed even when a proportional-font digit changes.
local function CountingBaseWidth(fs, data, tracking)
    local path, size, flags = fs:GetFont()
    local threshold = ns.GetStatAbbreviationThreshold()
    if fs.countBasePath ~= path or fs.countBaseSize ~= size or fs.countBaseFlags ~= flags
        or fs.countBaseName ~= ns.GetStatDisplayLabel(data) or fs.countBaseOld ~= data.old or fs.countBaseNew ~= data.new
        or fs.countBaseUnit ~= data.unit or fs.countBaseTracking ~= tracking or fs.countBaseThreshold ~= threshold then
        local digits = math.max(#ns.FormatStatInteger(math.abs(data.old)), #ns.FormatStatInteger(math.abs(data.new)))
        local width = 0
        for digit = 0, 9 do
            local value = tonumber(string.rep(tostring(digit), digits)) or 0
            width = math.max(width, MeasureStatText(fs, BuildStatLineText(data, tracking, nil, true, value)))
            if math.min(data.old, data.new) < 0 then
                width = math.max(width, MeasureStatText(fs, BuildStatLineText(data, tracking, nil, true, -value)))
            end
        end
        if threshold and math.min(data.old, data.new) < threshold and math.max(data.old, data.new) >= threshold then
            width = math.max(width, MeasureStatText(fs, BuildStatLineText(data, tracking, nil, true, threshold - 1)))
        end
        if threshold and math.max(math.abs(data.old),math.abs(data.new)) >= 1100000
            and math.min(math.abs(data.old),math.abs(data.new)) < 1000000000 then
            local millions = math.min(999, math.max(1, math.floor(math.max(math.abs(data.old),math.abs(data.new))/1000000)))
            for digit=0,9 do
                width=math.max(width,MeasureStatText(fs,BuildStatLineText(data,tracking,nil,true,millions*1000000+digit*111000)))
            end
        end
        fs.countBaseUnit = data.unit
        fs.countBaseThreshold = threshold
        fs.countBasePath, fs.countBaseSize, fs.countBaseFlags = path, size, flags
        fs.countBaseName, fs.countBaseOld, fs.countBaseNew = ns.GetStatDisplayLabel(data), data.old, data.new
        fs.countBaseTracking, fs.countBaseWidth = tracking, width
    end
    return fs.countBaseWidth
end

local function StatTextWidth(fs, data, tracking)
    if ns.db and ns.db.equalStatWidths then local _,width=render.StatWordMetrics(fs,data);return math.max(width,fs.statWordTarget or 0) end
    local counting = ns.db and ns.db.emphasizeStatGains
    local width = counting and CountingBaseWidth(fs, data, tracking)
        or MeasureStatText(fs, BuildStatLineText(data, tracking, nil, counting))
    return width + (counting and GainCounterWidth(fs, data.new - data.old, data) or 0)
end

-- Include the complete reserved count range and a small horizontal inset.
MeasureStatContentWidth = function()
    if ns.db and ns.db.equalStatWidths then render.UpdateStatWordTargets() end
    local width = 0
    for _, fs in ipairs(content.statLinePool) do
        if fs.statData then
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
        tostring(ns.db and ns.db.equalStatWidths), tostring(ns.GetTextScale("statTextScale")), tostring(ns.GetStatAbbreviationThreshold()), ns.GetLocale() }
    for _, fs in ipairs(content.statLinePool) do
        if fs.statData then
            local path, _, flags = fs:GetFont()
            local d = fs.statData
            parts[#parts + 1] = table.concat({ tostring(path), tostring(flags), tostring(ns.GetStatDisplayLabel(d)), tostring(d.unit), tostring(d.old), tostring(d.new), tostring(fs.statTracking) }, "\031")
        end
    end
    local key = table.concat(parts, "\030")
    if key == render.fitKey then SetSize(render.fitSize); return changed end
    -- Keep the smaller compact presentation for the whole popup so finishing
    -- a count never changes its font or frame width mid-display.
    local baseSize = (compact and ns.db and ns.db.emphasizeStatGains and 19 or 20) * ns.GetTextScale("statTextScale")
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

    render.UpdateStatWordTargets(statChanges)
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

function render.ApplyStatWords(fs, amount, counting)
    -- Keep the original row for existing timing/measurement consumers. Only
    -- these pooled word layers render; their shared parent supplies the fade.
    local d = fs.statData
    local ownWidths, natural = render.StatWordMetrics(fs,d)
    local widths=fs.statWordColumns or ownWidths
    local target = fs.statWordTarget or natural
    local key = fs.statWordMetricKey .. "\030" .. tostring(target) .. "\030" .. tostring(fs:GetWidth()) .. "\030" .. (fs.statWordColumnKey or "")
    if not fs.statWords then
        fs.statWords = {}
        for i=1,4 do
            local word = NewText(fs.slideFrame,"GameFontHighlight",2)
            word.gluStatText,word.slideFrame = true,fs.slideFrame
            word:SetWordWrap(false);word:SetJustifyH("LEFT")
            RegisterGlowFont(word,20,"")
            fs.statWords[i] = word
        end
    end
    local path,size,flags = fs:GetFont()
    local wordPath,wordSize,wordFlags = fs.statWords[1]:GetFont()
    local fontChanged = wordPath ~= path or wordSize ~= size or (wordFlags or "") ~= (flags or "")
    if fontChanged then fs.statWordLayoutKey = nil end
    if fs.statWordLayoutKey ~= key then
        local sum=0;for _,width in ipairs(widths) do sum=sum+width end
        local spacing = math.max(0,(target-sum)/(#widths-1))
        local x=(fs:GetWidth()-target+(not IsHorizontalLayout() and fs.statWordTrailing or 0))/2
        for i=1,#widths do
            local word=i==5 and fs.gainCounter or fs.statWords[i]
            -- A page can change its text/columns while keeping the same font
            -- and row height. Avoid resetting all eight glow layers needlessly.
            if fontChanged then ApplyToTextLayers(word,"SetFont",path,size,flags or "") end
            if word:GetWidth() ~= widths[i] then ApplyToTextLayers(word,"SetWidth",widths[i]) end
            local height = fs:GetHeight()
            if word:GetHeight() ~= height then ApplyToTextLayers(word,"SetHeight",height) end
            word.gluFixedStatHeight=true
            word:ClearAllPoints();word:SetPoint("TOPLEFT",fs.slideFrame,"TOPLEFT",x,0)
            x=x+widths[i]+spacing
        end
        ApplyToTextLayers(fs.gainCounter,"SetJustifyH","LEFT")
        fs.statWordLayoutKey=key
    end
    local values={ns.GetStatDisplayLabel(d)..":",ns.FormatStatTotal(d.old, d),"->",ns.FormatStatTotal(counting and d.old+amount or d.new, d)}
    local label=ActiveColor("statLabel")
    local r,g,b=StatGainColor(counting and fs.gainFlash or 0, d)
    for i,word in ipairs(fs.statWords) do
        if word.wordText~=values[i] then ApplyToTextLayers(word,"SetText",values[i]);word.wordText=values[i] end
        if ns.db.showTextShadow~=false then EnsureGlowLayers(word) end
        if not word:IsShown() then ApplyToTextLayers(word,"SetShown",true) end
        if i<3 then render.StatColor(word,label[1],label[2],label[3]) else render.StatColor(word,r,g,b) end
    end
    fs.wordLayoutActive=true
    render.Alpha(fs,0)
    for _,glow in ipairs(fs.glows) do render.Alpha(glow,0) end
end

ApplyStatLineText = function(fs)
    local d = fs.statData
    local wordMode = d and ns.db and ns.db.equalStatWidths == true
    if not wordMode and fs.wordLayoutActive then
        fs.wordLayoutActive=false;fs.statWordLayoutKey=nil
        fs.layoutWidth,fs.counterBaseWidth,fs.renderedGainText=nil,nil,nil
        render.Alpha(fs,1)
        for _,glow in ipairs(fs.glows) do render.Alpha(glow,CurrentShadowAlpha(fs)) end
        for _,word in ipairs(fs.statWords or {}) do ApplyToTextLayers(word,"Hide") end
        ApplyToTextLayers(fs.gainCounter,"SetJustifyH","LEFT")
    end
    local counting = d and ns.db and ns.db.emphasizeStatGains
    local tracking = ns.db and ns.db.equalStatWidths and fs.statTracking or 0
    local amount = d and (fs.displayGain == nil and d.new - d.old or fs.displayGain)
    local displayedValue = counting and d.old + amount or nil
    local cache = fs.statTextCache
    if not cache then cache = {}; fs.statTextCache = cache end
    local labelColor, gainColor = ColorOf("statLabel"), ColorOf("statNew")
    local name, old, new = d and ns.GetStatDisplayLabel(d), d and d.old, d and d.new
    local flash = counting and fs.gainFlash or 0
    local threshold = ns.GetStatAbbreviationThreshold()
    if fs.renderedStatText == nil or cache.name ~= name or cache.old ~= old or cache.new ~= new
        or cache.tracking ~= tracking or cache.counting ~= counting or cache.value ~= displayedValue
        or cache.flash ~= flash or cache.plain ~= fs.plainText or cache.threshold ~= threshold
        or cache.lr ~= labelColor[1] or cache.lg ~= labelColor[2] or cache.lb ~= labelColor[3]
        or cache.gr ~= gainColor[1] or cache.gg ~= gainColor[2] or cache.gb ~= gainColor[3] then
        local text = d and BuildStatLineText(d, tracking, flash, counting, displayedValue)
            or (fs.plainText or "")
        if text ~= fs.renderedStatText then
            ApplyToTextLayers(fs, "SetText", text)
            fs.renderedStatText = text
        end
        cache.name, cache.old, cache.new = name, old, new
        cache.tracking, cache.counting, cache.value = tracking, counting, displayedValue
        cache.flash, cache.plain = flash, fs.plainText
        cache.threshold = threshold
        cache.lr, cache.lg, cache.lb = labelColor[1], labelColor[2], labelColor[3]
        cache.gr, cache.gg, cache.gb = gainColor[1], gainColor[2], gainColor[3]
    end
    if fs.slideFrame and fs.slideFrame.modernShade then
        fs.slideFrame.modernShade:SetShown(ns.db and ns.db.backgroundMode == "MODERN")
    end
    local label = ActiveColor("statLabel")
    render.StatColor(fs, label[1], label[2], label[3])
    local path, size, flags = fs:GetFont()
    local geometryChanged = fs.layoutName ~= (d and ns.GetStatDisplayLabel(d)) or fs.layoutOld ~= (d and d.old)
        or fs.layoutNew ~= (d and d.new) or fs.layoutTracking ~= tracking or fs.layoutCounting ~= counting
        or fs.layoutPath ~= path or fs.layoutSize ~= size or fs.layoutFlags ~= flags
        or fs.layoutWidth ~= fs:GetWidth() or fs.layoutThreshold ~= threshold
    local offset = fs.statTextOffset or 0
    if fs.countingLayout ~= (counting == true) then
        ApplyToTextLayers(fs, "SetJustifyH", counting and "LEFT" or "CENTER")
        fs.countingLayout = counting == true
    end
    if counting then
        local target = d.new - d.old
        if geometryChanged then
          local width = GainCounterWidth(fs, target, d)
          local baseWidth = CountingBaseWidth(fs, d, tracking)
          offset = (fs:GetWidth() - baseWidth - (IsHorizontalLayout() and width or MeasureStatText(fs, ns.FormatStatGain(target, d)))) / 2
          if fs.counterBaseWidth ~= baseWidth or fs.counterWidth ~= width then
            fs.gainCounter:ClearAllPoints()
            fs.gainCounter:SetPoint("LEFT", fs, "LEFT", baseWidth, 0)
            ApplyToTextLayers(fs.gainCounter, "SetWidth", width)
            fs.counterBaseWidth, fs.counterWidth = baseWidth, width
          end
        end
        if fs.renderedGainText == nil or fs.renderedGainAmount ~= amount then
            local counterText = ns.FormatStatGain(amount, d)
            if counterText ~= fs.renderedGainText then
                ApplyToTextLayers(fs.gainCounter, "SetText", counterText)
                fs.renderedGainText = counterText
            end
            fs.renderedGainAmount = amount
        end
        local r, g, b = StatGainColor(fs.gainFlash, d)
        render.StatColor(fs.gainCounter, r, g, b)
    end
    if not counting then offset = 0 end
    if fs.gainCounter and fs.gainCounter:IsShown() ~= (counting == true) then ApplyToTextLayers(fs.gainCounter, "SetShown", counting == true) end
    if geometryChanged then
        fs.layoutName, fs.layoutOld, fs.layoutNew = d and ns.GetStatDisplayLabel(d), d and d.old, d and d.new
        fs.layoutTracking, fs.layoutCounting = tracking, counting
        fs.layoutThreshold = threshold
        fs.layoutPath, fs.layoutSize, fs.layoutFlags, fs.layoutWidth = path, size, flags, fs:GetWidth()
        SyncTextGeometry(fs)
        if fs.gainCounter then SyncTextGeometry(fs.gainCounter) end
    end
    if fs.statTextOffset ~= offset then
        fs:ClearAllPoints()
        fs:SetPoint("TOP", fs.slideFrame, "TOP", offset, 0)
        fs.statTextOffset = offset
    end
    if wordMode then render.ApplyStatWords(fs,amount,counting) end
end

-- Repeat the overlapping count-completion flashes using the same row offsets.
-- Reuse the existing text/glow layers so no clipping bar or glyph copies appear.
local function UpdateStatHighlights(cycleTime, enabled, age)
    local count = 0
    for _, fs in ipairs(content.statLinePool) do
        local visible = fs.statData and fs:IsShown()
        local value = 0
        if visible and fs.countFinishAt and entranceTimeline.statFlashStart then
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
content.edgeLayer = CreateFrame("Frame", nil, frame)
content.edgeLayer:SetAllPoints(frame)
content.edgeLayer:SetFrameLevel(frame:GetFrameLevel() + 4)
content.edgeLayer:SetAlpha(0.30)
function render.EnsureEdgeGlows()
    if #content.edgeGlows > 0 then return end
    for _, side in ipairs({ "LEFT", "RIGHT", "TOP", "BOTTOM" }) do
        for layer = 1, 3 do
            local texture = NewSparkTexture(content.edgeLayer)
            texture:SetTexture("Interface\\Buttons\\WHITE8X8")
            texture.side, texture.softness = side, layer
            texture:SetPoint("CENTER", frame, side, 0, 0)
            content.edgeGlows[#content.edgeGlows + 1] = texture
        end
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
    local db = ns.db or {}
    local milestone = content.isMilestone and db.milestoneAnimations ~= false and not db.reducedMotion and db.backgroundAnimations ~= false
    local maxLevel = content.isMaxLevel and db.maxLevelCelebration ~= false and not db.reducedMotion and db.backgroundAnimations ~= false
    render.backgroundMoteSpeed = maxLevel and 2 or 1
    render.milestoneScale = milestone and 1.25 or 1
    render.milestonePortraitScale = milestone and 1.10 or 1
    render.milestoneStarburstScale = render.milestoneScale * (milestone and 0.8 or 1) * render.milestonePortraitScale
    for i, spec in ipairs(ns.PARTICLE_SETTINGS) do
        local settings = render.particleSettings[i]
        local count = ns.GetParticleValue(spec, "count")
        settings.count = milestone and math.min(spec.maxCount, math.ceil(count * (i == 1 and 3 or i == 3 and 1.5 or 2))) or count
        settings.size = ns.GetParticleValue(spec, "size") / 100 * render.milestoneScale
        settings.opacity = math.min(1, ns.GetParticleValue(spec, "opacity") / 100 * (i == 3 and 1 or render.milestoneScale))
        if maxLevel and i == 3 then
            settings.count = math.min(spec.maxCount, math.ceil(count * 3))
        end
    end
    -- The foreground ember pool keeps the user's opacity; only depth motes brighten.
    render.backgroundMoteOpacity = math.min(1, render.particleSettings[3].opacity * (maxLevel and 1.8 or 1))
    render.starburstOpacity = ns.GetParticleValue(ns.EFFECT_OPACITY_SETTINGS[1], "opacity") / 100 * render.milestoneScale * render.milestonePortraitScale
    render.starburstOpacity = math.min(1, render.starburstOpacity)
    render.pulseOpacity = ns.GetParticleValue(ns.EFFECT_OPACITY_SETTINGS[2], "opacity") / 100 * render.milestoneScale * render.milestonePortraitScale
    render.pulseOpacity = math.min(1, render.pulseOpacity)
    render.edgeOpacity = ns.GetParticleValue(ns.EFFECT_OPACITY_SETTINGS[3], "opacity") / 100 * render.milestoneScale
    render.edgeOpacity = math.min(1, render.edgeOpacity)
    render.fireworkSize = ns.GetParticleValue(ns.FIREWORK_SETTINGS, "size") / 100
    render.fireworkOpacity = ns.GetParticleValue(ns.FIREWORK_SETTINGS, "opacity") / 100
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
    render.ParticlePoint(texture, frame, "BOTTOMLEFT", x + (endX - x) * eased, y + (endY - y) * eased)
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
    texture.opacityVariation = math.random() * .20 - .10
    texture.emberSpeed = 0.50 + math.random() * 0.50
    texture.emberSpeedMultiplier = render.backgroundMoteSpeed or 1
    texture.emberDuration = (5.5 + ((index - 1) % 8 + 1) * 0.41) / (texture.emberSpeed * 0.85 * texture.emberSpeedMultiplier)
    texture.moteSize = RandomMoteSize((4 + index % 3) * 1.15)
    texture.wanderPhase = math.random() * 2 * math.pi
    texture.wanderRate = 0.65 + math.random() * 0.50
    texture.wanderWidth = 3 + math.random() * 6
end

local function RefreshAbilityEffectSchedule()
    local db = ns.db or {}
    local count = db.highlightNewAbilities and render.particleSettings[4].count or 0
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

function render.AbilityReadyAt(icon)
    local ready = entranceTimeline and entranceTimeline.abilityEffectsStart or fadeFinished
    return math.max(ready or 0, icon.entranceEnd or 0)
end

local function AbilityShimmerTime(icon)
    local age = effectAge - render.AbilityReadyAt(icon) - SHIMMER_DELAY - (icon.sparkleDelay or 0)
    return age >= 0 and age % abilityShimmerPeriod or -1, math.floor(age / abilityShimmerPeriod)
end

-- Skip idle bursts on the existing clock. Refresh/start clear these deadlines.
function render.NextAbilityWake(icon, duration)
    local age = effectAge - render.AbilityReadyAt(icon) - SHIMMER_DELAY - (icon.sparkleDelay or 0)
    if age < 0 then return effectAge - age end
    if age % abilityShimmerPeriod < duration then return effectAge end
    return effectAge + abilityShimmerPeriod - age % abilityShimmerPeriod
end

-- Ambient twinkles use one reusable texture per icon. Flash bursts add the
-- configured corner sparkles without interrupting an ambient twinkle.
function render.PositionSparkle(icon, texture)
    local corner = math.random(4)
    local left, top = corner == 1 or corner == 4, corner <= 2
    render.ParticlePoint(texture, icon, "CENTER",
        (left and -1 or 1) * icon:GetWidth() * (0.30 + math.random() * 0.18),
        (top and 1 or -1) * icon:GetHeight() * (0.30 + math.random() * 0.18))
end

function render.UpdateAmbientSparkles()
    if render.ambientWake and effectAge < render.ambientWake then return render.ambientActive end
    render.ambientWake, render.ambientActive = math.huge, false
    local settings = render.particleSettings[4]
    local enabled = ns.db.highlightNewAbilities and settings.count > 0
    for _, pool in ipairs(render.abilityPools) do
        for _, icon in ipairs(pool) do
            local texture = icon.ambientSparkle
            if enabled and icon:IsShown() and icon.isNewAbility == true then
                if not texture.sparkleStart then
                    texture.sparkleStart = render.AbilityReadyAt(icon) + SHIMMER_DELAY + 0.25 + math.random() * 0.60
                    texture.positioned = false
                end
                local age = effectAge - texture.sparkleStart
                if age >= 0.42 then
                    texture.sparkleStart = effectAge + (0.30 + math.random() * 0.90) / render.milestoneScale
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
                    render.ParticleSize(texture, size, size)
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
            if pool == content.portraitSparks and IsHorizontalLayout() then
                local ringScale = db.portraitRingEnabled and PortraitRingScale() or 1
                radius = PortraitRingSize() * ringScale * 0.52 + size * 0.5 + radius * 0.25
                distance = distance * 1.7
            end
            texture.renderSize = size
            render.ParticleSize(texture, size, size)
            if pool == content.starburstMotes then
                PositionContainedMote(texture, radius, distance, eased, width, height, centerX, centerY)
            else
                render.ParticlePoint(texture, content.classRing, "CENTER",
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
            if texture.emberCycle == nil or texture.emberSpeedMultiplier ~= render.backgroundMoteSpeed then
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
            render.ParticleSize(texture, size, size)
            local phase = texture.wanderPhase
            local drift = texture.wanderWidth * math.sin(phase + progress * math.pi * 2 * texture.wanderRate)
                + 2 * math.sin(phase * 1.7 + progress * math.pi * 3)
            local limit = math.max(0, width / 2 - size * 0.75 - 2)
            render.ParticlePoint(texture, content, "BOTTOM", math.max(-limit, math.min(limit, x + drift)),
                18 + progress * math.max(1, height - 36))
            texture:SetRotation(progress * math.pi)
            texture:SetAlpha((settings.opacity > 0 and math.max(0, math.min(1, settings.opacity + texture.opacityVariation)) or 0) * math.sin(math.pi * t) ^ 2 * math.min(1, ambientAge / 0.30))
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
            render.ParticleSize(texture, vertical and thickness or width, vertical and math.max(1, height - 14) or thickness)
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
                local enabled = db.highlightNewAbilities and icon:IsShown() and icon.isNewAbility == true
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
                        render.ParticleSize(texture, size, size)
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

-- Enlarge milestone text from the registered base size without changing weight.
function render.RefreshMilestoneLevelText()
    local text = content.levelText
    local path, size, flags = text:GetFont()
    local base = size
    for _, entry in ipairs(content.fontElements) do
        if entry.fs == text then base = entry.size; break end
    end
    local enabled = content.isMilestone and ns.db and ns.db.milestoneAnimations ~= false
    local target = base * ns.GetTextScale("headingTextScale") * (enabled and 1.43 or 1)
    local fitHeading = content.levelRangeStart or ns.GetTextScale("headingTextScale") ~= 1
    if fitHeading then
        ApplyToTextLayers(text, "SetFont", path, target, flags)
        local available = IsHorizontalLayout() and PortraitColumnWidth() - 12 or FRAME_WIDTH - 40
        local width = text:GetStringWidth()
        if width > available then target = math.max(8, target * available / width) end
    end
    local changed = size ~= target
    if changed or fitHeading then ApplyToTextLayers(text, "SetFont", path, target, flags) end
    return changed
end

-- Milestone accents are allocated once and share the popup's existing clock.
function render.EnsureMilestoneAccents()
    if content.milestoneAccents then return end
    local accents = { rings = {}, burst = {}, trails = {}, gleams = {}, statEmitters = {} }
    content.milestoneAccents = accents
    for i = 1, 3 do
        if i == 1 then
            local ring = NewSparkTexture(content)
            ring:SetTexture("Interface\\AddOns\\GnomeLevelUp\\Textures\\Backgrounds\\circle-frame.tga")
            ring:SetPoint("CENTER", content.classRing, "CENTER")
            accents.rings[i] = ring
        end
        -- Clip a duplicate of the actual glyphs, never a solid rectangular bar.
        local clip = CreateFrame("Frame", nil, content)
        clip:SetClipsChildren(true)
        clip:SetFrameLevel(content:GetFrameLevel() + 3)
        clip:Hide()
        clip.text = clip:CreateFontString(nil, "OVERLAY")
        clip.text:SetPoint("CENTER", content.levelText, "CENTER")
        clip.text:SetJustifyH("CENTER")
        accents.gleams[i] = clip
    end
    accents.burstFrame = CreateFrame("Frame", nil, content)
    accents.burstFrame:SetAllPoints(content)
    accents.burstFrame:SetFrameLevel(math.max(content:GetFrameLevel(), bg:GetFrameLevel()) + 3)
    accents.burstFrame:SetClipsChildren(true)
    for _, divider in ipairs({ content.statsHeaderDivider, content.statsBottomDivider,
        content.timeBottomDivider, content.abilitiesDivider, content.petDivider,
        content.petHeaderDivider, content.weaponDivider }) do
        local trail = { divider = divider, textures = {} }
        for i = 1, 6 do trail.textures[i] = NewSparkTexture(divider) end
        accents.trails[#accents.trails + 1] = trail
    end
    for _, line in ipairs(bg.modernAccents) do
        local trail = { divider = line, isAccent = true, textures = {} }
        for i = 1, 6 do trail.textures[i] = NewSparkTexture(bg) end
        accents.trails[#accents.trails + 1] = trail
    end
end

function render.HideMilestoneAccents()
    local accents = content.milestoneAccents
    if not accents or render.milestoneAccentsHidden then return end
    render.milestoneAccentsHidden = true
    for _, ring in ipairs(accents.rings) do ring:Hide() end
    for _, clip in ipairs(accents.gleams) do clip:Hide() end
    for _, texture in ipairs(accents.burst) do texture:Hide() end
    for _, trail in ipairs(accents.trails) do
        for _, texture in ipairs(trail.textures) do texture:Hide() end
    end
end

-- Roll once per celebration, keeping positions steady while particles travel.
function render.RollStatFireworks()
    local accents = content.milestoneAccents
    if not accents then return end
    local rows = accents.statEmitters
    for i = #rows, 2, -1 do
        local j = math.random(i)
        rows[i], rows[j] = rows[j], rows[i]
    end
    accents.burstOrigins, accents.burstScales, accents.burstHeights = {}, {}, {}
    for i = 1, #rows do
        accents.burstOrigins[i] = (i % 2 == 1 and -1 or 1) * math.random()
        accents.burstScales[i] = 0.65 + math.random() * 0.90
        accents.burstHeights[i] = 0.75 + math.random() * 0.50
    end
end

function render.RefreshMilestoneAccents()
    local db = ns.db or {}
    if not content.isMilestone or db.milestoneAnimations == false or db.reducedMotion or db.backgroundAnimations == false then
        render.HideMilestoneAccents()
        return
    end
    render.EnsureMilestoneAccents()
    local accents, color = content.milestoneAccents, ActiveColor("animatedElements")
    accents.burstFrame:SetFrameLevel(math.max(content:GetFrameLevel(), bg:GetFrameLevel()) + 3)
    local visible, changed = 0, false
    for _, row in ipairs(content.statLinePool) do
        if row:IsShown() then
            visible = visible + 1
            local found = false
            for _, emitter in ipairs(accents.statEmitters) do if emitter == row then found = true; break end end
            if not found then changed = true end
        end
    end
    if changed or visible ~= #accents.statEmitters then
        for i = #accents.statEmitters, 1, -1 do accents.statEmitters[i] = nil end
        for _, row in ipairs(content.statLinePool) do
            if row:IsShown() then accents.statEmitters[#accents.statEmitters + 1] = row end
        end
        render.RollStatFireworks()
    end
    -- Choose up to four of the shuffled stat rows for this celebration.
    accents.burstCount = math.min(4, #accents.statEmitters)
    EnsureParticlePool(accents.burst, accents.burstFrame, accents.burstCount * 16)

    for _, ring in ipairs(accents.rings) do ring:SetVertexColor(color[1], color[2], color[3]) end
    local font, size, flags = content.levelText:GetFont()
    for _, clip in ipairs(accents.gleams) do
        clip.text:SetFont(font, size, flags)
        clip.text:SetText(content.levelText:GetText())
        clip.text:SetTextColor(0.90 + color[1] * 0.10, 0.90 + color[2] * 0.10, 0.90 + color[3] * 0.10)
    end
    accents.gleamWidth = math.max(1, content.levelText:GetStringWidth())
    accents.gleamHeight = math.max(1, content.levelText:GetStringHeight()) + 6
    for _, trail in ipairs(accents.trails) do
        for _, texture in ipairs(trail.textures) do texture:SetVertexColor(color[1], color[2], color[3]) end
    end
    for _, texture in ipairs(accents.burst) do texture:SetVertexColor(color[1], color[2], color[3]) end
end

function render.UpdateMilestoneAccents()
    local db, plan, accents = ns.db or {}, entranceTimeline, content.milestoneAccents
    if not content.isMilestone or db.milestoneAnimations == false or db.reducedMotion or db.backgroundAnimations == false
        or not plan or not accents or not frame:IsShown() then
        render.HideMilestoneAccents()
        return false
    end
    render.milestoneAccentsHidden = false
    local speed, active = Speed(), false
    local portraitFinish = plan.portrait.finish
    local shockwaves = db.portraitAnimation and db.portraitMode ~= "none" and IsPlayerPortrait()
    for i, ring in ipairs(accents.rings) do
        local t = (effectAge - portraitFinish - (PORTRAIT_PULSE_GAP + (i - 1) * 0.17) / speed) / (0.90 / speed)
        local shown = shockwaves and t >= 0 and t < 1
        render.Shown(ring, shown == true)
        if shown then
            if i == 1 and not render.portraitImpactPlayed then
                render.portraitImpactPlayed = true
                ns.PlayPortraitImpactSound()
            end
            local size = PortraitRingSize() * (1 + 1.7 * (1 - (1 - t) ^ 3)) * render.milestonePortraitScale
            render.Size(ring, size, size)
            ring:SetAlpha(render.pulseOpacity * 0.65 * math.min(1, t / 0.08) * (1 - t) ^ 2)
        end
        if shockwaves and t < 1 then active = true end
    end
    local gleamAge = effectAge - portraitFinish - 0.12 / speed
    -- Repeat start-to-start every 3 seconds, including at slow animation speeds.
    local gleam = gleamAge >= 0 and (gleamAge % 3) / math.min(1.25, 0.85 / speed) or -1
    local width, height = accents.gleamWidth, accents.gleamHeight
    local band = math.max(5, math.min(16, width * 0.11))
    for i, clip in ipairs(accents.gleams) do
        local shown = gleam >= 0 and gleam < 1
        render.Shown(clip, shown)
        if shown then
            local x = -width / 2 - band * 2 + (width + band * 4) * gleam + (i - 2) * band
            render.Size(clip, band, height)
            clip:ClearAllPoints()
            clip:SetPoint("CENTER", content.levelText, "CENTER", x, 0)
            clip:SetAlpha((i == 2 and 0.85 or 0.70) * math.sin(math.pi * gleam))
        end
    end
    active = true -- The recurring text gleam keeps this visible-only driver awake.
    -- Each pair branches from the centre of its divider after that section lands.
    for index, trail in ipairs(accents.trails) do
        local stage = trail.isAccent and plan.background or index == 1 and plan.statsHeader or index == 2 and plan.statsBottom
            or index == 3 and plan.levelTime or index == 4 and plan.abilitiesHeader
            or (index == 5 or index == 6) and plan.petHeader or plan.weapon
        local enabled = db.dividerReveal and stage and trail.divider:IsShown()
        local t = stage and (effectAge - stage.finish - 0.04 / speed) / (1.0 / speed) or 1
        local track = trail.isAccent and trail.divider or trail.divider.texture
        local half = math.max(0, track:GetWidth() / 2 - 12)
        for i, texture in ipairs(trail.textures) do
            local tail = (i - 1) % 3
            local position = t - tail * 0.055
            local shown = enabled and position >= 0 and position < 1
            render.Shown(texture, shown == true)
            if shown then
                local direction = i <= 3 and -1 or 1
                render.ParticlePoint(texture, trail.divider, "CENTER", direction * half * position, 0)
                render.ParticleSize(texture, 22 - tail * 4, 10 - tail * 2)
                texture:SetAlpha((0.9 - tail * 0.22) * math.sin(math.pi * position))
            end
        end
        if enabled and t < 1.12 then active = true end
    end
    -- Visit the shuffled stat rows one at a time, alternating left/right origins.
    local emitters = accents.burstCount or 0
    -- Leave the foreground impact sparks their full lifetime before fireworks.
    local burstStart = plan.statCountFinish + (db.emphasizeStatGains and .73 or .08) / speed
    accents.burstStart = burstStart
    local burstAge = effectAge - burstStart
    local budget = math.max(0.10, plan.finish + (tonumber(db.duration) or 7) - burstStart - 0.20)
    local slot = math.min(0.50 / speed, budget / math.max(1, emitters))
    local duration = slot * 0.90
    accents.burstSlot, accents.burstDuration = slot, duration
    local burstEnabled = db.emphasizeStatGains and plan.statFlashStart ~= nil
    local count = math.min(16, render.particleSettings[3].count)
    local opacity = render.particleSettings[3].opacity
    local alpha = opacity > 0 and math.min(1, (opacity * render.milestoneScale * 1.7 + 0.15) * 1.10) * render.fireworkOpacity or 0
    for i, texture in ipairs(accents.burst) do
        local ordinal = math.floor((i - 1) / 16) + 1
        local row = ordinal <= emitters and accents.statEmitters[ordinal]
        local burstTime = (burstAge - (ordinal - 1) * slot) / duration
        local shown = burstEnabled and row and (i - 1) % 16 < count and burstTime >= 0 and burstTime < 1
        render.Shown(texture, shown == true)
        if shown and row then
            local angle = texture.burstAngle or i * 2 * math.pi / 16
            local distance = (texture.burstDistance or 90) * (1 - (1 - burstTime) ^ 3)
            local size = math.min(36, (texture.burstSize or 7) * render.particleSettings[3].size * 1.25 * accents.burstScales[ordinal]) * render.fireworkSize
            local origin = accents.burstOrigins[ordinal] * math.max(0, row:GetWidth() / 2 - size / 2)
            render.ParticleSize(texture, size, size)
            render.ParticlePoint(texture, row, "CENTER", origin + math.cos(angle) * distance, math.sin(angle) * distance * accents.burstHeights[ordinal])
            texture:SetAlpha(math.min(1, alpha * (texture.burstOpacity or 1)) * math.min(1, burstTime / 0.06) * (1 - burstTime) ^ 1.4)
            texture:SetRotation(angle + burstTime)
        end
    end
    if burstEnabled and emitters > 0 and count > 0 and burstAge < emitters * slot then active = true end
    return active
end

local UpdateVisualEffects
function render.PortraitGlintDuration()
    return content.isMaxLevel and ns.db and ns.db.maxLevelCelebration ~= false and .75 or 1.1
end

function render.PortraitGlintFinish()
    local db = ns.db or {}
    if not entranceTimeline or not db.portraitRingGlint or db.portraitMode == "none"
        or db.reducedMotion or db.backgroundAnimations == false then return 0 end
    return entranceTimeline.portrait.finish + (.08 + render.PortraitGlintDuration() * 1.08) / Speed()
end

function render.HideMaxCelebration()
    local effects = content.maxLevelEffects
    if not effects or effects.hidden then return end
    effects.hidden = true
    effects.frame:Hide()
    for _, pool in ipairs(effects.pools) do for _, texture in ipairs(pool) do texture:Hide() end end
end

function render.MaxClassTint(texture)
    local _, class = UnitClass("player")
    local color = ns.CLASS_COLORS[class] or { 1, 0.82, 0.2 }
    local r, g, b = color[1], color[2], color[3]
    local hi, lo = math.max(r, g, b), math.min(r, g, b)
    local delta, hue = hi - lo, 0
    if delta > 0 then
        if hi == r then hue = ((g - b) / delta) % 6
        elseif hi == g then hue = (b - r) / delta + 2
        else hue = (r - g) / delta + 4 end
        hue = hue / 6
    end
    local saturation = hi > 0 and delta / hi or 0
    if saturation < .08 then
        hue, saturation = .50 + math.random() * .16, .08 + math.random() * .18
    else
        hue = (hue + (math.random() - .5) * .12) % 1
        saturation = math.min(1, saturation * (.75 + math.random() * .3))
    end
    local value = .78 + math.random() * .22
    local function channel(offset)
        local k = (offset + hue * 6) % 6
        return value * (1 - saturation * math.max(0, math.min(k, 4 - k, 1)))
    end
    texture.maxR, texture.maxG, texture.maxB = channel(5), channel(3), channel(1)
    texture:SetVertexColor(texture.maxR, texture.maxG, texture.maxB)
end

function render.PrepareMaxCelebration()
    local effects = content.maxLevelEffects
    if not effects then
        effects = { fireworks = {}, sparks = {}, surge = {}, origins = {} }
        effects.frame = CreateFrame("Frame", nil, frame)
        effects.frame:SetAllPoints(frame)
        effects.frame:SetClipsChildren(false)
        effects.frame:SetFrameLevel(frame:GetFrameLevel() + 12)
        effects.pools = { effects.fireworks, effects.sparks, effects.surge }
        content.maxLevelEffects = effects
        EnsureParticlePool(effects.fireworks, effects.frame, 240)
        EnsureParticlePool(effects.sparks, effects.frame, 24)
        EnsureParticlePool(effects.surge, effects.frame, 16)
    end
    if effects.prepared then return effects end
    effects.prepared, effects.fireworksFinished = true, false
    for i = 1, 8 do effects.origins[i] = (i % 2 == 0 and .28 or -.28) + (math.random() - .5) * .12 end
    for i, texture in ipairs(effects.fireworks) do
        if i % 2 == 1 then
            texture.distance, texture.spread, texture.bend = 110 + math.random() * 115, (math.random() - .5) * 200, (math.random() - .5) * 95
            texture.maxSize = 11 + math.random() * 9
            render.MaxClassTint(texture)
        else
            local head = effects.fireworks[i - 1]
            texture.distance, texture.spread, texture.bend, texture.maxSize = head.distance, head.spread, head.bend, head.maxSize
            texture:SetVertexColor(head.maxR, head.maxG, head.maxB)
        end
    end
    for i, texture in ipairs(effects.sparks) do
        texture.maxAngle = (i - 1) * math.pi * 2 / 24 + math.random() * .15
        texture.maxDistance, texture.maxDuration = 35 + math.random() * 60, 1.1 + math.random() * .7
        render.MaxClassTint(texture)
    end
    local _, class = UnitClass("player")
    local surgeColor = ns.CLASS_COLORS[class] or { 1, .82, .2 }
    for i, texture in ipairs(effects.surge) do
        texture:SetVertexColor(surgeColor[1], surgeColor[2], surgeColor[3])
        if i % 2 == 1 then
            texture.surgePeriod = .8 + math.random() * .6
            texture.surgeDuration = .24 + math.random() * .14
            texture.surgeOffset = math.random() * texture.surgePeriod
            texture.surgeCycle = nil
        end
    end
    return effects
end

function render.UpdateMaxCelebration()
    local db, plan = ns.db or {}, entranceTimeline
    if not content.isMaxLevel or db.maxLevelCelebration == false or db.reducedMotion
        or db.backgroundAnimations == false or not plan or not frame:IsShown() then
        render.HideMaxCelebration()
        return false
    end
    local effects = render.PrepareMaxCelebration()
    effects.hidden = false
    effects.frame:Show()
    local speed, active = Speed(), false
    local age = (effectAge - plan.finish) * speed
    local fireworkSpan = math.max(.35, math.min(3, (tonumber(db.duration) or 7) * speed - .15))
    local fireworkAge = age * 3 / fireworkSpan
    if not effects.fireworksFinished then
        if fireworkAge > 3 then
            for _, texture in ipairs(effects.fireworks) do texture:Hide() end
            effects.fireworksFinished = true
        else
            local width, height = frame:GetWidth(), frame:GetHeight()
            for i, texture in ipairs(effects.fireworks) do
                local emitter = math.floor((i - 1) / 30)
                local t = (fireworkAge - emitter * .16) / 1.65 - (i % 2 == 0 and .055 or 0)
                local shown = t >= 0 and t < 1
                render.Shown(texture, shown)
                if shown then
                    local side, origin = math.floor(emitter / 2), effects.origins[emitter + 1]
                    local nx, ny = side == 0 and -1 or side == 1 and 1 or 0, side == 2 and 1 or side == 3 and -1 or 0
                    local x, y = nx * width / 2 + (nx == 0 and origin * width or 0), ny * height / 2 + (ny == 0 and origin * height or 0)
                    local outward = texture.distance * (2 * t - t * t)
                    local curve = texture.spread * t + texture.bend * math.sin(math.pi * t)
                    x, y = x + nx * outward - ny * curve, y + ny * outward + nx * curve - 32 * t * t
                    render.ParticlePoint(texture, frame, "CENTER", x, y)
                    local size = texture.maxSize * math.max(.7, render.fireworkSize) * (i % 2 == 0 and .65 or 1) * (1 - .25 * t)
                    render.ParticleSize(texture, size, size)
                    texture:SetRotation(t * math.pi)
                    texture:SetAlpha(math.min(1, t / .05) * math.sin(math.pi * t) ^ .55 * math.min(1, render.fireworkOpacity * 1.4) * (i % 2 == 0 and .65 or 1))
                end
            end
            active = true
        end
    end
    local portrait = db.portraitMode ~= "none"
    local surgeAge = render.ringSurgeStartedAt and (effectAge - render.ringSurgeStartedAt - .2) * speed or -1
    local surgeEnabled = portrait and IsPlayerPortrait() and db.portraitAnimation and surgeAge >= 0
    local ring = db.portraitRingEnabled and content.classRingGraphic or content.classRing
    local ringRadius = ring:GetWidth() * .5 * content:GetScale()
    for i, texture in ipairs(effects.surge) do
        -- Independent slower flashes stay at one random spot for their whole life.
        local head = effects.surge[i % 2 == 1 and i or i - 1]
        local beat = (surgeAge + head.surgeOffset) / head.surgePeriod
        local cycle, phase = math.floor(beat), (beat % 1) * head.surgePeriod
        local shown = surgeEnabled and phase < head.surgeDuration
        if shown and head.surgeCycle ~= cycle then
            head.surgeCycle = cycle
            head.surgeAngle = math.random() * math.pi * 2
            head.surgeSize = .5 + math.random() * 1.25
        end
        render.Shown(texture, shown == true)
        if shown then
            local angle = head.surgeAngle
            local branch = i % 2 == 0 and 1 or -1
            local distance = ringRadius + branch
            local pulse = math.sin(math.pi * phase / head.surgeDuration)
            render.ParticlePoint(texture, ring, "CENTER", math.cos(angle) * distance, math.sin(angle) * distance)
            local scale = content:GetScale() * head.surgeSize
            render.ParticleSize(texture, (16 + 20 * pulse) * scale, 6 * scale)
            texture:SetRotation(angle + branch * .5)
            texture:SetAlpha(pulse)
        end
    end
    if surgeEnabled then active = true end
    local radius = (PortraitRingSize() * PortraitRingScale() * .56 + 12) * content:GetScale()
    local sparkAge = (effectAge - starburstStartedAt) * speed - .12
    for i, texture in ipairs(effects.sparks) do
        local t = (sparkAge - (i - 1) * .023) / texture.maxDuration
        local shown = portrait and IsPlayerPortrait() and db.portraitAnimation and portraitStage == "starburst" and t >= 0 and t < 1
        render.Shown(texture, shown == true)
        if shown then
            local angle = texture.maxAngle + t * .65
            local distance = radius * .45 + texture.maxDistance * (2 * t - t * t)
            render.ParticlePoint(texture, content.portraitAnchor, "CENTER", math.cos(angle) * distance, math.sin(angle) * distance)
            local size = (7 + i % 4) * (1 - .5 * t)
            render.ParticleSize(texture, size, size);texture:SetAlpha(math.sin(math.pi * t) * .9)
            active = true
        end
    end
    return active
end

function render.StartPortraitStarburst()
    if effectAge < render.PortraitStarburstTime() then
        portraitStage = "glint"
    else
        portraitStage = "starburst"
        starburstStartedAt = effectAge
    end
end

function render.PortraitStarburstTime()
    local finish = render.PortraitGlintFinish()
    -- Begin growth .12s before the leading glint reaches the top of the ring.
    return finish > 0 and finish - (.12 + render.PortraitGlintDuration() * .08) / Speed() or 0
end

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
        render.StartPortraitStarburst()
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

-- Optional finishing effects share the popup clock and reuse their textures.
function render.TrialSpark(parent, layer)
    local texture = NewSparkTexture(parent, layer)
    local color = ActiveColor("animatedElements")
    texture:SetVertexColor(color[1], color[2], color[3])
    return texture
end

function render.HideTrialEffects()
    local effects = content.trialEffects
    if not effects then return end
    if effects.portraitShimmer then effects.portraitShimmer:Hide() end
    for _, pool in ipairs({effects.glints, effects.depth}) do
        for _, texture in ipairs(pool) do texture:Hide() end
    end
    for _, pool in pairs(effects.impacts) do for _, texture in ipairs(pool) do texture:Hide() end end
    for _, pool in ipairs(render.abilityPools) do
        for _, icon in ipairs(pool) do if icon.revealShine then icon.revealShine:Hide() end end
    end
end

function render.TintTrialImpact(white)
    local effects = content.trialEffects
    if not effects then return end
    local color = ActiveColor("animatedElements")
    if effects.white == white and effects.red == color[1] and effects.green == color[2] and effects.blue == color[3] then return end
    effects.white, effects.red, effects.green, effects.blue = white, color[1], color[2], color[3]
    local r, g, b = color[1]+(1-color[1])*white, color[2]+(1-color[2])*white, color[3]+(1-color[3])*white
    local function Tint(texture) texture:SetVertexColor(r, g, b) end
    Tint(content.portraitPulse);Tint(content.portraitStarburst)
    for _, pool in ipairs(render.smallEffectPools) do for _, texture in ipairs(pool) do Tint(texture) end end
    for _, pool in ipairs({effects.glints, effects.depth}) do for _, texture in ipairs(pool) do Tint(texture) end end
    if effects.portraitShimmer then Tint(effects.portraitShimmer.texture) end
    for _, pool in pairs(effects.impacts) do for _, texture in ipairs(pool) do Tint(texture) end end
    for _, pool in ipairs(render.abilityPools) do
        for _, icon in ipairs(pool) do
            Tint(icon.newAbilityGlow);Tint(icon.ambientSparkle)
            for _, texture in ipairs(icon.cornerSparkles) do Tint(texture) end
            if icon.revealShine then Tint(icon.revealShine.texture) end
        end
    end
    local accents = content.milestoneAccents
    if accents then
        for _, pool in ipairs({accents.rings, accents.burst}) do for _, texture in ipairs(pool) do Tint(texture) end end
        for _, trail in ipairs(accents.trails) do for _, texture in ipairs(trail.textures) do Tint(texture) end end
    end
end

function render.UpdateTrialEffects()
    local db, plan = ns.db or {}, entranceTimeline
    local enabled = frame:IsShown() and not db.reducedMotion and db.backgroundAnimations ~= false
    if not enabled or not plan then
        render.HideTrialEffects();render.TintTrialImpact(0)
        return false
    end
    local effects = content.trialEffects
    if not effects then
        effects = {glints={},depth={},impacts={}}
        content.trialEffects = effects
    end
    local active, speed = false, Speed()
    local perf = ns.PerfStart("ring_glint_frame", effectAge)
    local color = ActiveColor("animatedElements")
    local portrait = db.portraitMode ~= "none"
    local milestone = content.isMilestone and db.milestoneAnimations ~= false
    local maxLevel = content.isMaxLevel and db.maxLevelCelebration ~= false
    local glintAge = (effectAge-plan.portrait.finish-.08/speed)/(render.PortraitGlintDuration()/speed)
    local willStarburst = db.portraitAnimation and IsPlayerPortrait()
    local flareDuration = (milestone and .42 or .34) / speed
    local flare = (effectAge-render.PortraitGlintFinish())/flareDuration
    local holding = willStarburst and glintAge >= 1 and portraitStage ~= "starburst" and flare < 0
    local flaring = flare >= 0 and flare < 1
    -- A short attack creates a spark, followed by a shrinking, lightly flickering tail.
    local spark = flaring and (flare < .22 and 1-(1-flare/.22)^3 or (1-(flare-.22)/.78)^2) or 0
    local flicker = flaring and (maxLevel and .65+.35*math.cos(flare*math.pi*10) or .92+.08*math.cos(flare*math.pi*6)) or 1
    if db.portraitRingGlint and portrait and (glintAge < 1.12 or holding or flaring) then
        if not effects.glintLayer then
            effects.glintLayer = CreateFrame("Frame", nil, content.portraitArtwork)
            effects.glintLayer:SetAllPoints(content.portraitArtwork)
        end
        effects.glintLayer:SetFrameLevel(math.max(content.portraitArtwork:GetFrameLevel(),
            content.playerModel and content.playerModel:GetFrameLevel() or 0)+3)
        EnsureParticlePool(effects.glints, effects.glintLayer, 3)
        local ring = db.portraitRingEnabled and content.classRingGraphic or content.classRing
        for i, texture in ipairs(effects.glints) do
            local t = glintAge-(i-1)*.04
            local onPath = t>=0 and t<1
            local visible = onPath or holding and i == 1 or flaring
            render.Shown(texture, visible)
            if visible then
                local angle = onPath and math.pi/2-t*math.pi*2 or math.pi/2
                local radius = ring:GetWidth() * (ring == content.classRingGraphic and render.portraitGlintRadius or .5)
                texture:ClearAllPoints();texture:SetPoint("CENTER", ring, "CENTER", math.cos(angle)*radius,math.sin(angle)*radius)
                local size = (22-(i-1)*6) * (flaring and .18+((maxLevel and 6.4 or milestone and 2.4 or 1.45)-.18)*spark or 1)
                render.ParticleSize(texture,size,size)
                texture:SetRotation(maxLevel and flaring and (flare-.22)*.6 or 0)
                local alpha = flaring and spark^.45*flicker*(milestone and 1 or .9)
                    or onPath and math.sin(math.pi*t)^.5 or .35
                texture:SetAlpha(alpha*(.75^(i-1)))
                local white = flaring and milestone and .8 or .45
                texture:SetVertexColor(white+(1-white)*color[1],white+(1-white)*color[2],white+(1-white)*color[3])
            end
        end
        active = true
    else for _, texture in ipairs(effects.glints) do texture:Hide() end end

    ns.PerfEnd(perf)
    perf = ns.PerfStart("portrait_shimmer_frame", effectAge)
    local shimmerAge = render.ringSurgeStartedAt and effectAge-render.ringSurgeStartedAt-.28/speed or -1
    local shimmerDuration = .85/speed
    local shimmerCycle = math.max(4, shimmerDuration+.5)
    local shimmerTime = shimmerAge >= 0 and (shimmerAge % shimmerCycle)/shimmerDuration or -1
    local shimmerVisible = (milestone or maxLevel) and db.portraitAnimation and IsPlayerPortrait()
        and shimmerTime >= 0 and shimmerTime < 1
    if shimmerVisible and not effects.portraitShimmer then
        local clip = CreateFrame("Frame", nil, content.portraitArtwork)
        clip:SetClipsChildren(true)
        clip.texture = render.TrialSpark(clip)
        clip.texture:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
        clip.texture:SetRotation(-math.pi/4)
        if clip.CreateMaskTexture then
            clip.mask = clip:CreateMaskTexture()
            clip.mask:SetAllPoints(clip)
            clip.mask:SetTexture(CIRCLE_MASK, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
            clip.texture:AddMaskTexture(clip.mask)
        end
        effects.portraitShimmer = clip
    end
    if effects.portraitShimmer then
        local clip = effects.portraitShimmer
        render.Shown(clip, shimmerVisible == true)
        if shimmerVisible then
            local target = db.portraitMode == "player3d" and content.modelBacking or content.classIcon
            local width, height = target:GetWidth(), target:GetHeight()
            clip:SetFrameLevel(math.max(content.portraitArtwork:GetFrameLevel(),
                content.playerModel and content.playerModel:GetFrameLevel() or 0)+4)
            clip:ClearAllPoints();clip:SetPoint("CENTER", target, "CENTER")
            render.Size(clip,width,height);render.Alpha(clip,1)
            local texture = clip.texture
            texture:Show();render.ParticleSize(texture,width*1.8,18)
            render.ParticlePoint(texture,clip,"CENTER",(-.8+1.6*shimmerTime)*width,(-.8+1.6*shimmerTime)*height)
            texture:SetVertexColor(.6+.4*color[1],.6+.4*color[2],.6+.4*color[3])
            texture:SetAlpha(.85*math.sin(math.pi*shimmerTime)^.5)
            active = true
        end
    end

    ns.PerfEnd(perf)
    perf = ns.PerfStart("ability_shine_frame", effectAge)
    if not effects.shinesFinished then
    local pending=false
    for _, pool in ipairs(render.abilityPools) do
        for _, icon in ipairs(pool) do
            local t = (effectAge-(icon.entranceEnd or 0)+.10/speed)/(.70/speed)
            local visible = db.highlightNewAbilities and icon:IsShown() and icon.isNewAbility == true
                and not icon.skipEntrance and t>=0 and t<1
            if visible and not icon.revealShine then
                local clip = CreateFrame("Frame", nil, icon)
                clip:SetAllPoints(icon);clip:SetClipsChildren(true);clip:SetFrameLevel(icon:GetFrameLevel()+4)
                clip.texture = render.TrialSpark(clip)
                clip.texture:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
                clip.texture:SetRotation(-math.pi/4)
                icon.revealShine = clip
            end
            if icon.revealShine then
                render.Shown(icon.revealShine, visible == true)
                if visible then
                    local texture,w,h = icon.revealShine.texture,icon:GetWidth(),icon:GetHeight()
                    texture:Show();render.ParticleSize(texture,w*1.8,16)
                    render.ParticlePoint(texture,icon,"CENTER",(-.8+1.6*t)*w,(-.8+1.6*t)*h)
                    texture:SetAlpha(.95*math.sin(math.pi*t)^.5)
                end
            end
            if db.highlightNewAbilities and icon:IsShown() and icon.isNewAbility == true and not icon.skipEntrance and t<1 then pending=true end
        end
    end

    effects.shinesFinished=not pending
    active=active or pending
    end

    ns.PerfEnd(perf)
    perf = ns.PerfStart("stat_impacts_frame", effectAge)
    if not effects.impactsFinished then
    local enabled = milestone and db.emphasizeStatGains
    local pending=false
    for _, row in ipairs(content.statLinePool) do
        local age = row.countFinishAt and effectAge-row.countFinishAt or -1
        local visible = enabled and row:IsShown() and age>=0 and age<.65/speed
        if visible and not effects.impacts[row] then
            effects.impacts[row] = {}
            for i=1,3 do effects.impacts[row][i]=render.TrialSpark(row.slideFrame) end
        end
        local pool = effects.impacts[row]
        if pool then for i, texture in ipairs(pool) do
            render.Shown(texture,visible == true)
            if visible then
                local t,angle = age/(.65/speed),(i-1)*math.pi*2/3
                local distance=6+28*(1-(1-t)^2)
                render.ParticlePoint(texture,row.gainCounter,"RIGHT",math.cos(angle)*distance,math.sin(angle)*distance)
                render.ParticleSize(texture,15-i*2,15-i*2);texture:SetAlpha(math.sin(math.pi*t)^.5*(1-.45*t))
            end
        end end
        if enabled and row:IsShown() and row.countFinishAt and age<.65/speed then pending=true end
    end

    effects.impactsFinished=not pending
    active=active or pending
    end

    ns.PerfEnd(perf)
    perf = ns.PerfStart("depth_particles_frame", effectAge)
    local ambient = effectAge-fadeFinished-.50
    local depth = db.backgroundEmbers and render.particleSettings[3].count>0
    if depth then
        local maxLevel = content.isMaxLevel and db.maxLevelCelebration ~= false
        local depthCount = maxLevel and 60 or milestone and 36 or 24
        EnsureParticlePool(effects.depth,content,depthCount,"BACKGROUND")
        local settings = render.particleSettings[3]
        local width,height = content:GetWidth(),content:GetHeight()
        local span,rise = math.max(1,width-50),math.max(1,height-36)
        local fade = math.min(1,ambient/.3)
        for i,texture in ipairs(effects.depth) do
            local far = i > depthCount / 2
            if texture.depthFar ~= far then
                texture:SetDrawLayer("BACKGROUND",far and -2 or -1)
                texture.depthFar = far
            end
            render.Shown(texture,ambient>=0 and i<=depthCount)
            if ambient>=0 and i<=depthCount then
                if not texture.depthStart or texture.emberSpeedMultiplier ~= render.backgroundMoteSpeed or ambient-texture.depthStart>=texture.emberDuration then
                    RollBackgroundEmber(texture,i)
                    texture.emberDuration=texture.emberDuration*(far and 2.2 or 1.6)
                    texture.depthStart=texture.depthStart and ambient or -((i*.9)%texture.emberDuration)
                end
                local t=math.max(0,math.min(1,(ambient-texture.depthStart)/texture.emberDuration))
                local progress=(t-.15*t*t)/.85
                local size=texture.moteSize*settings.size*(far and 1.4 or 2.5)
                local limit=math.max(0,width/2-size)
                local x=(((i*.61803398875)%1)-.5)*span+math.sin(texture.wanderPhase+progress*3)*12
                render.ParticlePoint(texture,content,"BOTTOM",math.max(-limit,math.min(limit,x)),18+progress*rise)
                local opacity = render.backgroundMoteOpacity
                render.ParticleSize(texture,size,size);texture:SetAlpha((opacity > 0 and math.max(0, math.min(1, opacity + texture.opacityVariation)) or 0)*(far and .14 or .22)*math.sin(math.pi*t)^2*fade)
            end
        end
        active=true
    else for _,texture in ipairs(effects.depth) do texture:Hide() end end

    ns.PerfEnd(perf)
    perf = ns.PerfStart("portrait_anticipation_frame", effectAge)
    local afterGlint = db.portraitRingGlint and portraitStage == "glint"
    local pre = afterGlint and (effectAge-render.PortraitStarburstTime()+.18/speed)/(.18/speed)
        or (effectAge-plan.portrait.finish)/(PORTRAIT_PULSE_GAP/speed)
    if milestone and db.portraitRingSettle and db.portraitAnimation and IsPlayerPortrait() and pre>=0 and pre<1
        and (afterGlint or not db.portraitRingGlint and portraitStage=="waiting") then
        local size=PortraitIconSize()*2.2*render.milestoneStarburstScale*(.65-.47*pre)
        content.portraitStarburst:Show();render.Size(content.portraitStarburst,size,size)
        content.portraitStarburst:SetAlpha(render.starburstOpacity*(.45-.30*pre))
        active=true
    end
    if milestone and db.portraitRingSettle and not db.portraitRingGlint and db.portraitAnimation and IsPlayerPortrait() and portraitStage=="pulse" then
        local size=PortraitIconSize()*2.2*render.milestoneStarburstScale*.18
        content.portraitStarburst:Show();render.Size(content.portraitStarburst,size,size)
        content.portraitStarburst:SetAlpha(render.starburstOpacity*.15)
        active=true
    end
    local impact = portraitStage == "starburst" and (effectAge-starburstStartedAt)/(1.2/speed) or -1
    local white=milestone and portrait and db.portraitAnimation and impact>=0 and impact<1 and .95*(1-impact)^2 or 0
    render.TintTrialImpact(white)
    if milestone and portrait and db.portraitAnimation and impact<1 then active=true end
    ns.PerfEnd(perf)
    return active
end

function render.CancelClosing()
    local closing = render.closing
    if not closing then return end
    render.closing=nil
    ns.SetClosingClickThrough(false)
    for texture,alpha in pairs(closing.textures) do texture:SetAlpha(alpha) end
    if frame.fadeOutGroup:IsPlaying() then frame.fadeOutGroup:Stop() end
    if entranceTimeline then render.ApplyClosingEntrance(entranceTimeline.finish) end
    render.sectionComplete = nil
    frame:SetScale(ns.GetPopupScale());frame:SetAlpha(1)
    if content.playerModel and ns.db and ns.db.portraitMode == "player3d" then
        UpdateModelMaskGeometry(ModelPortraitDiameter())
        render.SyncPlayerModelCamera()
    end
end

function render.ApplyClosingEntrance(age)
    render.sectionComplete = nil
    UpdateSectionEntrance(age, true)
    render.Alpha(bg, EntranceAlpha(entranceTimeline.background, age, true))
    local alpha = EntranceAlpha(entranceTimeline.portrait, age, true)
    render.Alpha(content.portraitArtwork, alpha)
    if content.playerModel then render.Alpha(content.playerModel, alpha) end
    for _, fs in ipairs(content.statLinePool) do
        local motion = fs.entranceMotion
        if motion and (fs.statData or fs.plainText) then
            local t = math.max(0, math.min(1, (age - motion.delay) / motion.duration))
            if render.closing then
                t = math.max(0, math.min(1, ((motion.clockOffset and render.closing.startEffectAge or render.closing.startAge) - (motion.clockOffset or 0) - motion.delay) / motion.duration) - render.closing.age / motion.duration)
            end
            local x = ns.db.statSlideDirection == "none" and 0 or motion.startX * (1 - t)^3
            fs.slideFrame:SetPoint("TOP", motion.container, "TOP", x, motion.y)
            SetLineAlpha(fs, t * t)
        end
    end
    for _, pool in ipairs(render.abilityPools) do
        for _, icon in ipairs(pool) do
            local motion = icon.entranceMotion
            if icon:IsShown() and motion and icon.animationContainer then
                local t = motion.skip and 1 or math.max(0, math.min(1, (age - motion.delay) / motion.duration))
                if render.closing and not motion.skip then
                    t = math.max(0, math.min(1, (render.closing.startAge - motion.delay) / motion.duration) - render.closing.age / motion.duration)
                end
                icon:SetPoint("CENTER", icon.animationContainer, "CENTER", icon.animationX,
                    icon.animationY - ABILITY_POP_DISTANCE * (1 - t)^3)
                icon:SetAlpha(t * t)
            end
        end
    end
    if content.levelTimeRecord and content.levelTimeRecord:IsShown() then
        content.levelTimeRecord:SetAlpha(EntranceAlpha(entranceTimeline.levelTime, age, true))
        SetLineAlpha(content.levelTimeText, 0)
    end
end

function render.UpdateClosing(elapsed)
    local closing = render.closing
    if not closing then return end
    closing.age = closing.age + elapsed * closing.multiplier
    local progress = math.min(1, closing.age / (.45 / closing.speed))
    for texture, alpha in pairs(closing.textures) do texture:SetAlpha(alpha * (1 - progress)^2) end
    render.ApplyClosingEntrance(closing.startAge)
    if closing.age >= closing.duration then frame:Hide() end
end

function render.RefreshAnimationSoundSettings()
    render.hasOptionalSounds = false
    for _, spec in ipairs(ns.ANIMATION_SOUND_SETTINGS) do
        if spec.cue ~= "portraitImpact" and spec.cue ~= "starburst" and ns.GetAnimationSoundID(spec.cue) > 0 then
            render.hasOptionalSounds = true
            break
        end
    end
end

-- Optional cues follow visible stages and share the existing effect driver.
function render.UpdateAnimationSounds()
    local db, plan = ns.db or {}, entranceTimeline
    if not render.hasOptionalSounds or not plan or not frame:IsShown() or db.reducedMotion or db.backgroundAnimations == false then return end
    local seen = render.animationCueSeen
    if not seen then return end
    local function Once(cue, visible)
        if visible and not seen[cue] then seen[cue] = true; ns.PlayAnimationSound(cue) end
    end
    local function Any(pool)
        for _, texture in ipairs(pool or {}) do if texture:IsShown() then return true end end
        return false
    end
    local effects, maximum = content.trialEffects or {}, content.maxLevelEffects or {}
    local portrait = db.portraitAnimation and IsPlayerPortrait()
    Once("portraitPulse", portrait and portraitStage == "pulse")
    Once("ringGlint", db.portraitRingGlint and Any(effects.glints))
    Once("glintSpark", db.portraitRingGlint and effectAge >= render.PortraitGlintFinish() and Any(effects.glints))
    Once("ringSettle", db.portraitRingSettle and db.portraitMode ~= "none" and effectAge >= plan.portrait.start)
    Once("statCount", db.emphasizeStatGains and next(activeLineAnims) ~= nil)
    local impact = false
    if not seen.statImpact then
        for _, pool in pairs(effects.impacts or {}) do if Any(pool) then impact = true; break end end
    end
    Once("statImpact", impact)
    local revealed, shine = false, false
    for _, pool in ipairs(render.abilityPools) do
        for _, icon in ipairs(pool) do
            if icon:IsShown() and effectAge >= (icon.entranceEnd or math.huge) then revealed = true end
            if icon.revealShine and icon.revealShine:IsShown() then shine = true end
        end
    end
    Once("abilityReveal", db.highlightNewAbilities and revealed)
    Once("abilityShine", db.highlightNewAbilities and shine)
    Once("portraitMotes", Any(content.portraitSparks) or Any(content.starburstMotes))
    Once("backgroundMotes", Any(content.backgroundEmbers))
    Once("frameEdge", Any(content.edgeGlows))
    Once("dividers", db.dividerReveal and effectAge >= plan.statsHeader.start)
    Once("depth", Any(effects.depth))
    local milestone = content.isMilestone and db.milestoneAnimations ~= false
    Once("anticipation", milestone and portrait and portraitStage == "pulse")
    Once("milestoneTint", milestone and (effects.white or 0) > 0)
    Once("milestone", milestone and effectAge >= plan.portrait.finish)
    Once("maxFireworks", Any(maximum.fireworks))
    Once("ringSurges", Any(maximum.surge))
    Once("maxSparks", Any(maximum.sparks))
    local visible = effects.portraitShimmer and effects.portraitShimmer:IsShown() or false
    if visible and not render.animationCueVisible.portraitShine then ns.PlayAnimationSound("portraitShine") end
    render.animationCueVisible.portraitShine = visible
end

function render.BeginClosing(multiplier)
    if not entranceTimeline or render.closing then return end
    ns.SetClosingClickThrough(true)
    if bg.entranceGroup then bg.entranceGroup:Stop() end
    ns.StopAnimationSounds()
    ns.PlayAnimationSound("closing")
    local closing = { age = 0, startEffectAge = effectAge, startAge = math.min(effectAge, entranceTimeline.finish),
        speed = Speed(), multiplier = multiplier or UI_METRICS.automaticCloseSpeed, duration = UI_METRICS.modernCloseSeconds / Speed(), textures = {} }
    for _, fs in ipairs(content.statLinePool) do StopLineAnimation(fs) end
    for _, pool in ipairs(render.abilityPools) do
        for _, icon in ipairs(pool) do StopIconAnimation(icon) end
    end
    local function Capture(texture) if texture:IsShown() then closing.textures[texture]=texture:GetAlpha() end end
    for _, pool in ipairs(render.smallEffectPools) do
        for _, texture in ipairs(pool) do Capture(texture) end
    end
    Capture(content.portraitStarburst)
    for _,pool in ipairs(render.abilityPools) do for _,icon in ipairs(pool) do
        Capture(icon.newAbilityGlow);Capture(icon.ambientSparkle)
        for _,texture in ipairs(icon.cornerSparkles) do Capture(texture) end
        if icon.revealShine then Capture(icon.revealShine) end
    end end
    local effects=content.trialEffects
    if effects then
        if effects.portraitShimmer then Capture(effects.portraitShimmer) end
        for _,pool in ipairs({effects.glints,effects.depth}) do for _,texture in ipairs(pool) do Capture(texture) end end
        for _,pool in pairs(effects.impacts) do for _,texture in ipairs(pool) do Capture(texture) end end
    end
    local maxEffects = content.maxLevelEffects
    if maxEffects then
        for _, pool in ipairs(maxEffects.pools) do for _, texture in ipairs(pool) do Capture(texture) end end
    end
    local accents=content.milestoneAccents
    if accents then
        for _,pool in ipairs({accents.rings,accents.burst}) do for _,texture in ipairs(pool) do Capture(texture) end end
        for _,trail in ipairs(accents.trails) do for _,texture in ipairs(trail.textures) do Capture(texture) end end
    end
    portraitPulseGroup:Stop();content.portraitPulse:Hide()
    render.closing=closing
    render.ApplyClosingEntrance(closing.startAge)
    effectDriver:SetScript("OnUpdate",function(_,elapsed)
        local perf = ns.PerfStart("closing_frame")
        render.UpdateClosing(elapsed)
        ns.PerfEnd(perf)
    end)
end

local previewActive = false

function render.StylePaceRecord()
    local record = content.levelTimeRecord
    if not record or not record:IsShown() then return end
    local path, size, flags = content.levelTimeText:GetFont()
    for _, key in ipairs({"label", "prefix", "oldTime", "newTime"}) do
        ApplyToTextLayers(record[key], "SetFont", path, size + (key == "label" and 3 or 0), key == "label" and "THICKOUTLINE" or flags or "")
    end
end

function render.AlignPaceRecord(eased)
    local record = content.levelTimeRecord
    if not record or not record:IsShown() then return end
    record.transition = eased
    local valueWidth = record.oldWidth + (record.newWidth - record.oldWidth) * eased
    record.prefix:ClearAllPoints()
    record.prefix:SetPoint("BOTTOM", record, "BOTTOM", -(valueWidth + 4) / 2, 0)
    record.oldTime:ClearAllPoints()
    record.oldTime:SetPoint("BOTTOM", record, "BOTTOM", record.valueX, 0)
    record.newTime:ClearAllPoints()
    record.newTime:SetPoint("BOTTOM", record, "BOTTOM", record.valueX - 32 * (1 - eased), 0)
end

function render.PositionPaceRecord()
    render.StylePaceRecord()
    local record = content.levelTimeRecord
    if not record or not record:IsShown() then return end
    local widths = {}
    -- Clear old constraints before measuring: the client may report a clipped
    -- width after a font/layout change. Padding includes the heavy outline.
    for _, key in ipairs({"label", "prefix", "oldTime", "newTime"}) do
        local text = record[key]
        ApplyToTextLayers(text, "SetWordWrap", false)
        ApplyToTextLayers(text, "SetJustifyH", "CENTER")
        ApplyToTextLayers(text, "SetWidth", 0)
        ApplyToTextLayers(text, "SetHeight", 0)
        widths[key] = text:GetStringWidth()
    end
    record.oldWidth, record.newWidth = widths.oldTime, widths.newTime
    record.valueX = (widths.prefix + 4) / 2
    for _, key in ipairs({"label", "prefix", "oldTime", "newTime"}) do
        local text = record[key]
        ApplyToTextLayers(text, "SetWidth", widths[key] + (key == "label" and 12 or 8))
        ApplyToTextLayers(text, "SetHeight", key == "label" and render.LevelTimeFontSize() + 13 or content.levelTimeNaturalHeight or 18)
    end
    render.AlignPaceRecord(record.transition or 0)
    record.label:ClearAllPoints()
    record.label:SetPoint("BOTTOM", record, "BOTTOM", 0, (content.levelTimeNaturalHeight or 18) - (IsHorizontalLayout() and 4 or 0))
end

function render.PreparePaceRecord(seconds, previous)
    local record = content.levelTimeRecord
    if not record then
        record = CreateFrame("Frame", nil, content)
        record:SetAllPoints(content.levelTimeText)
        for _, key in ipairs({"label", "prefix", "oldTime", "newTime"}) do
            local text = NewText(record, "GameFontHighlightSmall", 1.5)
            text.glowAlpha = 0.08
            ApplyToTextLayers(text, "SetWordWrap", false)
            RegisterGlowFont(text)
            record[key] = text
        end
        content.levelTimeRecord = record
    end
    record.transition = 0
    record:Show()
    ApplyToTextLayers(record.label, "SetText", ns.L("New Best Time!"))
    ApplyToTextLayers(record.prefix, "SetText", ns.L("Time to Level: %s", ""):match("^(.-)%s*$"))
    ApplyToTextLayers(record.oldTime, "SetText", render.FormatLevelClock(previous))
    ApplyToTextLayers(record.newTime, "SetText", render.FormatLevelClock(seconds))
    local path, size, flags = content.levelTimeText:GetFont()
    for _, key in ipairs({"label", "prefix", "oldTime", "newTime"}) do
        ApplyToTextLayers(record[key], "SetFont", path, size + (key == "label" and 3 or 0), key == "label" and "THICKOUTLINE" or flags or "")
        ApplyToTextLayers(record[key], "SetTextColor", .25, 1, .25)
    end
    render.PositionPaceRecord()
end

function render.UpdatePaceTransition(age, moving)
    local record = content.levelTimeRecord
    if not record or not record:IsShown() then return false end
    SetLineAlpha(content.levelTimeText, 0)
    local stage = entranceTimeline and entranceTimeline.levelTime
    record:SetAlpha(EntranceAlpha(stage, age, moving))
    local elapsed = (age - (stage and stage.finish or 0)) * Speed()
    local red = moving and math.max(0, math.min(1, elapsed / .18)) or 1
    local t = moving and math.max(0, math.min(1, (elapsed - .18) / .38)) or 1
    local eased = t * t * (3 - 2 * t)
    local expansion = moving and math.max(0, math.min(1, (elapsed - .56) / .22)) or 1
    expansion = expansion * expansion * (3 - 2 * expansion)
    local extra = (render.LevelTimeFontSize() + 13 - (IsHorizontalLayout() and 4 or 0)) * expansion
    if math.abs((content.paceRowExtra or 0) - extra) > .01 then
        content.paceRowExtra = extra
        if render.ResizeTimeRow then render.ResizeTimeRow() end
    end
    local label = moving and math.max(0, math.min(1, (elapsed - .78) / .18)) or 1
    SetLineAlpha(record.prefix, 1)
    SetLineAlpha(record.label, label)
    SetLineAlpha(record.oldTime, 1 - eased)
    SetLineAlpha(record.newTime, eased)
    ApplyToTextLayers(record.oldTime, "SetTextColor", .25 + .75 * red, 1 - .75 * red, .25)
    render.AlignPaceRecord(eased)
    return moving and label < 1
end

function render.UpdateLevelTime()
    content.paceRowExtra, render.timeRowOrigin = 0, nil
    local seconds, previous = tonumber(content.currentLevelPlayedTime), tonumber(content.previousFastestLevelTime)
    if content.levelTimeRecord then content.levelTimeRecord:Hide() end
    SetLineAlpha(content.levelTimeText, EntranceAlpha(entranceTimeline and entranceTimeline.levelTime,
        effectAge, true))
    local maxLevel = content.isMaxLevel and ns.db.maxLevelCelebration ~= false
    if maxLevel and (ns.db.showLevelTime or content.pacePreview) then
        local total = ns.GetTimeToMaxLevel()
        if total then
            local duration = total >= 86400 and ns.L("%dd %02dh %02dm %02ds", math.floor(total / 86400),
                math.floor(total % 86400 / 3600), math.floor(total % 3600 / 60), math.floor(total % 60))
                or render.FormatPaceTime(total)
            ApplyToTextLayers(content.levelTimeText, "SetText", ns.L("Time to max level: %s", duration))
            render.MeasureLevelTime()
            ApplyToTextLayers(content.levelTimeText, "SetShown", true)
            return
        end
    end
    local compare = not maxLevel and (ns.db.showLevelTime or content.pacePreview) and (not previewActive or content.pacePreview)
        and seconds and previous and seconds >= 1 and previous >= 1
    local faster = compare and seconds < previous
    local visible = seconds and (ns.db.showLevelTime or content.pacePreview)
    if visible then
        local text = content.levelRangeStart
            and ns.L("Time for %d levels: %s", content.currentReachedLevel - content.levelRangeStart, render.FormatLevelClock(seconds))
            or ns.L("Time to Level: %s", render.FormatLevelClock(seconds))
        ApplyToTextLayers(content.levelTimeText, "SetText", text)
        render.MeasureLevelTime()
        if faster then render.PreparePaceRecord(seconds, previous) end
    else
        ApplyToTextLayers(content.levelTimeText, "SetText", "")
    end
    ApplyToTextLayers(content.levelTimeText, "SetShown", visible and true or false)
end

function ns.RefreshLevelPaceDisplay()
    if not frame:IsShown() then return end
    render.UpdateLevelTime()
    ns.RefreshPopupLayout()
    UpdateVisualEffects()
end

function ns.ClearLevelPaceComparison()
    content.previousFastestLevelTime = nil
    ns.RefreshLevelPaceDisplay()
end

function ns.RefreshMaxLevelCelebration()
    if ns.db.maxLevelCelebration then ns.RequestLevelPlayedTime() end
    ns.RefreshLevelPaceDisplay()
    ns.RefreshVisualEffects()
end

local function RunVisualEffects(_, elapsed)
    local perf = ns.PerfStart("visual_effects_frame", effectAge)
    -- Visible motion updates every frame; idle bursts skip their pool scans.
    effectAge = effectAge + elapsed
    if render.AdvanceStatPages then render.AdvanceStatPages(elapsed) end
    UpdateVisualEffects()
    ns.PerfEnd(perf)
end

function render.ResetMaxBackgroundTint()
    if not render.maxBackgroundTinted then return end
    render.maxBackgroundTinted, render.maxBackgroundProgress, render.maxBackgroundFlash = nil, nil, nil
    ns.ApplyBackgroundAppearance()
end


function render.UpdateMaxBackgroundTint(force)
    local db = ns.db or {}
    local maxLevel = content.isMaxLevel and db.maxLevelCelebration ~= false
    local milestone = not content.isMaxLevel and content.isMilestone and db.milestoneAnimations ~= false
    if db.backgroundMode ~= "MODERN" or not (maxLevel or milestone)
        or db.backgroundAnimations == false or db.reducedMotion or not frame:IsShown() then
        render.ResetMaxBackgroundTint()
        return false
    end
    -- The finishing spark fires after the starburst starts growing.
    local flashStart = render.ringSurgeStartedAt and math.max(render.ringSurgeStartedAt, render.PortraitGlintFinish())
    local flashAge = flashStart and (effectAge - flashStart) * Speed() or -1
    if flashAge < 0 then
        render.ResetMaxBackgroundTint()
        return false
    end
    local duration = maxLevel and .60 or .45
    if flashAge >= duration then
        if render.maxBackgroundTinted and (force or render.maxBackgroundFlash ~= 0) then
            bg.HideModernBackgroundFlash()
            local hue = db.backgroundColor or BLACK_COLOR
            bg.modern:SetVertexColor(hue[1], hue[2], hue[3], bg.appliedOpacity or db.bgOpacity or .8)
            render.maxBackgroundFlash = 0
        end
        return false
    end
    local t = flashAge / duration
    local strength = 1 - t * t * (3 - 2 * t)
    if force or render.maxBackgroundFlash ~= strength then
        local _, class = UnitClass("player")
        bg.ShowModernBackgroundFlash(ns.CLASS_COLORS[class] or WHITE_COLOR, db.backgroundColor or BLACK_COLOR,
            strength, bg.appliedOpacity or db.bgOpacity or .8, maxLevel and .6 or .4)
        render.maxBackgroundTinted, render.maxBackgroundFlash = true, strength
    end
    return true
end

ns.RefreshMaxBackgroundTint = render.UpdateMaxBackgroundTint

UpdateVisualEffects = function()
    if render.closing then return end
    local db = ns.db or {}
    local moving = true
    local speed = Speed()
    local sectionPerf = ns.PerfStart("section_entrance_frame", effectAge)
    local active = UpdateSectionEntrance(effectAge, moving)
    ns.PerfEnd(sectionPerf)
    if render.statPages and (not render.statPages.paused or render.statPages.phase ~= "waiting") then active = true end
    if render.UpdatePaceTransition(effectAge, moving) then active = true end
    if render.reducedFade then
        local t = math.max(0, math.min(1, effectAge / render.reducedFade))
        render.Alpha(frame, 1 - (1 - t) ^ 2)
        if t < 1 then active = true else render.reducedFade = nil end
    end
    local decorative = db.backgroundAnimations ~= false and not db.reducedMotion
    local portraitPerf = ns.PerfStart("portrait_effects_frame", effectAge)
    local portraitEnabled = decorative and not db.reducedMotion and db.portraitAnimation and db.portraitMode ~= "none" and frame:IsShown()
    -- Keep the portrait hidden until setup and its entrance delay are complete.
    local portraitEntrance = entranceTimeline and entranceTimeline.portrait
    local ringAlpha = EntranceAlpha(portraitEntrance, effectAge, moving)
    if decorative and moving and portraitEntrance and db.portraitAnimation and IsPlayerPortrait() then
        local t = math.max(0, math.min(1, (effectAge - portraitEntrance.start) / (portraitEntrance.finish - portraitEntrance.start)))
        ringAlpha = t * t * (3 - 2 * t)
    end
    if moving and ringAlpha < 1 and db.portraitMode ~= "none" then active = true end
    local ringSettle = 1
    if decorative and moving and portraitEntrance and db.portraitRingSettle and db.portraitMode ~= "none" then
        local t = math.max(0, math.min(1, (effectAge - portraitEntrance.start) / (portraitEntrance.finish - portraitEntrance.start)))
        -- Keep the enlarged portrait through the dim part of its fade.
        local settle = math.max(0, math.min(1, (t - 0.35) / 0.65))
        ringSettle = 1 + 0.10 * (1 - settle * settle * (3 - 2 * settle))
    end
    local ringSize = math.max(1, PortraitRingSize())
    render.Size(content.classRing, ringSize * ringSettle, ringSize * ringSettle)
    render.Size(content.classIcon, PortraitArtworkSize() * ringSettle, PortraitArtworkSize() * ringSettle)
    if content.playerModel and ns.db and ns.db.portraitMode == "player3d" then
        local diameter = ModelPortraitDiameter() * ringSettle
        render.Size(content.playerModel, diameter * ModelViewportRatio(), diameter * ModelViewportRatio())
        render.Size(content.modelBacking, diameter, diameter)
        UpdateModelMaskGeometry(diameter)
        render.SyncPlayerModelCamera()
    end
    render.Size(content.classRingGraphic, ringSize * PortraitRingScale() * ringSettle, ringSize * PortraitRingScale() * ringSettle)
    local ringOffsetX, ringOffsetY = PortraitRingOffset()
    local pointX, pointY = ringOffsetX * ringSettle, ringOffsetY * ringSettle
    if render.pointX ~= pointX or render.pointY ~= pointY then
        content.classRingGraphic:SetPoint("CENTER", content.portraitAnchor, "CENTER", pointX, pointY)
        render.pointX, render.pointY = pointX, pointY
    end
    if content.playerModel and db.portraitMode == "player3d" then
        render.Alpha(content.playerModel, ringAlpha)
        render.Shown(content.playerModel, not portraitPreparing and ringAlpha > 0)
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
    if portraitEnabled and portraitStage == "glint" and effectAge >= render.PortraitStarburstTime() then
        render.StartPortraitStarburst()
    end
    local starburst = portraitEnabled and IsPlayerPortrait()
    local starTime = effectAge - starburstStartedAt
    local growDuration = STAR_GROW_DURATION / speed
    local settleDuration = STAR_SETTLE_DURATION / speed
    local starVisible = starburst and (not moving or portraitStage == "starburst")
    if starVisible and moving and render.starburstOpacity > 0 and not render.ringSurgeStartedAt then
        render.ringSurgeStartedAt = effectAge
    end
    if starVisible and moving and render.starburstOpacity > 0 and not render.starburstSoundPlayed then
        render.starburstSoundPlayed = true
        ns.PlayStarburstSound()
    end
    if render.UpdateMaxBackgroundTint() then active = true end
    render.Shown(content.portraitStarburst, starVisible == true)
    if starburst then
        local grow = moving and (starVisible and math.max(0, math.min(1, starTime / growDuration)) or 0) or 1
        local scale = 0.18 + 0.82 * (1 - (1 - grow) ^ 3)
        local size = PortraitIconSize() * 2.2 * scale * render.milestoneStarburstScale
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
    ns.PerfEnd(portraitPerf)
    local glowPerf = ns.PerfStart("ability_glow_frame", effectAge)
    -- Stat waves follow the last count; abilities keep their own entrance clock.
    local statCountFinish = entranceTimeline and entranceTimeline.statCountFinish or fadeFinished
    local shimmerAge = effectAge - statCountFinish - 1.50
    local cycleTime = shimmerAge >= 0 and (shimmerAge % (entranceTimeline.statFlashPeriod or SHIMMER_INTERVAL)) or -1
    if not moving or not render.glowWake or effectAge >= render.glowWake then
        render.glowWake, render.glowActive = math.huge, false
        for _, pool in ipairs(render.abilityPools) do
            for _, icon in ipairs(pool) do
                local phase = AbilityShimmerTime(icon) / 0.60
                local shimmer = decorative and icon:IsShown() and db.highlightNewAbilities and icon.isNewAbility == true and moving
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
    ns.PerfEnd(glowPerf)
    local statPerf = ns.PerfStart("stat_highlights_frame", effectAge)
    local statsCounting = db.emphasizeStatGains and not db.reducedMotion and next(activeLineAnims) ~= nil
    if statsCounting and frame:IsShown() then active = true end
    local statEnabled = decorative and db.emphasizeStatGains and moving and frame:IsShown()
    local completionPending = effectAge < statCountFinish + 0.40
    local statIdle = not statEnabled or (not completionPending and (cycleTime < 0 or cycleTime >= (entranceTimeline.statFlashDuration or 0)))
    -- Clear once after the overlapping wave; skip quiet frames until its repeat.
    if not statIdle or not render.statIdle or render.statEnabled ~= statEnabled then
        render.statActive = UpdateStatHighlights(statsCounting and -1 or cycleTime, statEnabled, effectAge)
    end
    render.statIdle, render.statEnabled = statIdle, statEnabled
    if statEnabled and render.statActive then active = true end
    ns.PerfEnd(statPerf)
    local particlePerf = ns.PerfStart("ambient_particles_frame", effectAge)
    if UpdateSmallEffects(cycleTime, moving and decorative) then active = true end
    ns.PerfEnd(particlePerf)
    local milestonePerf = ns.PerfStart("milestone_accents_frame", effectAge)
    if render.UpdateMilestoneAccents() then active = true end
    ns.PerfEnd(milestonePerf)
    if render.UpdateTrialEffects() then active = true end
    local maxPerf = content.isMaxLevel and ns.PerfStart("max_celebration_frame", effectAge)
    if render.UpdateMaxCelebration() then active = true end
    ns.PerfEnd(maxPerf)
    render.UpdateAnimationSounds()
    if render.screenshotAt then
        if effectAge >= render.screenshotAt then
            render.screenshotAt = nil
            -- Capture real milestones once, after every entrance has settled.
            if db.screenshotMilestones and content.isMilestone and not previewActive
                and frame:IsShown() and type(Screenshot) == "function" then
                Screenshot()
            end
        else
            active = true
        end
    end
    effectDriver:SetScript("OnUpdate", active and frame:IsShown() and RunVisualEffects or nil)
end

function ns.RefreshVisualEffects()
    render.RefreshAnimationSoundSettings()
    if ns.db and (ns.db.reducedMotion or ns.db.backgroundAnimations == false or not ns.db.portraitAnimation) then
        ns.StopAnimationSounds()
    end
    if render.closing or frame.fadeOutGroup and frame.fadeOutGroup:IsPlaying() then return end
    if content.trialEffects then
        content.trialEffects.white = nil
        content.trialEffects.shinesFinished, content.trialEffects.impactsFinished = false, false
    end
    if content.playerModel and ns.db and ns.db.portraitMode == "player3d" then content.playerModel:SetPaused(ns.db.backgroundAnimations == false) end
    render.RefreshParticleSettings()
    local levelChanged = render.RefreshMilestoneLevelText()
    render.glowWake, render.sparkleWake, render.statIdle = nil, nil, nil
    render.ambientWake = nil
    render.sectionComplete = nil
    render.pointX, render.pointY = nil, nil
    local db = ns.db or {}
    if not db.reducedMotion and render.reducedFade then
        render.reducedFade = nil
        frame:SetAlpha(1)
    end
    pulseAlpha:SetFromAlpha(math.min(1, render.pulseOpacity * (IsHorizontalLayout() and 1.25 or 1)))
    content.portraitPulse:SetTexture("Interface\\AddOns\\GnomeLevelUp\\Textures\\Backgrounds\\circle-frame.tga")
    pulseScale:SetScaleTo((IsHorizontalLayout() and 2.1 or 1.4) * render.milestoneScale * render.milestonePortraitScale, (IsHorizontalLayout() and 2.1 or 1.4) * render.milestoneScale * render.milestonePortraitScale)
    pulseScale:SetDuration(0.65 / Speed())
    pulseAlpha:SetDuration(0.65 / Speed())
    content.edgeLayer:SetAlpha(render.edgeOpacity)
    RefreshAbilityEffectSchedule()
    -- Keep disabled effects empty until they are actually used. Once created,
    -- their textures stay pooled for later popups and live settings changes.
    if (frame:IsShown() or portraitPreparing) and not db.reducedMotion and db.backgroundAnimations ~= false then
        local portraitMotes = db.portraitSparks and db.portraitAnimation and IsPlayerPortrait()
        for i, pool in ipairs(render.particlePools) do
            if (i < 3 and portraitMotes) or (i == 3 and db.backgroundEmbers) then
                EnsureParticlePool(pool, content, render.particleSettings[i].count,
                    i == 3 and "BACKGROUND" or nil)
            end
        end
        if db.frameEdgeGlow and db.backgroundMode ~= "MODERN" then render.EnsureEdgeGlows() end
        if db.highlightNewAbilities then
            for _, pool in ipairs(render.abilityPools) do
                for _, icon in ipairs(pool) do
                    if icon:IsShown() and icon.isNewAbility == true then
                        EnsureParticlePool(icon.cornerSparkles, icon, render.particleSettings[4].count, nil, true)
                    end
                end
            end
        end
    end
    local portraitColor = ActiveColor("animatedElements")
    content.portraitStarburst:SetSize(PortraitIconSize() * 2.2 * render.milestoneStarburstScale, PortraitIconSize() * 2.2 * render.milestoneStarburstScale)
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
    if db.backgroundAnimations == false or not db.portraitAnimation or db.portraitMode == "none" or db.reducedMotion then
        portraitPulseGroup:Stop()
        content.portraitPulse:Hide()
        portraitStage = db.reducedMotion and "starburst" or "waiting"
        starburstStartedAt = effectAge
    end
    for _, pool in ipairs(render.abilityPools) do
        for _, icon in ipairs(pool) do StyleAbilityIcon(icon) end
    end
    ns.RefreshStatTextLayout()
    render.RefreshMilestoneAccents()
    if frame:IsShown() then
        local previousWidth = FRAME_WIDTH
        ApplyPopupWidth()
        if (FRAME_WIDTH ~= previousWidth or levelChanged) and ns.RefreshPopupLayout then ns.RefreshPopupLayout() end
    end
    UpdateVisualEffects()
end

local function StartVisualEffects()
    render.maxBackgroundProgress = nil
    ns.StopAnimationSounds()
    render.animationCueSeen, render.animationCueVisible = {}, {}
    render.RefreshAnimationSoundSettings()
    render.portraitImpactPlayed, render.starburstSoundPlayed = false, false
    render.ringSurgeStartedAt = nil
    render.HideMaxCelebration()
    if content.maxLevelEffects then content.maxLevelEffects.prepared = false end
    render.screenshotAt = nil
    if render.CancelHideTimer then render.CancelHideTimer() end
    render.CancelClosing()
    render.HideTrialEffects()
    if content.trialEffects then
        content.trialEffects.white = nil
        content.trialEffects.shinesFinished, content.trialEffects.impactsFinished = false, false
        for _, texture in ipairs(content.trialEffects.depth) do texture.depthStart = nil end
    end
    render.RefreshParticleSettings()
    render.RefreshMilestoneAccents()
    render.HideMilestoneAccents()
    if content.isMilestone then render.RollStatFireworks() end
    if content.milestoneAccents then
        for i, texture in ipairs(content.milestoneAccents.burst) do
            texture.burstAngle = ((i - 1) % 16) * 2 * math.pi / 16 + math.random() * 0.20
            texture.burstDistance = 64 + math.random() * 110
            texture.burstOpacity = 0.90 + math.random() * 0.20
            texture.burstSize = 4 + math.random() * 7
        end
    end
    render.glowWake, render.sparkleWake, render.statIdle = nil, nil, nil
    render.ambientWake = nil
    effectAge = 0
    render.reducedFade = nil
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
      local count = render.particleSettings[groupIndex].count
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

function render.ReleasePopupData()
    render.timeRowOrigin = nil
    render.statPages = nil
    content.secondaryStatChanges, content.statPageRowCount, content.statPage = nil, nil, nil
    content.currentLevelPlayedTime, content.previousFastestLevelTime, content.pacePreview, content.paceRowExtra = nil, nil, nil, nil
    if content.levelTimeRecord then content.levelTimeRecord:Hide() end
    content.currentStatChanges = nil
    content.levelRangeStart, content.currentReachedLevel = nil, nil
    content.currentTrainerAbilities = {}
    content.currentWarlockPetAbilities = {}
    for _, fs in ipairs(content.statLinePool) do
        ReleaseStatLine(fs)
        fs.renderedStatText, fs.renderedGainText = nil, nil
        ApplyToTextLayers(fs, "SetText", "")
        if fs.gainCounter then ApplyToTextLayers(fs.gainCounter, "SetText", "") end
    end
    for _, pool in ipairs(render.abilityPools) do
        for _, icon in ipairs(pool) do StopIconAnimation(icon) end
    end
end

frame:HookScript("OnHide", function()
    ns.SetClosingClickThrough(false)
    render.ResetMaxBackgroundTint()
    ns.StopAnimationSounds()
    render.HideMaxCelebration()
    render.screenshotAt = nil
    if render.CancelHideTimer then render.CancelHideTimer() end
    render.CancelClosing()
    render.HideTrialEffects()
    render.TintTrialImpact(0)
    HideSmallEffects()
    render.HideMilestoneAccents()
    ClearStatHighlights()
    render.ReleasePopupData()
    effectDriver:SetScript("OnUpdate", nil)
    portraitPulseGroup:Stop()
    content.portraitPulse:Hide()
    for _, pool in ipairs(render.abilityPools) do
        for _, icon in ipairs(pool) do icon.newAbilityGlow:Hide() end
    end
end)

function ns.ApplyColors()
    ns.ApplyBackgroundAppearance()
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
    local dividerColor = ActiveColor("divider")
    for _, divider in ipairs({
        content.statsHeaderDivider, content.statsBottomDivider, content.timeBottomDivider,
        content.abilitiesDivider, content.petDivider, content.petHeaderDivider, content.weaponDivider,
    }) do
        SetSectionDividerColor(divider, dividerColor)
    end
end
ns.ApplyColors()

local function UpdateStatLines(statChanges, skipAnimation, deferText)
    statChanges = ns.FilterRelevantStats(statChanges)
    local pool = content.statLinePool
    local count = #statChanges
    local speed = Speed()
    local staggerBase = BASE_STAT_STAGGER_BASE / speed
    local staggerStep = BASE_STAT_STAGGER_STEP / speed
    local slideDuration = BASE_STAT_SLIDE_DURATION / speed

    if count > 0 and not deferText then UpdateStatTracking(statChanges) end

    local function LayoutStatLine(i, statChange, plainText)
        local fs = GetStatLine(i)
        fs.gainFlash, fs.displayGain = 0, nil
        fs.statData = statChange
        fs.plainText = plainText
        if deferText then
            -- The hidden replacement page gets its final font/columns before
            -- StartLineAnimation paints it. Avoid painting twice at the old size.
            StopLineAnimation(fs)
            fs.statTracking, fs.countFinishAt, fs.entranceEnd = 0, nil, 0
            return
        end
        ApplyStatLineText(fs)
        local dir = LineDirection(i)
        local y = -((i - 1) * STAT_LINE_HEIGHT)
        local delay = staggerBase + (i - 1) * staggerStep
        fs.entranceEnd = delay + slideDuration
        if skipAnimation then
            StopLineAnimation(fs)
            fs.countFinishAt, fs.entranceEnd = nil, 0
            fs.displayGain = statChange and statChange.new - statChange.old or nil
            fs.slideFrame:ClearAllPoints()
            fs.slideFrame:SetPoint("TOP", content.statsContainer, "TOP", 0, y)
            ApplyStatLineText(fs)
            SetLineAlpha(fs, 1)
            SetLineShown(fs, true)
        else
            StartLineAnimation(fs, content.statsContainer, dir * (ThemeContentInset() > 0 and 24 or STAT_SLIDE_DISTANCE_X), y, delay, slideDuration)
        end
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

    content.statsContainer:SetHeight(math.max(count, content.statPageRowCount or 0) * STAT_LINE_HEIGHT)
    return count
end

-- Only the stat rows/header change pages; portrait, abilities and footer keep
-- their original timeline. Reserve the taller page once to prevent frame jumps.
function render.AdvanceStatPages(elapsed)
    local page = render.statPages
    if not page or render.closing or frame.closingInputSuppressed then return end
    local previousAge = page.lastAge or 0
    page.lastAge = effectAge
    if page.paused and page.phase == "waiting" then return end
    if page.phase == "waiting" then
        page.holdAge = page.holdAge + math.max(0, effectAge - math.max(previousAge, entranceTimeline.finish))
        if page.holdAge < page.halfDuration then return end
        page.phase, page.age = "exiting", 0
        for _, text in ipairs(content.statLinePool) do StopLineAnimation(text) end
    end
    page.age = page.age + elapsed
    if page.phase == "exiting" then
        local progress = math.min(1, page.age / (BASE_STAT_SLIDE_DURATION / Speed() * page.animationScale))
        SetLineAlpha(content.statsHeader, (1 - progress)^2)
        for index, text in ipairs(content.statLinePool) do
            if text.statData or text.plainText then
                local distance = ns.db.statSlideDirection == "none" and 0
                    or LineDirection(index) * (ThemeContentInset() > 0 and 24 or STAT_SLIDE_DISTANCE_X)
                text.slideFrame:SetPoint("TOP", content.statsContainer, "TOP", distance * progress^3, -(index-1)*STAT_LINE_HEIGHT)
                SetLineAlpha(text, (1 - progress)^2)
            end
        end
        if progress < 1 then return end
        local perf = ns.PerfStart("stat_page_swap", effectAge)
        content.statPage = "secondary"
        content.currentStatChanges = content.secondaryStatChanges
        ApplyToTextLayers(content.statsHeader, "SetText", ns.L("Secondary Stats"))
        render.headingFitKey = nil
        UpdateStatLines(content.currentStatChanges, true, true)
        -- The second page can be wider than the first. Fit it to the existing
        -- column instead of widening the live popup or drawing across its border.
        FitStatFont(TEXT_WIDTH, true)
        render.UpdateStatWordTargets()
        -- Both page heights were reserved at popup creation; existing relative
        -- anchors follow them. Only the changed heading needs to be fitted.
        render.FitSectionHeadings()
        entranceTimeline.statFlashStart, entranceTimeline.statFlashFinish = nil, nil
        for index, text in ipairs(content.statLinePool) do
            if text.statData then
                local delay = (BASE_STAT_STAGGER_BASE+(index-1)*BASE_STAT_STAGGER_STEP)/Speed() * page.animationScale
                local duration = BASE_STAT_SLIDE_DURATION/Speed() * page.animationScale
                StartLineAnimation(text, content.statsContainer,
                    LineDirection(index) * (ThemeContentInset() > 0 and 24 or STAT_SLIDE_DISTANCE_X),
                    -(index-1)*STAT_LINE_HEIGHT, delay, duration, page.animationScale)
                text.entranceMotion.clockOffset = effectAge
                text.entranceEnd = effectAge + delay + duration
                if text.countFinishAt then
                    text.countFinishAt = effectAge + text.countFinishAt
                    entranceTimeline.statFlashStart = math.min(entranceTimeline.statFlashStart or text.countFinishAt, text.countFinishAt)
                    entranceTimeline.statFlashFinish = math.max(entranceTimeline.statFlashFinish or text.countFinishAt, text.countFinishAt)
                end
            end
        end
        entranceTimeline.statFlashDuration = entranceTimeline.statFlashStart
            and entranceTimeline.statFlashFinish - entranceTimeline.statFlashStart + .4 or 0
        entranceTimeline.statFlashPeriod = entranceTimeline.statFlashDuration + 3
        render.statIdle, render.glowWake = nil, nil
        page.phase, page.age = "entering", 0
        ns.PerfEnd(perf)
    end
    if page.phase == "entering" then
        SetLineAlpha(content.statsHeader, math.min(1, page.age / (.18 / Speed() * page.animationScale))^2)
        if page.age >= (BASE_STAT_STAGGER_BASE + math.max(0,#content.currentStatChanges-1)*BASE_STAT_STAGGER_STEP + 1)/Speed() * page.animationScale then
            render.statPages = nil
        end
    end
end

function render.ReflowStatsForFont()
    UpdateStatLines(content.currentStatChanges or {}, true)
end

function ns.RefreshTextSizes()
    ns.ApplyFont(ns.db.customFontPath)
end

function ns.RefreshRetailStatOptions()
    if ns.GetCurrentFlavor() ~= "retail" or not frame:IsShown() then return end
    UpdateStatLines(content.currentStatChanges or {}, true)
    ns.RefreshPopupLayout()
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
    for _, fs in ipairs(content.statLinePool) do if fs.statData or fs.plainText then statCount = statCount + 1 end end
    local stats = Add("stats", BASE_STAT_SLIDE_DURATION + math.max(0, statCount - 1) * BASE_STAT_STAGGER_STEP)
    local index = 0
    for _, fs in ipairs(content.statLinePool) do
        if fs.statData or fs.plainText then
            local delay = stats.start + index * BASE_STAT_STAGGER_STEP / speed
            local duration = BASE_STAT_SLIDE_DURATION / speed
            fs.entranceEnd = delay + duration
            StartLineAnimation(fs, content.statsContainer, LineDirection(index + 1) * (ThemeContentInset() > 0 and 24 or STAT_SLIDE_DISTANCE_X),
                -index * STAT_LINE_HEIGHT, delay, duration)
            index = index + 1
        end
    end
    plan.statCountFinish = stats.finish
    for _, fs in ipairs(content.statLinePool) do
        if fs.statData and fs.countFinishAt then
            plan.statCountFinish = math.max(plan.statCountFinish, fs.countFinishAt)
            plan.statFlashStart = math.min(plan.statFlashStart or fs.countFinishAt, fs.countFinishAt)
            plan.statFlashFinish = math.max(plan.statFlashFinish or fs.countFinishAt, fs.countFinishAt)
        end
    end
    plan.statFlashDuration = plan.statFlashStart and plan.statFlashFinish - plan.statFlashStart + 0.40 or 0
    plan.statFlashPeriod = plan.statFlashDuration + 3.00
    plan.statsBottom = { start = stats.finish - 0.12 / speed, finish = stats.finish }
    if content.levelTimeText:IsShown() then Add("levelTime", 0.18) end
    local trainingStart = cursor
    local showAbilities = ns.GetCurrentFlavor() ~= "retail" or #(content.currentTrainerAbilities or {}) > 0
    if showAbilities then Add("abilitiesHeader", 0.18) end
    local function AddIcons(key, pool)
        local count, animatedCount = 0, 0
        for _, icon in ipairs(pool) do
            if icon:IsShown() then
                count = count + 1
                if not icon.skipEntrance then animatedCount = animatedCount + 1 end
            end
        end
        local duration = BASE_STAT_SLIDE_DURATION + math.max(0, animatedCount - 1) * BASE_STAT_STAGGER_STEP
        if key == "abilities" and not showAbilities then duration = 0 end
        local stage = Add(key, duration)
        stage.count = count
        stage.animatedCount = animatedCount
        stage.shimmerReady = count > 0 and stage.start
            + (BASE_STAT_SLIDE_DURATION + math.max(0, math.min(animatedCount, 9) - 1) * BASE_STAT_STAGGER_STEP) / speed
            or stage.start
        local ordinal = 0
        for _, icon in ipairs(pool) do
            if icon:IsShown() then
                local delay = stage.start + ordinal * BASE_STAT_STAGGER_STEP / speed
                icon.entranceEnd = icon.skipEntrance and stage.start or delay + BASE_STAT_SLIDE_DURATION / speed
                StartIconPop(icon, icon.animationContainer, icon.animationX, icon.animationY,
                    delay, BASE_STAT_SLIDE_DURATION / speed, icon.skipEntrance)
                if not icon.skipEntrance then ordinal = ordinal + 1 end
            end
        end
    end
    AddIcons("abilities", content.abilityIconPool)
    if content.petSpellsHeader:IsShown() then
        local abilityFinish = cursor
        cursor = trainingStart
        Add("petHeader", 0.18)
        AddIcons("petAbilities", content.petAbilityIconPool)
        cursor = math.max(cursor, abilityFinish)
    end
    if content.weaponSkillsText:IsShown() then Add("weapon", 0.22) end
    plan.finish = cursor
    if ns.db and ns.db.emphasizeStatGains then
        for _, fs in ipairs(content.statLinePool) do
            if fs.statData and fs.statData.new ~= fs.statData.old then
                plan.finish = math.max(plan.finish, fs.entranceEnd + (1.0 - BASE_STAT_SLIDE_DURATION) / speed)
            end
        end
    end
    if ns.db and ns.db.backgroundAnimations ~= false and ns.db.dividerReveal then
        for _, stage in ipairs({ plan.statsHeader, plan.statsBottom }) do
            plan.finish = math.max(plan.finish, stage.start + 0.60 / speed)
        end
        for _, key in ipairs({ "levelTime", "abilitiesHeader", "petHeader", "weapon" }) do
            if plan[key] then plan.finish = math.max(plan.finish, plan[key].start + 0.60 / speed) end
        end
    end
    plan.abilityEffectsStart = plan.finish
    if plan.abilities.count > 9 or (plan.petAbilities and plan.petAbilities.count > 9) then
        plan.abilityEffectsStart = math.max(plan.abilities.shimmerReady,
            plan.petAbilities and plan.petAbilities.shimmerReady or 0)
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
    statCount = math.max(statCount, content.statPageRowCount or 0)
    render.MeasureLevelTime()
    local borderInset = ThemeContentInset()
    local gap = SectionGap()
    local h = SectionPadding() + PortraitRingSize() + render.PortraitLevelGap()
    h = h + TextHeight(content.levelText, 18)
    h = h + 22 + TextHeight(content.statsHeader, 18)
    h = h + gap + SECTION_DIVIDER_HEIGHT + gap
        + statCount * STAT_LINE_HEIGHT
    h = h + gap + SECTION_DIVIDER_HEIGHT + gap
    if content.levelTimeText:IsShown() then
        h = h + 2 + content.levelTimeText:GetHeight()
        h = h + gap + SECTION_DIVIDER_HEIGHT + gap
    end
    if ns.GetCurrentFlavor() ~= "retail" or #(content.currentTrainerAbilities or {}) > 0 then
        h = h + TextHeight(content.spellsHeader, 16)
        h = h + gap + SECTION_DIVIDER_HEIGHT + render.AbilitySectionPadding()
            + (content.abilityViewport:GetHeight() or ABILITY_ICON_SIZE)
    end
    if content.petSpellsHeader:IsShown() then
        h = h + gap + SECTION_DIVIDER_HEIGHT + gap
        h = h + TextHeight(content.petSpellsHeader, 16)
        h = h + gap + SECTION_DIVIDER_HEIGHT + render.AbilitySectionPadding()
            + (content.petAbilityViewport:GetHeight() or ABILITY_ICON_SIZE)
    end
    if content.weaponSkillsText:IsShown() then
        h = h + gap + SECTION_DIVIDER_HEIGHT + gap
            + math.max(18, TextHeight(content.weaponSkillsText, 18))
    end
    local abilitiesLast = not content.weaponSkillsText:IsShown()
        and (content.abilityViewport:IsShown() or content.petAbilityViewport:IsShown())
    h = h + (abilitiesLast and render.AbilitySectionPadding() or SectionPadding())
    content:ClearAllPoints()
    if IsHorizontalLayout() then
        local statsHeight = 24 + TextHeight(content.statsHeader, 18) + gap * 2 + SECTION_DIVIDER_HEIGHT + statCount * STAT_LINE_HEIGHT
        if content.levelTimeText:IsShown() then statsHeight = statsHeight + 2 + content.levelTimeText:GetHeight() end
        -- Keep the established frame budget. The visible grid has three rows;
        -- additional skills scroll instead of squeezing a fourth row into it.
        content.portraitFit = 1
        local naturalHeight = math.max(statsHeight + 38, PortraitRingSize() * PortraitRingScale() + 50)
        for _, viewport in ipairs({content.abilityViewport, content.petAbilityViewport}) do
            if (viewport == content.abilityViewport and content.spellsHeader:IsShown())
                or (viewport == content.petAbilityViewport and content.petSpellsHeader:IsShown()) then
                local header = viewport == content.abilityViewport and content.spellsHeader or content.petSpellsHeader
                viewport.layoutScale = 1
                viewport:SetScale(1)
                if ns.WrapOptionsText then ns.WrapOptionsText(header, TrainingWidth(viewport), "CENTER"); SyncTextGeometry(header) end
                local reserve = 24 + TextHeight(header, 18) + gap + SECTION_DIVIDER_HEIGHT + render.AbilitySectionPadding() * 2
                naturalHeight = math.max(naturalHeight, reserve + 4 * (viewport.cellHeight or AbilityCellHeight(NewAbilityIconSize())))
            end
        end
        local maximum = math.max(1, math.min(350, UIParent:GetHeight() - 40)) / ns.GetPopupScale()
        local statsTop = 24 + TextHeight(content.statsHeader, 18) + gap * 2 + SECTION_DIVIDER_HEIGHT
        local hasTime = content.levelTimeText:IsShown()
        local blockHeight = statCount * STAT_LINE_HEIGHT
            + (hasTime and gap + content.levelTimeText:GetHeight() or 0)
        local lowerInset = 22
        local required = statsTop + blockHeight + gap * 2
        naturalHeight = math.max(naturalHeight, required + lowerInset)
        if naturalHeight > maximum and maximum > lowerInset then
            naturalHeight = math.max(naturalHeight, required / (1 - lowerInset / maximum))
        end
        ApplyPopupWidth()
        local fit = math.min(1, maximum / naturalHeight)
        local panelHeight = naturalHeight * fit
        -- Borders fit inside the same outer dimensions as Modern.
        if borderInset > 0 then
            fit = math.max(0.001, math.min(fit,
                (FRAME_WIDTH - borderInset * 2) / FRAME_WIDTH,
                (panelHeight - borderInset * 2) / naturalHeight))
        end
        PositionSections()
        local main, pet = content.abilityViewport, content.petAbilityViewport
        local hasPet = content.petSpellsHeader:IsShown()
        local bottomAbilityInset = ns.db and ns.db.backgroundMode == "MODERN" and 20 / fit or 0
        local minimumAbilityPadding = ns.db and ns.db.backgroundMode == "MODERN"
            and UI_METRICS.modernAbilityPadding or UI_METRICS.texturedAbilityPadding
        local abilityPadding = math.max(render.AbilitySectionPadding(), minimumAbilityPadding / fit)
        local topGap = UI_METRICS.abilityTopGap / fit
        for _, viewport in ipairs({main, pet}) do
            local count = viewport.abilityCount or 0
            if count > 0 then
                local header = viewport == main and content.spellsHeader or content.petSpellsHeader
                local divider = viewport == main and content.abilitiesDivider or content.petHeaderDivider
                local abilityTop = 24 + TextHeight(header,18) + gap + SECTION_DIVIDER_HEIGHT + topGap
                local height = math.max(1, naturalHeight-bottomAbilityInset-abilityPadding-abilityTop)
                viewport:ClearAllPoints();viewport:SetPoint("TOP",divider,"BOTTOM",0,-topGap)
                viewport.abilityPadding = abilityPadding
                if count <= 9 then
                    viewport:SetHeight(height)
                    -- The child fills the viewport; icons start at its top edge.
                    viewport.row:SetHeight(height)
                    viewport.row:ClearAllPoints()
                    viewport.row:SetPoint("TOPLEFT", viewport, "TOPLEFT", 0, 0)
                    viewport.scrollMaximum = 0
                else
                    local visibleHeight = math.min(viewport:GetHeight(), height)
                    viewport:SetHeight(visibleHeight)
                    viewport.scrollMaximum = math.max(0, (viewport.rowContentHeight or 0) - visibleHeight)
                end
            end
        end
        main.sharedScroll = true
        main.sharedMaximum = math.max(main.scrollMaximum or 0, hasPet and pet.scrollMaximum or 0)
        main.scrollController = main.slider
        pet.scrollController = hasPet and main.slider or nil
        main.slider:SetParent(content)
        main.scrollTrack:SetParent(content)
        main.slider:ClearAllPoints()
        main.scrollTrack:ClearAllPoints()
        local barX = hasPet and 14 or 10
        main.slider:SetOrientation("VERTICAL")
        main.slider:SetWidth(SCROLLBAR_HEIGHT)
        main.scrollTrack:SetWidth(2)
        main.slider:SetPoint("TOP", main, "TOPRIGHT", barX, 0)
        main.slider:SetHeight(math.max(main:GetHeight(), hasPet and pet:GetHeight() or 0))
        main.scrollTrack:SetPoint("TOP", main.slider, "TOP", 0, 0)
        main.scrollTrack:SetHeight(main.slider:GetHeight())
        main.slider:SetMinMaxValues(0, main.sharedMaximum)
        local value = math.max(0, math.min(main.sharedMaximum, main.requestedScroll or 0))
        main.slider:SetValue(value)
        main.slider:GetScript("OnValueChanged")(main.slider, value)
        main.slider:SetShown(main.sharedMaximum > 0)
        main.scrollTrack:SetShown(main.sharedMaximum > 0)
        pet.slider:Hide()
        pet.scrollTrack:Hide()
        local thumb = main.slider:GetThumbTexture()
        if thumb then
            local height = main.slider:GetHeight()
            thumb:SetSize(8, math.max(20, height * height / (height + main.sharedMaximum)))
        end
        ns.RefreshPortraitGeometry(true)
        content.portraitPulse:SetSize(PortraitRingSize() * 1.1, PortraitRingSize() * 1.1)
        content:SetScale(fit)
        content:SetSize(FRAME_WIDTH, naturalHeight)
        local bottomClearance = ns.db and ns.db.backgroundMode ~= "MODERN" and content.isMaxLevel
            and UI_METRICS.texturedHorizontalMaxBottomPadding or 0
        -- Grow downward so portrait/level placement keeps its existing top margin.
        content:SetPoint("CENTER", frame, "CENTER", 0, bottomClearance / 2)
        local inset = 26 / fit
        content.statsContainer:ClearAllPoints()
        content.statsContainer:SetPoint("TOP", content.statsHeaderDivider, "BOTTOM", 0, -topGap)
        if hasTime then
            content.levelTimeText:ClearAllPoints()
            content.levelTimeText:SetPoint("BOTTOM", content, "BOTTOMLEFT",
                24 + PortraitColumnWidth() + 18 + TEXT_WIDTH / 2, inset)
        end
        h = panelHeight + bottomClearance
    else
        -- Reserve room below the last section before fitting textured content;
        -- otherwise ability icons can sit on the bottom border artwork.
        if ns.db and ns.db.backgroundMode ~= "MODERN" then
            h = h + UI_METRICS.texturedVerticalBottomPadding
        end
        content.portraitFit = 1
        content:SetScale(1)
        if borderInset > 0 then
            local fit = math.max(0.001, math.min(1,
                (FRAME_WIDTH - borderInset * 2) / FRAME_WIDTH,
                (h - borderInset * 2) / h))
            content:SetScale(fit)
            content:SetSize(FRAME_WIDTH, h)
            content:SetPoint("CENTER", frame, "CENTER", 0, 0)
        else
            content:SetAllPoints(frame)
        end
        for _, viewport in ipairs({content.abilityViewport, content.petAbilityViewport}) do viewport.layoutScale=1;viewport:SetScale(1) end
        for _, header in ipairs({content.spellsHeader, content.petSpellsHeader}) do
            ApplyToTextLayers(header, "SetWidth", TEXT_WIDTH)
            ApplyToTextLayers(header, "SetHeight", 0)
            ApplyToTextLayers(header, "SetWordWrap", false)
            ApplyToTextLayers(header, "SetJustifyH", "CENTER")
            ApplyToTextLayers(header, "SetJustifyV", "MIDDLE")
        end
    end
    closeButton:ClearAllPoints()
    closeButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -8, -8)
    frame:SetHeight(h)
    render.PositionPaceRecord()
    if IsHorizontalLayout() then
        for _, entry in ipairs({{content.abilityViewport,content.abilityIconPool},{content.petAbilityViewport,content.petAbilityIconPool}}) do
            local viewport,pool=entry[1],entry[2]
            if (viewport.abilityCount or 0)>3 then
                for i=1,viewport.abilityCount do
                    local icon=pool[i]
                    local row=i<=9 and (i-1)%3 or 3+math.floor((i-10)/3)
                    local y=viewport.row:GetHeight()/2-icon:GetHeight()/2-row*viewport.cellHeight
                    icon.animationY=y;icon:ClearAllPoints()
                    icon:SetPoint("CENTER",viewport.row,"CENTER",icon.animationX,y-(activeIconAnims[icon] and ABILITY_POP_DISTANCE or 0))
                end
            end
        end
    end
    render.FitSparseAbilityIcons(content.abilityViewport, content.abilityIconPool)
    render.FitSparseAbilityIcons(content.petAbilityViewport, content.petAbilityIconPool)
    LayoutBackground()
end

-- Grow only the timing row; keep the current animation timeline and icon state.
function render.ResizeTimeRow()
    if not render.timeRowOrigin then
        render.timeRowOrigin = { height = frame:GetHeight(), point = { frame:GetPoint() } }
    end
    render.MeasureLevelTime()
    PositionSections()
    local count = math.max(1, math.floor(content.statsContainer:GetHeight() / STAT_LINE_HEIGHT + .5))
    LayoutFrame(count)
    -- Preserve the footer's bottom while the extra line grows upward.
    local origin = render.timeRowOrigin
    local point = origin.point
    if point[1] and point[2] and point[3] and point[4] and point[5] then
        local fraction = point[1]:find("TOP", 1, true) and 1 or point[1]:find("BOTTOM", 1, true) and 0 or .5
        frame:ClearAllPoints()
        frame:SetPoint(point[1], point[2], point[3], point[4], point[5] + (frame:GetHeight() - origin.height) * frame:GetScale() * fraction)
    end
end

-- Refresh projection after layout without asynchronously reloading the unit.
function render.RefreshPlayerModelLayout()
    local model = content.playerModel
    if not model or not ns.db or ns.db.portraitMode ~= "player3d" then return end
    local horizontal, scale, fit = IsHorizontalLayout(), ns.GetPopupScale(), content:GetScale()
    if model.layoutHorizontal == horizontal and model.layoutPopupScale == scale and model.layoutFit == fit then return end
    model.layoutHorizontal, model.layoutPopupScale, model.layoutFit = horizontal, scale, fit
    if modelMaskState then modelMaskState.inset, modelMaskState.scale = nil, nil end
    render.ApplyPlayerModelCamera(model)
end

local function RefreshPopupLayoutNow()
    if render.closing or frame.fadeOutGroup and frame.fadeOutGroup:IsPlaying() then return end
    local perf = ns.PerfStart("popup_layout")
    frame:SetScale(ns.GetPopupScale())
    ApplyPopupWidth()
    ns.RefreshPortraitGeometry()
    UpdateTrainerAbilityIcons(content.currentTrainerAbilities or {}, true)
    UpdateWarlockPetAbilityIcons(content.currentWarlockPetAbilities or {}, true)
    UpdateWeaponSkillText(content.currentWeaponSkills or {})
    ns.RefreshVisualEffects()
    PositionSections()
    local statCount = math.max(1, math.floor((content.statsContainer:GetHeight() or STAT_LINE_HEIGHT) / STAT_LINE_HEIGHT + 0.5))
    LayoutFrame(statCount)
    ns.PositionFrame(frame)
    render.RefreshPlayerModelLayout()
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
bg.entranceGroup = bgAnim
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

function render.BeginFadeOut(multiplier)
    ns.SetClosingClickThrough(true)
    fadeOut:SetDuration(UI_METRICS.texturedCloseSeconds / Speed() / (multiplier or UI_METRICS.automaticCloseSpeed))
    frame.fadeOutGroup:Play()
end

local hideToken = 0
local previewSuspended = false
local fadeDeadline
local remainingPreviewTime

function render.CancelHideTimer()
    if render.hideTimer then render.hideTimer:Cancel(); render.hideTimer = nil end
end

function render.ArmHideTimer(delay, token, callback)
    render.CancelHideTimer()
    local function Fire()
        if token ~= hideToken then return end
        render.hideTimer = nil
        callback()
    end
    if type(C_Timer.NewTimer) == "function" then
        render.hideTimer = C_Timer.NewTimer(delay, Fire)
    else
        C_Timer.After(delay, Fire)
    end
end

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
        render.ArmHideTimer(0.15, token, function() TryFadeOut(token) end)
        return
    end
    if ns.db and ns.db.backgroundMode == "MODERN" then
        render.BeginClosing()
    else
        render.BeginFadeOut()
    end
end

local function ScheduleFadeOut(delay)
    render.CancelHideTimer()
    hideToken = hideToken + 1
    local token = hideToken
    delay = math.max(0, delay or 0)
    fadeDeadline = GetTime() + delay
    if ShouldSuspendPreview() then
        previewSuspended = true
        if render.statPages then render.statPages.paused = true end
        remainingPreviewTime = delay
        return
    end
    render.ArmHideTimer(delay, token, function() TryFadeOut(token) end)
end
ns.RescheduleFadeOut = ScheduleFadeOut

-- Only pause the timeout for a manually requested preview. Real level-ups
-- retain their usual timer, position, scale, animation, and layout.
function ns.RefreshPreviewSuspension()
    if not previewActive or not frame:IsShown() or frame.closingInputSuppressed then return end
    if ShouldSuspendPreview() then
        if previewSuspended then return end
        remainingPreviewTime = math.max(0, (fadeDeadline or GetTime()) - GetTime())
        previewSuspended = true
        if render.statPages then render.statPages.paused = true end
        hideToken = hideToken + 1
        render.CancelHideTimer()
        if frame.fadeOutGroup:IsPlaying() then frame.fadeOutGroup:Stop() end
        render.CancelClosing()
        UpdateVisualEffects()
        frame:SetAlpha(1)
    elseif previewSuspended then
        local remaining = remainingPreviewTime or 0
        previewSuspended = false
        if render.statPages then render.statPages.paused = false end
        remainingPreviewTime = nil
        ScheduleFadeOut(remaining)
        UpdateVisualEffects()
    end
end

function ns.DismissLevelUp()
    if not frame:IsShown() or render.closing then return end
    bgAnim:Stop()
    bg:SetAlpha(1)
    previewActive, previewSuspended = false, false
    remainingPreviewTime = nil
    hideToken = hideToken + 1
    render.CancelHideTimer()
    if ns.db and ns.db.backgroundMode == "MODERN" then
        render.BeginClosing(UI_METRICS.manualCloseSpeed)
    else
        render.BeginFadeOut(UI_METRICS.manualCloseSpeed)
    end
end

function ns.CloseLevelUp()
    previewActive = false
    previewSuspended = false
    remainingPreviewTime = nil
    hideToken = hideToken + 1
    render.CancelHideTimer()
    for _, fs in ipairs(content.statLinePool) do StopLineAnimation(fs) end
    for _, icon in ipairs(content.abilityIconPool) do StopIconAnimation(icon) end
    for _, icon in ipairs(content.petAbilityIconPool) do StopIconAnimation(icon) end
    bgAnim:Stop()
    if frame.fadeOutGroup:IsPlaying() then frame.fadeOutGroup:Stop() end
    render.ReleasePopupData()
    frame:SetAlpha(1)
    frame:Hide()
end


-- Once an exit starts, pointer movement must not restart the popup.
frame:SetScript("OnEnter", nil)


local function ShowLevelUpImpl(currentLevel, statChanges, trainerAbilities, unlearnedWeaponSkills, timePlayedThisLevel, warlockPetAbilities, milestone, previousFastest, secondaryStats)
    -- Prepare the content, play the animations, and show the panel.
    local db = ns.db or {}
    if db.enabled == false then return end

    local speed = Speed()

    content.isMilestone = milestone == true

    -- Hide the previous portrait before refreshing textures and anchors.
    portraitPreparing = true
    content.portraitArtwork:Hide()
    if content.playerModel then content.playerModel:SetAlpha(0); content.playerModel:Hide() end
    content:SetAlpha(0)
    content.currentTrainerAbilities = trainerAbilities or {}
    content.currentWarlockPetAbilities = ns.GetCurrentFlavor() ~= "retail" and warlockPetAbilities or {}
    ApplyPopupWidth()
    frame:SetScale(ns.GetPopupScale())
    EnsureAllTextGlows()
    ns.RefreshClassIcon()
    content.currentReachedLevel = currentLevel
    ApplyToTextLayers(content.levelText, "SetText", content.levelRangeStart
        and ns.L("Level %d - %d", content.levelRangeStart, currentLevel) or ns.L("Level %d", currentLevel))
    render.RefreshMilestoneLevelText()

    render.statPages = nil
    content.statPage = "primary"
    ApplyToTextLayers(content.statsHeader, "SetText", ns.L("Stats Gained"))
    content.secondaryStatChanges = db.showSecondaryStats and secondaryStats or nil
    content.statPageRowCount = content.secondaryStatChanges and math.max(#ns.FilterRelevantStats(statChanges or {}), #content.secondaryStatChanges) or nil
    content.currentStatChanges = statChanges or {}
    local statCount = UpdateStatLines(content.currentStatChanges)
    -- Current stats must be measured before the first visible frame.
    ApplyPopupWidth()

    content.currentLevelPlayedTime, content.previousFastestLevelTime = timePlayedThisLevel, previousFastest
    render.UpdateLevelTime()

    content.currentWarlockPetAbilities = warlockPetAbilities or {}
    UpdateTrainerAbilityIcons(trainerAbilities or {})
    UpdateWarlockPetAbilityIcons(warlockPetAbilities or {})
    UpdateWeaponSkillText(unlearnedWeaponSkills or {})

    PositionSections()
    LayoutFrame(statCount)
    ns.RefreshPortraitGeometry(true)
    render.RefreshPlayerModelLayout()

    BuildEntranceTimeline()
    bgFade:SetDuration(BASE_BG_FADE_DURATION / speed)

    bgAnim:Stop()
    bgAnim:Play()

    ns.PositionFrame(frame)

    frame:SetAlpha(1) -- undo any leftover fade-out alpha from a previous close
    if frame.fadeOutGroup:IsPlaying() then
        frame.fadeOutGroup:Stop()
    end
    RefreshCloseButtonLabel()
    -- Reset the previous popup's effect clock and portrait alpha before Show.
    local entranceDuration = entranceTimeline.finish
    StartVisualEffects()
    if db.screenshotMilestones and content.isMilestone and not previewActive then
        render.screenshotAt = entranceDuration + .15
    end
    content:SetAlpha(1)
    frame:Show()
    portraitPreparing = false
    -- Arm cleanup before optional effects or sound can fail.
    local lifetime = entranceDuration + (db.duration or 7)
    render.popupLifetime = lifetime
    if content.secondaryStatChanges and #content.secondaryStatChanges > 0 then
        local halfDuration = (db.duration or 7)/2
        local animationLength = (BASE_STAT_SLIDE_DURATION + BASE_STAT_STAGGER_BASE
            + math.max(0,#content.secondaryStatChanges-1)*BASE_STAT_STAGGER_STEP + 1)/Speed()
        render.statPages = {phase = "waiting", holdAge = 0, halfDuration = halfDuration,
            animationScale = math.min(1, halfDuration / animationLength),
            lastAge = 0, paused = ShouldSuspendPreview()}
    end
    ScheduleFadeOut(lifetime)
    UpdateVisualEffects()

    local soundOK, soundError = pcall(ns.PlayLevelUpSound)
    if not soundOK then
        print("|cffff4040GnomeLevelUp|r: " .. ns.L("Play sound on level up") .. ": " .. tostring(soundError))
    end
end

function ns.ShowLevelUp(currentLevel, statChanges, trainerAbilities, unlearnedWeaponSkills, timePlayedThisLevel, warlockPetAbilities, isPreview, milestonePreview, previousFastest, maxLevelPreview, pacePreview, rangeStart, secondaryStats)
    ns.EnsureDatabase()
    ns.SetClosingClickThrough(false)
    hideToken = hideToken + 1
    render.CancelHideTimer()
    if frame.fadeOutGroup:IsPlaying() then frame.fadeOutGroup:Stop() end
    render.CancelClosing()
    content.pacePreview = isPreview == true and pacePreview == true
    previewActive = isPreview == true
    previewSuspended = false
    remainingPreviewTime = nil
    local level = tonumber(currentLevel)
    rangeStart = tonumber(rangeStart)
    content.levelRangeStart = rangeStart and level and rangeStart >= 1 and rangeStart % 1 == 0 and rangeStart < level - 1 and rangeStart or nil
    content.isMaxLevel = level ~= nil and level == ns.GetLevelCap() and (not isPreview or maxLevelPreview == true)
    -- Ordinary previews stay normal; /glu milestone opts into the celebration.
    local milestone = (not isPreview or milestonePreview == true) and level and level > 0
        and (level % 10 == 0 or content.levelRangeStart and math.floor(level / 10) > math.floor(content.levelRangeStart / 10))
    local perf = ns.PerfStart("popup_prepare")
    local ok, err = pcall(ShowLevelUpImpl, currentLevel, statChanges, trainerAbilities, unlearnedWeaponSkills, timePlayedThisLevel, warlockPetAbilities, milestone, previousFastest, secondaryStats)
    ns.PerfEnd(perf)
    if not ok then
        print("|cffff4040GnomeLevelUp " .. ns.L("error:") .. "|r " .. tostring(err))
        print("|cffff4040GnomeLevelUp:|r " .. ns.L("The level-up screen failed to display (see above). Please report this error."))
    end
end
