local ADDON_NAME, ns = ...

-- Register a cheap settings shell after saved settings load. Controls and text
-- measurements are deferred until the first actual opening of this panel.
local PANEL_NAME = "GnomeLevelUp"
local panel, registeredWith

local testWatermarkPath

-- Keep each artwork's original aspect ratio while using the same display height.
local WATERMARK_DIMENSIONS = {
    ["options-watermark"] = { width = 235, height = 400 },
    ["options-watermark-h"] = { width = 287, height = 400 },
    ["options-watermark-wv"] = { width = 254, height = 400 },
    ["options-watermark-forever"] = { width = 379, height = 400 },
}
local WATERMARK_HEIGHT = 300

local function GetWatermarkName(texturePath)
    return texturePath and texturePath:match("([^\\/]+)$")
end

local function SizeWatermark(watermark, texturePath)
    local dimensions = WATERMARK_DIMENSIONS[GetWatermarkName(texturePath)]
        or WATERMARK_DIMENSIONS["options-watermark"]
    watermark:SetSize(WATERMARK_HEIGHT * dimensions.width / dimensions.height, WATERMARK_HEIGHT)
end

local function GetSeasonalWatermark()
    local today = date("*t")

    if today.month == 10 then
        if today.day == 31 then
            return nil
        end
        return "Interface\\AddOns\\GnomeLevelUp\\Textures\\options-watermark-h"
    elseif today.month == 11 then
        return "Interface\\AddOns\\GnomeLevelUp\\Textures\\options-watermark-forever"
    elseif today.month == 12 then
        return "Interface\\AddOns\\GnomeLevelUp\\Textures\\options-watermark-wv"
    end

    return "Interface\\AddOns\\GnomeLevelUp\\Textures\\options-watermark"
end

function ns.RefreshOptionsWatermark(watermark)
    local texturePath = testWatermarkPath or GetSeasonalWatermark()
    if texturePath then
        SizeWatermark(watermark, texturePath)
        watermark:SetTexture(texturePath)
        watermark:SetAlpha(0.40)
        watermark:Show()
    else
        watermark:Hide()
    end
end

function ns.SetOptionsWatermarkTest(fileName)
    if type(fileName) ~= "string" then return false end
    fileName = fileName:match("^%s*(.-)%s*$")
    if fileName == "" or fileName:lower() == "clear" then
        testWatermarkPath = nil
    else
        if fileName:find("[\\/]") then return false end
        fileName = fileName:gsub("%.[tT][gG][aA]$", "")
        if fileName == "" or not fileName:match("^[%w_.%-]+$") then return false end
        testWatermarkPath = "Interface\\AddOns\\GnomeLevelUp\\Textures\\" .. fileName
    end
    if panel and panel.gluWatermark then ns.RefreshOptionsWatermark(panel.gluWatermark) end
    if ns.RefreshControllerOptionsWatermark then ns.RefreshControllerOptionsWatermark() end
    return true
end

