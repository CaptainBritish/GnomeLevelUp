local ADDON_NAME, ns = ...

-- Options are created while the addon files load, before ADDON_LOADED runs.
-- Initialize the saved settings here so the first refresh has real values.
if ns.EnsureDatabase then ns.EnsureDatabase() end

-- Keep the settings page compact and aligned with Blizzard's panels.
local PANEL_NAME = "GnomeLevelUp"
local LEFT = 16
local CONTROL_X = 250

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
    local fs = body:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    fs:SetPoint("TOPLEFT", body, "TOPLEFT", x or LEFT, rowY - 5)
    fs:SetText(text)
    TrackElement(fs, x or LEFT, rowY - 5, debugOnly, debugRowY, debugRowHeight)
    return fs
end

local function AddButton(text, width, x, rowY, onClick)
    local btn = CreateFrame("Button", nil, body, "UIPanelButtonTemplate")
    btn:SetSize(width, 22)
    btn:SetText(text)
    btn:SetPoint("TOPLEFT", body, "TOPLEFT", x, rowY)
    btn:SetScript("OnClick", onClick)
    TrackElement(btn, x, rowY)
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

local function AddStepper(labelText, formatValue, getValue, adjust)
    local rowY = y
    AddLabel(labelText, rowY)
    local valueText = body:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    valueText:SetPoint("TOPLEFT", body, "TOPLEFT", CONTROL_X + 30, rowY - 5)
    valueText:SetWidth(60)
    valueText:SetJustifyH("CENTER")
    TrackElement(valueText, CONTROL_X + 30, rowY - 5)
    local function refresh() valueText:SetText(formatValue(getValue())) end
    AddButton("-", 24, CONTROL_X, rowY, function()
        adjust(-1)
        refresh()
    end)
    AddButton("+", 24, CONTROL_X + 96, rowY, function()
        adjust(1)
        refresh()
    end)
    refreshers[#refreshers + 1] = refresh
    y = y - 34
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
            if c.value == value then return c.label end
        end
        return choices[1].label
    end

    UIDropDownMenu_Initialize(dd, function(_, level)
        if not ns.db then return end
        for i, c in ipairs(choices) do
            local menuItem = UIDropDownMenu_CreateInfo()
            menuItem.text = c.label
            menuItem.checked = (getCurrent() == c.value)
            if c.previewFont then
                c.fontObject = c.fontObject or CreateFont("GnomeLevelUpFontChoice" .. dropdownCount .. "_" .. i)
                c.fontObject:SetFont(c.previewFont, 13, "")
                menuItem.fontObject = c.fontObject
            end
            menuItem.func = function()
                onSelect(c.value)
                UIDropDownMenu_SetText(dd, c.label)
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

local function AddCheckboxPair(first, second)
    local rowY = y
    local firstCheck, firstLabel = AddCheckbox(first[1], first[2], first[3], LEFT, rowY)
    local secondCheck, secondLabel = AddCheckbox(second[1], second[2], second[3], LEFT + 270, rowY)
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
    title:SetText(PANEL_NAME)

    local version = body:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    version:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -2)
    version:SetTextColor(0.70, 0.70, 0.70)
    local addonVersion = GetAddOnMetadata and GetAddOnMetadata(ADDON_NAME, "Version") or "1.3"
    version:SetText("Version " .. tostring(addonVersion or "1.3"))

    local byline = body:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    byline:SetPoint("TOPLEFT", version, "BOTTOMLEFT", 0, -2)
    byline:SetText("By Lessá-ArgentDawn")

    y = y - 68
end

AddSectionHeader("Appearance", "appearance")

AddDropdown("Portrait", ns.PORTRAIT_CHOICES,
    function() return ns.db.portraitMode or "class" end,
    function(value)
        ns.db.portraitMode = value
        if ns.RefreshClassIcon then ns.RefreshClassIcon() end
    end)

AddStepper("Background opacity",
    function(v) return math.floor(v * 100 + 0.5) .. "%" end,
    function() return ns.db.bgOpacity end,
    function(dir)
        ns.db.bgOpacity = math.max(0, math.min(1, ns.db.bgOpacity + dir * 0.05))
        ns.ApplyBackgroundOpacity(ns.db.bgOpacity)
    end)

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
        local color = getColor() or { 0, 0, 0 }
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

AddColorPicker("Background gradient color",
    function() return ns.db and ns.db.backgroundColor or { 0.00, 0.00, 0.00 } end,
    function(color)
        if ns.EnsureDatabase then ns.EnsureDatabase() end
        ns.db.backgroundColor = color
    end)

local backgroundThemeChoices = {}
for _, theme in ipairs(ns.CUSTOM_BACKGROUND_THEMES or {}) do
    if type(theme) == "table" and theme.value and theme.textures then
        backgroundThemeChoices[#backgroundThemeChoices + 1] = {
            value = theme.value,
            label = theme.label or theme.value,
        }
    end
end
local refreshBackgroundControls
local backgroundStyleChoices = {
    { value = "MODERN", label = "Modern" },
}
local backgroundStyleThemes = {}
for _, theme in ipairs(backgroundThemeChoices) do
    local value = "CUSTOM:" .. theme.value
    backgroundStyleChoices[#backgroundStyleChoices + 1] = {
        value = value,
        label = theme.label,
    }
    backgroundStyleThemes[value] = theme.value
end

local refreshBackgroundStyle, backgroundStyleDropdown = AddDropdown("Background style", backgroundStyleChoices,
    function()
        if ns.db.backgroundMode == "CUSTOM" and ns.db.backgroundTheme then
            return "CUSTOM:" .. ns.db.backgroundTheme
        end
        return "MODERN"
    end,
    function(value)
        if value == "MODERN" then
            if ns.RestoreModernAppearance then ns.RestoreModernAppearance() end
        else
            local themeValue = backgroundStyleThemes[value]
            if themeValue and ns.ApplyBackgroundTheme then ns.ApplyBackgroundTheme(themeValue) end
        end
        if refreshBackgroundControls then refreshBackgroundControls() end
    end)

local refreshBackgroundFill, backgroundFillDropdown = AddDropdown("Center texture", ns.BACKGROUND_FILL_CHOICES,
    function() return ns.db.backgroundFillMode or "scale" end,
    function(value)
        ns.db.backgroundFillMode = value
        if ns.ApplyBackgroundAppearance then ns.ApplyBackgroundAppearance() end
    end)

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
            return (ns.db.backgroundTextureColors and ns.db.backgroundTextureColors[key]) or { 1, 1, 1 }
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

refreshers[#refreshers + 1] = function()
    if refreshBackgroundStyle then refreshBackgroundStyle() end
    if refreshBackgroundFill then refreshBackgroundFill() end
end

refreshBackgroundControls = function()
    local enabled = ns.db.backgroundMode == "CUSTOM" and #backgroundThemeChoices > 0
    for _, swatch in pairs(textureSwatches) do
        swatch:SetEnabled(enabled)
        swatch:SetAlpha(enabled and 1 or 0.45)
    end
    for _, controls in ipairs(textureTransformControls) do
        if enabled then UIDropDownMenu_EnableDropDown(controls.dropdown)
        else UIDropDownMenu_DisableDropDown(controls.dropdown) end
        controls.flipH:SetEnabled(enabled)
        controls.flipV:SetEnabled(enabled)
        controls.flipH:SetAlpha(enabled and 1 or 0.45)
        controls.flipV:SetAlpha(enabled and 1 or 0.45)
    end
    if enabled then UIDropDownMenu_EnableDropDown(backgroundFillDropdown)
    else UIDropDownMenu_DisableDropDown(backgroundFillDropdown) end
end
refreshers[#refreshers + 1] = refreshBackgroundControls
refreshBackgroundControls()

AddStepper("Section padding",
    function(v) return string.format("%d px", math.floor(tonumber(v) or 0)) end,
    function() return ns.db.sectionPadding end,
    function(dir)
        ns.db.sectionPadding = math.max(0, math.min(30, (tonumber(ns.db.sectionPadding) or 8) + dir))
        if ns.RefreshPopupLayout then ns.RefreshPopupLayout() end
    end)

AddDropdown("Font", FONT_CHOICES,
    function() return ns.db.customFontPath or FONT_CHOICES[1].value end,
    function(value)
        ns.db.customFontPath = value
        ns.ApplyFont(value)
    end)

AddDropdown("Frame strata", ns.STRATA_CHOICES,
    function() return ns.db.frameStrata or "HIGH" end,
    function(value)
        ns.db.frameStrata = value
        ns.ApplyFrameStrata(value)
    end)

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
})

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
    "Ignore Mouseover Delay (controller users)",
    function() return ns.db.ignoreMouseoverDelay == true end,
    function(v)
        ns.db.ignoreMouseoverDelay = v
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

AddStepper("Display duration",
    function(v) return string.format("%ds", v) end,
    function() return ns.db.duration end,
    function(dir)
        ns.db.duration = math.max(1, math.min(60, ns.db.duration + dir))
    end)

AddStepper("Popup scale",
    function(v) return string.format("%.1fx", v) end,
    function() return ns.db.scale end,
    function(dir)
        ns.db.scale = math.max(0.5, math.min(2.0, ns.db.scale + dir * 0.1))
    end)

AddSectionHeader("Trainer Data", "trainer_data")

AddCheckbox("Auto-save trainer data",
    function() return ns.db.autoScanTrainers end,
    function(v) ns.db.autoScanTrainers = v end)

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

local filterPetCheck, filterPetLabel = AddCheckbox(
    "Filter grimoires by active pet",
    function() return ns.db.filterWarlockPetByActivePet end,
    function(v) ns.db.filterWarlockPetByActivePet = v end)
AddAvailabilityRefresh(filterPetCheck, filterPetLabel, IsForeverWarlock)

-- Keep this common option in the left column when Warlock-only controls are hidden.
local scrollCheck, scrollLabel = AddCheckbox(
    "Use horizontal scrolling",
    function() return ns.db.useHorizontalAbilityScroll end,
    function(v) ns.db.useHorizontalAbilityScroll = v end)

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
    hint:SetText("Optional. Overrides the sound above. Example: Interface\\AddOns\\GnomeLevelUp\\Sounds\\ding.ogg")
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
        cacheStatusText:SetText("Cache status unavailable.")
        return
    end
    local lastScan = status.lastScanAt and date("%Y-%m-%d %H:%M", status.lastScanAt) or "Never"
    local rescan = status.rescanRequired and "\nA trainer rescan is required." or ""
    cacheStatusText:SetText(string.format(
        "Flavor: %s\nClass: %s\nCached abilities: %d\nLast trainer: %s\nLast scan: %s\nSchema: %d%s",
        status.flavor or "unknown", status.classToken or "unknown", status.count or 0,
        status.npcName or "None", lastScan, status.schemaVersion or 0, rescan))
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
    RefreshSeasonalWatermark()
    ns.RefreshOptionsPanel()
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
    -- Forever's native gamepad settings teardown can taint Blizzard's protected
    -- binding cleanup. Keep this addon panel out of that transition.
    if GetCVar and GetCVar("InputDeviceInterfaceStyle") == "1" then
        -- Let the chat edit box finish releasing gamepad focus first.
        C_Timer.After(0, ToggleStandalone)
        return
    end
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
