local ADDON_NAME, ns = ...

-- This controller page is deliberately separate from Options.lua. Blizzard's
-- dropdowns and checkboxes do not provide a dependable focus model on Forever,
-- while a small page with explicit rows can use the same override-click input
-- pattern as the native controller UI. Nothing is built until it is opened.
local window
local setupMode, manualOpen = false, false
local bindingOwner
local bindingsConfigured = false
local rows, tabs, inputButtons = {}, {}, {}
local Close
local refreshCloseButton
local portraitPreview
local tabIndex, selected = 1, 1
local rowOffset = 0
local VISIBLE_ROWS = 12
local ROW_HEIGHT = 42
local controllerLayoutRunning = false
local savedPreviewStrata

local TAB_DEFS = {
    { key = "appearance", label = "Appearance" },
    { key = "mode", label = "Mode" },
    { key = "trainer", label = "Trainer Data" },
    { key = "sound", label = "Sound" },
    { key = "animation", label = "Animation" },
    { key = "colors", label = "Colors" },
    { key = "profile", label = "Profile" },
}

local function IsActive()
    return ns.GetCurrentFlavor() ~= "retail" and ns.IsControllerUIActive()
end

local function SetControllerIgnoreMouseoverDelay(value)
    ns.db.ignoreMouseoverDelay = value == true
    ns.db.ignoreMouseoverDelayUserSet = true
    if value and ns.levelUpFrame and ns.levelUpFrame:IsShown() then
        ns.RescheduleFadeOut(0.15)
    end
end

local function ControllerGlyphChoice()
    local value = ns.db and ns.db.controllerGlyphStyle
    if value == "none" then return "none" end
    if value == "playstation" or value == "nintendo" then return value end
    return "xbox"
end

local CONTROLLER_HINT_ATLASES = {
    xbox = {
        move = { "Gamepad_Gen_Up_64", "Gamepad_Ltr_Up_64" },
        select = { "gamepad_ltr_a_64", "Gamepad_Ltr_A_64" },
        adjust = { "Gamepad_Gen_Left_64", "Gamepad_Ltr_Left_64" },
        tabLeft = { "Gamepad_Ltr_LShoulder_64", "Gamepad_Gen_LShoulder_64" },
        tabRight = { "Gamepad_Ltr_RShoulder_64", "Gamepad_Gen_RShoulder_64" },
        close = { "gamepad_ltr_b_64", "Gamepad_Ltr_B_64" },
    },
    playstation = {
        move = { "Gamepad_Gen_Up_64", "Gamepad_Shp_Up_64" },
        select = { "gamepad_shp_cross_64", "Gamepad_Shp_Cross_64" },
        adjust = { "Gamepad_Gen_Left_64", "Gamepad_Shp_Left_64" },
        tabLeft = { "Gamepad_Shp_LShoulder_64", "Gamepad_Gen_LShoulder_64" },
        tabRight = { "Gamepad_Shp_RShoulder_64", "Gamepad_Gen_RShoulder_64" },
        close = { "gamepad_shp_circle_64", "Gamepad_Shp_Circle_64" },
    },
    nintendo = {
        move = { "gamepad-switch-128x-dpad-up-normal" },
        select = { "gamepad-switch-128x-face-b-normal" },
        adjust = { "gamepad-switch-128x-dpad-leftright-normal" },
        tabLeft = { "gamepad-switch-128x-shoulder-l-normal" },
        tabRight = { "gamepad-switch-128x-shoulder-r-normal" },
        close = { "gamepad-switch-128x-face-a-normal" },
    },
}

local function ApplyHintAtlas(texture, candidates)
    local applied, left, right, top, bottom = ns.ApplyAtlasCandidates(texture, candidates, false, true)
    if applied and left then texture:SetTexCoord(left, right, top, bottom) end
    return applied
end

local function CreateControllerHintItem(parent, action, label, fallback, index)
    local item = CreateFrame("Frame", nil, parent)
    item:SetSize(136, 34)
    item:SetPoint("LEFT", parent, "LEFT", (index - 1) * 136, 0)
    item.icon = item:CreateTexture(nil, "ARTWORK")
    item.icon:SetSize(30, 30)
    item.icon:SetPoint("LEFT")
    item.secondaryIcon = item:CreateTexture(nil, "ARTWORK")
    item.secondaryIcon:SetSize(30, 30)
    item.secondaryIcon:SetPoint("LEFT", item.icon, "RIGHT", -2, 0)
    item.secondaryIcon:Hide()
    item.fallback = item:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    item.fallback:SetSize(36, 30)
    item.fallback:SetPoint("LEFT")
    item.fallback:SetJustifyH("CENTER")
    item.fallback:SetText(fallback)
    item.label = item:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    if type(action) == "table" then
        item.label:SetPoint("LEFT", item.secondaryIcon, "RIGHT", 2, 0)
    else
        item.label:SetPoint("LEFT", item.icon, "RIGHT", 3, 0)
    end
    item.labelKey = label
    item.label:SetText(ns.L(label))
    item.action = action
    item.fallbackText = fallback
    item.icon:Hide()
    item.secondaryIcon:Hide()
    item.fallback:Show()
    return item
end

local function RefreshControllerHints(items)
    local style = ControllerGlyphChoice()
    local refs = CONTROLLER_HINT_ATLASES[style]
    for _, item in ipairs(items or {}) do
        local leftApplied, rightApplied
        if refs and type(item.action) == "table" then
            leftApplied = ApplyHintAtlas(item.icon, refs[item.action.left])
            rightApplied = ApplyHintAtlas(item.secondaryIcon, refs[item.action.right])
        else
            leftApplied = refs and ApplyHintAtlas(item.icon, refs[item.action]) or false
        end
        local complete = type(item.action) ~= "table" or (leftApplied and rightApplied)
        if complete then
            item.icon:Show()
            item.secondaryIcon:SetShown(rightApplied == true)
            item.fallback:Hide()
        else
            item.icon:Hide()
            item.secondaryIcon:Hide()
            item.fallback:SetText(item.fallbackText)
            item.fallback:Show()
        end
    end
end

local function SetControllerPreviewStrata(active)
    local preview = ns.levelUpFrame
    if not preview or not preview.GetFrameStrata then return end
    if active then
        if not savedPreviewStrata then savedPreviewStrata = preview:GetFrameStrata() end
        if preview:GetFrameStrata() ~= "DIALOG" then preview:SetFrameStrata("DIALOG") end
    else
        local strata = savedPreviewStrata or (ns.db and ns.db.frameStrata) or "HIGH"
        preview:SetFrameStrata(strata)
        savedPreviewStrata = nil
    end
end

local function IsControllerBackButton(button)
    button = tostring(button or ""):upper()
    return button == "PAD2" or button == "PADB" or button == "PADBACK"
        or button == "GAMEPAD_BUTTON_B" or button == "GAMEPAD_B"
end

local function CreateControllerCloseButton(parent, onClose)
    local button = CreateFrame("Button", nil, parent)
    button:SetSize(30, 30)
    button:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -8, -8)
    button:SetFrameLevel(parent:GetFrameLevel() + 10)
    button:RegisterForClicks("AnyUp")
    local text = button:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    text:SetAllPoints()
    text:SetJustifyH("CENTER")
    text:SetJustifyV("MIDDLE")
    text:SetTextColor(1, 1, 1, 1)
    local icon = button:CreateTexture(nil, "OVERLAY")
    icon:SetPoint("CENTER")
    icon:SetSize(24, 24)

    local function Refresh()
        if not IsActive() then
            icon:Hide()
            text:SetText("X")
            text:Show()
            return
        end
        if ControllerGlyphChoice() == "none" then
            icon:Hide()
            text:SetText("X")
            text:Show()
            return
        end
        local applied = ns.ApplyControllerGlyph(icon, "back", ControllerGlyphChoice())
        if applied then
            icon:SetSize(24, 24)
            icon:Show()
            text:Hide()
        else
            icon:Hide()
            text:SetText(ControllerGlyphChoice() == "nintendo" and "A" or "B")
            text:Show()
        end
    end

    button:SetScript("OnClick", onClose)
    button:SetScript("OnMouseUp", function(_, mouseButton)
        if mouseButton == "RightButton" then onClose() end
    end)
    return button, Refresh