local function BuildOptions()
    if panel.gluOptionsBuilt then return end

    -- Keep the settings page compact and aligned with Blizzard's panels.
    local LEFT = 16
    local CONTROL_X = 160
    local APPEARANCE_SHIFT = 50
    local WHITE_COLOR = { 1, 1, 1 }
    local BLACK_COLOR = { 0, 0, 0 }

    local FONT_CHOICES = {
        { value = STANDARD_TEXT_FONT or "Fonts\\FRIZQT__.TTF", label = "Default font", previewFont = STANDARD_TEXT_FONT or "Fonts\\FRIZQT__.TTF" },
        { value = "Fonts\\ARIALN.TTF",    label = "Arial Narrow", previewFont = "Fonts\\ARIALN.TTF" },
        { value = "Fonts\\SKURRI.TTF",    label = "Skurri", previewFont = "Fonts\\SKURRI.TTF" },
        { value = "Fonts\\MORPHEUS.TTF",  label = "Morpheus", previewFont = "Fonts\\MORPHEUS.TTF" },
    }

    -- LibSharedMedia is optional; use it when another addon has registered fonts.
    local sharedMedia
    local function AddSharedMediaFonts()
        if not LibStub then return end
        local ok, media = pcall(LibStub, "LibSharedMedia-3.0", true)
        if not ok or not media or not media.List or not media.Fetch then return end
        sharedMedia = media

        for _, name in ipairs(media:List("font") or {}) do
            local path = media:Fetch("font", name)
            if path and path ~= "" then
                FONT_CHOICES[#FONT_CHOICES + 1] = {
                    value = path,
                    label = name,
                    previewFont = path,
                }
            end
        end
    end
    AddSharedMediaFonts()

    -- Treat LibSharedMedia sounds like named custom sounds in the sound dropdown.
    local function AddSharedMediaSounds()
        if not sharedMedia then return end
        ns.CUSTOM_SOUND_CHOICES = ns.CUSTOM_SOUND_CHOICES or {}
        for _, name in ipairs(sharedMedia:List("sound") or {}) do
            local path = sharedMedia:Fetch("sound", name)
            if path and path ~= "" then
                local choice = {
                    value = "LSM_SOUND_" .. name,
                    label = name,
                    path = path,
                }
                ns.SOUND_CHOICES[#ns.SOUND_CHOICES + 1] = choice
            end
        end
    end
    AddSharedMediaSounds()

    -- The panel is registered with either the modern or legacy settings API below.

    local controllerOptionsButton
    local controllerLauncherOwner
    local controllerLauncherBound = false
    local refreshControllerOpenGlyph
    local lastControllerActive, lastControllerGlyphStyle
    local controllerPollElapsed = 0

    local function RefreshControllerOptionsButton()
        if not controllerOptionsButton then return end
        local active = ns.IsControllerUIActive()
        active = active == true
        local glyphStyle = ns.db and ns.db.controllerGlyphStyle
        if active ~= lastControllerActive then controllerOptionsButton:SetShown(active) end
        if active ~= lastControllerActive or glyphStyle ~= lastControllerGlyphStyle then
            if refreshControllerOpenGlyph then refreshControllerOpenGlyph(active) end
        end
        lastControllerActive, lastControllerGlyphStyle = active, glyphStyle
        if active then
            local inCombat = type(InCombatLockdown) == "function" and InCombatLockdown()
            if not inCombat and controllerLauncherOwner and type(SetOverrideBindingClick) == "function" then
                if not controllerLauncherOwner:IsShown() then controllerLauncherOwner:Show() end
                local expected = "CLICK " .. (controllerOptionsButton:GetName() or "") .. ":LeftButton"
                local current
                if type(GetBindingAction) == "function" then
                    local ok, value = pcall(GetBindingAction, "PAD1", true)
                    if ok then current = value end
                end
                if current ~= expected then
                    local ok = pcall(SetOverrideBindingClick, controllerLauncherOwner, true,
                        "PAD1", controllerOptionsButton:GetName(), "LeftButton")
                    controllerLauncherBound = ok
                end
            end
        elseif controllerLauncherBound then
            -- Retry after combat rather than losing track of a live binding.
            if type(InCombatLockdown) == "function" and InCombatLockdown() then return end
            if controllerLauncherOwner and type(ClearOverrideBindings) == "function"
                and not (type(InCombatLockdown) == "function" and InCombatLockdown()) then
                pcall(ClearOverrideBindings, controllerLauncherOwner)
            end
            if controllerLauncherOwner then controllerLauncherOwner:Hide() end
            controllerLauncherBound = false
        end
    end

    -- Keep the character artwork as a subtle watermark behind the settings.
    local watermark = panel:CreateTexture(nil, "BACKGROUND")
    watermark:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -24, 18)
    watermark:SetAlpha(0.40)
    panel.gluWatermark = watermark
    local function RefreshSeasonalWatermark() ns.RefreshOptionsWatermark(watermark) end

    RefreshSeasonalWatermark()

    local body, optionsScroll
    do
        local ok, scroll = pcall(CreateFrame, "ScrollFrame", "GnomeLevelUpOptionsScroll", panel, "UIPanelScrollFrameTemplate")
        if ok and scroll then
            optionsScroll = scroll
            scroll:SetPoint("TOPLEFT", panel, "TOPLEFT", 4, -8)
            scroll:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -28, 8)
            body = CreateFrame("Frame", nil, scroll)
            body:SetSize(560, 900)
            scroll:SetScrollChild(body)
        else
            body = panel
        end
    end

    -- Create the launcher under its final scroll child. Reparenting it later can
    -- leave it outside Forever's controller focus group.
    controllerOptionsButton = CreateFrame(
        "Button", "GnomeLevelUpControllerOptionsLauncher", body, "UIPanelButtonTemplate")
    controllerOptionsButton:SetSize(240, 26)
    controllerOptionsButton:SetPoint("TOPRIGHT", body, "TOPRIGHT", -8, -8)
    controllerOptionsButton:SetText(ns.L("Open Controller Options"))
    controllerOptionsButton:SetScript("OnClick", function()
        if ns.OpenControllerOptionsWhenFree then ns.OpenControllerOptionsWhenFree() end
    end)
    controllerOptionsButton:Hide()
    controllerLauncherOwner = CreateFrame("Frame", "GnomeLevelUpControllerLauncherBindings", UIParent)
    controllerLauncherOwner:Hide()

    local controllerOpenGlyph = controllerOptionsButton:CreateTexture(nil, "ARTWORK")
    controllerOpenGlyph:SetSize(24, 24)
    controllerOpenGlyph:SetPoint("RIGHT", controllerOptionsButton, "LEFT", -6, 0)
    local controllerOpenGlyphText = controllerOptionsButton:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    controllerOpenGlyphText:SetSize(24, 24)
    controllerOpenGlyphText:SetPoint("RIGHT", controllerOptionsButton, "LEFT", -6, 0)
    controllerOpenGlyphText:SetJustifyH("CENTER")
    controllerOpenGlyphText:SetJustifyV("MIDDLE")
    controllerOpenGlyphText:SetTextColor(1, 1, 1, 1)
    refreshControllerOpenGlyph = function(active)
        if not active or not ns.db or ns.db.controllerGlyphStyle == "none" then
            controllerOpenGlyph:Hide()
            controllerOpenGlyphText:Hide()
            return
        end
        local style = ns.db.controllerGlyphStyle
        local applied = ns.ApplyControllerGlyph(controllerOpenGlyph, "select", style)
        if applied then
            controllerOpenGlyphText:Hide()
            controllerOpenGlyph:Show()
        else
            controllerOpenGlyph:Hide()
            controllerOpenGlyphText:SetText(style == "playstation" and "X" or "A")
            controllerOpenGlyphText:Show()
        end
    end

    local refreshers = {}
    local y = -16
    local sections = {}
    local currentSection

    -- The original row identifiers preserve setting order; measured cells own
    -- positioning, wrapping, collapse visibility and debug-only visibility.
    local optionLayout = ns.CreateOptionsLayout(body)
    local function LayoutCell(kind, rowY, x, label, control, widgets, debugOnly, extra)
        local cell = extra or {}
        cell.kind, cell.y, cell.x = kind, rowY, x
        cell.label, cell.control = label, control
        cell.section, cell.debugOnly = currentSection, debugOnly
        return optionLayout:Replace(widgets, cell)
    end
    local function TrackElement(element, x, rowY, debugOnly)
        if not element then return end
        local text = element:GetObjectType() == "FontString"
        LayoutCell(text and "text" or "widget", rowY, x,
            text and element or nil, text and nil or element, { element }, debugOnly)
    end
    local function ReflowSections()
        optionLayout:Reflow()
    end

    -- Section headers share the same vertical rhythm as the controls beneath them.
    local function AddSectionHeader(text, key)
        text = ns.L(text)
        y = y - 6
        local headerY = y
        local section = {
            key = key or text:lower():gsub("[^%w]+", "_"),
            title = text,
            headerY = headerY,
            collapsed = ns.db and ns.db.collapsedSections and ns.db.collapsedSections[key or text:lower():gsub("[^%w]+", "_")] == true,
        }
        sections[#sections + 1] = section
        currentSection = section

        local header = CreateFrame("Button", nil, body)
        header:SetSize(520, 26)
        header:SetPoint("TOPLEFT", body, "TOPLEFT", LEFT - 4, headerY + 4)
        header:SetHighlightTexture("Interface\\Buttons\\UI-Listbox-Highlight", "ADD")
        section.header = header
        TrackElement(header, LEFT - 4, headerY + 4)

        local fs = body:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        fs:SetPoint("LEFT", header, "LEFT", 4, 0)
        fs:SetText((section.collapsed and "[+] " or "[-] ") .. text)
        section.label = fs
        header:SetScript("OnClick", function()
            section.collapsed = not section.collapsed
            ns.db.collapsedSections[section.key] = section.collapsed or nil
            fs:SetText((section.collapsed and "[+] " or "[-] ") .. text)
            ReflowSections()
        end)
        LayoutCell("header", headerY, LEFT, fs, header, { header, fs })
        y = y - 30
    end

    local function AddLabel(text, rowY, x, debugOnly, debugRowY, debugRowHeight)
        text = ns.L(text)
        local fs = body:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        fs:SetPoint("TOPLEFT", body, "TOPLEFT", x or LEFT, rowY - 5)
        fs:SetWidth(140)
        fs:SetWordWrap(true)
        fs:SetText(text)
        LayoutCell("text", rowY, x or LEFT, fs, nil, { fs }, debugOnly)
        return fs
    end

    local function AddButton(text, width, x, rowY, onClick, debugOnly, debugRowY, debugRowHeight)
        text = ns.L(text)
        local btn = CreateFrame("Button", nil, body, "UIPanelButtonTemplate")
        btn:SetSize(width, 22)
        btn:SetText(text)
        btn:SetPoint("TOPLEFT", body, "TOPLEFT", x, rowY)
        btn:SetScript("OnClick", onClick)
        LayoutCell("button", rowY, x, nil, btn, { btn }, debugOnly, { preferredWidth = width })
        return btn
    end

    local function OpenColorPicker(color, onChange)
        local r, g, b = color[1], color[2], color[3]
        local revision = ns.colorPaletteRevision
        local function apply(nr, ng, nb)
            if ns.colorPaletteRevision == revision then onChange(nr, ng, nb) end
        end
        local function swatchFunc()
            local nr, ng, nb = ColorPickerFrame:GetColorRGB()
            apply(nr, ng, nb)
        end
        local function cancelFunc()
            apply(r, g, b)
        end
        if ColorPickerFrame.SetupColorPickerAndShow then
            ColorPickerFrame:SetupColorPickerAndShow({
                r = r, g = g, b = b, hasOpacity = false,
                swatchFunc = swatchFunc, cancelFunc = cancelFunc,
            })
        else
            ColorPickerFrame.hasOpacity = false
            ColorPickerFrame.opacityFunc = nil
            ColorPickerFrame.func = swatchFunc
            ColorPickerFrame.cancelFunc = cancelFunc
            ColorPickerFrame.previousValues = { r = r, g = g, b = b }
            ColorPickerFrame:SetColorRGB(r, g, b)
            ColorPickerFrame:Hide()
            ColorPickerFrame:Show()
        end
    end

    local function AddStepper(labelText, formatValue, getValue, adjust, debugOnly, debugRowY, debugRowHeight, leftOverride, controlXOverride, rowYOverride)
        local rowY = rowYOverride or y
        local left = leftOverride or LEFT
        local controlX = controlXOverride or CONTROL_X
        local trackedRowY = debugRowY or rowY
        local label = AddLabel(labelText, rowY, left, debugOnly, trackedRowY, debugRowHeight)
        local valueText = body:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        valueText:SetPoint("TOPLEFT", body, "TOPLEFT", controlX + 30, rowY - 5)
        valueText:SetWidth(60)
        valueText:SetJustifyH("CENTER")
        TrackElement(valueText, controlX + 30, rowY - 5, debugOnly)
        local function refresh() valueText:SetText(formatValue(getValue())); ReflowSections() end
        local minus = AddButton("-", 24, controlX, rowY, function()
            adjust(-1)
            refresh()
        end, debugOnly, trackedRowY, debugRowHeight)
        local plus = AddButton("+", 24, controlX + 96, rowY, function()
            adjust(1)
            refresh()
        end, debugOnly, trackedRowY, debugRowHeight)
        LayoutCell("stepper", rowY, left, label, nil, { label, valueText, minus, plus }, debugOnly,
            { value = valueText, minus = minus, plus = plus })
        refreshers[#refreshers + 1] = refresh
        if not rowYOverride then y = y - 34 end
        return refresh
    end

    local dropdownCount = 0

    local function AddDropdown(labelText, choices, getCurrent, onSelect, rowYOverride, widthOverride, leftOverride, controlXOverride, debugOnly, debugRowHeight)
        dropdownCount = dropdownCount + 1
        local rowY = rowYOverride or y
        local labelX = leftOverride or LEFT
        local controlX = controlXOverride or CONTROL_X
        local label = AddLabel(labelText, rowY, labelX, debugOnly, rowY, debugRowHeight)
        local dd = CreateFrame("Frame", "GnomeLevelUpDropdown" .. dropdownCount, body, "UIDropDownMenuTemplate")
        dd:SetPoint("TOPLEFT", body, "TOPLEFT", controlX - 16, rowY + 2)
        TrackElement(dd, controlX - 16, rowY + 2, debugOnly)
        UIDropDownMenu_SetWidth(dd, widthOverride or 190)

        local function GetChoiceLabel(value)
            local menuChoices = type(choices) == "function" and choices() or choices
            for i, c in ipairs(menuChoices) do
                if c.value == value then return ns.LocalizeChoiceLabel(c) end
            end
            return ns.LocalizeChoiceLabel(menuChoices[1])
        end

        UIDropDownMenu_Initialize(dd, function(_, level)
            if not ns.db then return end
            local menuChoices = type(choices) == "function" and choices() or choices
            for i, c in ipairs(menuChoices) do
                local menuItem = UIDropDownMenu_CreateInfo()
                menuItem.text = ns.LocalizeChoiceLabel(c)
                menuItem.checked = (getCurrent() == c.value)
                if c.previewFont then
                    c.fontObject = c.fontObject or CreateFont("GnomeLevelUpFontChoice" .. dropdownCount .. "_" .. i)
                    c.fontObject:SetFont(c.previewFont, 13, "")
                    menuItem.fontObject = c.fontObject
                end
                menuItem.func = function()
                    onSelect(c.value)
                    UIDropDownMenu_SetText(dd, ns.LocalizeChoiceLabel(c))
                    CloseDropDownMenus()
                    ReflowSections()
                end
                UIDropDownMenu_AddButton(menuItem, level)
            end
        end)

        LayoutCell("dropdown", rowY, labelX, label, dd, { label, dd }, debugOnly,
            { preferredWidth = widthOverride or 180 })
        local function refresh() UIDropDownMenu_SetText(dd, GetChoiceLabel(getCurrent())) end
        refreshers[#refreshers + 1] = refresh
        if not rowYOverride then y = y - 36 end
        return refresh, dd, label
    end

    local function AddCheckbox(labelText, getValue, setValue, xOverride, rowYOverride, debugOnly, debugRowHeight, debugRowY)
        labelText = ns.L(labelText)
        local rowY = rowYOverride or y
        local left = xOverride or LEFT
        local cb
        for _, template in ipairs({ "UICheckButtonTemplate", "InterfaceOptionsCheckButtonTemplate" }) do
            local ok, made = pcall(CreateFrame, "CheckButton", nil, body, template)
            if ok and made then cb = made break end
        end
        if not cb then
            cb = CreateFrame("CheckButton", nil, body)
            cb:SetNormalTexture("Interface\\Buttons\\UI-CheckBox-Up")
            cb:SetPushedTexture("Interface\\Buttons\\UI-CheckBox-Down")
            cb:SetHighlightTexture("Interface\\Buttons\\UI-CheckBox-Highlight", "ADD")
            cb:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check")
        end
        cb:SetSize(26, 26)
        cb:SetPoint("TOPLEFT", body, "TOPLEFT", left - 2, rowY + 2)
        TrackElement(cb, left - 2, rowY + 2, debugOnly)
        cb:SetScript("OnClick", function(self) setValue(self:GetChecked() and true or false) end)
        local fs = body:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        fs:SetPoint("LEFT", cb, "RIGHT", 4, 0)
        fs:SetWidth((labelText == ns.L("Lock Location") and 118)
            or (labelText == ns.L("Compact Layout") and 138)
            or (labelText == ns.L("Suspend Preview") and 205) or 230)
        fs:SetWordWrap(true)
        fs:SetText(labelText)
        LayoutCell("checkbox", rowY, left, fs, cb, { fs, cb }, debugOnly)
        refreshers[#refreshers + 1] = function() cb:SetChecked(getValue() and true or false) end
        if not rowYOverride then y = y - 32 end
        return cb, fs, rowY
    end

    local function AddCheckboxPair(first, second, firstX, secondX)
        local rowY = y
        local firstCheck, firstLabel = AddCheckbox(first[1], first[2], first[3], firstX or LEFT, rowY)
        local secondCheck, secondLabel = AddCheckbox(second[1], second[2], second[3], secondX or (LEFT + 270), rowY)
        y = y - 32
        return firstCheck, firstLabel, secondCheck, secondLabel
    end

    local function AddAvailabilityRefresh(checkButton, label, isAvailable)
        local section = currentSection
        refreshers[#refreshers + 1] = function()
            local available = isAvailable()
            local visible = not (section and section.collapsed)
            checkButton:SetShown(visible)
            label:SetShown(visible)
            if checkButton.SetEnabled then checkButton:SetEnabled(available) end
            label:SetTextColor(available and 1 or 0.45, available and 1 or 0.45, available and 1 or 0.45)
        end
    end

    do
        local title = body:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
        title:SetPoint("TOPLEFT", body, "TOPLEFT", LEFT, y)
        title:SetText(ns.L(PANEL_NAME))

        local version = body:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        version:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -2)
        version:SetTextColor(0.70, 0.70, 0.70)
        local addonVersion = _G["GetAddOnMetadata"] and _G["GetAddOnMetadata"](ADDON_NAME, "Version") or "1.4.0"
        version:SetText(ns.L("Version %s", tostring(addonVersion or "1.4.0")))

        local byline = body:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        byline:SetPoint("TOPLEFT", version, "BOTTOMLEFT", 0, -2)
        byline:SetText(ns.L("By Lessá-ArgentDawn"))

        y = y - 68
    end

    AddSectionHeader("Appearance", "appearance")

    local appearanceRow = y
    AddDropdown("Portrait", ns.PORTRAIT_CHOICES,
        function() return ns.db.portraitMode or "class" end,
        function(value)
            ns.db.portraitMode = value
            ns.RefreshClassIcon()
            ns.RefreshPopupLayout()
        end, appearanceRow, 140, LEFT, CONTROL_X)

    local portraitRingDropdown
    if ns.PORTRAIT_RING_CHOICES then
        portraitRingDropdown = AddDropdown("Portrait ring", ns.PORTRAIT_RING_CHOICES,
            function()
                if ns.db.portraitRingChoice and not (ns.db.portraitRingChoice == "NONE" and ns.db.portraitRingTexture) then
                    return ns.db.portraitRingChoice
                end
                for _, choice in ipairs(ns.PORTRAIT_RING_CHOICES) do
                    local reference = ns.GetPortraitRingReference(choice.value)
                    if reference and reference == ns.db.portraitRingTexture then return choice.value end
                end
                return "NONE"
            end,
            function(value)
                ns.db.portraitRingChoice = value
                local reference = ns.GetPortraitRingReference(value)
                ns.db.portraitRingTexture = reference
                ns.db.portraitRingEnabled = reference ~= nil
                ns.RefreshPortraitRing()
            end, appearanceRow, 140, LEFT + 270 + APPEARANCE_SHIFT, CONTROL_X + 220 + APPEARANCE_SHIFT)
    end
    y = appearanceRow - 36

    local appearanceThemeRow = y
    local refreshTheme, themeDropdown = AddDropdown("Theme", ns.THEME_CHOICES or {},
        function()
            return ns.db.backgroundMode == "MODERN" and "MODERN" or (ns.db.backgroundTheme or "MODERN")
        end,
        function(value)
            ns.ApplyBackgroundTheme(value)
        end, appearanceThemeRow, 140, LEFT, CONTROL_X)

    local refreshBackground, backgroundDropdown = AddDropdown("Background", ns.BACKGROUND_TEXTURE_CHOICES or {},
        function() return ns.db.backgroundChoice or "NONE" end,
        function(value)
            ns.ApplyBackgroundChoice(value)
        end, appearanceThemeRow, 140, LEFT + 270 + APPEARANCE_SHIFT, CONTROL_X + 220 + APPEARANCE_SHIFT)
    y = appearanceThemeRow - 36

    local appearanceFrameRow = y
    local refreshBackgroundTexture, backgroundTextureDropdown = AddDropdown("Background texture", ns.BACKGROUND_FILL_CHOICES,
        function()
            if ns.db.backgroundStyle == "fill" or ns.db.backgroundStyle == "tile"
                or ns.db.backgroundStyle == "stretch" then return ns.db.backgroundStyle end
            return ns.db.backgroundFillMode == "tile" and "tile" or "stretch"
        end,
        function(value)
            ns.db.backgroundStyle = value
            ns.db.backgroundFillMode = value == "tile" and "tile" or "scale"
            ns.ApplyBackgroundAppearance()
        end, appearanceFrameRow, 140, LEFT, CONTROL_X)

    local refreshFrame, frameDropdown = AddDropdown("Frame", ns.FRAME_CHOICES or {},
        function() return ns.db.frameChoice or "BLACK_METAL" end,
        function(value)
            ns.ApplyFrameChoice(value)
        end, appearanceFrameRow, 140, LEFT + 270 + APPEARANCE_SHIFT, CONTROL_X + 220 + APPEARANCE_SHIFT)
    y = appearanceFrameRow - 36

    local function RefreshThemeAvailability()
        local modern = ns.db and ns.db.backgroundMode == "MODERN"
        local controls = { backgroundDropdown, frameDropdown, backgroundTextureDropdown }
        for _, control in ipairs(controls) do
            if control then
                if modern then UIDropDownMenu_DisableDropDown(control)
                else UIDropDownMenu_EnableDropDown(control) end
            end
        end
    end
    refreshers[#refreshers + 1] = function()
        if refreshTheme then refreshTheme() end
        if refreshBackground then refreshBackground() end
        if refreshFrame then refreshFrame() end
        if refreshBackgroundTexture then refreshBackgroundTexture() end
        RefreshThemeAvailability()
    end

    local function AddColorPicker(labelText, getColor, setColor, xOverride, rowYOverride, debugOnly)
        local rowY = rowYOverride or y
        local left = xOverride or LEFT
        local label = AddLabel(labelText, rowY, left, debugOnly, rowY, 34)
        local swatch = CreateFrame("Button", nil, body)
        swatch:SetSize(40, 20)
        swatch:SetPoint("TOPLEFT", body, "TOPLEFT", left + 170, rowY - 1)
        LayoutCell("color", rowY, left, label, swatch, { label, swatch }, debugOnly)
        local border = swatch:CreateTexture(nil, "BACKGROUND")
        border:SetAllPoints()
        border:SetColorTexture(0.75, 0.75, 0.75, 1)
        local fill = swatch:CreateTexture(nil, "ARTWORK")
        fill:SetPoint("TOPLEFT", 2, -2)
        fill:SetPoint("BOTTOMRIGHT", -2, 2)
        local function refresh()
            local color = getColor() or BLACK_COLOR
            fill:SetColorTexture(color[1], color[2], color[3], 1)
        end
        swatch:SetScript("OnClick", function()
            OpenColorPicker(getColor(), function(r, g, b)
                ns.EnsureDatabase()
                setColor({ r, g, b })
                fill:SetColorTexture(r, g, b, 1)
                ns.ApplyBackgroundOpacity(ns.db and ns.db.bgOpacity or 0.70)
            end)
        end)
        refreshers[#refreshers + 1] = refresh
        refresh()
        if not rowYOverride then y = y - 34 end
        return swatch
    end

    AddStepper("Background opacity",
        function(v) return math.floor(v * 100 + 0.5) .. "%" end,
        function() return ns.db.bgOpacity end,
        function(dir)
            ns.db.bgOpacity = math.max(0, math.min(1, ns.db.bgOpacity + dir * 0.05))
            ns.ApplyBackgroundOpacity(ns.db.bgOpacity)
        end, nil, nil, nil, LEFT, CONTROL_X, y)

    AddStepper("Section padding",
        function(v) return string.format("%d px", math.floor(tonumber(v) or 0)) end,
        function() return ns.db.sectionPadding end,
        function(dir)
            ns.db.sectionPadding = math.max(0, math.min(30, (tonumber(ns.db.sectionPadding) or 8) + dir))
            ns.RefreshPopupLayout()
        end, nil, nil, nil, LEFT + 270 + APPEARANCE_SHIFT, CONTROL_X + 220 + APPEARANCE_SHIFT, y)
    y = y - 34

    local function AddSmallSectionLabel(text)
        local label = body:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        label:SetPoint("TOPLEFT", body, "TOPLEFT", LEFT, y)
        label:SetText(ns.L(text))
        label:SetTextColor(0.65, 0.65, 0.65)
        TrackElement(label, LEFT, y)
        y = y - 20
    end

    local function AddColorsSection()
        AddSectionHeader("Colors", "colors")

        local portraitHueSwatch
        local portraitBorderButton

        AddSmallSectionLabel("Textures")
        portraitHueSwatch = AddColorPicker("Background hue",
            function() return ns.db and ns.db.backgroundColor or BLACK_COLOR end,
            function(color)
                ns.db.backgroundColor = color
                ns.ApplyBackgroundOpacity(ns.db.bgOpacity)
            end, LEFT, y)
        AddColorPicker("Frame hue",
            function() return ns.db and ns.db.frameColor or WHITE_COLOR end,
            function(color)
                ns.db.frameColor = color
                ns.ApplyBackgroundAppearance()
            end, LEFT + 270, y)
        y = y - 34
        portraitHueSwatch = AddColorPicker("Portrait ring hue",
            function() return ns.db and ns.db.portraitRingColor or WHITE_COLOR end,
            function(color)
                ns.db.portraitRingColor = color
                ns.RefreshPortraitRing()
            end, LEFT, y)
        portraitBorderButton = AddColorPicker("Portrait border",
            function() return ns.db and ns.db.colors and ns.db.colors.portraitBorder or WHITE_COLOR end,
            function(color)
                ns.SetOptionColor("portraitBorder", color)
            end, LEFT + 270, y)
        y = y - 38

        AddSmallSectionLabel("Text")
        local colorToggleY = y
        AddCheckbox("Show text shadows",
            function() return ns.db.showTextShadow end,
            function(v)
                ns.db.showTextShadow = v
                ns.ApplyTextShadow(v)
            end, LEFT, colorToggleY)
        AddCheckbox("Use class colors",
            function() return ns.db.useClassColors end,
            function(v)
                ns.SetClassColorsEnabled(v)
            end, LEFT + 270, colorToggleY)
        y = y - 32

        local colorEntries = {
            { "title", "Title" }, { "level", "Level number" },
            { "statsHeader", "Stats header" }, { "statLabel", "Stat name / old value" },
            { "statNew", "Improved value" }, { "abilitiesHeader", "Abilities header" },
            { "abilityName", "Ability icon border" }, { "divider", "Section divider" },
            { "animatedElements", "Animated Elements" },
        }
        local swatches = {}
        local startY = y
        for i, colorEntry in ipairs(colorEntries) do
            local key, text = colorEntry[1], colorEntry[2]
            local col = (i - 1) % 2
            local row = math.floor((i - 1) / 2)
            local x0 = LEFT + col * 270
            local rowY = startY - row * 32
            local label = AddLabel(text, rowY, x0)
            local btn = CreateFrame("Button", nil, body)
            btn:SetSize(40, 20)
            btn:SetPoint("TOPLEFT", body, "TOPLEFT", x0 + 170, rowY - 1)
            LayoutCell("color", rowY, x0, label, btn, { label, btn })
            local border = btn:CreateTexture(nil, "BACKGROUND")
            border:SetAllPoints()
            border:SetColorTexture(0.75, 0.75, 0.75, 1)
            local fill = btn:CreateTexture(nil, "ARTWORK")
            fill:SetPoint("TOPLEFT", 2, -2)
            fill:SetPoint("BOTTOMRIGHT", -2, 2)
            btn.fill = fill
            btn:SetScript("OnClick", function()
                OpenColorPicker(ns.db.colors[key], function(r, g, b)
                    ns.SetOptionColor(key, { r, g, b })
                    fill:SetColorTexture(r, g, b, 1)
                end)
            end)
            swatches[key] = btn
        end
        refreshers[#refreshers + 1] = function()
            for key, btn in pairs(swatches) do
                local c = ns.db.colors[key]
                btn.fill:SetColorTexture(c[1], c[2], c[3], 1)
                btn:Enable()
                btn:SetAlpha(1)
            end
            local customRing = ns.db.portraitRingChoice and ns.db.portraitRingChoice ~= "NONE"
            if portraitBorderButton then
                if customRing then portraitBorderButton:Disable(); portraitBorderButton:SetAlpha(0.45)
                else portraitBorderButton:Enable(); portraitBorderButton:SetAlpha(1) end
            end
            if portraitHueSwatch then
                if customRing then portraitHueSwatch:Enable(); portraitHueSwatch:SetAlpha(1)
                else portraitHueSwatch:Disable(); portraitHueSwatch:SetAlpha(0.45) end
            end
        end
        y = startY - math.ceil(#colorEntries / 2) * 32 - 40
    end

    local textureColorChoices = {
        { "topLeft", "Top-left corner" }, { "top", "Top edge" },
        { "topRight", "Top-right corner" }, { "left", "Left edge" },
        { "center", "Center" }, { "right", "Right edge" },
        { "bottomLeft", "Bottom-left corner" }, { "bottom", "Bottom edge" },
        { "bottomRight", "Bottom-right corner" },
    }
    local textureSwatches = {}
    local textureTransformControls = {}
    local textureGridStartY = y
    for _, entry in ipairs(textureColorChoices) do
        local index = _
        local key, label = entry[1], entry[2]
        local column = (index - 1) % 2
        local row = math.floor((index - 1) / 2)
        local rowY = textureGridStartY - row * 34
        local x0 = LEFT + column * 270
        textureSwatches[key] = AddColorPicker(ns.L("%s hue", ns.L(label)),
            function()
                return (ns.db.backgroundTextureColors and ns.db.backgroundTextureColors[key]) or WHITE_COLOR
            end,
            function(color)
                ns.db.backgroundTextureColors[key] = color
                ns.ApplyBackgroundAppearance()
            end, x0, rowY, true)
    end
    y = textureGridStartY - math.ceil(#textureColorChoices / 2) * 34

    -- Keep each texture's transform controls in a compact two-column grid.
    local textureTransformStartY = y
    for _, entry in ipairs(textureColorChoices) do
        local index = _
        local key, label = entry[1], entry[2]
        local column = (index - 1) % 2
        local row = math.floor((index - 1) / 2)
        local rowY = textureTransformStartY - row * 64
        local x0 = LEFT + column * 270
        local _, rotationDropdown = AddDropdown(ns.L("%s rotation", ns.L(label)), ns.BACKGROUND_ROTATION_CHOICES,
            function()
                local transform = ns.db.backgroundTextureTransforms[key]
                return transform and tonumber(transform.rotation) or 0
            end,
            function(value)
                ns.db.backgroundTextureTransforms[key].rotation = value
                ns.ApplyBackgroundAppearance()
            end, rowY, 52, x0, x0 + 170, true, 64)
        local flipRowY = rowY - 30
        local flipH = AddCheckbox("Flip H",
            function()
                local transform = ns.db.backgroundTextureTransforms[key]
                return transform and transform.flipX
            end,
            function(value)
                ns.db.backgroundTextureTransforms[key].flipX = value
                ns.ApplyBackgroundAppearance()
            end, x0, flipRowY, true, 64, rowY)
        local flipV = AddCheckbox("Flip V",
            function()
                local transform = ns.db.backgroundTextureTransforms[key]
                return transform and transform.flipY
            end,
            function(value)
                ns.db.backgroundTextureTransforms[key].flipY = value
                ns.ApplyBackgroundAppearance()
            end, x0 + 130, flipRowY, true, 64, rowY)
        textureTransformControls[#textureTransformControls + 1] = {
            dropdown = rotationDropdown,
            flipH = flipH,
            flipV = flipV,
        }
    end
    y = textureTransformStartY - math.ceil(#textureColorChoices / 2) * 64

    local fontStrataRow = y
    AddDropdown("Frame strata", ns.STRATA_CHOICES,
        function() return ns.db.frameStrata or "HIGH" end,
        function(value)
            ns.db.frameStrata = value
            ns.ApplyFrameStrata(value)
        end, fontStrataRow, 140, LEFT, CONTROL_X)

    AddDropdown("Font", FONT_CHOICES,
        function() return ns.db.customFontPath or FONT_CHOICES[1].value end,
        function(value)
            ns.db.customFontPath = value
            ns.ApplyFont(value)
        end, fontStrataRow, 140, LEFT + 270 + APPEARANCE_SHIFT, CONTROL_X + 270)
    y = fontStrataRow - 36

    -- Pack the main Appearance settings independently of the optional debug rows.
    local appearanceCells = {}
    for _, row in pairs(optionLayout.rows) do
        for _, cell in ipairs(row) do
            if not cell.skip and cell.section == currentSection and not cell.debugOnly
                and (cell.kind == "dropdown" or cell.kind == "stepper") then
                appearanceCells[#appearanceCells + 1] = cell
            end
        end
    end
    table.sort(appearanceCells, function(a, b)
        if a.y == b.y then return a.x < b.x end
        return a.y > b.y
    end)
    -- Frame strata and Font use the outside columns; the middle stays empty.
    -- Steppers get two wider columns so descriptors have room beside the buttons.
    local appearanceOrder = { 1, 2, 3, 4, 5, 6, 9, 10, 7, 8 }
    for _, cell in ipairs(appearanceCells) do
        local row = optionLayout.rows[cell.y]
        for i = #row, 1, -1 do
            if row[i] == cell then table.remove(row, i); break end
        end
    end
    for index, originalIndex in ipairs(appearanceOrder) do
        local cell = appearanceCells[originalIndex]
        local rowIndex = index <= 6 and math.floor((index - 1) / 3) or (index <= 8 and 2 or 3)
        local rowY = appearanceRow - rowIndex * 0.1
        cell.y, cell.x, cell.columns = rowY, index, 3
        if index == 7 then cell.column = 1 end
        if index == 8 then cell.column = 3 end
        if index >= 9 then cell.columns = 2 end
        optionLayout.rows[rowY] = optionLayout.rows[rowY] or {}
        local target = optionLayout.rows[rowY]
        target[#target + 1] = cell
    end

    local appearanceToggleRow = y
    AddCheckbox("Lock Location",
        function() return ns.db.lockFramePosition end,
        function(v)
            ns.db.lockFramePosition = v
            ns.ApplyFrameLock(v)
        end, LEFT, appearanceToggleRow)
    AddCheckbox("Compact Layout",
        function() return ns.db.compactMode end,
        function(v)
            ns.db.compactMode = v
            ns.RefreshPopupLayout()
        end, LEFT + 150, appearanceToggleRow)
    AddCheckbox("Suspend Preview",
        function() return ns.db.suspendPreview ~= false end,
        function(v)
            ns.db.suspendPreview = v
            ns.RefreshPreviewSuspension()
        end, LEFT + 320, appearanceToggleRow)
    y = appearanceToggleRow - 32

    AddButton("Reset Appearance", 150, LEFT, y, function()
        ns.ResetAppearanceToDefaults()
    end)
    AddButton("Preview Level-Up", 150, LEFT + 160, y, function()
        ns.PreviewLevelUp()
    end)
    y = y - 34

    AddColorsSection()

    AddSectionHeader("Animation", "animation")

    local function EffectToggle(label, key)
        return { label, function() return ns.db[key] == true end,
            function(value)
                ns.db[key] = value
                ns.RefreshVisualEffects()
            end }
    end
    local portraitEffect = EffectToggle("Portrait pulse and starburst", "portraitAnimation")
    AddCheckbox(portraitEffect[1], portraitEffect[2], portraitEffect[3])
    AddCheckboxPair(EffectToggle("Highlight new abilities", "highlightNewAbilities"),
        EffectToggle("Emphasize stat gains", "emphasizeStatGains"))
    AddCheckboxPair(EffectToggle("Portrait sparks", "portraitSparks"),
        EffectToggle("New ability sparkles", "newAbilitySparkles"))
    local _, _, edgeCheck, edgeLabel = AddCheckboxPair(EffectToggle("Background embers", "backgroundEmbers"),
        EffectToggle("Frame edge glow", "frameEdgeGlow"))
    AddAvailabilityRefresh(edgeCheck, edgeLabel, function() return ns.db.backgroundMode ~= "MODERN" end)

    AddCheckboxPair(EffectToggle("Portrait and ring settle", "portraitRingSettle"),
        EffectToggle("Reveal dividers", "dividerReveal"))

    local animationRow = y
    AddStepper("Animation speed",
        function(v) return string.format("%.2fx", v) end,
        function() return ns.db.animSpeedMultiplier end,
        function(dir)
            ns.db.animSpeedMultiplier = math.max(0.25, math.min(3.0, ns.db.animSpeedMultiplier + dir * 0.25))
        end, nil, nil, nil, LEFT, CONTROL_X, animationRow)

    AddDropdown("Slide direction", {
        { value = "none", label = "None" },
        { value = "left", label = "Left" },
        { value = "right", label = "Right" },
        { value = "alternate", label = "Alternate" },
    }, function() return ns.db.statSlideDirection end,
        function(value) ns.db.statSlideDirection = value end,
        animationRow, 140, LEFT + 270, CONTROL_X + 270)
    y = animationRow - 36

    AddCheckbox("Reduced motion",
        function() return ns.db.reducedMotion end,
        function(v) ns.db.reducedMotion = v; ns.RefreshVisualEffects() end)

    AddSectionHeader("Mode", "mode")

    local modeRowY = y
    AddCheckbox("Show minimap button",
        function() return ns.db.minimapButtonShown end,
        function(v)
            ns.db.minimapButtonShown = v
            ns.SetMinimapButtonShown(v)
        end, LEFT, modeRowY)
    y = modeRowY - 32

    AddCheckbox("Hide Blizzard level-up toast",
        function() return ns.db.hideBlizzardLevelUp ~= false end,
        function(v)
            ns.db.hideBlizzardLevelUp = v
            if v then
                ns.SuppressBlizzardBanner()
            else
                ns.RestoreBlizzardBanner()
            end
        end, LEFT, y)
    AddCheckbox("Right-click to close",
        function() return ns.db.rightClickClose end,
        function(v) ns.db.rightClickClose = v end, LEFT + 270, y)
    y = y - 32

    AddCheckbox("Show time played this level",
        function() return ns.db.showLevelTime end,
        function(v)
            ns.db.showLevelTime = v
            if v then ns.RequestLevelPlayedTime() end
        end, LEFT, y)
    AddCheckbox("Don't show until combat ends",
        function() return ns.db.waitForCombatEnd end,
        function(v) ns.db.waitForCombatEnd = v end, LEFT + 270, y)
    y = y - 32

    AddCheckbox("Ignore mouseover delay",
        function() return ns.db.ignoreMouseoverDelay == true end,
        function(v)
            ns.db.ignoreMouseoverDelay = v
            ns.db.ignoreMouseoverDelayUserSet = true
            if v and ns.levelUpFrame and ns.levelUpFrame:IsShown() then
                ns.RescheduleFadeOut(0.15)
            end
        end, LEFT, y)
    AddCheckbox("Allow click-through",
        function() return ns.db.clickThrough == true end,
        function(v)
            ns.db.clickThrough = v
            ns.ApplyClickThrough(v)
        end, LEFT + 270, y)
    y = y - 32

    AddCheckbox("Enable debug commands",
        function() return ns.db.debugEnabled end,
        function(v)
            ns.db.debugEnabled = v
            ns.RefreshOptionsPanel()
        end, LEFT, y)
    y = y - 32

    AddCheckbox("Enable addon",
        function() return ns.db.enabled end,
        function(v)
            ns.SetAddonEnabled(v)
        end, LEFT, y)
    y = y - 32

    AddCheckbox("Show all available grimoires",
        function() return ns.db.showAllWarlockGrimoires == true end,
        function(v) ns.db.showAllWarlockGrimoires = v end,
        LEFT, y, true, 32, y)
    y = y - 32

    local function AddVisualTuningField(spec, kind, rowY, column)
        local key = spec[kind]
        local label = AddLabel(spec[kind .. "Label"], rowY, LEFT + (column - 1) * 175, true)
        local input = CreateFrame("EditBox", nil, body, "InputBoxTemplate")
        input:SetSize(110, 24)
        input:SetAutoFocus(false)
        input:SetMaxLetters(8)
        local function refresh() input:SetText(tostring(ns.GetParticleValue(spec, kind))) end
        local function commit()
            local value = tonumber(input:GetText())
            if value and value == value and value ~= math.huge and value ~= -math.huge then
                ns.db[key] = value
                ns.db[key] = ns.GetParticleValue(spec, kind)
                ns.RefreshVisualEffects()
            end
            refresh()
        end
        input:SetScript("OnEnterPressed", function(self) commit(); self:ClearFocus() end)
        input:SetScript("OnEditFocusLost", commit)
        input:SetScript("OnEscapePressed", function(self) refresh(); self:ClearFocus() end)
        LayoutCell("edit", rowY, LEFT + (column - 1) * 175, label, input, { label, input }, true,
            { columns = 3, column = column })
        refreshers[#refreshers + 1] = function()
            if not input:HasFocus() then refresh() end
        end
        refresh()
    end
    for _, spec in ipairs(ns.PARTICLE_SETTINGS) do
        for column, kind in ipairs({ "count", "size", "opacity" }) do
            AddVisualTuningField(spec, kind, y, column)
        end
        y = y - 60
    end
    for column, spec in ipairs(ns.EFFECT_OPACITY_SETTINGS) do
        AddVisualTuningField(spec, "opacity", y, column)
    end
    y = y - 60

    AddButton("Print performance report", 170, LEFT, y, function()
        ns.PrintPerformanceDiagnostics()
    end, true, y, 32)
    AddButton("Reset performance data", 170, LEFT + 180, y, function()
        ns.ResetPerformanceDiagnostics()
    end, true, y, 32)
    y = y - 32

    AddCheckbox("Equal-width stat text",
        function() return ns.db.equalStatWidths == true end,
        function(v)
            ns.db.equalStatWidths = v
            ns.RefreshStatTextLayout()
        end, LEFT, y, true, 32, y)
    y = y - 32

    AddStepper("Portrait ring scale",
        function(v) return string.format("%.2fx", v) end,
        function() return tonumber(ns.db.portraitRingScale) or 1.0 end,
        function(dir)
            ns.db.portraitRingScale = math.max(0.5, math.min(2.0,
                (tonumber(ns.db.portraitRingScale) or 1.0) + dir * 0.05))
            ns.RefreshPortraitGeometry()
        end, true, y, 34)

    AddStepper("Portrait ring offset X",
        function(v) return string.format("%+.0f", v) end,
        function()
            local offset = ns.db.portraitRingOffset or {}
            return tonumber(offset.x) or 0
        end,
        function(dir)
            ns.db.portraitRingOffset = ns.db.portraitRingOffset or {}
            ns.db.portraitRingOffset.x = math.max(-50, math.min(50,
                (tonumber(ns.db.portraitRingOffset.x) or 0) + dir))
            ns.RefreshPortraitGeometry()
        end, true, y, 34)

    AddStepper("Portrait ring offset Y",
        function(v) return string.format("%+.0f", v) end,
        function()
            local offset = ns.db.portraitRingOffset or {}
            return tonumber(offset.y) or 0
        end,
        function(dir)
            ns.db.portraitRingOffset = ns.db.portraitRingOffset or {}
            ns.db.portraitRingOffset.y = math.max(-50, math.min(50,
                (tonumber(ns.db.portraitRingOffset.y) or 0) + dir))
            ns.RefreshPortraitGeometry()
        end, true, y, 34)

    local durationScaleRow = y
    AddStepper("Display duration",
        function(v) return string.format("%ds", v) end,
        function() return ns.db.duration end,
        function(dir)
            ns.db.duration = math.max(1, math.min(60, ns.db.duration + dir))
        end, nil, nil, nil, LEFT, CONTROL_X, durationScaleRow)

    AddStepper("Popup scale",
        function(v) return string.format("%.1fx", v) end,
        function() return ns.db.scale end,
        function(dir)
            ns.db.scale = math.max(0.5, math.min(2.0, ns.db.scale + dir * 0.1))
        end, nil, nil, nil, LEFT + 280, CONTROL_X + 230, durationScaleRow)
    y = durationScaleRow - 34

    AddDropdown("Controller glyphs", {
        { value = "none", label = "None" },
        { value = "xbox", label = "Xbox" },
        { value = "playstation", label = "Playstation" },
        { value = "nintendo", label = "Nintendo" },
    },
        function() return ns.db.controllerGlyphStyle or "xbox" end,
        function(value)
            ns.db.controllerGlyphStyle = value
            ns.RefreshControllerGlyph()
        end, y, 130, LEFT, CONTROL_X)
    y = y - 36

    AddSectionHeader("Trainer Data", "trainer_data")

    AddCheckbox("Check trainer lists for catalogue changes",
        function() return ns.db.monitorTrainerChanges ~= false end,
        function(value) ns.db.monitorTrainerChanges = value end)
    AddButton("Export trainer report", 180, LEFT, y, function()
        ns.OpenTrainerReport()
    end)
    y = y - 34


    local autoScanCheck, autoScanLabel = AddCheckboxPair({
        "Automatically save trainer data",
        function() return ns.CanCaptureTrainerData() and ns.db.autoScanTrainers end,
        function(v) ns.db.autoScanTrainers = v end,
    }, {
        "Only display new skills",
        function() return ns.db.showOnlyNewSkills == true end,
        function(v) ns.db.showOnlyNewSkills = v end,
    })
    AddAvailabilityRefresh(autoScanCheck, autoScanLabel, function()
        return ns.CanCaptureTrainerData()
    end)

    local weaponCheck, weaponLabel, costCheck, costLabel = AddCheckboxPair({
        "Show unlearned weapon skills",
        function() return ns.db.showWeaponSkills end,
        function(v) ns.db.showWeaponSkills = v end,
    }, {
        "Show learning costs",
        function() return ns.db.showTrainerCosts end,
        function(v) ns.db.showTrainerCosts = v end,
    })
    local function IsForeverClient()
        return ns.GetCurrentFlavor() == "forever"
    end
    AddAvailabilityRefresh(weaponCheck, weaponLabel, IsForeverClient)
    AddAvailabilityRefresh(costCheck, costLabel, IsForeverClient)

    local currentLevelCheck, currentLevelLabel, petCheck, petLabel = AddCheckboxPair({
        "Only skills unlocked at this level",
        function() return ns.db.showOnlyCurrentLevelSkills end,
        function(v) ns.db.showOnlyCurrentLevelSkills = v end,
    }, {
        "Show Warlock pet abilities",
        function() return ns.db.showWarlockPetSkills end,
        function(v) ns.db.showWarlockPetSkills = v end,
    })
    local function IsForeverWarlock()
        if ns.GetCurrentFlavor() ~= "forever" then return false end
        local _, classToken = UnitClass("player")
        return classToken == "WARLOCK"
    end
    AddAvailabilityRefresh(petCheck, petLabel, IsForeverWarlock)

    local hunterPetCheck, hunterPetLabel = AddCheckbox("Show Hunter pet abilities",
        function() return ns.db.showHunterPetSkills ~= false end,
        function(v) ns.db.showHunterPetSkills = v end)
    local function IsForeverHunter()
        if not IsForeverClient() then return false end
        local _, classToken = UnitClass("player")
        return classToken == "HUNTER"
    end
    AddAvailabilityRefresh(hunterPetCheck, hunterPetLabel, IsForeverHunter)

    local filterPetCheck, filterPetLabel, scrollCheck, scrollLabel = AddCheckboxPair({
        "Filter grimoires by active pet",
        function() return ns.db.filterWarlockPetByActivePet end,
        function(v) ns.db.filterWarlockPetByActivePet = v end,
    }, {
        "Use horizontal scrolling",
        function() return ns.db.useHorizontalAbilityScroll end,
        function(v) ns.db.useHorizontalAbilityScroll = v end,
    })
    AddAvailabilityRefresh(filterPetCheck, filterPetLabel, IsForeverWarlock)

    AddSectionHeader("Sound", "sound")

    AddCheckboxPair({
        "Play sound on level up",
        function() return ns.db.playSound end,
        function(v) ns.db.playSound = v end,
    }, {
        "Mute Blizzard level-up sound",
        function() return ns.db.muteNativeDing ~= false end,
        function(v)
            ns.db.muteNativeDing = v
            ns.ApplyAddonState(false)
        end,
    })

    local refreshCustomSound -- assigned below
    local refreshSoundChoice
    local refreshCustomSoundChoice
    local customSoundDropdown

    local function GetCustomSoundChoices()
        local choices = {}
        for key, choice in pairs(ns.CUSTOM_SOUND_CHOICES or {}) do
            if type(choice) == "table" and choice.path then
                choices[#choices + 1] = {
                    value = choice.value or key,
                    label = choice.label or choice.value or key,
                    path = choice.path,
                }
            end
        end
        table.sort(choices, function(a, b) return a.label < b.label end)
        return choices
    end

    local customSoundChoices = GetCustomSoundChoices()
    if #customSoundChoices == 0 then
        customSoundChoices = { { value = "", label = "No registered custom sounds" } }
    end

    local soundRow = y
    refreshSoundChoice = AddDropdown("Sound", ns.SOUND_CHOICES,
        function() return ns.db.soundChoice end,
        function(value)
            ns.db.soundChoice = value
            local selected
            for _, choice in ipairs(ns.SOUND_CHOICES) do
                if choice.value == value then selected = choice break end
            end
            if selected and selected.path then
                ns.db.customSoundFile = selected.path
            elseif value ~= "CUSTOM" then
                ns.db.customSoundFile = nil -- picking a built-in sound replaces any custom file
            end
            if refreshCustomSound then refreshCustomSound() end
            if refreshCustomSoundChoice then refreshCustomSoundChoice() end
            ns.PlayLevelUpSound(true)
        end, soundRow, 180, LEFT, CONTROL_X)

    AddDropdown("Sound channel", ns.SOUND_CHANNELS,
        function() return ns.db.soundChannel end,
        function(value) ns.db.soundChannel = value end,
        soundRow, 140, LEFT + 270, CONTROL_X + 270)
    y = soundRow - 36

    do
        local label = AddLabel("Sound volume", y - 5)
        local slider = CreateFrame("Slider", nil, body, "OptionsSliderTemplate")
        slider:SetPoint("TOPLEFT", body, "TOPLEFT", CONTROL_X, y - 2)
        slider:SetSize(180, 18)
        slider:SetMinMaxValues(0, 1)
        slider:SetValueStep(0.05)
        slider:SetObeyStepOnDrag(true)
        slider:SetValue(tonumber(ns.db.soundVolume) or 1)
        slider:SetScript("OnValueChanged", function(self, value)
            ns.db.soundVolume = math.max(0, math.min(1, tonumber(value) or 1))
        end)
        TrackElement(slider, CONTROL_X, y - 2)
        local value = body:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        value:SetPoint("LEFT", slider, "RIGHT", 10, 0)
        value:SetText(string.format("%d%%", math.floor((ns.db.soundVolume or 1) * 100 + 0.5)))
        slider:SetScript("OnValueChanged", function(self, v)
            ns.db.soundVolume = math.max(0, math.min(1, tonumber(v) or 1))
            value:SetText(string.format("%d%%", math.floor(ns.db.soundVolume * 100 + 0.5)))
        end)
        LayoutCell("slider", y, LEFT, label, slider, { label, slider, value }, nil, { value = value })
        refreshers[#refreshers + 1] = function() slider:SetValue(tonumber(ns.db.soundVolume) or 1) end
        y = y - 32
    end

    do
        local rowY = y
        refreshCustomSoundChoice = AddDropdown("Registered custom sound", customSoundChoices,
            function() return ns.db.customSoundChoice or "" end,
            function(value)
                if value == "" then return end
                for _, choice in ipairs(customSoundChoices) do
                    if choice.value == value then
                        ns.db.customSoundChoice = value
                        ns.db.customSoundFile = choice.path
                        ns.db.soundChoice = "CUSTOM"
                        if refreshSoundChoice then refreshSoundChoice() end
                        if refreshCustomSound then refreshCustomSound() end
                        ns.PlayLevelUpSound(true)
                        break
                    end
                end
            end)

        customSoundDropdown = _G["GnomeLevelUpDropdown" .. dropdownCount]

        y = y - 2
        rowY = y
        local edit
        do
            local ok, made = pcall(CreateFrame, "EditBox", nil, body, "InputBoxTemplate")
            if ok and made then
                edit = made
            else
                edit = CreateFrame("EditBox", nil, body)
                edit:SetFontObject("GameFontHighlight")
                edit:SetTextInsets(6, 6, 0, 0)
                local backing = edit:CreateTexture(nil, "BACKGROUND")
                backing:SetAllPoints()
                backing:SetColorTexture(0, 0, 0, 0.6)
            end
        end
        edit:SetSize(290, 22)
        edit:SetPoint("TOPLEFT", body, "TOPLEFT", CONTROL_X + 6, rowY)
        TrackElement(edit, CONTROL_X + 6, rowY)
        edit:SetAutoFocus(false)
        edit:SetMaxLetters(240)
        local function commit(self)
            local text = self:GetText():match("^%s*(.-)%s*$")
            ns.db.customSoundFile = (text ~= "") and text or nil
            ns.db.soundChoice = (text ~= "") and "CUSTOM" or "LEVELUP"
            if refreshSoundChoice then refreshSoundChoice() end
            if refreshCustomSound then refreshCustomSound() end
            self:ClearFocus()
        end
        edit:SetScript("OnEnterPressed", commit)
        edit:SetScript("OnEditFocusLost", function(self)
            local text = self:GetText():match("^%s*(.-)%s*$")
            ns.db.customSoundFile = (text ~= "") and text or nil
            ns.db.soundChoice = (text ~= "") and "CUSTOM" or "LEVELUP"
            if refreshSoundChoice then refreshSoundChoice() end
            if refreshCustomSound then refreshCustomSound() end
        end)
        edit:SetScript("OnEscapePressed", function(self)
            self:SetText(ns.db.customSoundFile or "")
            self:ClearFocus()
        end)
        local customSoundLabel = AddLabel("Custom sound file", rowY)
        LayoutCell("edit", rowY, LEFT, customSoundLabel, edit, { customSoundLabel, edit })
        refreshCustomSound = function()
            edit:SetText(ns.db.customSoundFile or "")
            local enabled = ns.db.soundChoice == "CUSTOM"
            if enabled then
                edit:Enable()
                customSoundLabel:SetTextColor(1, 1, 1)
                UIDropDownMenu_EnableDropDown(customSoundDropdown)
            else
                edit:Disable()
                customSoundLabel:SetTextColor(0.5, 0.5, 0.5)
                UIDropDownMenu_DisableDropDown(customSoundDropdown)
            end
        end
        refreshers[#refreshers + 1] = refreshCustomSound
        y = y - 28

        local hint = body:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
        hint:SetPoint("TOPLEFT", body, "TOPLEFT", CONTROL_X + 6, y)
        TrackElement(hint, CONTROL_X + 6, y)
        hint:SetWidth(300)
        hint:SetJustifyH("LEFT")
        hint:SetText(ns.L("Optional. Overrides the sound above. Example: Interface\\AddOns\\GnomeLevelUp\\Sounds\\ding.ogg"))
        y = y - 40
    end

    do
        AddButton("Play sound", 120, CONTROL_X, y, function() ns.PlayLevelUpSound(true) end)
        y = y - 36
    end

    do
        AddButton("Reset to Defaults", 150, LEFT, y, function() ns.ResetOptionsToDefaults() end)
        y = y - 40
    end

    do
        AddSectionHeader("Profile", "profile")
        local profileSection = currentSection
        AddCheckbox("Save per Character", ns.GetSavePerCharacter, ns.SetSavePerCharacter)
        AddDropdown("Profile", ns.GetProfileChoices, ns.GetActiveProfileName, ns.SelectProfile)
        AddLabel("Changes are saved automatically.", y):SetWidth(520)
        y = y - 32

        local function ProfileField(label, limit)
            local fieldLabel = AddLabel(label, y)
            local edit = CreateFrame("EditBox", nil, body, "InputBoxTemplate")
            edit:SetSize(108, 24)
            edit:SetAutoFocus(false)
            edit:SetMaxLetters(limit)
            edit:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
            edit:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)
            LayoutCell("edit", y, LEFT, fieldLabel, edit, { fieldLabel, edit }, nil, { widthFraction = 0.30 })
            y = y - 60
            return edit
        end
        local name = ProfileField("Profile name", 80)
        local status
        AddButton("Create profile", 160, LEFT, y, function()
            local ok, reason = ns.CreateProfile(name:GetText())
            status:SetText(ns.L(ok and "Profile created." or reason))
            if ok then name:SetText(""); name:ClearFocus() end
            ReflowSections()
        end)
        AddButton("Import / export", 180, LEFT + 170, y, ns.OpenProfileTransfer)
        y = y - 36
        local rename = AddButton("Rename profile", 160, LEFT, y, function()
            local ok, reason = ns.RenameProfile(name:GetText())
            status:SetText(ns.L(ok and "Profile renamed." or reason))
            if ok then name:SetText(""); name:ClearFocus() end
            ReflowSections()
        end)
        local delete = AddButton("Delete profile", 180, LEFT + 170, y, function()
            ns.RequestDeleteProfile(function(ok, reason)
                if ok or reason then status:SetText(ns.L(ok and "Profile deleted." or reason)) end
                ReflowSections()
            end)
        end)
        refreshers[#refreshers + 1] = function()
            local canModify = ns.GetActiveProfileName() ~= "Default"
            rename:SetEnabled(canModify)
            delete:SetEnabled(canModify)
        end
        y = y - 36
        status = AddLabel("", y)
        status:SetWidth(520)
        y = y - 36
        -- Static labels use the selected language after /reload.
        AddDropdown("Language", ns.GetLanguageChoices(), function() return ns.GetLanguageSelection(ns.db.language) end,
            function(value) ns.db.language = value end)
        AddLabel("Changes apply after reloading the UI.", y):SetWidth(520)
        y = y - 32
        AddButton("Reload UI", 150, LEFT, y, function() ReloadUI() end)
        y = y - 40
        function ns.ScrollToProfileOptions()
            ns.db.collapsedSections.profile = nil
            ns.RefreshOptionsPanel()
            if optionsScroll then
                local _, _, _, _, offset = profileSection.header:GetPoint(1)
                local maximum = math.max(0, body:GetHeight() - optionsScroll:GetHeight())
                optionsScroll:SetVerticalScroll(math.min(maximum, math.max(0, -(offset or 0))))
            end
        end
    end

    AddSectionHeader("Cache Status", "cache_status")

    AddDropdown("Mode", ns.MODE_CHOICES,
        function() return ns.db.forceFlavor or "auto" end,
        function(value)
            ns.db.forceFlavor = value
            ns.InvalidateTrainerIndex()
            ns.RefreshOptionsPanel()
        end)

    local cacheStatusText = body:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    cacheStatusText:SetPoint("TOPLEFT", body, "TOPLEFT", LEFT, y - 4)
    TrackElement(cacheStatusText, LEFT, y - 4)
    cacheStatusText:SetWidth(410)
    cacheStatusText:SetJustifyH("LEFT")
    cacheStatusText:SetWordWrap(true)

    local function RefreshCacheStatus()
        if not cacheStatusText then return end
        local status = ns.GetTrainerCacheStatus()
        if not status then
            cacheStatusText:SetText(ns.L("Cache status unavailable."))
            return
        end
        local lastScan = status.lastScanAt and date("%Y-%m-%d %H:%M", status.lastScanAt) or ns.L("Never")
        local rescan = status.rescanRequired and "\n" .. ns.L("A trainer rescan is required.") or ""
        local statusText = ns.L(
            "Flavor: %s\nClass: %s\nCached abilities: %d\nLast trainer: %s\nLast scan: %s\nSchema: %d%s",
            status.flavor or ns.L("unknown"), status.classToken or ns.L("unknown"), status.count or 0,
            status.npcName or ns.L("None"), lastScan, status.schemaVersion or 0, rescan)
        cacheStatusText:SetText(statusText)
    end
    refreshers[#refreshers + 1] = RefreshCacheStatus
    RefreshCacheStatus()
    y = y - 88

    AddButton("Clear trainer cache", 160, LEFT, y, function()
        ns.ClearScannedTrainerData()
        RefreshCacheStatus()
        ReflowSections()
        print("|cff3fe0ffGnomeLevelUp|r: cleared all scanned trainer data. Visit a trainer again to re-scan it.")
    end)
    AddButton("Refresh Cache Status", 160, LEFT + 170, y, function() RefreshCacheStatus(); ReflowSections() end)
    y = y - 36

    optionLayout.topPadding = function(width)
        local caption = controllerOptionsButton:GetFontString()
        local launcherWidth = math.min(240, width - 40)
        controllerOptionsButton:SetWidth(launcherWidth)
        local launcherHeight = caption and ns.WrapOptionsText(caption, launcherWidth - 20) + 12 or 26
        controllerOptionsButton:SetHeight(math.max(26, launcherHeight))
        controllerOptionsButton:ClearAllPoints()
        if width < 500 then
            controllerOptionsButton:SetPoint("TOPLEFT", body, "TOPLEFT", LEFT + 40, -78)
            return controllerOptionsButton:IsShown() and 90 + launcherHeight or 84
        end
        controllerOptionsButton:SetPoint("TOPRIGHT", body, "TOPRIGHT", -8, -8)
        return 84
    end
    optionLayout.onReflow = function()
        if optionsScroll then
            optionsScroll:UpdateScrollChildRect()
            local maximum = math.max(0, body:GetHeight() - optionsScroll:GetHeight())
            optionsScroll:SetVerticalScroll(math.min(optionsScroll:GetVerticalScroll(), maximum))
        end
    end
    optionLayout.ready = true
    local function RefreshOptionsWidth()
        local width = optionsScroll and optionsScroll:GetWidth() or panel:GetWidth()
        if width and width > 0 and body ~= panel then body:SetWidth(math.max(160, width)) end
        ReflowSections()
    end
    if optionsScroll then optionsScroll:HookScript("OnSizeChanged", RefreshOptionsWidth) end
    body:HookScript("OnSizeChanged", function() if not optionLayout.running then ReflowSections() end end)
    RefreshOptionsWidth()

    function ns.RefreshOptionsPanel()
        if not ns.db then return end
        for _, section in ipairs(sections) do
            section.collapsed = ns.db.collapsedSections and ns.db.collapsedSections[section.key] == true
            section.label:SetText((section.collapsed and "[+] " or "[-] ") .. ns.L(section.title))
        end
        optionLayout.defer = true
        for _, refresh in ipairs(refreshers) do
            refresh()
        end
        optionLayout.defer = false
        RefreshOptionsWidth()
    end

    function ns.IsPreviewSuspensionRequested()
        return ns.db and ns.db.suspendPreview ~= false
            and (panel:IsShown() or (ns.IsControllerOptionsShown and ns.IsControllerOptionsShown()))
    end

    panel:SetScript("OnShow", function()
        controllerPollElapsed = 0
        lastControllerActive, lastControllerGlyphStyle = nil, nil
        RefreshControllerOptionsButton()
        RefreshSeasonalWatermark()
        ns.RefreshOptionsPanel()
        ns.RefreshPreviewSuspension()
    end)
    panel:SetScript("OnHide", function()
        ns.RefreshPreviewSuspension()
        if controllerLauncherOwner and controllerLauncherBound
            and type(ClearOverrideBindings) == "function"
            and not (type(InCombatLockdown) == "function" and InCombatLockdown()) then
            pcall(ClearOverrideBindings, controllerLauncherOwner)
        end
        if controllerLauncherOwner then controllerLauncherOwner:Hide() end
        controllerLauncherBound = false
    end)
    panel:SetScript("OnUpdate", function(_, elapsed)
        controllerPollElapsed = controllerPollElapsed + (elapsed or 0)
        if controllerPollElapsed < 0.20 then return end
        controllerPollElapsed = 0
        RefreshControllerOptionsButton()
    end)

    panel.OnCommit = function() end
    panel.OnDefault = function() ns.ResetOptionsToDefaults() end
    panel.OnRefresh = function() ns.RefreshOptionsPanel() end
    panel.okay = function() end
    panel.cancel = function() end
    panel.default = function() ns.ResetOptionsToDefaults() end
    panel.refresh = function() ns.RefreshOptionsPanel() end

    panel.gluOptionsBuilt = true
end

function ns.OpenProfileOptions()
    ns.ToggleOptions(true)
    BuildOptions()
    ns.ScrollToProfileOptions()
end

-- Refreshes caused by other settings changes should not create the controls.
ns.RefreshOptionsPanel = function() end
function ns.IsPreviewSuspensionRequested()
    return ns.db and ns.db.suspendPreview ~= false
        and ((panel and panel:IsShown()) or (ns.IsControllerOptionsShown and ns.IsControllerOptionsShown()))
end

function ns.InitializeOptions()
    if panel then return end
    panel = CreateFrame("Frame", "GnomeLevelUpOptionsPanel", UIParent)
    panel.name = PANEL_NAME
    panel:Hide()
    ns.optionsPanel = panel
    panel:SetScript("OnShow", function(self)
        BuildOptions()
        -- BuildOptions installs the full handler; this first OnShow has already
        -- started, so explicitly run that handler once as well.
        local onShow = self:GetScript("OnShow")
        if onShow then onShow(self) end
    end)
    panel.OnCommit = function() end
    panel.OnDefault = function() ns.ResetOptionsToDefaults() end
    panel.OnRefresh = function() ns.RefreshOptionsPanel() end
    panel.okay, panel.cancel = function() end, function() end
    panel.default, panel.refresh = panel.OnDefault, panel.OnRefresh
    pcall(function()
        if Settings and Settings.RegisterCanvasLayoutCategory and Settings.RegisterAddOnCategory then
            local category = Settings.RegisterCanvasLayoutCategory(panel, PANEL_NAME)
            Settings.RegisterAddOnCategory(category)
            ns.settingsCategory = category
            registeredWith = "settings"
        elseif InterfaceOptions_AddCategory then
            InterfaceOptions_AddCategory(panel)
            registeredWith = "interface"
        end
    end)
end

local standalone
local function ToggleStandalone()
    if not standalone then
        standalone = CreateFrame("Frame", "GnomeLevelUpOptionsWindow", UIParent, "BackdropTemplate")
        standalone:Hide()
        standalone:SetSize(620, 540)
        standalone:SetPoint("CENTER")
        standalone:SetFrameStrata("DIALOG")
        standalone:SetMovable(true)
        standalone:EnableMouse(true)
        standalone:RegisterForDrag("LeftButton")
        standalone:SetScript("OnDragStart", standalone.StartMoving)
        standalone:SetScript("OnDragStop", standalone.StopMovingOrSizing)
        standalone:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
            tile = true, tileSize = 32, edgeSize = 32,
            insets = { left = 11, right = 12, top = 12, bottom = 11 },
        })
        local close = CreateFrame("Button", nil, standalone, "UIPanelCloseButton")
        close:SetPoint("TOPRIGHT", -2, -2)
        panel:SetParent(standalone)
        panel:ClearAllPoints()
        panel:SetPoint("TOPLEFT", standalone, "TOPLEFT", 14, -30)
        panel:SetPoint("BOTTOMRIGHT", standalone, "BOTTOMRIGHT", -14, 14)
        panel:Show()
    end
    standalone:SetShown(not standalone:IsShown())
end

function ns.ToggleOptions(forceKeyboard)
    ns.InitializeOptions()
    ns.EnsureDatabase()
    local controllerActive = ns.IsControllerUIActive()
    -- Read both CVar surfaces here as well. On Forever the slash command can
    -- run during the same frame that the native UI switches input styles, so
    -- one API may briefly report the previous value.
    if not controllerActive and type(GetCVar) == "function" then
        local ok, style = pcall(GetCVar, "InputDeviceInterfaceStyle")
        controllerActive = ok and (style == "1" or style == "gamepad")
    end
    if not controllerActive and C_CVar and type(C_CVar.GetCVar) == "function" then
        local ok, style = pcall(C_CVar.GetCVar, "InputDeviceInterfaceStyle")
        controllerActive = ok and (style == "1" or style == "gamepad")
    end
    if controllerActive and not forceKeyboard and ns.ToggleControllerOptions then
        -- The controller page is the primary options page in this mode. Open
        -- it directly so the first /glu options command is sufficient.
        ns.ToggleControllerOptions(true)
        return
    end
    -- Forever's native gamepad settings teardown can taint Blizzard's protected
    -- binding cleanup. Keep this addon panel out of that transition.
    if registeredWith == "settings" and Settings.OpenToCategory then
        local category = ns.settingsCategory
        local id = category.GetID and category:GetID() or category.ID
        Settings.OpenToCategory(id)
    elseif registeredWith == "interface" then
        local InterfaceOptionsFrame_OpenToCategory = _G["InterfaceOptionsFrame_OpenToCategory"]
        if type(InterfaceOptionsFrame_OpenToCategory) == "function" then
            InterfaceOptionsFrame_OpenToCategory(panel)
            InterfaceOptionsFrame_OpenToCategory(panel)
        else
            ToggleStandalone()
        end
    else
        ToggleStandalone()
    end
end

