local ADDON_NAME, ns = ...

-- Retail does not expose the Forever controller options/input API reliably.
-- Leave this module inert there so it cannot create bindings, glyph handlers,
-- or controller frames on that client.
if ns.GetCurrentFlavor and ns.GetCurrentFlavor() == "retail" then
    return
end

-- This controller page is deliberately separate from Options.lua. Blizzard's
-- dropdowns and checkboxes do not provide a dependable focus model on Forever,
-- while a small page with explicit rows can use the same override-click input
-- pattern as the native controller UI. Nothing is built until it is opened.
local window
local bindingOwner
local rows, tabs, inputButtons = {}, {}, {}
local refreshCloseButton
local portraitPreview
local tabIndex, selected = 1, 1
local rowOffset = 0
local VISIBLE_ROWS = 12
local ROW_HEIGHT = 34
local ROW_SPACING = 36
local savedPreviewStrata

local TAB_DEFS = {
    { key = "appearance", label = "Appearance" },
    { key = "mode", label = "Mode" },
    { key = "trainer", label = "Trainer Data" },
    { key = "sound", label = "Sound" },
    { key = "animation", label = "Animation" },
    { key = "colors", label = "Colors" },
    { key = "debug", label = "Debug" },
}

local function IsActive()
    return ns.IsControllerUIActive and ns.IsControllerUIActive()
end

local function SetControllerIgnoreMouseoverDelay(value)
    ns.db.ignoreMouseoverDelay = value == true
    ns.db.ignoreMouseoverDelayUserSet = true
    if value and ns.RescheduleFadeOut and ns.levelUpFrame and ns.levelUpFrame:IsShown() then
        ns.RescheduleFadeOut(0.15)
    end
end

local CONTROLLER_GLYPHS = {
    xbox = { atlases = { "gamepad_ltr_b_64", "Gamepad_Ltr_B_64" }, file = "Interface\\Gamepad\\gamepadltr.blp" },
    playstation = { atlases = { "gamepad_shp_circle_64", "Gamepad_Shp_Circle_64" }, file = "Interface\\Gamepad\\gamepadshp.blp" },
    -- Nintendo face labels are reversed relative to Xbox/PlayStation. The
    -- physical cancel/back position is therefore represented by A here.
    nintendo = { atlases = { "gamepad_rev_a_64", "Gamepad_Rev_A_64" }, file = "Interface\\Gamepad\\gamepadrev.blp" },
}

local function ControllerGlyphChoice()
    local value = ns.db and ns.db.controllerGlyphStyle
    if value == "none" then return "none" end
    if value == "playstation" or value == "nintendo" then return value end
    return "xbox"
end

local function SetGlyphTexture(texture, path)
    local ok = pcall(texture.SetTexture, texture, path)
    if not ok then return false end
    if texture.GetTextureFileID then
        local idOK, fileID = pcall(texture.GetTextureFileID, texture)
        if idOK then return fileID ~= nil and fileID ~= 0 end
    end
    return true
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
    if C_Texture and type(C_Texture.GetAtlasInfo) == "function" then
        for _, atlas in ipairs(candidates or {}) do
            local ok, info = pcall(C_Texture.GetAtlasInfo, atlas)
            if ok and info and (info.file or info.filename)
                and info.leftTexCoord and info.rightTexCoord
                and info.topTexCoord and info.bottomTexCoord then
                local applied = SetGlyphTexture(texture, info.file or info.filename)
                if applied then
                    texture:SetTexCoord(info.leftTexCoord, info.rightTexCoord,
                        info.topTexCoord, info.bottomTexCoord)
                    return true
                end
            end
        end
    end
    if texture.SetAtlas then
        for _, atlas in ipairs(candidates or {}) do
            local applied = pcall(texture.SetAtlas, texture, atlas, false)
            if applied then return true end
        end
    end
    return false
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
    item.label:SetText(ns.L and ns.L(label) or label)
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
        preview:SetFrameStrata("DIALOG")
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
        local reference = CONTROLLER_GLYPHS[ControllerGlyphChoice()] or CONTROLLER_GLYPHS.xbox
        local applied = false
        if C_Texture and type(C_Texture.GetAtlasInfo) == "function" then
            for _, atlas in ipairs(reference.atlases or {}) do
                local ok, info = pcall(C_Texture.GetAtlasInfo, atlas)
                if ok and info and (info.file or info.filename)
                    and info.leftTexCoord and info.rightTexCoord
                    and info.topTexCoord and info.bottomTexCoord then
                    applied = pcall(icon.SetTexture, icon, info.file or info.filename)
                    if applied then
                        icon:SetTexCoord(info.leftTexCoord, info.rightTexCoord,
                            info.topTexCoord, info.bottomTexCoord)
                        break
                    end
                end
            end
        end
        if not applied and icon.SetAtlas then
            for _, atlas in ipairs(reference.atlases or {}) do
                applied = pcall(icon.SetAtlas, icon, atlas, false)
                if applied then break end
            end
        end
        if not applied then
            applied = SetGlyphTexture(icon, reference.file)
            if applied then icon:SetTexCoord(0, 1, 0, 1) end
        end
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