end

local STRATA_ORDER = {
    BACKGROUND = 1, LOW = 2, MEDIUM = 3, HIGH = 4, DIALOG = 5,
    FULLSCREEN = 6, FULLSCREEN_DIALOG = 7, TOOLTIP = 8,
}

local function PlaceControllerBelowPreview()
    if not window then return end
    local preview = ns.levelUpFrame
    local previewStrata = preview and preview.GetFrameStrata and preview:GetFrameStrata()
    local configured = ns.db and ns.db.controllerMenuFrameStrata
    local previewOrder = STRATA_ORDER[previewStrata or "HIGH"] or STRATA_ORDER.HIGH
    local targetOrder
    if configured and configured ~= "AUTO" and STRATA_ORDER[configured] then
        targetOrder = STRATA_ORDER[configured]
    else
        targetOrder = math.max(STRATA_ORDER.BACKGROUND, previewOrder - 1)
    end
    local targetStrata = "BACKGROUND"
    for name, order in pairs(STRATA_ORDER) do
        if order == targetOrder then targetStrata = name break end
    end
    window:SetFrameStrata(targetStrata)
    if preview and preview.GetFrameStrata and previewStrata == targetStrata
        and preview.GetFrameLevel then
        window:SetFrameLevel(math.max(0, (preview:GetFrameLevel() or 1) - 1))
    end
end

local PREVIEW_CLASS_COORDS = {
    WARRIOR = { 0, 0.25, 0, 0.25 }, MAGE = { 0.25, 0.5, 0, 0.25 },
    ROGUE = { 0.5, 0.75, 0, 0.25 }, DRUID = { 0.75, 1, 0, 0.25 },
    HUNTER = { 0, 0.25, 0.25, 0.5 }, SHAMAN = { 0.25, 0.5, 0.25, 0.5 },
    PRIEST = { 0.5, 0.75, 0.25, 0.5 }, WARLOCK = { 0.75, 1, 0.25, 0.5 },
    PALADIN = { 0, 0.25, 0.5, 0.75 }, DEATHKNIGHT = { 0.25, 0.5, 0.5, 0.75 },
    MONK = { 0.5, 0.75, 0.5, 0.75 }, DEMONHUNTER = { 0.75, 1, 0.5, 0.75 },
}

local function RefreshPortraitPreview()
    if not portraitPreview then return end
    local db = ns.db or {}
    local reference = db.portraitRingTexture
    if (type(reference) ~= "string" or reference == "")
        and db.portraitRingChoice and ns.GetPortraitRingReference then
        reference = ns.GetPortraitRingReference(db.portraitRingChoice)
    end
    local enabled = db.portraitRingEnabled == true
        and ((type(reference) == "string" and reference ~= "")
            or (type(reference) == "table" and reference.atlas))
    if not enabled or db.portraitMode == "none" then
        portraitPreview:Hide()
        return
    end

    local playerPortrait = db.portraitMode == "player"
    local portraitScale = playerPortrait and math.max(0.5, math.min(2.0, tonumber(db.playerPortraitScale) or 1)) or 1
    -- Keep both portrait choices the same size in this compact preview. The
    -- player portrait used the smaller preview size before the class-icon fix;
    -- preserve that size and enlarge only the class icon to match it.
    local baseSize = 90 * portraitScale
    local previewScale = 0.55
    local iconSize = baseSize * previewScale
    local ringScale = math.max(0.5, math.min(2.0, tonumber(db.portraitRingScale) or 1.1))
    local ringSize = (baseSize + 6) * ringScale * previewScale
    local offset = db.portraitRingOffset or {}
    local offsetX = (tonumber(offset.x) or 0) * previewScale
    local offsetY = (tonumber(offset.y) or 0) * previewScale

    portraitPreview:SetSize(ringSize, ringSize)
    portraitPreview.icon:SetSize(iconSize, iconSize)
    portraitPreview.ring:SetSize(ringSize, ringSize)
    portraitPreview.ring:ClearAllPoints()
    portraitPreview.ring:SetPoint("CENTER", portraitPreview, "CENTER", offsetX, offsetY)

    if playerPortrait then
        portraitPreview.icon:SetTexCoord(0, 1, 0, 1)
        if SetPortraitTexture then
            SetPortraitTexture(portraitPreview.icon, "player")
        else
            portraitPreview.icon:SetTexture("Interface\\CHARACTERFRAME\\TempPortrait")
        end
    else
        local _, classToken = UnitClass("player")
        local coords = (CLASS_ICON_TCOORDS and CLASS_ICON_TCOORDS[classToken])
            or PREVIEW_CLASS_COORDS[classToken]
        portraitPreview.icon:SetTexture("Interface\\GLUES\\CHARACTERCREATE\\UI-CHARACTERCREATE-CLASSES")
        if coords then
            portraitPreview.icon:SetTexCoord(coords[1], coords[2], coords[3], coords[4])
        else
            portraitPreview.icon:SetTexCoord(0, 1, 0, 1)
        end
    end

    local applied = ns.ApplyPortraitRingTexture(portraitPreview.ring, reference)
    if not applied then
        portraitPreview:Hide()
        return
    end
    portraitPreview:Show()
end

local function PlacePortraitPreviewBelowPopup()
    if not portraitPreview then return end
    if window then
        portraitPreview:SetFrameStrata(window:GetFrameStrata() or "MEDIUM")
        portraitPreview:SetFrameLevel(window:GetFrameLevel() + 4)
    end
end

local function Apply()
    ns.ApplyCurrentAppearance()
    ns.RefreshOptionsPanel()
end

local function ChoiceLabel(value, choices)
    for _, choice in ipairs(choices or {}) do
        if choice.value == value then return ns.LocalizeChoiceLabel(choice) end
    end
    return tostring(value or "")
end

