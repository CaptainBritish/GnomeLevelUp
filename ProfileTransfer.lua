local ADDON_NAME, ns = ...

-- Build the sharing window only when requested. The text area is independent
-- of the profile-creation field, so a leftover name cannot block an import.
local window, name, text, status, selectedProfile

function ns.RequestDeleteProfile(callback)
    local profile = ns.GetActiveProfileName()
    if profile == "Default" then
        if callback then callback(false, "Default profile cannot be renamed or deleted.") end
        return
    end
    local dialogs, show = _G["StaticPopupDialogs"], _G["StaticPopup_Show"]
    if type(dialogs) ~= "table" or type(show) ~= "function" then return end
    dialogs.GNOMELEVELUP_DELETE_PROFILE = {
        text = "%s", button1 = ns.L("Delete profile"), button2 = _G["CANCEL"] or ns.L("Cancel"),
        timeout = 0, whileDead = true, hideOnEscape = true,
        OnAccept = function(_, data)
            local ok, reason
            if ns.GetProfileID(data.name) == data.id then
                ok, reason = ns.DeleteProfile(data.name)
            else
                ok, reason = false, "Profile not found."
            end
            if data.callback then data.callback(ok, reason) end
        end,
        OnCancel = function(_, data) if data.callback then data.callback(false) end end,
    }
    show("GNOMELEVELUP_DELETE_PROFILE", ns.L("Delete profile \"%s\"?", profile), nil,
        { name = profile, id = ns.GetProfileID(profile), callback = callback })
end

local function ClearFocus()
    name:ClearFocus()
    text:ClearFocus()
end

local function UpdateSelectedProfile()
    selectedProfile:SetText(ns.L("Profile") .. ": " .. ns.GetActiveProfileName())
end

local function BuildWindow()
    window = CreateFrame("Frame", "GnomeLevelUpProfileTransfer", UIParent, "BackdropTemplate")
    window:Hide()
    window:SetSize(640, 460)
    window:SetPoint("CENTER")
    window:SetFrameStrata("FULLSCREEN_DIALOG")
    window:SetClampedToScreen(true)
    window:SetMovable(true)
    window:EnableMouse(true)
    window:RegisterForDrag("LeftButton")
    window:SetScript("OnDragStart", window.StartMoving)
    window:SetScript("OnDragStop", window.StopMovingOrSizing)
    window:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 24,
        insets = { left = 8, right = 8, top = 8, bottom = 8 },
    })
    local close = CreateFrame("Button", nil, window, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", -2, -2)
    close:SetScript("OnClick", function() window:Hide() end)
    local specialFrames = _G["UISpecialFrames"]
    if type(specialFrames) == "table" then specialFrames[#specialFrames + 1] = "GnomeLevelUpProfileTransfer" end

    local title = window:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 22, -20)
    title:SetText(ns.L("Import / export"))
    selectedProfile = window:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    selectedProfile:SetPoint("TOPLEFT", 22, -50)
    selectedProfile:SetSize(590, 36)
    selectedProfile:SetJustifyH("LEFT")
    selectedProfile:SetWordWrap(true)
    local label = window:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    label:SetPoint("TOPLEFT", 22, -91)
    label:SetSize(255, 36)
    label:SetJustifyH("LEFT")
    label:SetWordWrap(true)
    label:SetText(ns.L("Profile name (optional)"))
    name = CreateFrame("EditBox", "GnomeLevelUpProfileTransferName", window, "InputBoxTemplate")
    name:SetSize(310, 24)
    name:SetPoint("TOPLEFT", 292, -90)
    name:SetAutoFocus(false)
    name:SetMaxLetters(80)
    name:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)
    name:SetScript("OnEscapePressed", function() window:Hide() end)

    local scroll = CreateFrame("ScrollFrame", nil, window, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", 24, -142)
    scroll:SetPoint("BOTTOMRIGHT", -46, 100)
    text = CreateFrame("EditBox", "GnomeLevelUpProfileTransferText", scroll)
    text:SetMultiLine(true)
    text:SetAutoFocus(false)
    text:SetMaxLetters(65536)
    text:SetFontObject(ChatFontNormal)
    text:SetWidth(560)
    text:SetHeight(210)
    text:SetTextInsets(4, 4, 4, 4)
    text:SetScript("OnEscapePressed", function() window:Hide() end)
    text:SetScript("OnTextChanged", function() scroll:UpdateScrollChildRect() end)
    text:SetScript("OnCursorChanged", function(_, _, y, _, height)
        local offset, top = scroll:GetVerticalScroll(), -y
        if top < offset then
            scroll:SetVerticalScroll(math.max(0, top))
        elseif top + height > offset + scroll:GetHeight() then
            scroll:SetVerticalScroll(math.max(0, top + height - scroll:GetHeight()))
        end
    end)
    scroll:SetScrollChild(text)
    local backing = scroll:CreateTexture(nil, "BACKGROUND")
    backing:SetAllPoints()
    backing:SetColorTexture(0, 0, 0, 0.45)

    local import = CreateFrame("Button", "GnomeLevelUpProfileTransferImport", window, "UIPanelButtonTemplate")
    import:SetSize(270, 32)
    import:SetPoint("BOTTOMLEFT", 24, 60)
    import:SetText(ns.L("Import profile"))
    import:SetScript("OnClick", function()
        local ok, reason = ns.ImportProfile(text:GetText(), name:GetText())
        status:SetText(ns.L(ok and "Profile imported." or reason))
        if ok then
            text:SetText("")
            name:SetText("")
            ClearFocus()
            scroll:SetVerticalScroll(0)
            UpdateSelectedProfile()
        end
    end)
    local export = CreateFrame("Button", "GnomeLevelUpProfileTransferExport", window, "UIPanelButtonTemplate")
    export:SetSize(270, 32)
    export:SetPoint("BOTTOMRIGHT", -24, 60)
    export:SetText(ns.L("Export profile"))
    export:SetScript("OnClick", function()
        name:SetText("")
        name:ClearFocus()
        text:SetText(ns.ExportProfile())
        scroll:SetVerticalScroll(0)
        text:SetFocus()
        text:HighlightText()
        status:SetText(ns.L("Press Ctrl+C to copy."))
        UpdateSelectedProfile()
    end)
    status = window:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    status:SetPoint("BOTTOMLEFT", 24, 16)
    status:SetSize(590, 36)
    status:SetWordWrap(true)
    status:SetJustifyH("LEFT")
    status:SetText("")
    window:SetScript("OnHide", ClearFocus)
end

function ns.OpenProfileTransfer()
    ns.EnsureDatabase()
    if not window then BuildWindow() end
    UpdateSelectedProfile()
    status:SetText("")
    window:Show()
    text:SetFocus()
end
