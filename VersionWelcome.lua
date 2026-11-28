local ADDON_NAME, ns = ...

-- A personal release letter, deliberately independent of appearance profiles.
-- The account marker is outside the resettable/exported settings.
local window, ready, loading, scheduled = nil, false, false, false
local textureRoot = "Interface\\AddOns\\GnomeLevelUp\\Textures\\"
local WIDTH, MARGIN = 680, 52
local PORTRAIT_SCALE = 1.15
local EMPHASIS, NORMAL = "|cffffd775", "|r"
local paragraphs = {
    "Yo! Sorry to get in the way. I just want to say thank you to all of you for checking out "
        .. EMPHASIS .. "GnomeLevelUp" .. NORMAL .. " over the last few months. I've met a bunch of you in game both in live and the beta, and you've been nothing but lovely.",
    "With this update, " .. EMPHASIS .. "GLU" .. NORMAL .. " is in what I'd consider a \"feature complete\" state. Anything else I add now might be redundant and bloat the addon, but just in case you missed it here are the major features of this update (and the last few.)",
    "- " .. EMPHASIS .. "A timeline to show your upcoming abilities!" .. NORMAL
        .. "\n- " .. EMPHASIS .. "Full custom theme support!" .. NORMAL
        .. " (Check out my Curse page for an example addon on how to do it!)"
        .. "\n- " .. EMPHASIS .. "Background effects that match the weather." .. NORMAL
        .. " (I know this is dumb, I just wanted to see if I could do it)"
        .. "\n- " .. EMPHASIS .. "Synchronized best times with your guildies!" .. NORMAL,
    "Again, thank you all for your support. I never expected this goofy lil addon would reach "
        .. EMPHASIS .. "22k unique users" .. NORMAL .. " but somehow it did.",
    "Love from Lessa <3",
}

local function EligibleVersion()
    local metadata = C_AddOns and C_AddOns.GetAddOnMetadata or GetAddOnMetadata
    local version = metadata and metadata(ADDON_NAME, "Version")
    return type(version) == "string" and tonumber(version:match("^[vV]?(%d+)%.%d+")) == 2
end

local function Resize()
    if not window then return end
    local top = 218 + 126 * (PORTRAIT_SCALE - 1)
    for _, text in ipairs(window.paragraphs) do
        text:ClearAllPoints()
        text:SetPoint("TOPLEFT", window, "TOPLEFT", MARGIN, -top)
        text:SetWidth(WIDTH - MARGIN * 2)
        top = top + math.ceil(text:GetStringHeight()) + 19
    end
    local height = top + 67
    window:SetSize(WIDTH, height)
    local scale = math.min(1, math.max(.1, (UIParent:GetWidth() - 32) / WIDTH),
        math.max(.1, (UIParent:GetHeight() - 32) / height))
    window:SetScale(scale)
    ns.LayoutThemeFrame(window.theme, window, window.pieces, window.backing, WIDTH, height)
    ns.PaintThemePiece(window.backing, "center", window.theme.textures.center, 1, true, window.appearance)
    for name, texture in pairs(window.pieces) do
        if name == "center" then texture:Hide()
        else ns.PaintThemePiece(texture, name, window.theme.textures[name], 1, true, window.appearance) end
    end
end

local function RefreshControllerHint()
    if not window then return end
    local style = ns.IsControllerUIActive() and (ns.db.controllerGlyphStyle or "xbox") or "none"
    if style ~= "playstation" and style ~= "nintendo" and style ~= "none" then style = "xbox" end
    if window.controllerStyle == style then return end
    window.controllerStyle = style
    local visible = style ~= "none"
    local applied = visible and ns.ApplyControllerGlyph(window.closeIcon, "back", style)
    window.closeIcon:SetShown(applied == true)
    window.closeGlyph:SetShown(visible and not applied)
    window.closeGlyph:SetText(style == "playstation" and "○" or style == "nintendo" and "A" or "B")
