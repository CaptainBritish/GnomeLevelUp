local ADDON_NAME, ns = ...

-- Options are created while the addon files load, before ADDON_LOADED runs.
-- Initialize the saved settings here so the first refresh has real values.
if ns.EnsureDatabase then ns.EnsureDatabase() end

-- Keep the settings page compact and aligned with Blizzard's panels.
local PANEL_NAME = "GnomeLevelUp"
local LEFT = 16
local CONTROL_X = 160
local APPEARANCE_SHIFT = 50
local WHITE_COLOR = { 1, 1, 1 }
local BLACK_COLOR = { 0, 0, 0 }

local FONT_CHOICES = {
    { value = "Fonts\\FRIZQT__.TTF",  label = "Friz Quadrata (default)", previewFont = "Fonts\\FRIZQT__.TTF" },
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
local panel = CreateFrame("Frame", "GnomeLevelUpOptionsPanel", UIParent)
panel.name = PANEL_NAME
panel:Hide()

-- The gamepad cannot reliably navigate the normal Blizzard settings widgets.
-- The launcher is created below, directly under the final scroll-child frame,
-- like BugSack's options controls. Creating it under the panel and reparenting
-- it later can leave it out of Forever's controller focus group.
local controllerOptionsButton
local controllerLauncherOwner
local controllerLauncherBound = false
local refreshControllerOpenGlyph

local function RefreshControllerOptionsButton()
    if not controllerOptionsButton then return end
    local active = ns.IsControllerUIActive and ns.IsControllerUIActive()
    controllerOptionsButton:SetShown(active == true)
    if refreshControllerOpenGlyph then refreshControllerOpenGlyph(active == true) end
    if active then
        local inCombat = type(InCombatLockdown) == "function" and InCombatLockdown()
        if not inCombat and controllerLauncherOwner and type(SetOverrideBindingClick) == "function" then
            controllerLauncherOwner:Show()
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
local testWatermarkPath

-- Keep each artwork's original aspect ratio while using the same display height.
local WATERMARK_DIMENSIONS = {
    ["options-watermark"] = { width = 235, height = 400 },
    ["options-watermark-h"] = { width = 287, height = 400 },
    ["options-watermark-wv"] = { width = 254, height = 400 },
}
local WATERMARK_HEIGHT = 300

local function GetWatermarkName(texturePath)
    return texturePath and texturePath:match("([^\\/]+)$")
end

local function SizeWatermark(texturePath)
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
    elseif today.month == 12 then
        return "Interface\\AddOns\\GnomeLevelUp\\Textures\\options-watermark-wv"
    end

    return "Interface\\AddOns\\GnomeLevelUp\\Textures\\options-watermark"
end

local function RefreshSeasonalWatermark()
    local texturePath = testWatermarkPath or GetSeasonalWatermark()
    if texturePath then
        SizeWatermark(texturePath)
        watermark:SetTexture(texturePath)
        watermark:Show()
    else
        watermark:Hide()
    end
end

-- This is intentionally exposed only for quiet local texture previews from
-- the slash command; normal users continue to receive seasonal artwork.
function ns.SetOptionsWatermarkTest(fileName)
    if type(fileName) ~= "string" then return false end
    fileName = fileName:match("^%s*(.-)%s*$")
    if fileName == "" or fileName:lower() == "clear" then
        testWatermarkPath = nil
        RefreshSeasonalWatermark()
        return true
    end
    if fileName:find("[\\/]") then return false end
    fileName = fileName:gsub("%.[tT][gG][aA]$", "")
    if fileName == "" or not fileName:match("^[%w_.%-]+$") then return false end
    testWatermarkPath = "Interface\\AddOns\\GnomeLevelUp\\Textures\\" .. fileName
    RefreshSeasonalWatermark()
    return true
end

RefreshSeasonalWatermark()

local body
do
    local ok, scroll = pcall(CreateFrame, "ScrollFrame", "GnomeLevelUpOptionsScroll", panel, "UIPanelScrollFrameTemplate")
    if ok and scroll then
        scroll:SetPoint("TOPLEFT", panel, "TOPLEFT", 4, -8)
        scroll:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -28, 8)
        body = CreateFrame("Frame", nil, scroll)
        body:SetSize(560, 900)
        scroll:SetScrollChild(body)
    else
        body = panel
    end
end

-- Keep the launcher inside the scroll child and create it with that final
-- parent. This is the same construction pattern used by BugSack's options
-- controls and gives the Forever gamepad focus scanner a normal child button.
controllerOptionsButton = CreateFrame(
    "Button", "GnomeLevelUpControllerOptionsLauncher", body, "UIPanelButtonTemplate")
controllerOptionsButton:SetSize(240, 26)
controllerOptionsButton:SetPoint("TOPRIGHT", body, "TOPRIGHT", -8, -8)
controllerOptionsButton:SetText("Open Controller Options")
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
local function SetControllerGlyphTexture(texture, path)
    local ok = pcall(texture.SetTexture, texture, path)
    if not ok then return false end
    if texture.GetTextureFileID then
        local idOK, fileID = pcall(texture.GetTextureFileID, texture)
        if idOK then return fileID ~= nil and fileID ~= 0 end
    end
    return true
