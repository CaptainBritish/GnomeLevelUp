local ADDON_NAME, ns = ...

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
                label = name .. " (LibSharedMedia)",
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
                label = name .. " (LibSharedMedia)",
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
watermark:SetTexture("Interface\\AddOns\\GnomeLevelUp\\Textures\\options-watermark")
watermark:SetSize(176, 300)
watermark:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -24, 18)
watermark:SetAlpha(0.40)

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

-- Section headers share the same vertical rhythm as the controls beneath them.
local function AddSectionHeader(text)
    y = y - 6
    local fs = body:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    fs:SetPoint("TOPLEFT", body, "TOPLEFT", LEFT, y)
    fs:SetText(text)
    y = y - 30
end

local function AddLabel(text, rowY, x)
    local fs = body:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    fs:SetPoint("TOPLEFT", body, "TOPLEFT", x or LEFT, rowY - 5)
    fs:SetText(text)
    return fs
end

local function AddButton(text, width, x, rowY, onClick)
    local btn = CreateFrame("Button", nil, body, "UIPanelButtonTemplate")
    btn:SetSize(width, 22)
    btn:SetText(text)
    btn:SetPoint("TOPLEFT", body, "TOPLEFT", x, rowY)
    btn:SetScript("OnClick", onClick)
    return btn
end

local function AddStepper(labelText, formatValue, getValue, adjust)
    local rowY = y
    AddLabel(labelText, rowY)
    local valueText = body:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    valueText:SetPoint("TOPLEFT", body, "TOPLEFT", CONTROL_X + 30, rowY - 5)
    valueText:SetWidth(60)
    valueText:SetJustifyH("CENTER")
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

local function AddDropdown(labelText, choices, getCurrent, onSelect)
    dropdownCount = dropdownCount + 1
    local rowY = y
    AddLabel(labelText, rowY)
    local dd = CreateFrame("Frame", "GnomeLevelUpDropdown" .. dropdownCount, body, "UIDropDownMenuTemplate")
    dd:SetPoint("TOPLEFT", body, "TOPLEFT", CONTROL_X - 16, rowY + 2)
    UIDropDownMenu_SetWidth(dd, 190)

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
    y = y - 36
    return refresh
end

local function AddCheckbox(labelText, getValue, setValue)
    local rowY = y
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
    cb:SetPoint("TOPLEFT", body, "TOPLEFT", LEFT - 2, rowY + 2)
    cb:SetScript("OnClick", function(self) setValue(self:GetChecked() and true or false) end)
    local fs = body:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    fs:SetPoint("LEFT", cb, "RIGHT", 4, 0)
    fs:SetText(labelText)
    refreshers[#refreshers + 1] = function() cb:SetChecked(getValue() and true or false) end
    y = y - 32
end

do
    local title = body:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
    title:SetPoint("TOPLEFT", body, "TOPLEFT", LEFT, y)
    title:SetText(PANEL_NAME)

    local byline = body:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    byline:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -2)
    byline:SetText("By Lessá-ArgentDawn")

    y = y - 54
end

AddSectionHeader("Appearance")

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

AddCheckbox("Lock panel location",
    function() return ns.db.lockFramePosition end,
    function(v)
        ns.db.lockFramePosition = v
        if ns.ApplyFrameLock then ns.ApplyFrameLock(v) end
    end)

AddSectionHeader("Animation")

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

AddSectionHeader("Mode")

AddCheckbox("Enable addon",
    function() return ns.db.enabled end,
    function(v)
        if ns.SetAddonEnabled then ns.SetAddonEnabled(v) else ns.db.enabled = v end
    end)

AddCheckbox("Hide Blizzard level-up toast",
    function() return ns.db.hideBlizzardLevelUp ~= false end,
    function(v)
        ns.db.hideBlizzardLevelUp = v
        if v then
            if ns.SuppressBlizzardBanner then ns.SuppressBlizzardBanner() end
        elseif ns.RestoreBlizzardBanner then
            ns.RestoreBlizzardBanner()
        end
    end)

AddCheckbox("Right-click to close the level-up popup",
    function() return ns.db.rightClickClose end,
    function(v) ns.db.rightClickClose = v end)

AddCheckbox("Show time played this level",
    function() return ns.db.showLevelTime end,
    function(v)
        ns.db.showLevelTime = v
        if v then ns.RequestLevelPlayedTime() end
    end)

AddCheckbox("Print instructions to chat",
    function() return ns.db.printInstructions end,
    function(v)
        ns.db.printInstructions = v
        if v and ns.PrintStartupInstructions then ns.PrintStartupInstructions() end
    end)