end

local function UpdateControllerBinding()
    if not window then return end
    if not window:IsShown() then
        if window.controllerBound and type(ClearOverrideBindings) == "function" then
            local cleared = pcall(ClearOverrideBindings, window)
            if cleared then window.controllerBound = false end
        end
    elseif not window.controllerBound and type(SetOverrideBindingClick) == "function"
        and not (InCombatLockdown and InCombatLockdown()) then
        window.controllerBound = pcall(SetOverrideBindingClick, window, true, "PAD2",
            "GnomeLevelUpWelcomeClose", "LeftButton")
    end
end

local function BuildWindow()
    if window then return window end
    window = CreateFrame("Frame", "GnomeLevelUpVersionWelcome", UIParent)
    window:Hide()
    window:SetFrameStrata("DIALOG")
    window:SetPoint("CENTER", UIParent, "CENTER")
    window:EnableMouse(true)
    window:SetClampedToScreen(true)
    window.theme = ns.GetCompositeTheme("GNOMEREGAN", "GNOMEREGAN")
    window.appearance = { backgroundStyle = "fill", backgroundChoice = "GNOMEREGAN",
        backgroundColor = { 1, 1, 1 }, frameColor = { 1, 1, 1 },
        backgroundTextureTransforms = window.theme.appearance.backgroundTextureTransforms }
    window.backing = window:CreateTexture(nil, "BACKGROUND", nil, -8)
    window.pieces = {}
    for _, name in ipairs({ "topLeft", "top", "topRight", "left", "center", "right", "bottomLeft", "bottom", "bottomRight" }) do
        local edge = name == "top" or name == "bottom" or name == "left" or name == "right"
        window.pieces[name] = window:CreateTexture(nil, "BACKGROUND", nil, edge and -7 or -6)
    end
    window.shade = window:CreateTexture(nil, "BACKGROUND", nil, -5)
    window.shade:SetColorTexture(0, 0, 0, .48)
    window.shade:SetPoint("TOPLEFT", window, "TOPLEFT", 27, -27)
    window.shade:SetPoint("BOTTOMRIGHT", window, "BOTTOMRIGHT", -27, 27)

    window.portrait = CreateFrame("Frame", nil, window)
    window.portrait:SetSize(126 * PORTRAIT_SCALE, 126 * PORTRAIT_SCALE)
    window.portrait:SetPoint("TOP", window, "TOP", 0, -24)
    window.avatar = window.portrait:CreateTexture(nil, "ARTWORK")
    window.avatar:SetAllPoints(window.portrait)
    window.avatar:SetTexture(textureRoot .. "lessaheart.tga")
    if window.portrait.CreateMaskTexture and window.avatar.AddMaskTexture then
        window.mask = window.portrait:CreateMaskTexture()
        window.mask:SetAllPoints(window.portrait)
        window.mask:SetTexture("Interface\\CharacterFrame\\TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
        window.avatar:AddMaskTexture(window.mask)
    end
    window.ring = window.portrait:CreateTexture(nil, "OVERLAY")
    window.ring:SetTexture(ns.PORTRAIT_RING_TEXTURES.STEEL.texture)
    window.ring:SetSize(146 * PORTRAIT_SCALE, 146 * PORTRAIT_SCALE)
    window.ring:SetPoint("CENTER", window.portrait, "CENTER")

    local font = ns.GetPopupFontPath(ns.DEFAULT_FONT_PATH)
    window.title = window:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    window.title:SetFont(font, 27, "OUTLINE")
    window.title:SetPoint("TOP", window.portrait, "BOTTOM", 0, -13)
    window.title:SetWidth(WIDTH - MARGIN * 2)
    window.title:SetJustifyH("CENTER")
    window.title:SetTextColor(1, .84, .42)
    window.title:SetText("GnomeLevelUp 2.0!")
    window.paragraphs = {}
    for _, value in ipairs(paragraphs) do
        local text = window:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        text:SetFont(font, 16, "")
        text:SetTextColor(.96, .94, .88)
        text:SetShadowColor(0, 0, 0, 1)
        text:SetShadowOffset(1, -1)
        text:SetJustifyH("LEFT")
        text:SetWordWrap(true)
        text:SetSpacing(4)
        text:SetText(value)
        window.paragraphs[#window.paragraphs + 1] = text
    end
    window.close = CreateFrame("Button", "GnomeLevelUpWelcomeClose", window, "UIPanelButtonTemplate")
    window.close:SetSize(300, 32)
    window.close:SetPoint("BOTTOM", window, "BOTTOM", 0, 31)
    window.close:SetText("Get off my screen, gnome.")
    window.close:RegisterForClicks("AnyDown", "AnyUp")
    window.closeIcon = window.close:CreateTexture(nil, "OVERLAY")
    window.closeIcon:SetSize(24, 24)
    window.closeIcon:SetPoint("LEFT", window.close, "LEFT", 10, 0)
    window.closeGlyph = window.close:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    window.closeGlyph:SetAllPoints(window.closeIcon)
    window.closeGlyph:SetJustifyH("CENTER")
    window.closeGlyph:SetJustifyV("MIDDLE")
    window.close:SetScript("OnClick", function() window:Hide() end)
    window:SetScript("OnShow", function()
        RefreshControllerHint()
        UpdateControllerBinding()
    end)
    window:SetScript("OnHide", function()
        window.automatic = false
        UpdateControllerBinding()
    end)
    local controllerElapsed = 0
    window:SetScript("OnUpdate", function(_, elapsed)
        controllerElapsed = controllerElapsed + elapsed
        if controllerElapsed < .2 then return end
        controllerElapsed = 0
        RefreshControllerHint()
    end)
    UISpecialFrames = UISpecialFrames or {}
    UISpecialFrames[#UISpecialFrames + 1] = "GnomeLevelUpVersionWelcome"
    Resize()
    return window
end

function ns.ShowVersionWelcome(preview)
    ns.EnsureDatabase()
    local panel = BuildWindow()
    Resize()
    panel.automatic = preview ~= true
    panel:Show()
    if panel.automatic then GnomeLevelUpDB.welcome2Seen = true end
    return panel
end

function ns.MaybeShowVersionWelcome()
    if not ready or loading or not EligibleVersion() or not ns.db or ns.db.enabled == false
        or GnomeLevelUpDB.welcome2Seen or not ns.db.firstTimeSetupCompleted
        or InCombatLockdown and InCombatLockdown() then return false end
    if window and window:IsShown() then return false end
    ns.ShowVersionWelcome(false)
    return true
end

local events = CreateFrame("Frame")
events:RegisterEvent("PLAYER_LOGIN")
events:RegisterEvent("PLAYER_ENTERING_WORLD")
events:RegisterEvent("LOADING_SCREEN_ENABLED")
events:RegisterEvent("LOADING_SCREEN_DISABLED")
events:RegisterEvent("PLAYER_REGEN_ENABLED")
events:RegisterEvent("DISPLAY_SIZE_CHANGED")
events:RegisterEvent("UI_SCALE_CHANGED")
events:SetScript("OnEvent", function(_, event)
    if event == "PLAYER_REGEN_ENABLED" then UpdateControllerBinding() end
    if event == "DISPLAY_SIZE_CHANGED" or event == "UI_SCALE_CHANGED" then Resize(); return end
    if event == "LOADING_SCREEN_ENABLED" then loading = true; return end
    if event == "LOADING_SCREEN_DISABLED" then loading = false end
    if event == "PLAYER_ENTERING_WORLD" then ready = true end
    if scheduled then return end
    scheduled = true
    local function check() scheduled = false; ns.MaybeShowVersionWelcome() end
    if C_Timer and C_Timer.After then C_Timer.After(2, check) else check() end
end)