end
refreshControllerOpenGlyph = function(active)
    if not active or not ns.db or ns.db.controllerGlyphStyle == "none" then
        controllerOpenGlyph:Hide()
        controllerOpenGlyphText:Hide()
        return
    end
    local style = ns.db.controllerGlyphStyle
    local glyphReferences = {
        xbox = { atlases = { "gamepad_ltr_a_64", "Gamepad_Ltr_A_64" }, file = "Interface\\Gamepad\\gamepadltr.blp" },
        playstation = { atlases = { "gamepad_shp_cross_64", "Gamepad_Shp_Cross_64" }, file = "Interface\\Gamepad\\gamepadshp.blp" },
        nintendo = { atlases = { "gamepad_rev_b_64", "Gamepad_Rev_B_64" }, file = "Interface\\Gamepad\\gamepadrev.blp" },
    }
    local reference = glyphReferences[style] or {
        atlas = "gamepad_ltr_a_64", file = "Interface\\Gamepad\\gamepadltr.blp",
    }
    local applied = false
    if C_Texture and type(C_Texture.GetAtlasInfo) == "function" then
        for _, atlas in ipairs(reference.atlases or {}) do
            local ok, info = pcall(C_Texture.GetAtlasInfo, atlas)
            if ok and info and (info.file or info.filename)
                and info.leftTexCoord and info.rightTexCoord
                and info.topTexCoord and info.bottomTexCoord then
                applied = pcall(controllerOpenGlyph.SetTexture, controllerOpenGlyph, info.file or info.filename)
                if applied then
                    controllerOpenGlyph:SetTexCoord(info.leftTexCoord, info.rightTexCoord,
                        info.topTexCoord, info.bottomTexCoord)
                    break
                end
            end
        end
    end
    if not applied and controllerOpenGlyph.SetAtlas then
        for _, atlas in ipairs(reference.atlases or {}) do
            applied = pcall(controllerOpenGlyph.SetAtlas, controllerOpenGlyph, atlas, false)
            if applied then break end
        end
    end
    if not applied then
        applied = SetControllerGlyphTexture(controllerOpenGlyph, reference.file)
        if applied then controllerOpenGlyph:SetTexCoord(0, 1, 0, 1) end
    end
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
local finalBodyHeight

-- Keep each section's original coordinates so collapsing one section can move
-- everything below it without rebuilding the settings page.
local function TrackElement(element, x, rowY, debugOnly, debugRowY, debugRowHeight)
    if not currentSection or not element then return end
    currentSection.elements[#currentSection.elements + 1] = {
        frame = element,
        x = x,
        y = rowY,
        debugOnly = debugOnly == true,
    }
    if debugOnly then
        currentSection.debugRows = currentSection.debugRows or {}
        local key = debugRowY or rowY
        local height = debugRowHeight or 32
        currentSection.debugRows[key] = math.max(currentSection.debugRows[key] or 0, height)
    end
end