local function CycleChoice(label, get, set, choices, after)
    return {
        label = label,
        get = function() return ChoiceLabel(get(), type(choices) == "function" and choices() or choices) end,
        activate = function(direction)
            local choices = type(choices) == "function" and choices() or choices
            local current, index = get(), 1
            for i, choice in ipairs(choices) do
                if choice.value == current then index = i break end
            end
            index = ((index - 1 + (direction or 1)) % #choices) + 1
            set(choices[index].value)
            if after then after(choices[index].value) end
        end,
    }
end

local function Toggle(label, key, after)
    local function available()
        if key == "frameEdgeGlow" then return ns.db.backgroundMode ~= "MODERN" end
        return key ~= "autoScanTrainers" or ns.CanCaptureTrainerData()
    end
    return {
        label = label,
        isAvailable = available,
        get = function() return available() and ns.db[key] == true and "On" or "Off" end,
        activate = function()
            if not available() then return end
            ns.db[key] = not (ns.db[key] == true)
            if after then after(ns.db[key]) end
        end,
    }
end

local function PetClassToggle(label, key, class)
    local entry = Toggle(label, key)
    entry.isAvailable = function()
        local _, token = UnitClass("player")
        return token == class and ns.GetCurrentFlavor() == "forever"
    end
    local activate = entry.activate
    entry.activate = function()
        if entry.isAvailable() then activate() end
    end
    return entry
end

local function EntriesFor(key)
    if key == "setup" then
        local entries = {
            CycleChoice("Language", function() return ns.GetLanguageSelection(ns.db.language) end,
                function(v)
                    ns.db.language = v
                    ns.SetLocale(v)
                    if ns.RefreshLocalizedPopupText then ns.RefreshLocalizedPopupText() end
                end, ns.GetLanguageChoices),
            CycleChoice("Theme", function() return ns.db.backgroundMode == "MODERN" and "MODERN" or (ns.db.backgroundTheme or "MODERN") end,
                function(v) ns.ApplyBackgroundTheme(v) end, ns.THEME_CHOICES or {}),
            Toggle("Compact Layout", "compactMode", function() ns.RefreshPopupLayout() end),
            Toggle("Show time played this level", "showLevelTime"),
        }
        entries[#entries + 1] = { label = "Show pet skills",
            get = function() return ns.db.showHunterPetSkills and ns.db.showWarlockPetSkills and "On" or "Off" end,
            activate = function()
                local enabled = not (ns.db.showHunterPetSkills and ns.db.showWarlockPetSkills)
                ns.db.showHunterPetSkills, ns.db.showWarlockPetSkills = enabled, enabled
            end }
        entries[#entries + 1] = { label = "Enable animations",
            get = function() return not ns.db.reducedMotion and "On" or "Off" end,
            activate = function()
                ns.db.reducedMotion = not ns.db.reducedMotion
                ns.RefreshVisualEffects()
            end }
        entries[#entries + 1] = Toggle("Right-click to close", "rightClickClose")
        entries[#entries + 1] = { label = "Ignore mouseover delay",
            get = function() return ns.db.ignoreMouseoverDelay and "On" or "Off" end,
            activate = function() SetControllerIgnoreMouseoverDelay(not ns.db.ignoreMouseoverDelay) end }
        entries[#entries + 1] = { label = "Use class colors",
            get = function() return ns.db.useClassColors and "On" or "Off" end,
            activate = function() ns.SetClassColorsEnabled(not ns.db.useClassColors) end }
        entries[#entries + 1] = CycleChoice("Controller glyphs", function() return ns.db.controllerGlyphStyle or "xbox" end,
            function(v) ns.db.controllerGlyphStyle = v; ns.RefreshControllerGlyph() end,
            { { value = "none", label = "None" }, { value = "xbox", label = "Xbox" },
              { value = "playstation", label = "Playstation" }, { value = "nintendo", label = "Nintendo" } })
        entries[#entries + 1] = Toggle("Show unlearned weapon skills", "showWeaponSkills")
        entries[#entries + 1] = Toggle("Show learning costs", "showTrainerCosts")
        return entries
    elseif key == "appearance" then
        return {
            CycleChoice("Theme", function() return ns.db.backgroundMode == "MODERN" and "MODERN" or (ns.db.backgroundTheme or "MODERN") end,
                function(v) ns.ApplyBackgroundTheme(v) end, ns.THEME_CHOICES or {}),
            CycleChoice("Portrait", function() return ns.db.portraitMode or "class" end,
                function(v) ns.db.portraitMode = v; ns.RefreshClassIcon(); ns.RefreshPopupLayout() end, ns.PORTRAIT_CHOICES),
            CycleChoice("Portrait ring", function() return ns.db.portraitRingChoice or "NONE" end,
                function(v)
                    ns.db.portraitRingChoice = v
                    ns.db.portraitRingTexture = ns.GetPortraitRingReference(v)
                    ns.db.portraitRingEnabled = ns.db.portraitRingTexture ~= nil
                    ns.RefreshPortraitRing()
                end, ns.PORTRAIT_RING_CHOICES),
            CycleChoice("Background", function() return ns.db.backgroundChoice or "NONE" end,
                function(v) ns.ApplyBackgroundChoice(v) end, ns.BACKGROUND_TEXTURE_CHOICES or {}),
            CycleChoice("Frame", function() return ns.db.frameChoice or "BLACK_METAL" end,
                function(v) ns.ApplyFrameChoice(v) end, ns.FRAME_CHOICES or {}),
            CycleChoice("Background texture", function() return ns.db.backgroundStyle or "stretch" end,
                function(v)
                    ns.db.backgroundStyle = v
                    ns.db.backgroundFillMode = v == "tile" and "tile" or "scale"
                    Apply()
                end, ns.BACKGROUND_FILL_CHOICES or {}),
            { label = "Background opacity", get = function() return string.format("%d%%", (tonumber(ns.db.bgOpacity) or 0.7) * 100) end,
                activate = function(direction)
                    ns.db.bgOpacity = math.max(0, math.min(1, (tonumber(ns.db.bgOpacity) or 0.7) + direction * 0.05))
                    ns.ApplyBackgroundOpacity(ns.db.bgOpacity)
                end },
            Toggle("Lock Location", "lockFramePosition", function(v) ns.ApplyFrameLock(v) end),
            { label = "Preview Level-Up", get = function() return "A to preview" end,
                activate = function() ns.PreviewLevelUp() end },
            { label = "Reset Appearance", get = function() return "A to reset" end,
                activate = function() ns.ResetAppearanceToDefaults() end },
        }
    elseif key == "mode" then
        return {
            { label = "Enable addon", get = function() return ns.db.enabled ~= false and "On" or "Off" end,
                activate = function() ns.SetAddonEnabled(not (ns.db.enabled ~= false)) end },
            { label = "Hide Blizzard level-up toast", get = function() return ns.db.hideBlizzardLevelUp ~= false and "On" or "Off" end,
                activate = function()
                    ns.db.hideBlizzardLevelUp = not (ns.db.hideBlizzardLevelUp ~= false)
                    ns.ApplyAddonState(true)
                end },
            Toggle("Don't show until combat ends", "waitForCombatEnd"),
            Toggle("Show time played this level", "showLevelTime"),
            Toggle("Show minimap button", "minimapButtonShown", function(v) ns.SetMinimapButtonShown(v) end),
            Toggle("Compact Layout", "compactMode", function() ns.RefreshPopupLayout() end),
            Toggle("Right-click to close", "rightClickClose"),
            Toggle(ns.L("%s (recommended for gamepad)", ns.L("Allow click-through")), "clickThrough", function(v) ns.ApplyClickThrough(v) end),
            { label = ns.L("%s (recommended for gamepad)", ns.L("Ignore mouseover delay")),
                get = function() return ns.db.ignoreMouseoverDelay == true and "On" or "Off" end,
                activate = function() SetControllerIgnoreMouseoverDelay(not (ns.db.ignoreMouseoverDelay == true)) end },
            CycleChoice("Controller glyphs", function() return ns.db.controllerGlyphStyle or "xbox" end,
                function(v) ns.db.controllerGlyphStyle = v; ns.RefreshControllerGlyph() end,
                { { value = "none", label = "None" }, { value = "xbox", label = "Xbox" },
                  { value = "playstation", label = "Playstation" }, { value = "nintendo", label = "Nintendo" } }),
            CycleChoice("Frame strata", function() return ns.db.frameStrata or "HIGH" end,
                function(v) ns.db.frameStrata = v; ns.ApplyFrameStrata(v) end, ns.STRATA_CHOICES),
        }
    elseif key == "trainer" then
        return {
            Toggle("Automatically save trainer data", "autoScanTrainers"),
            Toggle("Include profession trainers", "scanProfessionTrainers"),
            Toggle("Show unlearned weapon skills", "showWeaponSkills"),
            Toggle("Show learning costs", "showTrainerCosts"),
            Toggle("Only skills unlocked at this level", "showOnlyCurrentLevelSkills"),
            Toggle("Only display new skills", "showOnlyNewSkills"),
            PetClassToggle("Show Warlock pet abilities", "showWarlockPetSkills", "WARLOCK"),
            PetClassToggle("Filter grimoires by active pet", "filterWarlockPetByActivePet", "WARLOCK"),
            PetClassToggle("Show Hunter pet abilities", "showHunterPetSkills", "HUNTER"),
        }
    elseif key == "sound" then
        return {
            Toggle("Play sound on level up", "playSound"),
            Toggle("Mute Blizzard level-up sound", "muteNativeDing", function() ns.ApplyAddonState(false) end),
            CycleChoice("Sound", function() return ns.db.soundChoice or "LEVELUP" end,
                function(v) ns.db.soundChoice = v; ns.db.customSoundFile = nil end, ns.SOUND_CHOICES or {}),
            CycleChoice("Sound channel", function() return ns.db.soundChannel or "Master" end,
                function(v) ns.db.soundChannel = v end, ns.SOUND_CHANNELS or {}),
            { label = "Sound volume", get = function() return string.format("%d%%", (tonumber(ns.db.soundVolume) or 1) * 100) end,
                activate = function(direction) ns.db.soundVolume = math.max(0, math.min(1, (tonumber(ns.db.soundVolume) or 1) + direction * 0.05)) end },
            { label = "Play sound", get = function() return "A to play" end,
                activate = function() ns.PlayLevelUpSound(true) end },
        }
    elseif key == "animation" then
        return {
            Toggle("Portrait pulse and starburst", "portraitAnimation", function() ns.RefreshVisualEffects() end),
            Toggle("Highlight new abilities", "highlightNewAbilities", function() ns.RefreshVisualEffects() end),
            Toggle("Emphasize stat gains", "emphasizeStatGains", function() ns.RefreshVisualEffects() end),
            Toggle("Portrait sparks", "portraitSparks", function() ns.RefreshVisualEffects() end),
            Toggle("New ability sparkles", "newAbilitySparkles", function() ns.RefreshVisualEffects() end),
            Toggle("Background embers", "backgroundEmbers", function() ns.RefreshVisualEffects() end),
            Toggle("Frame edge glow", "frameEdgeGlow", function() ns.RefreshVisualEffects() end),
            Toggle("Portrait and ring settle", "portraitRingSettle", function() ns.RefreshVisualEffects() end),
            Toggle("Reveal dividers", "dividerReveal", function() ns.RefreshVisualEffects() end),
            Toggle("Reduced motion", "reducedMotion", function() ns.RefreshVisualEffects() end),
            CycleChoice("Slide direction", function() return ns.db.statSlideDirection or "alternate" end,
                function(v) ns.db.statSlideDirection = v end,
                { { value = "none", label = "None" }, { value = "alternate", label = "Alternate" }, { value = "left", label = "Left" }, { value = "right", label = "Right" } }),
            { label = "Animation speed", get = function() return string.format("%.1fx", tonumber(ns.db.animSpeedMultiplier) or 1) end,
                activate = function(direction) ns.db.animSpeedMultiplier = math.max(0.25, math.min(3, (tonumber(ns.db.animSpeedMultiplier) or 1) + direction * 0.1)) end },
            { label = "Display duration", get = function() return string.format("%ds", tonumber(ns.db.duration) or 7) end,
                activate = function(direction) ns.db.duration = math.max(1, math.min(60, (tonumber(ns.db.duration) or 7) + direction)) end },
            { label = "Popup scale", get = function() return string.format("%.1fx", tonumber(ns.db.scale) or 1) end,
                activate = function(direction) ns.db.scale = math.max(0.5, math.min(2, (tonumber(ns.db.scale) or 1) + direction * 0.1)); Apply() end },
        }
    elseif key == "colors" then
        return {
            Toggle("Use class colors", "useClassColors", function(v) ns.SetClassColorsEnabled(v) end),
            Toggle("Show text shadows", "showTextShadow", function(v) ns.ApplyTextShadow(v) end),
            Toggle("Equal-width stat text", "equalStatWidths", function() ns.RefreshStatTextLayout() end),
        }
    elseif key == "profile" then
        return {
            { label = "Save per Character", get = function() return ns.L(ns.GetSavePerCharacter() and "On" or "Off") end,
                activate = function() ns.SetSavePerCharacter(not ns.GetSavePerCharacter()) end },
            CycleChoice("Profile", ns.GetActiveProfileName, ns.SelectProfile, ns.GetProfileChoices),
            { label = "Clear trainer cache", get = function() return "" end,
                activate = function() ns.ClearScannedTrainerData() end },
            { label = "Reset all options", get = function() return "" end,
                activate = function() ns.ResetOptionsToDefaults() end },
            { label = "Manage profiles", get = function() return "" end,
                activate = function() window:Hide(); ns.OpenProfileOptions() end },
            CycleChoice("Language", function() return ns.GetLanguageSelection(ns.db.language) end,
                function(value) ns.db.language = value end, ns.GetLanguageChoices()),
            { label = "Changes apply after reloading the UI.", get = function() return "" end },
            { label = "Reload UI", get = function() return "" end, activate = function() ReloadUI() end },
            { label = "Import / export", get = function() return "" end,
                activate = function()
                    window:Hide()
                    ns.OpenProfileTransfer()
                end },
        }
    end
    return {}
end

local function ClearBindings()
    local combat = type(InCombatLockdown) == "function" and InCombatLockdown()
    if bindingOwner and not combat then
        if type(ClearOverrideBindings) == "function" then pcall(ClearOverrideBindings, bindingOwner) end
        bindingsConfigured = false
    end
end

function ns.IsControllerOptionsShown()
    return window and window:IsShown() or false
end

Close = function()
    ClearBindings()
    SetControllerPreviewStrata(false)
    if window then window:Hide() end
    ns.RefreshPreviewSuspension()
    if bindingOwner then bindingOwner:Hide() end
end

local CONTROLLER_BACKDROP = {
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 32, edgeSize = 32,
    insets = { left = 11, right = 12, top = 12, bottom = 11 },
}

local function ControllerPieceColor(name)
    local colors = ns.db and ns.db.backgroundTextureColors
    local color = colors and colors[name]
    local hue = ns.db and (name == "center" and ns.db.backgroundColor or ns.db.frameColor)
    color = color or { 1, 1, 1 }
    if name == "center" and hue and hue[1] == 0 and hue[2] == 0 and hue[3] == 0 then
        return color[1], color[2], color[3]
    end
    hue = hue or { 1, 1, 1 }
    return color[1] * hue[1], color[2] * hue[2], color[3] * hue[3]
end

local function MakeControllerSkin()
    if window.gluThemeSkin then return window.gluThemeSkin end
    local skin = { pieces = {}, backing = window:CreateTexture(nil, "BACKGROUND", nil, -8) }
    skin.pieces.center = window:CreateTexture(nil, "BACKGROUND", nil, -8)
    for _, name in ipairs({ "topLeft", "top", "topRight", "left", "right", "bottomLeft", "bottom", "bottomRight" }) do
        local level = (name == "top" or name == "bottom" or name == "left" or name == "right") and -7 or -6
        skin.pieces[name] = window:CreateTexture(nil, "BACKGROUND", nil, level)
    end
    window.gluThemeSkin = skin
    return skin
end

local function SetControllerTexture(texture, name, path, alpha, tileH, tileV)
    if not path or path == "" or type(path) ~= "string" then
        texture:Hide()
        return false
    end
    local ok = ns.SetTextureFile(texture, path, tileH, tileV)
    if not ok then
        texture:Hide()
        return false
    end
    local transforms = ns.db and ns.db.backgroundTextureTransforms
    local transform = transforms and transforms[name]
    local rotation = transform and tonumber(transform.rotation) or 0
    if texture.SetRotation then texture:SetRotation(math.rad(rotation)) end
    if transform and transform.flipX then
        texture:SetTexCoord(1, 0, transform.flipY and 1 or 0, transform.flipY and 0 or 1)
    else
        texture:SetTexCoord(0, 1, transform and transform.flipY and 1 or 0, transform and transform.flipY and 0 or 1)
    end
    if texture.SetBlendMode then texture:SetBlendMode("BLEND") end
    local r, g, b = ControllerPieceColor(name)
    texture:SetVertexColor(r, g, b, alpha)
    texture:Show()
    return true
end

-- Reuse the same composite frame/background references as the level-up popup.
-- The tab buttons intentionally remain plain so controller focus and text stay
-- readable across all themes.
local function SkinControllerWindow()
    if not window then return end
    local skin = MakeControllerSkin()
    local theme = ns.GetSelectedCompositeTheme()
    if not theme or not theme.textures or not theme.textures.center then
        for _, texture in pairs(skin.pieces) do texture:Hide() end
        skin.backing:Hide()
        if window.SetBackdrop then window:SetBackdrop(CONTROLLER_BACKDROP) end
        return
    end

    if window.SetBackdrop then window:SetBackdrop(nil) end
    local width, height = window:GetWidth(), window:GetHeight()
    local corner = math.max(1, math.min(tonumber(theme.cornerSize) or 48, width / 2, height / 2))
    local edge = math.max(1, math.min(tonumber(theme.edgeSize) or corner, corner, width / 2, height / 2))
    local inset = math.max(0, tonumber(theme.edgeMaskInset) or 5)
    local edgeSpanWidth, edgeSpanHeight = math.max(1, width - inset * 2), math.max(1, height - inset * 2)
    local pieces = skin.pieces
    local function Anchor(texture, point, relativePoint, x, y, w, h)
        texture:ClearAllPoints()
        texture:SetPoint(point, window, relativePoint, x or 0, y or 0)
        texture:SetSize(math.max(1, w), math.max(1, h))
    end

    Anchor(pieces.topLeft, "TOPLEFT", "TOPLEFT", 0, 0, corner, corner)
    Anchor(pieces.top, "TOPLEFT", "TOPLEFT", inset, 0, edgeSpanWidth, edge)
    Anchor(pieces.topRight, "TOPRIGHT", "TOPRIGHT", 0, 0, corner, corner)
    Anchor(pieces.left, "TOPLEFT", "TOPLEFT", 0, -inset, edge, edgeSpanHeight)
    Anchor(pieces.right, "TOPRIGHT", "TOPRIGHT", 0, -inset, edge, edgeSpanHeight)
    Anchor(pieces.bottomLeft, "BOTTOMLEFT", "BOTTOMLEFT", 0, 0, corner, corner)
    Anchor(pieces.bottom, "BOTTOMLEFT", "BOTTOMLEFT", inset, 0, edgeSpanWidth, edge)
    Anchor(pieces.bottomRight, "BOTTOMRIGHT", "BOTTOMRIGHT", 0, 0, corner, corner)

    local style = ns.db and ns.db.backgroundStyle
    local tiled = style == "tile"
    -- Keep the backing across the full window. The authored frame pieces are
    -- layered above it, so stretch fills the complete panel instead of leaving
    -- a centered patch surrounded by the default backdrop.
    Anchor(skin.backing, "TOPLEFT", "TOPLEFT", 0, 0, width, height)
    if skin.backing.SetHorizTile then skin.backing:SetHorizTile(tiled) end
    if skin.backing.SetVertTile then skin.backing:SetVertTile(tiled) end
    SetControllerTexture(skin.backing, "center", theme.textures.center,
        (ns.db and ns.db.bgOpacity) or 0.70, tiled, tiled)
    for _, name in ipairs({ "topLeft", "top", "topRight", "left", "right", "bottomLeft", "bottom", "bottomRight" }) do
        local texture = pieces[name]
        local tileH = name == "top" or name == "bottom"
        local tileV = name == "left" or name == "right"
        if texture.SetHorizTile then texture:SetHorizTile(tileH) end
        if texture.SetVertTile then texture:SetVertTile(tileV) end
        SetControllerTexture(texture, name, theme.textures[name],
            (ns.db and ns.db.bgOpacity) or 0.70, tileH, tileV)
    end
end

-- Tabs, hints and rows share the same measured text policy as the normal
-- menu. Pagination uses remaining height rather than an assumed row count.
local function LayoutControllerChrome()
    local width = window:GetWidth() - 48
    local titleTop = 18
    if setupMode then titleTop = math.max(24, portraitPreview and portraitPreview:IsShown() and portraitPreview:GetHeight() / 2 - 24 + 12 or 24) + 8 end
    window.title:ClearAllPoints()
    window.title:SetPoint(setupMode and "TOP" or "TOPLEFT", window, setupMode and "TOP" or "TOPLEFT", setupMode and 0 or 24, -titleTop)
    local titleHeight = ns.WrapOptionsText(window.title, width - 40, setupMode and "CENTER" or "LEFT")
    local top = titleTop + titleHeight + 16
    local tabCount = setupMode and 0 or #tabs
    local columns = math.max(1, math.min(tabCount, math.max(1, math.floor((width + 6) / 100))))
    local tabWidth = (width - (columns - 1) * 6) / columns
    for first = 1, tabCount, columns do
        local height = 28
        for column = 0, columns - 1 do
            local tab = tabs[first + column]
            if tab then height = math.max(height, ns.WrapOptionsText(tab.text, tabWidth - 12, "CENTER") + 12) end
        end
        for column = 0, columns - 1 do
            local tab = tabs[first + column]
            if tab then
                tab:SetSize(tabWidth, height)
                tab:ClearAllPoints()
                tab:SetPoint("TOPLEFT", window, "TOPLEFT", 24 + column * (tabWidth + 6), -top)
                tab.text:ClearAllPoints()
                tab.text:SetPoint("TOPLEFT", tab, "TOPLEFT", 6, -6)
                tab.text:SetJustifyH("CENTER")
            end
        end
        top = top + height + 6
    end
    local hint = window.controllerHint
    hint:SetWidth(width)
    local visibleHints = {}
    local showHints = ControllerGlyphChoice() ~= "none"
    hint:SetShown(showHints)
    for _, item in ipairs(hint.items) do
        local visible = showHints and not (setupMode and item.labelKey == "Tabs")
        item:SetShown(visible)
        if visible then visibleHints[#visibleHints + 1] = item end
    end
    local hintColumns = math.max(1, math.min(#visibleHints, math.floor((width + 8) / 132)))
    local hintWidth = math.min(160, (width - (hintColumns - 1) * 8) / hintColumns)
    local hintTop = 0
    for first = 1, #visibleHints, hintColumns do
        local height, rowWidth = 34, 0
        local rowCount = math.min(hintColumns, #visibleHints - first + 1)
        for column = 0, rowCount - 1 do
            local item = visibleHints[first + column]
            local glyphWidth
            if item.fallback:IsShown() then
                glyphWidth = math.max(1, item.fallback:GetStringWidth())
                item.fallback:SetWidth(glyphWidth)
            else
                glyphWidth = item.icon:GetWidth()
                if item.secondaryIcon:IsShown() then glyphWidth = glyphWidth + item.secondaryIcon:GetWidth() - 2 end
            end
            local iconWidth = glyphWidth + 8
            ns.WrapOptionsText(item.label, hintWidth - iconWidth)
            local labelWidth = math.max(1, math.min(hintWidth - iconWidth, item.label:GetStringWidth()))
            height = math.max(height, ns.WrapOptionsText(item.label, labelWidth) + 8)
            item.contentWidth = iconWidth + labelWidth
            item.label:ClearAllPoints()
            item.label:SetPoint("LEFT", item, "LEFT", iconWidth, 0)
            rowWidth = rowWidth + item.contentWidth
        end
        local gap = math.min(24, math.max(8, (width - rowWidth) / math.max(1, rowCount - 1)))
        rowWidth = rowWidth + (rowCount - 1) * gap
        local cursor = (width - rowWidth) / 2
        for column = 0, rowCount - 1 do
            local item = visibleHints[first + column]
            item:SetSize(item.contentWidth, height)
            item:ClearAllPoints()
            item:SetPoint("TOPLEFT", hint, "TOPLEFT", cursor, -hintTop)
            cursor = cursor + item.contentWidth + gap
        end
        hintTop = hintTop + height + 4
    end
    hint:SetHeight(hintTop)
    local availabilityHeight = ns.WrapOptionsText(window.availability, width, setupMode and "CENTER" or "LEFT")
    window.availability:ClearAllPoints()
    window.availability:SetPoint("BOTTOM", window, "BOTTOM", 0, 20 + hintTop)
    local footerTop = hintTop + availabilityHeight + 36
    if window.finishButton then
        window.finishButton:SetShown(setupMode)
        window.finishButton:ClearAllPoints()
        window.finishButton:SetPoint("BOTTOM", window, "BOTTOM", 0, footerTop + 8)
        window.finishButton.text:SetText(ns.L("Finish setup"))
        local focused = selected == #window.entries + 1
        window.finishButton.text:SetTextColor(1, focused and 0.82 or 1, focused and 0.15 or 1)
    end
    return top + 8, window:GetHeight() - footerTop - (setupMode and 56 or 0)
end

local function RefreshRowHighlight(row, entryIndex, entry)
    local focused = entryIndex == selected or row.hovered == true
    row.selectionIndicator:SetText(entryIndex == selected and ">" or "")
    row.selectionIndicator:SetTextColor(focused and 1 or 0.75, focused and 0.82 or 0.75, focused and 0.15 or 0.75)
    row.text:SetTextColor(focused and 1 or 0.75, focused and 0.82 or 0.75, focused and 0.15 or 0.75)
    row.value:SetTextColor(focused and 1 or 0.75, focused and 0.82 or 0.75, focused and 0.15 or 0.75)
    row.background:SetColorTexture(0.45, 0.32, 0.12, focused and 0.42 or 0.08)
    if entry.isAvailable and not entry.isAvailable() then
        row.selectionIndicator:SetTextColor(0.45, 0.45, 0.45)
        row.text:SetTextColor(0.45, 0.45, 0.45)
        row.value:SetTextColor(0.45, 0.45, 0.45)
    end
end

local function SelectVisibleEntry(entryIndex)
    if controllerLayoutRunning or not window.entries or not window.entries[entryIndex] then return end
    selected = entryIndex
    for _, row in ipairs(rows) do
        if row:IsShown() and row.entryIndex and window.entries[row.entryIndex] then
            RefreshRowHighlight(row, row.entryIndex, window.entries[row.entryIndex])
        end
    end
end

local function Render()
    if not window or controllerLayoutRunning then return end
    controllerLayoutRunning = true
    PlaceControllerBelowPreview()
    if refreshCloseButton then refreshCloseButton() end
    RefreshPortraitPreview()
    PlacePortraitPreviewBelowPopup()
    local def = TAB_DEFS[tabIndex]
    window.entries = EntriesFor(setupMode and "setup" or def.key)
    window.title:SetText(ns.L(setupMode and "Welcome to GnomeLevelUp!" or "GnomeLevelUp - Controller options"))
    for _, item in ipairs(window.controllerHint and window.controllerHint.items or {}) do
        item.label:SetText(ns.L(item.labelKey))
    end
    window.availability:SetText(ns.L(setupMode and "Change these choices anytime in Options." or "Some options are not available in the controller menu."))
    local entryCount = #window.entries
    selected = math.min(selected, math.max(1, entryCount + (setupMode and 1 or 0)))
    for i, tab in ipairs(tabs) do
        tab:SetShown(not setupMode)
        local tabLabel = ns.L(TAB_DEFS[i].label)
        tab.text:SetText(tabLabel)
        tab.text:SetTextColor(i == tabIndex and 1 or 0.65, i == tabIndex and 0.82 or 0.65, i == tabIndex and 0.15 or 0.75)
        tab.background:SetColorTexture(0.45, 0.32, 0.12, i == tabIndex and 0.38 or 0.10)
    end
    local top, bottom = LayoutControllerChrome()
    local width = window:GetWidth() - 66
    local valueWidth = math.max(80, math.floor(width * 0.36))
    local labelWidth = width - valueWidth - 40
    rowOffset = math.max(0, math.min(rowOffset, math.max(0, selected - 1)))
    local selectedVisible
    repeat
        local cursor = top
        selectedVisible = entryCount == 0 or (setupMode and selected == entryCount + 1)
        window.visibleEntryCount = 0
        for i, row in ipairs(rows) do
            local entryIndex = rowOffset + i
            local entry = window.entries[entryIndex]
            row:Hide()
            if entry then
                row.text:SetText(ns.L(entry.label))
                local value = entry.get and tostring(entry.get()) or ""
                row.value:SetText(ns.L(value))
                local height = math.max(ROW_HEIGHT, math.max(ns.WrapOptionsText(row.text, labelWidth), ns.WrapOptionsText(row.value, valueWidth, "RIGHT")) + 12)
                if cursor + height > bottom then break end
                row:SetSize(width, height)
                row:ClearAllPoints()
                row:SetPoint("TOPLEFT", window, "TOPLEFT", 24, -cursor)
                row.text:ClearAllPoints()
                row.text:SetPoint("TOPLEFT", row, "TOPLEFT", 20, -6)
                row.value:ClearAllPoints()
                row.value:SetPoint("TOPRIGHT", row, "TOPRIGHT", -4, -6)
                row.value:SetJustifyH("RIGHT")
                row.entryIndex = entryIndex
                RefreshRowHighlight(row, entryIndex, entry)
                row:Show()
                if entryIndex == selected then selectedVisible = true end
                window.visibleEntryCount = window.visibleEntryCount + 1
                cursor = cursor + height + 2
            end
        end
        -- Rows after the first one that did not fit may still have been shown
        -- by the previous page; clear those stale hit targets as well.
        for i = window.visibleEntryCount + 1, #rows do rows[i]:Hide() end
        if not selectedVisible then rowOffset = rowOffset + 1 end
    until selectedVisible or rowOffset >= selected
    if window.scrollbar then
        local bar = window.scrollbar
        local hidden = entryCount > window.visibleEntryCount
        -- Leave the native slider's range and thumb untouched during a drag.
        if not bar.dragging then
            local height = math.max(48, window:GetHeight() - 64)
            if bar.layoutHeight ~= height then
                bar:ClearAllPoints()
                bar:SetPoint("TOPRIGHT", window, "TOPRIGHT", -12, -44)
                bar:SetHeight(height)
                bar.layoutHeight = height
            end
            bar:SetMinMaxValues(0, math.max(0, entryCount - math.max(1, window.visibleEntryCount)))
            if bar.inputRowOffset ~= rowOffset then bar.inputValue, bar.inputRowOffset = nil, nil end
            bar:SetValue(bar.inputValue or rowOffset)
            bar:GetThumbTexture():SetHeight(math.max(28, math.min(64, height * window.visibleEntryCount / math.max(1, entryCount))))
        end
        bar:SetShown(hidden)
    end
    SkinControllerWindow()
    ns.RefreshControllerOptionsWatermark()
    controllerLayoutRunning = false
end

local function Move(direction)
    local count = #window.entries + (setupMode and 1 or 0)
    selected = ((selected - 1 + direction) % count) + 1
    Render()
end

local function Scroll(delta)
    if not window or not window.entries then return end
    local visible = math.max(1, window.visibleEntryCount or 1)
    local maxOffset = math.max(0, #window.entries - visible)
    rowOffset = math.max(0, math.min(maxOffset, rowOffset + (delta > 0 and -1 or 1)))
    selected = math.max(rowOffset + 1, math.min(selected, rowOffset + visible))
    Render()
end

local function ChangeTab(direction)
    if setupMode then return end
    tabIndex = ((tabIndex - 1 + direction) % #TAB_DEFS) + 1
    selected = 1
    rowOffset = 0
    if window.scrollbar then window.scrollbar.inputValue, window.scrollbar.inputRowOffset = nil, nil end
    Render()
end

local function Activate()
    if setupMode and selected == #window.entries + 1 then
        ns.SaveActiveProfile()
        Close()
        return
    end
    local entry = window.entries[selected]
    if entry and entry.activate then entry.activate(1) end
    Render()
end

local function Adjust(direction)
    local entry = window.entries[selected]
    if entry and entry.activate then entry.activate(direction) end
    Render()
end

local function Bind(key, action)
    local button = inputButtons[key]
    if not button then
        button = CreateFrame("Button", "GnomeLevelUpControllerOptionInput" .. key, bindingOwner)
        button:SetSize(1, 1)
        button:SetPoint("TOPLEFT", UIParent, "TOPLEFT", -20, 20)
        button:RegisterForClicks("AnyDown")
        inputButtons[key] = button
    end
    button:SetScript("OnClick", action)
    if type(SetOverrideBindingClick) == "function" then
        pcall(SetOverrideBindingClick, bindingOwner, true, key, button:GetName(), "LeftButton")
    end
end

local function UpdateBindings(active)
    if type(InCombatLockdown) == "function" and InCombatLockdown() then return end
    if not active then
        if bindingsConfigured then ClearBindings() end
        bindingOwner:Hide()
        return
    end
    bindingOwner:Show()
    if bindingsConfigured then return end
    -- Forever uses PADD* for the D-pad and PAD*SHOULDER for bumpers.
    Bind("PADDUP", function() Move(-1) end)
    Bind("PADDDOWN", function() Move(1) end)
    Bind("PADDLEFT", function() Adjust(-1) end)
    Bind("PADDRIGHT", function() Adjust(1) end)
    Bind("PADLSHOULDER", function() ChangeTab(-1) end)
    Bind("PADRSHOULDER", function() ChangeTab(1) end)
    Bind("PAD1", Activate)
    Bind("PAD2", Close)
    bindingsConfigured = true
end

local function Build()
    if window then return end
    bindingOwner = CreateFrame("Frame", "GnomeLevelUpControllerOptionsBindings", UIParent)
    bindingOwner:Hide()
    window = CreateFrame("Frame", "GnomeLevelUpControllerOptions", UIParent, "BackdropTemplate")
    window:Hide()
    local specialFrames = _G["UISpecialFrames"]
    if type(specialFrames) == "table" then specialFrames[#specialFrames + 1] = "GnomeLevelUpControllerOptions" end
    window:SetSize(math.min(760, UIParent:GetWidth() - 40), math.min(620, UIParent:GetHeight() - 40))
    window:SetPoint("CENTER")
    window:SetFrameStrata("HIGH")
    window:EnableKeyboard(true)
    window:SetScript("OnKeyDown", function(self, key)
        local focus = type(GetCurrentKeyBoardFocus) == "function" and GetCurrentKeyBoardFocus()
        local editing = focus and focus.IsObjectType and focus:IsObjectType("EditBox")
        local handled = not editing and (key == "UP" or key == "DOWN" or key == "LEFT"
            or key == "RIGHT" or key == "ENTER" or key == "NUMPADENTER" or key == "ESCAPE" or key == "TAB")
        if self.SetPropagateKeyboardInput then self:SetPropagateKeyboardInput(not handled) end
        if not handled then return end
        if key == "UP" then Move(-1)
        elseif key == "DOWN" then Move(1)
        elseif key == "LEFT" then Adjust(-1)
        elseif key == "RIGHT" then Adjust(1)
        elseif key == "ENTER" or key == "NUMPADENTER" then Activate()
        elseif key == "ESCAPE" then Close()
        elseif key == "TAB" then
            local direction = IsShiftKeyDown and IsShiftKeyDown() and -1 or 1
            if setupMode then Move(direction) else ChangeTab(direction) end
        end
    end)
    window:EnableMouseWheel(true)
    window:SetScript("OnMouseWheel", function(_, delta) Scroll(delta) end)
    window:SetBackdrop({ bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark", edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", tile = true, tileSize = 32, edgeSize = 32, insets = { left = 11, right = 12, top = 12, bottom = 11 } })
    _, refreshCloseButton = CreateControllerCloseButton(window, Close)
    portraitPreview = CreateFrame("Frame", nil, window)
    portraitPreview:SetPoint("TOP", window, "TOP", 0, 24)
    portraitPreview:SetFrameLevel(window:GetFrameLevel() + 4)
    portraitPreview.icon = portraitPreview:CreateTexture(nil, "ARTWORK", nil, 1)
    portraitPreview.icon:SetPoint("CENTER")
    portraitPreview.ring = portraitPreview:CreateTexture(nil, "ARTWORK", nil, 2)
    portraitPreview.ring:SetPoint("CENTER")
    if portraitPreview.CreateMaskTexture then
        local iconMask = portraitPreview:CreateMaskTexture()
        iconMask:SetAllPoints(portraitPreview.icon)
        iconMask:SetTexture("Interface\\CharacterFrame\\TempPortraitAlphaMask",
            "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
        portraitPreview.icon:AddMaskTexture(iconMask)
    end
    portraitPreview:Hide()
    local title = window:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 24, -18)
    title:SetText(ns.L("GnomeLevelUp - Controller options"))
    window.title = title
    for i, def in ipairs(TAB_DEFS) do
        local tab = CreateFrame("Button", nil, window)
        local tabNumber = i
        tab:SetSize(98, 28)
        tab:SetPoint("TOPLEFT", 18 + (i - 1) * 103, -43)
        tab.background = tab:CreateTexture(nil, "BACKGROUND")
        tab.background:SetAllPoints()
        tab.text = tab:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        tab.text:SetPoint("CENTER")
        tab.text:SetText(ns.L(def.label))
        tab:SetScript("OnClick", function()
            tabIndex, selected = i, 1
            rowOffset = 0
            Render()
        end)
        tab:SetScript("OnEnter", function()
            tab.background:SetColorTexture(0.60, 0.42, 0.16, 0.30)
        end)
        tab:SetScript("OnLeave", function()
            tab.background:SetColorTexture(0.45, 0.32, 0.12, tabNumber == tabIndex and 0.38 or 0.10)
        end)
        tabs[i] = tab
    end
    -- Keep enough visible rows for the larger Appearance and Mode tabs. The
    -- controller page uses D-pad focus rather than a second scroll frame.
    for i = 1, VISIBLE_ROWS do
        local row = CreateFrame("Button", nil, window)
        local rowNumber = i
        row:SetSize(700, ROW_HEIGHT)
        row:SetPoint("TOPLEFT", 24, -84)
        row.background = row:CreateTexture(nil, "BACKGROUND")
        row.background:SetAllPoints()
        row:SetScript("OnEnter", function(self)
            self.hovered = true
            local entry = window.entries and window.entries[self.entryIndex]
            if entry then RefreshRowHighlight(self, self.entryIndex, entry) end
        end)
        row:SetScript("OnLeave", function(self)
            self.hovered = false
            local entry = window.entries and window.entries[self.entryIndex]
            if entry then RefreshRowHighlight(self, self.entryIndex, entry) end
        end)
        row:SetScript("OnHide", function(self) self.hovered = false end)
        row:EnableMouseWheel(true)
        row:SetScript("OnMouseWheel", function(_, delta) Scroll(delta) end)
        row:SetScript("OnClick", function()
            local entryIndex = rowOffset + rowNumber
            if window.entries and window.entries[entryIndex] then selected = entryIndex; Activate() end
        end)
        row.text = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
        row.text:SetPoint("TOPLEFT", row, "TOPLEFT", 20, -6)
        row.text:SetJustifyH("LEFT")
        row.value = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
        row.value:SetPoint("TOPRIGHT", row, "TOPRIGHT", -4, -6)
        row.value:SetJustifyH("RIGHT")
        row.selectionIndicator = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
        row.selectionIndicator:SetPoint("TOPLEFT", row, "TOPLEFT", 4, -6)
        row.selectionIndicator:SetSize(14, 16)
        row.selectionIndicator:SetJustifyH("LEFT")
        rows[i] = row
    end
    local scrollbar = CreateFrame("Slider", nil, window)
    scrollbar:EnableMouse(true)
    scrollbar:SetWidth(16)
    scrollbar:SetHitRectInsets(-4, -4, 0, 0)
    scrollbar:SetOrientation("VERTICAL")
    scrollbar:SetValueStep(0)
    scrollbar:SetObeyStepOnDrag(false)
    local track = scrollbar:CreateTexture(nil, "BACKGROUND")
    track:SetAllPoints()
    track:SetColorTexture(0.25, 0.25, 0.25, 0.65)
    scrollbar:SetThumbTexture("Interface\\Buttons\\WHITE8X8")
    scrollbar:GetThumbTexture():SetWidth(12)
    scrollbar:GetThumbTexture():SetVertexColor(0.9, 0.76, 0.45, 1)
    local function EndScrollDrag()
        scrollbar.dragging = false
        scrollbar:SetScript("OnUpdate", nil)
        if window:IsShown() then Render() end
    end
    scrollbar:SetScript("OnMouseDown", function(_, button)
        if button ~= "LeftButton" then return end
        scrollbar.dragging = true
        scrollbar:SetScript("OnUpdate", function()
            if type(IsMouseButtonDown) == "function" and not IsMouseButtonDown("LeftButton") then EndScrollDrag() end
        end)
    end)
    scrollbar:SetScript("OnMouseUp", function(_, button)
        if button == "LeftButton" then EndScrollDrag() end
    end)
    scrollbar:SetScript("OnHide", function()
        scrollbar.dragging = false
        scrollbar:SetScript("OnUpdate", nil)
    end)
    scrollbar:SetScript("OnValueChanged", function(_, value)
        if controllerLayoutRunning or not window.entries then return end
        local nextOffset = math.floor(value + 0.5)
        scrollbar.inputValue, scrollbar.inputRowOffset = value, nextOffset
        if nextOffset == rowOffset then return end
        rowOffset = nextOffset
        selected = rowOffset + 1
        Render()
    end)
    scrollbar:EnableMouseWheel(true)
    scrollbar:SetScript("OnMouseWheel", function(_, delta) Scroll(delta) end)
    window.scrollbar = scrollbar
    local finish = CreateFrame("Button", nil, window, "UIPanelButtonTemplate")
    finish:SetSize(220, 36)
    finish:SetNormalFontObject("GameFontNormalLarge")
    finish:SetHighlightFontObject("GameFontNormalLarge")
    finish:SetDisabledFontObject("GameFontNormalLarge")
    finish.text = finish:GetFontString()
    finish.text:SetFontObject("GameFontNormalLarge")
    finish:SetScript("OnClick", function() ns.SaveActiveProfile(); Close() end)
    window.finishButton = finish
    window.watermark = window:CreateTexture(nil, "BACKGROUND", nil, -5)
    window.watermark:SetPoint("BOTTOMRIGHT", window, "BOTTOMRIGHT", -24, 18)
    local hint = CreateFrame("Frame", nil, window)
    hint:SetSize(680, 34)
    hint:SetPoint("BOTTOM", 0, 10)
    local hintStyle = ControllerGlyphChoice()
    local selectFallback = hintStyle == "nintendo" and "B" or (hintStyle == "playstation" and "X" or "A")
    local closeFallback = hintStyle == "nintendo" and "A" or (hintStyle == "playstation" and "O" or "B")
    local hintItems = {
        CreateControllerHintItem(hint, "move", "Move", "D", 1),
        CreateControllerHintItem(hint, "select", "Select", selectFallback, 2),
        CreateControllerHintItem(hint, "adjust", "Adjust", "< >", 3),
        CreateControllerHintItem(hint, { left = "tabLeft", right = "tabRight" }, "Tabs", "LB/RB", 4),
        CreateControllerHintItem(hint, "close", "Close", closeFallback, 5),
    }
    hint.items = hintItems
    RefreshControllerHints(hintItems)
    window.controllerHint = hint
    window.controllerHintStyle = hintStyle
    local availability = window:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    availability:SetPoint("BOTTOM", 0, 62)
    availability:SetText(ns.L("Some options are not available in the controller menu."))
    availability:SetTextColor(0.75, 0.75, 0.75)
    window.availability = availability
    window:HookScript("OnSizeChanged", Render)
    local controllerPollElapsed = 0
    local lastCloseGlyphStyle
    window:SetScript("OnShow", function()
        controllerPollElapsed = 0
        lastCloseGlyphStyle = ControllerGlyphChoice()
        if refreshCloseButton then refreshCloseButton() end
        SetControllerPreviewStrata(true)
        ns.RefreshPreviewSuspension()
    end)
    window:SetScript("OnHide", Close)
    window:SetScript("OnUpdate", function(_, elapsed)
        controllerPollElapsed = controllerPollElapsed + (elapsed or 0)
        if controllerPollElapsed < 0.20 then return end
        controllerPollElapsed = 0
        local controllerActive = IsActive()
        if not controllerActive and not manualOpen then
            Close()
            return
        end
        UpdateBindings(controllerActive)
        SetControllerPreviewStrata(true)
        local glyphStyle = ControllerGlyphChoice()
        if glyphStyle ~= lastCloseGlyphStyle then
            if refreshCloseButton then refreshCloseButton() end
            lastCloseGlyphStyle = glyphStyle
        end
        if window.controllerHint and window.controllerHintStyle ~= glyphStyle then
            RefreshControllerHints(window.controllerHint.items)
            window.controllerHintStyle = glyphStyle
            Render()
        end
    end)
end

function ns.ToggleControllerOptions(force, allowKeyboard, firstTime)
    if (not IsActive() and not allowKeyboard) or (type(InCombatLockdown) == "function" and InCombatLockdown()) then
        if window then Close() end
        return false
    end
    setupMode, manualOpen = firstTime == true, allowKeyboard == true
    if setupMode then
        selected, rowOffset = 1, 0
        if window and window.scrollbar then window.scrollbar.inputValue, window.scrollbar.inputRowOffset = nil, nil end
    end
    Build()
    if force == false then Close() return false end
    if window:IsShown() and force ~= true then Close() return false end
    bindingOwner:SetShown(IsActive())
    SetControllerPreviewStrata(true)
    ClearBindings()
    UpdateBindings(IsActive())
    Render()
    window:Show()
    return true
end

function ns.CloseControllerOptions() Close() end

function ns.OpenControllerOptionsWhenFree()
    if not IsActive() then return false end
    local function open()
        if IsActive() then ns.ToggleControllerOptions(true) end
    end
    local panel = _G["SettingsPanel"] or _G["InterfaceOptionsFrame"]
    if panel and panel:IsShown() then
        if type(HideUIPanel) == "function" then pcall(HideUIPanel, panel) else panel:Hide() end
        if C_Timer and C_Timer.After then C_Timer.After(0.15, open) else open() end
    else
        open()
    end
    return true
end

-- Share the existing measured rows, theme skin and controller navigation.
function ns.OpenFirstTimeSetup()
    ns.EnsureDatabase()
    if ns.ToggleControllerOptions(true, true, true) then
        ns.db.firstTimeSetupShown = true
        return true
    end
    return false
end

function ns.ShowFirstTimeSetupIfNeeded()
    if not ns.db.firstTimeSetupShown then return ns.OpenFirstTimeSetup() end
end

function ns.RefreshControllerOptionsWatermark()
    if window and window.watermark and ns.RefreshOptionsWatermark then
        ns.RefreshOptionsWatermark(window.watermark)
        window.watermark:SetAlpha(0.36)
    end
end
