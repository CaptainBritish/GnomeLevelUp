local ADDON_NAME, ns = ...

-- Sharing has its own name field so unfinished edits in Options cannot change
-- the name used by an import.
local transferWindow, profileNameInput, profileTextInput, statusText, selectedProfileText

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
    profileNameInput:ClearFocus()
    profileTextInput:ClearFocus()
end

local function UpdateSelectedProfile()
    selectedProfileText:SetText(ns.L("Profile") .. ": " .. ns.GetActiveProfileName())
end

local function CreateProfileTextArea()
    local scroll = CreateFrame("ScrollFrame", nil, transferWindow, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", 24, -142)
    scroll:SetPoint("BOTTOMRIGHT", -46, 100)
    profileTextInput = CreateFrame("EditBox", "GnomeLevelUpProfileTransferText", scroll)
    profileTextInput:SetMultiLine(true)
    profileTextInput:SetAutoFocus(false)
    profileTextInput:SetMaxLetters(65536)
    profileTextInput:SetFontObject(ChatFontNormal)
    profileTextInput:SetWidth(560)
    profileTextInput:SetHeight(210)
    profileTextInput:SetTextInsets(4, 4, 4, 4)
    profileTextInput:SetScript("OnEscapePressed", function() transferWindow:Hide() end)
    profileTextInput:SetScript("OnTextChanged", function() scroll:UpdateScrollChildRect() end)
    profileTextInput:SetScript("OnCursorChanged", function(_, _, y, _, height)
        local offset, top = scroll:GetVerticalScroll(), -y
        if top < offset then
            scroll:SetVerticalScroll(math.max(0, top))
        elseif top + height > offset + scroll:GetHeight() then
            scroll:SetVerticalScroll(math.max(0, top + height - scroll:GetHeight()))
        end
    end)
    scroll:SetScrollChild(profileTextInput)
    local backing = scroll:CreateTexture(nil, "BACKGROUND")
    backing:SetAllPoints()
    backing:SetColorTexture(0, 0, 0, 0.45)

    return scroll
end

local function BuildWindow()
    transferWindow = CreateFrame("Frame", "GnomeLevelUpProfileTransfer", UIParent, "BackdropTemplate")
    transferWindow:Hide()
    transferWindow:SetSize(640, 460)
    transferWindow:SetPoint("CENTER")
    transferWindow:SetFrameStrata("FULLSCREEN_DIALOG")
    transferWindow:SetClampedToScreen(true)
    transferWindow:SetMovable(true)
    transferWindow:EnableMouse(true)
    transferWindow:RegisterForDrag("LeftButton")
    transferWindow:SetScript("OnDragStart", transferWindow.StartMoving)
    transferWindow:SetScript("OnDragStop", transferWindow.StopMovingOrSizing)
    transferWindow:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 24,
        insets = { left = 8, right = 8, top = 8, bottom = 8 },
    })
    local close = CreateFrame("Button", nil, transferWindow, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", -2, -2)
    close:SetScript("OnClick", function() transferWindow:Hide() end)
    local specialFrames = _G["UISpecialFrames"]
    if type(specialFrames) == "table" then specialFrames[#specialFrames + 1] = "GnomeLevelUpProfileTransfer" end

    local title = transferWindow:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 22, -20)
    title:SetText(ns.L("Import / export"))
    selectedProfileText = transferWindow:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    selectedProfileText:SetPoint("TOPLEFT", 22, -50)
    selectedProfileText:SetSize(590, 36)
    selectedProfileText:SetJustifyH("LEFT")
    selectedProfileText:SetWordWrap(true)
    local label = transferWindow:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    label:SetPoint("TOPLEFT", 22, -91)
    label:SetSize(255, 36)
    label:SetJustifyH("LEFT")
    label:SetWordWrap(true)
    label:SetText(ns.L("Profile name (optional)"))
    profileNameInput = CreateFrame("EditBox", "GnomeLevelUpProfileTransferName", transferWindow, "InputBoxTemplate")
    profileNameInput:SetSize(310, 24)
    profileNameInput:SetPoint("TOPLEFT", 292, -90)
    profileNameInput:SetAutoFocus(false)
    profileNameInput:SetMaxLetters(80)
    profileNameInput:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)
    profileNameInput:SetScript("OnEscapePressed", function() transferWindow:Hide() end)

    local scroll = CreateProfileTextArea()

    local import = CreateFrame("Button", "GnomeLevelUpProfileTransferImport", transferWindow, "UIPanelButtonTemplate")
    import:SetSize(270, 32)
    import:SetPoint("BOTTOMLEFT", 24, 60)
    import:SetText(ns.L("Import profile"))
    import:SetScript("OnClick", function()
        local ok, reason = ns.ImportProfile(profileTextInput:GetText(), profileNameInput:GetText())
        local message = ns.L(ok and "Profile imported." or reason)
        if not ok and reason == "Invalid profile string." then
            message = message .. " " .. ns.L("Paste the complete GLU profile export, then try again.")
        elseif not ok and reason == "Invalid profile settings." then
            message = message .. " " .. ns.L("Export the profile again from an up-to-date GLU installation.")
        end
        statusText:SetText(message)
        if ok then
            profileTextInput:SetText("")
            profileNameInput:SetText("")
            ClearFocus()
            scroll:SetVerticalScroll(0)
            UpdateSelectedProfile()
        end
    end)
    local export = CreateFrame("Button", "GnomeLevelUpProfileTransferExport", transferWindow, "UIPanelButtonTemplate")
    export:SetSize(270, 32)
    export:SetPoint("BOTTOMRIGHT", -24, 60)
    export:SetText(ns.L("Export profile"))
    export:SetScript("OnClick", function()
        profileNameInput:SetText("")
        profileNameInput:ClearFocus()
        profileTextInput:SetText(ns.ExportProfile())
        scroll:SetVerticalScroll(0)
        profileTextInput:SetFocus()
        profileTextInput:HighlightText()
        statusText:SetText(ns.L("Press Ctrl+C to copy."))
        UpdateSelectedProfile()
    end)
    statusText = transferWindow:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    statusText:SetPoint("BOTTOMLEFT", 24, 16)
    statusText:SetSize(590, 36)
    statusText:SetWordWrap(true)
    statusText:SetJustifyH("LEFT")
    statusText:SetText("")
    transferWindow:SetScript("OnHide", ClearFocus)
end

function ns.OpenProfileTransfer()
    ns.EnsureDatabase()
    if not transferWindow then BuildWindow() end
    UpdateSelectedProfile()
    statusText:SetText("")
    transferWindow:Show()
    profileTextInput:SetFocus()
end