local function TrackVisibilityElement(element)
    if currentSection and element then
        currentSection.visibilityElements = currentSection.visibilityElements or {}
        currentSection.visibilityElements[#currentSection.visibilityElements + 1] = element
    end
end

local function TrackDebugOnlyElement(element, rowY, rowHeight)
    if not currentSection or not element then return end
    currentSection.debugOnlyElements = currentSection.debugOnlyElements or {}
    currentSection.debugOnlyElements[#currentSection.debugOnlyElements + 1] = element
    currentSection.debugRows = currentSection.debugRows or {}
    currentSection.debugRows[rowY] = math.max(currentSection.debugRows[rowY] or 0, rowHeight or 32)
end

local function ReflowSections()
    local shift = 0
    for _, section in ipairs(sections) do
        local debugEnabled = not ns.IsDebugEnabled or ns.IsDebugEnabled()
        local hiddenDebugRows = {}
        local hiddenDebugHeight = 0
        for rowY, rowHeight in pairs(section.debugRows or {}) do
            if not debugEnabled then
                hiddenDebugRows[rowY] = rowHeight
                hiddenDebugHeight = hiddenDebugHeight + rowHeight
            end
        end
        for _, item in ipairs(section.elements) do
            local localShift = 0
            if not debugEnabled then
                for rowY, rowHeight in pairs(hiddenDebugRows) do
                    if item.y < rowY then localShift = localShift + rowHeight end
                end
            end
            item.frame:ClearAllPoints()
            item.frame:SetPoint("TOPLEFT", body, "TOPLEFT", item.x, item.y + shift + localShift)
            item.frame:SetShown(not section.collapsed and (not item.debugOnly or debugEnabled))
        end
        section.header:Show()
        section.label:Show()
        for _, element in ipairs(section.visibilityElements or {}) do
            element:SetShown(not section.collapsed)
        end
        for _, element in ipairs(section.debugOnlyElements or {}) do
            element:SetShown(not section.collapsed and debugEnabled)
        end
        if section.collapsed then
            shift = shift + section.collapseShift
        elseif hiddenDebugHeight > 0 then
            shift = shift + hiddenDebugHeight
        end
    end
    if finalBodyHeight then body:SetHeight(math.max(260, finalBodyHeight - shift)) end
end

-- Section headers share the same vertical rhythm as the controls beneath them.
local function AddSectionHeader(text, key)
    text = ns.L and ns.L(text) or text
    if currentSection then currentSection.nextHeaderY = y - 6 end
    y = y - 6
    local headerY = y
    local section = {
        key = key or text:lower():gsub("[^%w]+", "_"),
        title = text,
        headerY = headerY,
        elements = {},
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
    y = y - 30
end

local function AddLabel(text, rowY, x, debugOnly, debugRowY, debugRowHeight)
    text = ns.L and ns.L(text) or text
    local fs = body:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    fs:SetPoint("TOPLEFT", body, "TOPLEFT", x or LEFT, rowY - 5)
    fs:SetText(text)
    TrackElement(fs, x or LEFT, rowY - 5, debugOnly, debugRowY, debugRowHeight)
    return fs
end

local function AddButton(text, width, x, rowY, onClick, debugOnly, debugRowY, debugRowHeight)
    text = ns.L and ns.L(text) or text
    local btn = CreateFrame("Button", nil, body, "UIPanelButtonTemplate")
    btn:SetSize(width, 22)
    btn:SetText(text)
    btn:SetPoint("TOPLEFT", body, "TOPLEFT", x, rowY)
    btn:SetScript("OnClick", onClick)
    TrackElement(btn, x, rowY, debugOnly, debugRowY or rowY, debugRowHeight)
    return btn
end

local function OpenColorPicker(color, onChange)
    local r, g, b = color[1], color[2], color[3]
    local function swatchFunc()
        local nr, ng, nb = ColorPickerFrame:GetColorRGB()
        onChange(nr, ng, nb)
    end
    local function cancelFunc()
        onChange(r, g, b)
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
    AddLabel(labelText, rowY, left, debugOnly, trackedRowY, debugRowHeight)
    local valueText = body:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    valueText:SetPoint("TOPLEFT", body, "TOPLEFT", controlX + 30, rowY - 5)
    valueText:SetWidth(60)
    valueText:SetJustifyH("CENTER")
    TrackElement(valueText, controlX + 30, rowY - 5, debugOnly, trackedRowY, debugRowHeight)
    local function refresh() valueText:SetText(formatValue(getValue())) end
    AddButton("-", 24, controlX, rowY, function()
        adjust(-1)
        refresh()
    end, debugOnly, trackedRowY, debugRowHeight)
    AddButton("+", 24, controlX + 96, rowY, function()
        adjust(1)
        refresh()
    end, debugOnly, trackedRowY, debugRowHeight)
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
    TrackElement(dd, controlX - 16, rowY + 2, debugOnly, rowY, debugRowHeight)
    UIDropDownMenu_SetWidth(dd, widthOverride or 190)

    local function GetChoiceLabel(value)
        for i, c in ipairs(choices) do
            if c.value == value then return ns.LocalizeChoiceLabel and ns.LocalizeChoiceLabel(c) or c.label end
        end
        return ns.LocalizeChoiceLabel and ns.LocalizeChoiceLabel(choices[1]) or choices[1].label
    end

    UIDropDownMenu_Initialize(dd, function(_, level)
        if not ns.db then return end
        for i, c in ipairs(choices) do
            local menuItem = UIDropDownMenu_CreateInfo()
            menuItem.text = ns.LocalizeChoiceLabel and ns.LocalizeChoiceLabel(c) or c.label
            menuItem.checked = (getCurrent() == c.value)
            if c.previewFont then
                c.fontObject = c.fontObject or CreateFont("GnomeLevelUpFontChoice" .. dropdownCount .. "_" .. i)
                c.fontObject:SetFont(c.previewFont, 13, "")
                menuItem.fontObject = c.fontObject
            end
            menuItem.func = function()
                onSelect(c.value)
                UIDropDownMenu_SetText(dd, ns.LocalizeChoiceLabel and ns.LocalizeChoiceLabel(c) or c.label)
                CloseDropDownMenus()
            end
            UIDropDownMenu_AddButton(menuItem, level)
        end
    end)

    local function refresh() UIDropDownMenu_SetText(dd, GetChoiceLabel(getCurrent())) end
    refreshers[#refreshers + 1] = refresh
    if not rowYOverride then y = y - 36 end
    return refresh, dd, label
end

local function AddCheckbox(labelText, getValue, setValue, xOverride, rowYOverride, debugOnly, debugRowHeight, debugRowY)
    labelText = ns.L and ns.L(labelText) or labelText
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
    TrackElement(cb, left - 2, rowY + 2, debugOnly, debugRowY or rowY, debugRowHeight)
    cb:SetScript("OnClick", function(self) setValue(self:GetChecked() and true or false) end)
    local fs = body:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    fs:SetPoint("LEFT", cb, "RIGHT", 4, 0)
    fs:SetText(labelText)
    if debugOnly then
        TrackDebugOnlyElement(fs, debugRowY or rowY, debugRowHeight)
    else
        TrackVisibilityElement(fs)
    end
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
        local visible = available and not (section and section.collapsed)
        checkButton:SetShown(visible)
        label:SetShown(visible)
        if checkButton.SetEnabled then checkButton:SetEnabled(available) end
        label:SetTextColor(available and 1 or 0.45, available and 1 or 0.45, available and 1 or 0.45)
    end
end

local function AddCheckboxWithColor(labelText, getValue, setValue, getColor, setColor, xOverride, rowYOverride)
    local _, label = AddCheckbox(labelText, getValue, setValue, xOverride, rowYOverride)
    local swatch = CreateFrame("Button", nil, body)
    swatch:SetSize(36, 18)
    swatch:SetPoint("LEFT", label, "RIGHT", 10, 0)
    TrackVisibilityElement(swatch)

    local border = swatch:CreateTexture(nil, "BACKGROUND")
    border:SetAllPoints()
    border:SetColorTexture(0.75, 0.75, 0.75, 1)
    local fill = swatch:CreateTexture(nil, "ARTWORK")
    fill:SetPoint("TOPLEFT", 2, -2)
    fill:SetPoint("BOTTOMRIGHT", -2, 2)

    local function refresh()
        local color = getColor() or { 1.00, 1.00, 159 / 255 }
        fill:SetColorTexture(color[1], color[2], color[3], 1)
    end
    swatch:SetScript("OnClick", function()
        OpenColorPicker(getColor(), function(r, g, b)
            setColor({ r, g, b })
            fill:SetColorTexture(r, g, b, 1)
        end)
    end)
    refreshers[#refreshers + 1] = refresh
    refresh()
end

do
    local title = body:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
    title:SetPoint("TOPLEFT", body, "TOPLEFT", LEFT, y)
    title:SetText(ns.L and ns.L(PANEL_NAME) or PANEL_NAME)

    local version = body:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    version:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -2)
    version:SetTextColor(0.70, 0.70, 0.70)
    local addonVersion = GetAddOnMetadata and GetAddOnMetadata(ADDON_NAME, "Version") or "1.3"
    version:SetText((ns.L and ns.L("Version %s", tostring(addonVersion or "1.3")))
        or ("Version " .. tostring(addonVersion or "1.3")))

    local byline = body:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    byline:SetPoint("TOPLEFT", version, "BOTTOMLEFT", 0, -2)
    byline:SetText(ns.L and ns.L("By Lessá-ArgentDawn") or "By Lessá-ArgentDawn")

    y = y - 68
end

AddSectionHeader("Appearance", "appearance")

local appearanceRow = y
AddDropdown("Portrait", ns.PORTRAIT_CHOICES,
    function() return ns.db.portraitMode or "class" end,
    function(value)
        ns.db.portraitMode = value
        if ns.RefreshClassIcon then ns.RefreshClassIcon() end
    end, appearanceRow, 140, LEFT, CONTROL_X)

if ns.PORTRAIT_RING_CHOICES then
    AddDropdown("Portrait ring", ns.PORTRAIT_RING_CHOICES,
        function()
            if ns.db.portraitRingChoice and not (ns.db.portraitRingChoice == "NONE" and ns.db.portraitRingTexture) then
                return ns.db.portraitRingChoice
            end
            for _, choice in ipairs(ns.PORTRAIT_RING_CHOICES) do
                local reference = ns.GetPortraitRingReference and ns.GetPortraitRingReference(choice.value)
                if reference and reference == ns.db.portraitRingTexture then return choice.value end
            end
            return "NONE"
        end,
        function(value)
            ns.db.portraitRingChoice = value
            local reference = ns.GetPortraitRingReference and ns.GetPortraitRingReference(value)
            ns.db.portraitRingTexture = reference
            ns.db.portraitRingEnabled = reference ~= nil
            if ns.RefreshPortraitRing then ns.RefreshPortraitRing() end
        end, appearanceRow, 140, LEFT + 270 + APPEARANCE_SHIFT, CONTROL_X + 220 + APPEARANCE_SHIFT)
end
y = appearanceRow - 36

local appearanceThemeRow = y
local refreshTheme, themeDropdown = AddDropdown("Theme", ns.THEME_CHOICES or {},
    function()
        return ns.db.backgroundMode == "MODERN" and "MODERN" or (ns.db.backgroundTheme or "MODERN")
    end,
    function(value)
        if ns.ApplyBackgroundTheme then ns.ApplyBackgroundTheme(value) end
    end, appearanceThemeRow, 140, LEFT, CONTROL_X)

local refreshBackground, backgroundDropdown = AddDropdown("Background", ns.BACKGROUND_TEXTURE_CHOICES or {},
    function() return ns.db.backgroundChoice or "NONE" end,
    function(value)
        if ns.ApplyBackgroundChoice then ns.ApplyBackgroundChoice(value) end
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
        if ns.ApplyBackgroundAppearance then ns.ApplyBackgroundAppearance() end
    end, appearanceFrameRow, 140, LEFT, CONTROL_X)

local refreshFrame, frameDropdown = AddDropdown("Frame", ns.FRAME_CHOICES or {},
    function() return ns.db.frameChoice or "BLACK_METAL" end,
    function(value)
        if ns.ApplyFrameChoice then ns.ApplyFrameChoice(value) end
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
    AddLabel(labelText, rowY, left, debugOnly, rowY, 34)
    local swatch = CreateFrame("Button", nil, body)
    swatch:SetSize(40, 20)
    swatch:SetPoint("TOPLEFT", body, "TOPLEFT", left + 170, rowY - 1)
    TrackElement(swatch, left + 170, rowY - 1, debugOnly, rowY, 34)
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
            if ns.EnsureDatabase then ns.EnsureDatabase() end
            setColor({ r, g, b })
            fill:SetColorTexture(r, g, b, 1)
            if ns.ApplyBackgroundOpacity then ns.ApplyBackgroundOpacity(ns.db and ns.db.bgOpacity or 0.70) end
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
        if ns.RefreshPopupLayout then ns.RefreshPopupLayout() end
    end, nil, nil, nil, LEFT + 270 + APPEARANCE_SHIFT, CONTROL_X + 220 + APPEARANCE_SHIFT, y)
y = y - 34

local function AddColorsSection()
    AddSectionHeader("Colors", "colors")

    local classColorKeys = {
        title = true, level = true, statsHeader = true, abilitiesHeader = true,
        abilityName = true, portraitBorder = true,
    }

    local colorToggleY = y
    AddCheckbox("Show Text Shadows",
        function() return ns.db.showTextShadow end,
        function(v)
            ns.db.showTextShadow = v
            if ns.ApplyTextShadow then ns.ApplyTextShadow(v) end
        end, LEFT, colorToggleY)
    AddCheckbox("Apply class colours",
        function() return ns.db.useClassColors end,
        function(v)
            if ns.SetClassColorsEnabled then ns.SetClassColorsEnabled(v) else ns.db.useClassColors = v end
        end, LEFT + 270, colorToggleY)
    y = y - 32

    local colorEntries = {
        { "title",           "Title" },
        { "level",           "Level number" },
        { "statsHeader",     "Stats header" },
        { "statLabel",       "Stat name / old value" },
        { "statNew",         "Improved value" },
        { "abilitiesHeader", "Abilities header" },
        { "abilityName",     "Ability icon border" },
        { "portraitBorder",  "Portrait border" },
        { "divider",         "Section divider" },
    }

    local swatches = {}
    local startY = y
    for i, colorEntry in ipairs(colorEntries) do
        local key, text = colorEntry[1], colorEntry[2]
        local col = (i - 1) % 2
        local row = math.floor((i - 1) / 2)
        local x0 = LEFT + col * 270
        local rowY = startY - row * 32

        AddLabel(text, rowY, x0)

        local btn = CreateFrame("Button", nil, body)
        btn:SetSize(40, 20)
        btn:SetPoint("TOPLEFT", body, "TOPLEFT", x0 + 170, rowY - 1)
        TrackElement(btn, x0 + 170, rowY - 1)
        local border = btn:CreateTexture(nil, "BACKGROUND")
        border:SetAllPoints()
        border:SetColorTexture(0.75, 0.75, 0.75, 1)
        local fill = btn:CreateTexture(nil, "ARTWORK")
        fill:SetPoint("TOPLEFT", 2, -2)
        fill:SetPoint("BOTTOMRIGHT", -2, 2)
        btn.fill = fill
        btn:SetScript("OnClick", function()
            OpenColorPicker(ns.db.colors[key], function(r, g, b)
                ns.db.colors[key] = { r, g, b }
                fill:SetColorTexture(r, g, b, 1)
                if ns.ApplyColors then ns.ApplyColors() end
            end)
        end)
        swatches[key] = btn
    end
    refreshers[#refreshers + 1] = function()
        for key, btn in pairs(swatches) do
            local c = ns.db.colors[key]
            btn.fill:SetColorTexture(c[1], c[2], c[3], 1)
            local controlled = ns.db.useClassColors and classColorKeys[key]
            if controlled then
                btn:Disable()
                btn:SetAlpha(0.55)
            else
                btn:Enable()
                btn:SetAlpha(1)
            end
        end
    end
    y = startY - math.ceil(#colorEntries / 2) * 32 - 8
end

local textureColorChoices = {
    { "topLeft", "Top-left corner hue" }, { "top", "Top edge hue" },
    { "topRight", "Top-right corner hue" }, { "left", "Left edge hue" },
    { "center", "Center hue" }, { "right", "Right edge hue" },
    { "bottomLeft", "Bottom-left corner hue" }, { "bottom", "Bottom edge hue" },
    { "bottomRight", "Bottom-right corner hue" },
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
    textureSwatches[key] = AddColorPicker(label,
        function()
            return (ns.db.backgroundTextureColors and ns.db.backgroundTextureColors[key]) or WHITE_COLOR
        end,
        function(color)
            ns.db.backgroundTextureColors[key] = color
            if ns.ApplyBackgroundAppearance then ns.ApplyBackgroundAppearance() end
        end, x0, rowY, true)
end
y = textureGridStartY - math.ceil(#textureColorChoices / 2) * 34

-- Keep each texture's transform controls in a compact two-column grid.
local textureTransformStartY = y
for _, entry in ipairs(textureColorChoices) do
    local index = _
    local key, label = entry[1], entry[2]:gsub(" hue$", "")
    local column = (index - 1) % 2
    local row = math.floor((index - 1) / 2)
    local rowY = textureTransformStartY - row * 64
    local x0 = LEFT + column * 270
    local _, rotationDropdown = AddDropdown(label .. " rotation", ns.BACKGROUND_ROTATION_CHOICES,
        function()
            local transform = ns.db.backgroundTextureTransforms[key]
            return transform and tonumber(transform.rotation) or 0
        end,
        function(value)
            ns.db.backgroundTextureTransforms[key].rotation = value
            if ns.ApplyBackgroundAppearance then ns.ApplyBackgroundAppearance() end
        end, rowY, 52, x0, x0 + 170, true, 64)
    local flipRowY = rowY - 30
    local flipH = AddCheckbox("Flip H",
        function()
            local transform = ns.db.backgroundTextureTransforms[key]
            return transform and transform.flipX
        end,
        function(value)
            ns.db.backgroundTextureTransforms[key].flipX = value
            if ns.ApplyBackgroundAppearance then ns.ApplyBackgroundAppearance() end
        end, x0, flipRowY, true, 64, rowY)
    local flipV = AddCheckbox("Flip V",
        function()
            local transform = ns.db.backgroundTextureTransforms[key]
            return transform and transform.flipY
        end,
        function(value)
            ns.db.backgroundTextureTransforms[key].flipY = value
            if ns.ApplyBackgroundAppearance then ns.ApplyBackgroundAppearance() end
        end, x0 + 130, flipRowY, true, 64, rowY)
    textureTransformControls[#textureTransformControls + 1] = {
        dropdown = rotationDropdown,
        flipH = flipH,
        flipV = flipV,
    }
end
y = textureTransformStartY - math.ceil(#textureColorChoices / 2) * 64

AddColorPicker("Background Hue",
    function() return ns.db and ns.db.backgroundColor or BLACK_COLOR end,
    function(color)
        if ns.EnsureDatabase then ns.EnsureDatabase() end
        ns.db.backgroundColor = color
        if ns.ApplyBackgroundOpacity then ns.ApplyBackgroundOpacity(ns.db.bgOpacity) end
    end, LEFT, y)
y = y - 34

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

AddCheckboxPair({
    "Lock panel location",
    function() return ns.db.lockFramePosition end,
    function(v)
        ns.db.lockFramePosition = v
        if ns.ApplyFrameLock then ns.ApplyFrameLock(v) end
    end,
}, {
    "Compact popup layout",
    function() return ns.db.compactMode end,
    function(v)
        ns.db.compactMode = v
        if ns.RefreshPopupLayout then ns.RefreshPopupLayout() end
    end,
}, nil, nil, LEFT + 270 + APPEARANCE_SHIFT)

AddButton("Reset Appearance", 150, LEFT, y, function()
    if ns.ResetAppearanceToDefaults then ns.ResetAppearanceToDefaults() end
end)
AddButton("Preview Level-Up", 150, LEFT + 160, y, function()
    ns.PreviewLevelUp()
end)
y = y - 34

AddColorsSection()

AddSectionHeader("Animation", "animation")

AddStepper("Animation speed",
    function(v) return string.format("%.2fx", v) end,
    function() return ns.db.animSpeedMultiplier end,
    function(dir)
        ns.db.animSpeedMultiplier = math.max(0.25, math.min(3.0, ns.db.animSpeedMultiplier + dir * 0.25))
    end)

AddCheckbox("Reduced motion (skip popup animations)",
    function() return ns.db.reducedMotion end,
    function(v) ns.db.reducedMotion = v end)

do
    local rowY = y
    AddLabel("Slide direction", rowY)
    local buttons = {}
    local function refresh()
        for value, btn in pairs(buttons) do
            if value == ns.db.statSlideDirection then btn:LockHighlight() else btn:UnlockHighlight() end
        end
    end
    for i, choice in ipairs({
        { "left", "Left" }, { "right", "Right" }, { "alternate", "Alternate" },
    }) do
        buttons[choice[1]] = AddButton(choice[2], 90, CONTROL_X + (i - 1) * 96, rowY, function()
            ns.db.statSlideDirection = choice[1]
            refresh()
        end)
    end
    refreshers[#refreshers + 1] = refresh
    y = y - 34
end

AddSectionHeader("Mode", "mode")

AddCheckboxPair({
    "Enable addon",
    function() return ns.db.enabled end,
    function(v)
        if ns.SetAddonEnabled then ns.SetAddonEnabled(v) else ns.db.enabled = v end
    end,
}, {
    "Hide Blizzard level-up toast",
    function() return ns.db.hideBlizzardLevelUp ~= false end,
    function(v)
        ns.db.hideBlizzardLevelUp = v
        if v then
            if ns.SuppressBlizzardBanner then ns.SuppressBlizzardBanner() end
        elseif ns.RestoreBlizzardBanner then
            ns.RestoreBlizzardBanner()
        end
    end,
})

AddCheckboxPair({
    "Right-click to close the level-up popup",
    function() return ns.db.rightClickClose end,
    function(v) ns.db.rightClickClose = v end,
}, {
    "Show time played this level",
    function() return ns.db.showLevelTime end,
    function(v)
        ns.db.showLevelTime = v
        if v then ns.RequestLevelPlayedTime() end
    end,
})

local modeRowY = y
AddCheckbox("Don't show until combat ends",
    function() return ns.db.waitForCombatEnd end,
    function(v) ns.db.waitForCombatEnd = v end,
    LEFT, modeRowY)
AddCheckbox("Show minimap button",
    function() return ns.db.minimapButtonShown end,
    function(v)
        ns.db.minimapButtonShown = v
        if ns.SetMinimapButtonShown then ns.SetMinimapButtonShown(v) end
    end, LEFT + 270, modeRowY)
y = y - 32

AddCheckboxPair({
    "Ignore Mouseover Delay",
    function() return ns.db.ignoreMouseoverDelay == true end,
    function(v)
        ns.db.ignoreMouseoverDelay = v
        ns.db.ignoreMouseoverDelayUserSet = true
        if v and ns.RescheduleFadeOut and ns.levelUpFrame and ns.levelUpFrame:IsShown() then
            ns.RescheduleFadeOut(0.15)
        end
    end,
}, {
    "Allow click-through",
    function() return ns.db.clickThrough == true end,
    function(v)
        ns.db.clickThrough = v
        if ns.ApplyClickThrough then ns.ApplyClickThrough(v) end
    end,
})

modeRowY = y
AddCheckbox("Enable debug commands",
    function() return ns.db.debugEnabled end,
    function(v)
        ns.db.debugEnabled = v
        if ns.RefreshOptionsPanel then ns.RefreshOptionsPanel() end
    end,
    LEFT, modeRowY)
AddCheckboxWithColor("Classic-style level up text",
    function() return ns.db.printClassicLevelUpText end,
    function(v) ns.db.printClassicLevelUpText = v end,
    function() return ns.db and ns.db.classicLevelUpTextColor end,
    function(color) ns.db.classicLevelUpTextColor = color end,
    LEFT + 270, modeRowY)
y = y - 32

AddCheckbox("Show all available grimoires",
    function() return ns.db.showAllWarlockGrimoires == true end,
    function(v) ns.db.showAllWarlockGrimoires = v end,
    LEFT, y, true, 32, y)
y = y - 32

AddButton("Print performance report", 170, LEFT, y, function()
    if ns.PrintPerformanceDiagnostics then ns.PrintPerformanceDiagnostics() end
end, true, y, 32)
AddButton("Reset performance data", 170, LEFT + 180, y, function()
    if ns.ResetPerformanceDiagnostics then ns.ResetPerformanceDiagnostics() end
end, true, y, 32)
y = y - 32

AddCheckbox("Equal-width stat text",
    function() return ns.db.equalStatWidths == true end,
    function(v)
        ns.db.equalStatWidths = v
        if ns.RefreshStatTextLayout then ns.RefreshStatTextLayout() end
    end, LEFT, y, true, 32, y)
y = y - 32

AddStepper("Portrait ring scale",
    function(v) return string.format("%.2fx", v) end,
    function() return tonumber(ns.db.portraitRingScale) or 1.0 end,
    function(dir)
        ns.db.portraitRingScale = math.max(0.5, math.min(2.0,
            (tonumber(ns.db.portraitRingScale) or 1.0) + dir * 0.05))
        if ns.RefreshPortraitGeometry then ns.RefreshPortraitGeometry() end
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
        if ns.RefreshPortraitGeometry then ns.RefreshPortraitGeometry() end
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
        if ns.RefreshPortraitGeometry then ns.RefreshPortraitGeometry() end
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
        if ns.RefreshControllerGlyph then ns.RefreshControllerGlyph() end
    end, y, 130, LEFT, CONTROL_X)
y = y - 36

AddSectionHeader("Trainer Data", "trainer_data")

AddCheckboxPair({
    "Auto-save trainer data",
    function() return ns.db.autoScanTrainers end,
    function(v) ns.db.autoScanTrainers = v end,
}, {
    "Only display new skills",
    function() return ns.db.showOnlyNewSkills == true end,
    function(v) ns.db.showOnlyNewSkills = v end,
})

-- Keep this control for later; profession scanning is not needed for now.
--[[
AddCheckbox("Also scan profession trainers",
    function() return ns.db.scanProfessionTrainers end,
    function(v)
        ns.db.scanProfessionTrainers = v
        if ns.InvalidateTrainerIndex then ns.InvalidateTrainerIndex() end
    end)
]]

local weaponCheck, weaponLabel, costCheck, costLabel = AddCheckboxPair({
    "Show unlearned weapon skills",
    function() return ns.db.showWeaponSkills end,
    function(v) ns.db.showWeaponSkills = v end,
}, {
    "Show trainer skill costs",
    function() return ns.db.showTrainerCosts end,
    function(v) ns.db.showTrainerCosts = v end,
})
local function IsForeverClient()
    return not ns.GetCurrentFlavor or ns.GetCurrentFlavor() == "forever"
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
    if ns.GetCurrentFlavor and ns.GetCurrentFlavor() ~= "forever" then return false end
    local _, classToken = UnitClass("player")
    return classToken == "WARLOCK"
end
AddAvailabilityRefresh(petCheck, petLabel, IsForeverWarlock)

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
    "Play a sound on level up",
    function() return ns.db.playSound end,
    function(v) ns.db.playSound = v end,
}, {
    "Mute native Ding",
    function() return ns.db.muteNativeDing ~= false end,
    function(v)
        ns.db.muteNativeDing = v
        if ns.ApplyAddonState then ns.ApplyAddonState(false) end
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
    end)

AddDropdown("Sound channel", ns.SOUND_CHANNELS,
    function() return ns.db.soundChannel end,
    function(value) ns.db.soundChannel = value end)

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
    TrackElement(value, CONTROL_X + 200, y - 5)
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
    hint:SetText(ns.L and ns.L("Optional. Overrides the sound above. Example: Interface\\AddOns\\GnomeLevelUp\\Sounds\\ding.ogg")
        or "Optional. Overrides the sound above. Example: Interface\\AddOns\\GnomeLevelUp\\Sounds\\ding.ogg")
    y = y - 40
end

do
    AddButton("Play Sound", 120, CONTROL_X, y, function() ns.PlayLevelUpSound(true) end)
    y = y - 36
end

do
    AddButton("Reset to Defaults", 150, LEFT, y, function() ns.ResetOptionsToDefaults() end)
    y = y - 40
end

AddSectionHeader("Cache Status", "cache_status")

AddDropdown("Mode", ns.MODE_CHOICES,
    function() return ns.db.forceFlavor or "auto" end,
    function(value)
        ns.db.forceFlavor = value
        if ns.InvalidateTrainerIndex then ns.InvalidateTrainerIndex() end
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
    local status = ns.GetTrainerCacheStatus and ns.GetTrainerCacheStatus()
    if not status then
        cacheStatusText:SetText(ns.L and ns.L("Cache status unavailable.") or "Cache status unavailable.")
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

AddButton("Clear Scanned Data", 160, LEFT, y, function()
    if ns.ClearScannedTrainerData then
        ns.ClearScannedTrainerData()
        RefreshCacheStatus()
        print("|cff3fe0ffGnomeLevelUp|r: cleared all scanned trainer data. Visit a trainer again to re-scan it.")
    end
end)
AddButton("Refresh Cache Status", 160, LEFT + 170, y, RefreshCacheStatus)
y = y - 36

finalBodyHeight = -y + 20
for i, section in ipairs(sections) do
    local nextSection = sections[i + 1]
    local nextY = nextSection and nextSection.headerY or y
    section.fullSpan = math.max(32, section.headerY - nextY)
    section.collapseShift = math.max(0, section.fullSpan - 32)
end
body:SetHeight(finalBodyHeight)
ReflowSections()

function ns.RefreshOptionsPanel()
    if not ns.db then return end
    for _, section in ipairs(sections) do
        section.collapsed = ns.db.collapsedSections and ns.db.collapsedSections[section.key] == true
        section.label:SetText((section.collapsed and "[+] " or "[-] ") .. section.title)
    end
    ReflowSections()
    for _, refresh in ipairs(refreshers) do
        refresh()
    end
end

panel:SetScript("OnShow", function()
    RefreshControllerOptionsButton()
    RefreshSeasonalWatermark()
    ns.RefreshOptionsPanel()
end)
panel:SetScript("OnHide", function()
    if controllerLauncherOwner and controllerLauncherBound
        and type(ClearOverrideBindings) == "function"
        and not (type(InCombatLockdown) == "function" and InCombatLockdown()) then
        pcall(ClearOverrideBindings, controllerLauncherOwner)
    end
    if controllerLauncherOwner then controllerLauncherOwner:Hide() end
    controllerLauncherBound = false
end)
panel:SetScript("OnUpdate", function()
    if panel:IsShown() then RefreshControllerOptionsButton() end
end)

panel.OnCommit = function() end
panel.OnDefault = function() ns.ResetOptionsToDefaults() end
panel.OnRefresh = function() ns.RefreshOptionsPanel() end
panel.okay = function() end
panel.cancel = function() end
panel.default = function() ns.ResetOptionsToDefaults() end
panel.refresh = function() ns.RefreshOptionsPanel() end

local registeredWith -- "settings" | "interface" | nil

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

local standalone
local function ToggleStandalone()
    if not standalone then
        standalone = CreateFrame("Frame", "GnomeLevelUpOptionsWindow", UIParent, "BackdropTemplate")
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

function ns.ToggleOptions()
    if ns.EnsureDatabase then ns.EnsureDatabase() end
    local controllerActive = ns.IsControllerUIActive and ns.IsControllerUIActive()
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
    if controllerActive and ns.ToggleControllerOptions then
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
    elseif registeredWith == "interface" and InterfaceOptionsFrame_OpenToCategory then
        InterfaceOptionsFrame_OpenToCategory(panel)
        InterfaceOptionsFrame_OpenToCategory(panel)
    else
        ToggleStandalone()
    end
end

ns.optionsPanel = panel