AddDropdown("Mode", ns.MODE_CHOICES,
    function() return ns.db.forceFlavor or "auto" end,
    function(value)
        ns.db.forceFlavor = value
        if ns.InvalidateTrainerIndex then ns.InvalidateTrainerIndex() end
    end)

AddCheckbox("Show minimap button",
    function() return ns.db.minimapButtonShown end,
    function(v)
        ns.db.minimapButtonShown = v
        if ns.SetMinimapButtonShown then ns.SetMinimapButtonShown(v) end
    end)

AddCheckbox("Enable debug commands",
    function() return ns.db.debugEnabled end,
    function(v) ns.db.debugEnabled = v end)

AddCheckbox("Wait until combat ends before showing the screen",
    function() return ns.db.waitForCombatEnd end,
    function(v) ns.db.waitForCombatEnd = v end)

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

AddSectionHeader("Trainer Data")

AddCheckbox("Auto-save trainer data when visiting a trainer",
    function() return ns.db.autoScanTrainers end,
    function(v) ns.db.autoScanTrainers = v end)

AddCheckbox("Also scan profession trainers",
    function() return ns.db.scanProfessionTrainers end,
    function(v)
        ns.db.scanProfessionTrainers = v
        if ns.InvalidateTrainerIndex then ns.InvalidateTrainerIndex() end
    end)

AddCheckbox("Show unlearned weapon skills",
    function() return ns.db.showWeaponSkills end,
    function(v) ns.db.showWeaponSkills = v end)

AddCheckbox("Show trainer skill costs",
    function() return ns.db.showTrainerCosts end,
    function(v) ns.db.showTrainerCosts = v end)

AddCheckbox("Show only skills unlocked at the current level",
    function() return ns.db.showOnlyCurrentLevelSkills end,
    function(v) ns.db.showOnlyCurrentLevelSkills = v end)

AddButton("Clear Scanned Data", 160, LEFT, y, function()
    if ns.ClearScannedTrainerData then
        ns.ClearScannedTrainerData()
        print("|cff3fe0ffGnomeLevelUp|r: cleared all scanned trainer data. Visit a trainer again to re-scan it.")
    end
end)
y = y - 36

AddSectionHeader("Sound")

AddCheckbox("Play a sound on level up",
    function() return ns.db.playSound end,
    function(v) ns.db.playSound = v end)

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
    hint:SetWidth(300)
    hint:SetJustifyH("LEFT")
    hint:SetText("Optional. Overrides the sound above. Example: Interface\\AddOns\\GnomeLevelUp\\Sounds\\ding.ogg")
    y = y - 40
end

do
    AddButton("Play Sound", 120, CONTROL_X, y, function() ns.PlayLevelUpSound(true) end)
    y = y - 36
end

AddSectionHeader("Text Colors")

AddCheckbox("Show text shadows",
    function() return ns.db.showTextShadow end,
    function(v)
        ns.db.showTextShadow = v
        if ns.ApplyTextShadow then ns.ApplyTextShadow(v) end
    end)

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

local COLOR_ENTRIES = {
    { "title",           "Title" },
    { "level",           "Level number" },
    { "statsHeader",     "Stats header" },
    { "statLabel",       "Stat name / old value" },
    { "statNew",         "Improved value" },
    { "abilitiesHeader", "Abilities header" },
    { "abilityName",     "Ability icon border" },
}

do
    local swatches = {}
    local startY = y
    for i, colorEntry in ipairs(COLOR_ENTRIES) do
        local key, text = colorEntry[1], colorEntry[2]
        local col = (i - 1) % 2
        local row = math.floor((i - 1) / 2)
        local x0 = LEFT + col * 270
        local rowY = startY - row * 32

        AddLabel(text, rowY, x0)

        local btn = CreateFrame("Button", nil, body)
        btn:SetSize(40, 20)
        btn:SetPoint("TOPLEFT", body, "TOPLEFT", x0 + 170, rowY - 1)
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
                ns.ApplyColors()
            end)
        end)
        swatches[key] = btn
    end
    refreshers[#refreshers + 1] = function()
        for key, btn in pairs(swatches) do
            local c = ns.db.colors[key]
            btn.fill:SetColorTexture(c[1], c[2], c[3], 1)
        end
    end
    y = startY - math.ceil(#COLOR_ENTRIES / 2) * 32 - 8
end

do
    AddButton("Preview Level-Up", 150, LEFT, y, function() ns.PreviewLevelUp() end)
    AddButton("Reset to Defaults", 150, LEFT + 160, y, function() ns.ResetOptionsToDefaults() end)
    y = y - 40
end

body:SetHeight(-y + 20)

function ns.RefreshOptionsPanel()
    if not ns.db then return end
    for _, refresh in ipairs(refreshers) do
        refresh()
    end
end

panel:SetScript("OnShow", ns.RefreshOptionsPanel)

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