local function ControllerStrataChoices()
    local choices = { { value = "AUTO", label = "Auto (below preview)" } }
    for _, choice in ipairs(ns.STRATA_CHOICES or {}) do
        choices[#choices + 1] = { value = choice.value, label = choice.label }
    end
    return choices
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
    if not enabled then
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

    local applied = false
    if type(reference) == "table" and reference.atlas and portraitPreview.ring.SetAtlas then
        applied = pcall(portraitPreview.ring.SetAtlas, portraitPreview.ring, reference.atlas, reference.useAtlasSize == true)
    elseif type(reference) == "string" then
        -- Portrait rings are complete circular images; keep the same direct
        -- texture path used by the popup and never apply tiling here.
        applied = pcall(portraitPreview.ring.SetTexture, portraitPreview.ring, reference)
    end
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
    if ns.ApplyCurrentAppearance then ns.ApplyCurrentAppearance() end
    if ns.RefreshOptionsPanel then ns.RefreshOptionsPanel() end
end

local function ChoiceLabel(value, choices)
    for _, choice in ipairs(choices or {}) do
        if choice.value == value then return ns.L and ns.L(choice.label) or choice.label end
    end
    return tostring(value or "")
end

local function CycleChoice(label, get, set, choices, after)
    return {
        label = label,
        get = function() return ChoiceLabel(get(), choices) end,
        activate = function(direction)
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
    return {
        label = label,
        get = function() return ns.db[key] == true and "On" or "Off" end,
        activate = function()
            ns.db[key] = not (ns.db[key] == true)
            if after then after(ns.db[key]) end
        end,
    }
end

local function PetClassToggle(label, key, class)
    local entry = Toggle(label, key)
    entry.isAvailable = function()
        local _, token = UnitClass("player")
        return token == class and (not ns.GetCurrentFlavor or ns.GetCurrentFlavor() == "forever")
    end
    local activate = entry.activate
    entry.activate = function()
        if entry.isAvailable() then activate() end
    end
    return entry
end

local function EntriesFor(key)
    if key == "appearance" then
        return {
            CycleChoice("Theme", function() return ns.db.backgroundMode == "MODERN" and "MODERN" or (ns.db.backgroundTheme or "MODERN") end,
                function(v) if ns.ApplyBackgroundTheme then ns.ApplyBackgroundTheme(v) end end, ns.THEME_CHOICES or {}),
            CycleChoice("Portrait", function() return ns.db.portraitMode or "class" end,
                function(v) ns.db.portraitMode = v; if ns.RefreshClassIcon then ns.RefreshClassIcon() end end, ns.PORTRAIT_CHOICES),
            CycleChoice("Portrait ring", function() return ns.db.portraitRingChoice or "NONE" end,
                function(v)
                    ns.db.portraitRingChoice = v
                    ns.db.portraitRingTexture = ns.GetPortraitRingReference and ns.GetPortraitRingReference(v)
                    ns.db.portraitRingEnabled = ns.db.portraitRingTexture ~= nil
                    if ns.RefreshPortraitRing then ns.RefreshPortraitRing() end
                end, ns.PORTRAIT_RING_CHOICES),
            CycleChoice("Background", function() return ns.db.backgroundChoice or "NONE" end,
                function(v) if ns.ApplyBackgroundChoice then ns.ApplyBackgroundChoice(v) end end, ns.BACKGROUND_TEXTURE_CHOICES or {}),
            CycleChoice("Frame", function() return ns.db.frameChoice or "BLACK_METAL" end,
                function(v) if ns.ApplyFrameChoice then ns.ApplyFrameChoice(v) end end, ns.FRAME_CHOICES or {}),
            CycleChoice("Background texture", function() return ns.db.backgroundStyle or "stretch" end,
                function(v)
                    ns.db.backgroundStyle = v
                    ns.db.backgroundFillMode = v == "tile" and "tile" or "scale"
                    Apply()
                end, ns.BACKGROUND_FILL_CHOICES or {}),
            { label = "Background opacity", get = function() return string.format("%d%%", (tonumber(ns.db.bgOpacity) or 0.7) * 100) end,
                activate = function(direction)
                    ns.db.bgOpacity = math.max(0, math.min(1, (tonumber(ns.db.bgOpacity) or 0.7) + direction * 0.05))
                    if ns.ApplyBackgroundOpacity then ns.ApplyBackgroundOpacity(ns.db.bgOpacity) end
                end },
            Toggle("Lock frame position", "lockFramePosition", function(v) if ns.ApplyFrameLock then ns.ApplyFrameLock(v) end end),
            { label = "Preview level-up", get = function() return "A to preview" end,
                activate = function() if ns.PreviewLevelUp then ns.PreviewLevelUp() end end },
            { label = "Reset appearance", get = function() return "A to reset" end,
                activate = function() if ns.ResetAppearanceToDefaults then ns.ResetAppearanceToDefaults() end end },
        }
    elseif key == "mode" then
        return {
            { label = "Enable addon", get = function() return ns.db.enabled ~= false and "On" or "Off" end,
                activate = function() if ns.SetAddonEnabled then ns.SetAddonEnabled(not (ns.db.enabled ~= false)) end end },
            { label = "Hide Blizzard level-up toast", get = function() return ns.db.hideBlizzardLevelUp ~= false and "On" or "Off" end,
                activate = function()
                    ns.db.hideBlizzardLevelUp = not (ns.db.hideBlizzardLevelUp ~= false)
                    if ns.ApplyAddonState then ns.ApplyAddonState(true) end
                end },
            Toggle("Don't show until combat ends", "waitForCombatEnd"),
            Toggle("Show time played this level", "showLevelTime"),
            Toggle("Show minimap button", "minimapButtonShown", function(v) if ns.SetMinimapButtonShown then ns.SetMinimapButtonShown(v) end end),
            Toggle("Compact layout", "compactMode", function() if ns.RefreshPopupLayout then ns.RefreshPopupLayout() end end),
            Toggle("Right-click to close", "rightClickClose"),
            Toggle("Allow click-through (recommended for gamepad)", "clickThrough", function(v) if ns.ApplyClickThrough then ns.ApplyClickThrough(v) end end),
            { label = "Ignore mouseover delay (recommended for gamepad)",
                get = function() return ns.db.ignoreMouseoverDelay == true and "On" or "Off" end,
                activate = function() SetControllerIgnoreMouseoverDelay(not (ns.db.ignoreMouseoverDelay == true)) end },
            CycleChoice("Controller glyphs", function() return ns.db.controllerGlyphStyle or "xbox" end,
                function(v) ns.db.controllerGlyphStyle = v; if ns.RefreshControllerGlyph then ns.RefreshControllerGlyph() end end,
                { { value = "none", label = "None" }, { value = "xbox", label = "Xbox" },
                  { value = "playstation", label = "Playstation" }, { value = "nintendo", label = "Nintendo" } }),
            CycleChoice("Frame strata", function() return ns.db.frameStrata or "HIGH" end,
                function(v) ns.db.frameStrata = v; if ns.ApplyFrameStrata then ns.ApplyFrameStrata(v) end end, ns.STRATA_CHOICES),
        }
    elseif key == "trainer" then
        return {
            Toggle("Auto-save trainer data", "autoScanTrainers"),
            Toggle("Scan profession trainers", "scanProfessionTrainers"),
            Toggle("Show weapon skills", "showWeaponSkills"),
            Toggle("Show trainer costs", "showTrainerCosts"),
            Toggle("Only current-level skills", "showOnlyCurrentLevelSkills"),
            Toggle("Only new skills", "showOnlyNewSkills"),
            PetClassToggle("Show warlock grimoires", "showWarlockPetSkills", "WARLOCK"),
            PetClassToggle("Filter by active pet", "filterWarlockPetByActivePet", "WARLOCK"),
            PetClassToggle("Show Hunter pet abilities", "showHunterPetSkills", "HUNTER"),
        }
    elseif key == "sound" then
        return {
            Toggle("Play a sound", "playSound"),
            Toggle("Mute native Ding", "muteNativeDing", function() if ns.ApplyAddonState then ns.ApplyAddonState(false) end end),
            CycleChoice("Sound", function() return ns.db.soundChoice or "LEVELUP" end,
                function(v) ns.db.soundChoice = v; ns.db.customSoundFile = nil end, ns.SOUND_CHOICES or {}),
            CycleChoice("Sound channel", function() return ns.db.soundChannel or "Master" end,
                function(v) ns.db.soundChannel = v end, ns.SOUND_CHANNELS or {}),
            { label = "Sound volume", get = function() return string.format("%d%%", (tonumber(ns.db.soundVolume) or 1) * 100) end,
                activate = function(direction) ns.db.soundVolume = math.max(0, math.min(1, (tonumber(ns.db.soundVolume) or 1) + direction * 0.05)) end },
            { label = "Play selected sound", get = function() return "A to play" end,
                activate = function() if ns.PlayLevelUpSound then ns.PlayLevelUpSound(true) end end },
        }
    elseif key == "animation" then
        return {
            Toggle("Reduced motion", "reducedMotion"),
            CycleChoice("Stat slide direction", function() return ns.db.statSlideDirection or "alternate" end,
                function(v) ns.db.statSlideDirection = v end,
                { { value = "alternate", label = "Alternate" }, { value = "left", label = "Left" }, { value = "right", label = "Right" } }),
            { label = "Animation speed", get = function() return string.format("%.1fx", tonumber(ns.db.animSpeedMultiplier) or 1) end,
                activate = function(direction) ns.db.animSpeedMultiplier = math.max(0.25, math.min(3, (tonumber(ns.db.animSpeedMultiplier) or 1) + direction * 0.1)) end },
            { label = "Display duration", get = function() return string.format("%ds", tonumber(ns.db.duration) or 7) end,
                activate = function(direction) ns.db.duration = math.max(1, math.min(60, (tonumber(ns.db.duration) or 7) + direction)) end },
            { label = "Popup scale", get = function() return string.format("%.1fx", tonumber(ns.db.scale) or 1) end,
                activate = function(direction) ns.db.scale = math.max(0.5, math.min(2, (tonumber(ns.db.scale) or 1) + direction * 0.1)); Apply() end },
        }
    elseif key == "colors" then
        return {
            Toggle("Use class colors", "useClassColors", function(v) if ns.SetClassColorsEnabled then ns.SetClassColorsEnabled(v) end end),
            Toggle("Text shadow", "showTextShadow", function(v) if ns.ApplyTextShadow then ns.ApplyTextShadow(v) end end),
            Toggle("Equal-width stat text", "equalStatWidths", function() if ns.RefreshStatTextLayout then ns.RefreshStatTextLayout() end end),
            Toggle("Classic level-up text", "printClassicLevelUpText"),
        }
    elseif key == "debug" then
        return {
            Toggle("Debug commands", "debugEnabled"),
            CycleChoice("Controller Menu Frame Strata",
                function() return ns.db.controllerMenuFrameStrata or "AUTO" end,
                function(v) ns.db.controllerMenuFrameStrata = v; PlaceControllerBelowPreview() end,
                ControllerStrataChoices()),
            { label = "Portrait ring scale", get = function() return string.format("%.2fx", tonumber(ns.db.portraitRingScale) or 1.1) end,
                activate = function(direction) ns.db.portraitRingScale = math.max(0.5, math.min(2, (tonumber(ns.db.portraitRingScale) or 1.1) + direction * 0.05)); if ns.RefreshPortraitGeometry then ns.RefreshPortraitGeometry() end end },
            { label = "Portrait offset X", get = function() return string.format("%+.0f", tonumber(ns.db.portraitRingOffset and ns.db.portraitRingOffset.x) or 0) end,
                activate = function(direction) ns.db.portraitRingOffset.x = math.max(-50, math.min(50, (tonumber(ns.db.portraitRingOffset.x) or 0) + direction)); if ns.RefreshPortraitGeometry then ns.RefreshPortraitGeometry() end end },
            { label = "Portrait offset Y", get = function() return string.format("%+.0f", tonumber(ns.db.portraitRingOffset and ns.db.portraitRingOffset.y) or 0) end,
                activate = function(direction) ns.db.portraitRingOffset.y = math.max(-50, math.min(50, (tonumber(ns.db.portraitRingOffset.y) or 0) + direction)); if ns.RefreshPortraitGeometry then ns.RefreshPortraitGeometry() end end },
            { label = "Print performance report", get = function() return "A to print" end,
                activate = function() if ns.PrintPerformanceDiagnostics then ns.PrintPerformanceDiagnostics() end end },
            { label = "Reset performance data", get = function() return "A to reset" end,
                activate = function() if ns.ResetPerformanceDiagnostics then ns.ResetPerformanceDiagnostics() end end },
            { label = "Clear trainer cache", get = function() return "A to clear" end,
                activate = function() if ns.ClearScannedTrainerData then ns.ClearScannedTrainerData() end end },
            { label = "Reset all options", get = function() return "A to reset" end,
                activate = function() if ns.ResetOptionsToDefaults then ns.ResetOptionsToDefaults() end end },
        }
    end
    return {}
end

local function ClearBindings()
    local combat = type(InCombatLockdown) == "function" and InCombatLockdown()
    if bindingOwner and type(ClearOverrideBindings) == "function" and not combat then pcall(ClearOverrideBindings, bindingOwner) end
end

function ns.IsControllerOptionsShown()
    return window and window:IsShown() or false
end

local function Close()
    ClearBindings()
    SetControllerPreviewStrata(false)
    if window then window:Hide() end
    if ns.RefreshPreviewSuspension then ns.RefreshPreviewSuspension() end
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
    local horizontalWrap = tileH and "REPEAT" or "CLAMP"
    local verticalWrap = tileV and "REPEAT" or "CLAMP"
    local ok = pcall(texture.SetTexture, texture, path, horizontalWrap, verticalWrap)
    if not ok then ok = pcall(texture.SetTexture, texture, path) end
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
    local theme = ns.GetSelectedCompositeTheme and ns.GetSelectedCompositeTheme()
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

local function Render()
    if not window then return end
    PlaceControllerBelowPreview()
    if refreshCloseButton then refreshCloseButton() end
    RefreshPortraitPreview()
    PlacePortraitPreviewBelowPopup()
    SkinControllerWindow()
    local def = TAB_DEFS[tabIndex]
    window.entries = EntriesFor(def.key)
    local entryCount = #window.entries
    selected = math.min(selected, math.max(1, entryCount))
    if selected <= rowOffset then
        rowOffset = selected - 1
    elseif selected > rowOffset + VISIBLE_ROWS then
        rowOffset = selected - VISIBLE_ROWS
    end
    rowOffset = math.max(0, math.min(rowOffset, math.max(0, entryCount - VISIBLE_ROWS)))
    for i, tab in ipairs(tabs) do
        local tabLabel = ns.L and ns.L(TAB_DEFS[i].label) or TAB_DEFS[i].label
        tab.text:SetText((i == tabIndex and "[ " or "") .. tabLabel .. (i == tabIndex and " ]" or ""))
        tab.text:SetTextColor(i == tabIndex and 1 or 0.65, i == tabIndex and 0.82 or 0.65, i == tabIndex and 0.15 or 0.65)
        tab.background:SetColorTexture(0.45, 0.32, 0.12, i == tabIndex and 0.38 or 0.10)
    end
    for i, row in ipairs(rows) do
        local entryIndex = rowOffset + i
        local entry = window.entries[entryIndex]
        row:SetShown(entry ~= nil)
        if entry then
            row.text:SetText((entryIndex == selected and "> " or "  ") .. (ns.L and ns.L(entry.label) or entry.label))
            local value = entry.get and tostring(entry.get()) or ""
            row.value:SetText(ns.L and ns.L(value) or value)
            row.text:SetTextColor(entryIndex == selected and 1 or 0.75, entryIndex == selected and 0.82 or 0.75, entryIndex == selected and 0.15 or 0.75)
            row.value:SetTextColor(entryIndex == selected and 1 or 0.75, entryIndex == selected and 0.82 or 0.75, entryIndex == selected and 0.15 or 0.75)
            row.background:SetColorTexture(0.45, 0.32, 0.12, entryIndex == selected and 0.42 or 0.08)
            if entry.isAvailable and not entry.isAvailable() then
                row.text:SetTextColor(0.45, 0.45, 0.45)
                row.value:SetTextColor(0.45, 0.45, 0.45)
            end
        end
    end
end

local function Move(direction)
    local count = #window.entries
    selected = ((selected - 1 + direction) % count) + 1
    Render()
end

local function ChangeTab(direction)
    tabIndex = ((tabIndex - 1 + direction) % #TAB_DEFS) + 1
    selected = 1
    rowOffset = 0
    Render()
end

local function Activate()
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

local function Build()
    if window then return end
    bindingOwner = CreateFrame("Frame", "GnomeLevelUpControllerOptionsBindings", UIParent)
    bindingOwner:Hide()
    window = CreateFrame("Frame", "GnomeLevelUpControllerOptions", UIParent, "BackdropTemplate")
    window:SetSize(760, 620)
    window:SetPoint("CENTER")
    window:SetFrameStrata("HIGH")
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
    title:SetText(ns.L and ns.L("GnomeLevelUp - Controller Options") or "GnomeLevelUp - Controller Options")
    for i, def in ipairs(TAB_DEFS) do
        local tab = CreateFrame("Button", nil, window)
        local tabNumber = i
        tab:SetSize(98, 28)
        tab:SetPoint("TOPLEFT", 18 + (i - 1) * 103, -43)
        tab.background = tab:CreateTexture(nil, "BACKGROUND")
        tab.background:SetAllPoints()
        tab.text = tab:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        tab.text:SetPoint("CENTER")
        tab.text:SetText(def.label)
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
        row:SetPoint("TOPLEFT", 24, -84 - (i - 1) * ROW_SPACING)
        row.background = row:CreateTexture(nil, "BACKGROUND")
        row.background:SetAllPoints()
        row:SetScript("OnEnter", function()
            local entryIndex = rowOffset + rowNumber
            if window.entries and window.entries[entryIndex] then selected = entryIndex; Render() end
        end)
        row:SetScript("OnClick", function()
            local entryIndex = rowOffset + rowNumber
            if window.entries and window.entries[entryIndex] then selected = entryIndex; Activate() end
        end)
        row.text = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        row.text:SetPoint("LEFT")
        row.value = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        row.value:SetPoint("RIGHT")
        rows[i] = row
    end
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
    availability:SetText(ns.L and ns.L("Some options are not available in the controller menu.")
        or "Some options are not available in the controller menu.")
    availability:SetTextColor(0.75, 0.75, 0.75)
    window:SetScript("OnShow", function()
        if ns.RefreshPreviewSuspension then ns.RefreshPreviewSuspension() end
    end)
    window:SetScript("OnHide", Close)
    window:SetScript("OnUpdate", function(_, elapsed)
        if not IsActive() then
            Close()
            return
        end
        SetControllerPreviewStrata(true)
        if refreshCloseButton then refreshCloseButton() end
        if window.controllerHint and window.controllerHintStyle ~= ControllerGlyphChoice() then
            RefreshControllerHints(window.controllerHint.items)
            window.controllerHintStyle = ControllerGlyphChoice()
        end
    end)
end

function ns.ToggleControllerOptions(force)
    if not IsActive() or (type(InCombatLockdown) == "function" and InCombatLockdown()) then
        if window then Close() end
        return false
    end
    Build()
    if force == false then Close() return false end
    if window:IsShown() and force ~= true then Close() return false end
    bindingOwner:Show()
    SetControllerPreviewStrata(true)
    ClearBindings()
    -- Forever uses PADD* for the D-pad and PAD*SHOULDER for bumpers.
    Bind("PADDUP", function() Move(-1) end)
    Bind("PADDDOWN", function() Move(1) end)
    Bind("PADDLEFT", function() Adjust(-1) end)
    Bind("PADDRIGHT", function() Adjust(1) end)
    Bind("PADLSHOULDER", function() ChangeTab(-1) end)
    Bind("PADRSHOULDER", function() ChangeTab(1) end)
    Bind("PAD1", Activate)
    Bind("PAD2", Close)
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
    local panel = _G.SettingsPanel or _G.InterfaceOptionsFrame
    if panel and panel:IsShown() then
        if type(HideUIPanel) == "function" then pcall(HideUIPanel, panel) else panel:Hide() end
        if C_Timer and C_Timer.After then C_Timer.After(0.15, open) else open() end
    else
        open()
    end
    return true
end
