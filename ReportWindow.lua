local ADDON_NAME, ns = ...

function ns.CreateReportWindow(options)
    local window = CreateFrame("Frame", options.name, UIParent, "BackdropTemplate")
    window:SetSize(640, options.height)
    window:SetPoint("CENTER")
    window:SetFrameStrata(options.strata)
    window:SetClampedToScreen(true)
    window:EnableMouse(true)
    window:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 24,
        insets = { left = 8, right = 8, top = 8, bottom = 8 },
    })
    local close = CreateFrame("Button", nil, window, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", -2, -2)
    close:SetScript("OnClick", function() window:Hide() end)
    local title = window:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", options.inset, options.titleY)
    local instructions = window:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    instructions:SetPoint("TOPLEFT", options.inset, -48)
    instructions:SetWidth(options.textWidth)
    instructions:SetWordWrap(true)
    instructions:SetJustifyH("LEFT")
    return window, title, instructions
end

function ns.CreateReportTextBox(window, width, onEscape)
    local scroll = CreateFrame("ScrollFrame", nil, window, "UIPanelScrollFrameTemplate")
    local edit = CreateFrame("EditBox", nil, scroll)
    edit:SetMultiLine(true)
    edit:SetAutoFocus(false)
    edit:SetMaxLetters(0)
    edit:SetFontObject(ChatFontNormal)
    edit:SetWidth(width)
    edit:SetHeight(260)
    edit:SetScript("OnEscapePressed", onEscape)
    edit:SetScript("OnTextChanged", function() scroll:UpdateScrollChildRect() end)
    scroll:SetScrollChild(edit)
    return edit, scroll
end

function ns.InstallReportCopyControls(window, edit, options)
    local armed, pendingText = false, nil
    local controls = {}

    function controls.Reset()
        armed, pendingText = false, nil
        if options.onReset then options.onReset() end
    end

    function controls.SelectText()
        if edit:GetText() == "" then return end
        armed, pendingText = true, nil
        edit:SetFocus()
        edit:HighlightText()
        if options.onSelect then options.onSelect() end
    end

    -- Addons cannot write directly to the clipboard. Leave the text intact
    -- until the edit box has performed its native Ctrl+C/Command+C copy.
    edit:SetScript("OnKeyDown", function(self, key)
        local modifier = (IsControlKeyDown and IsControlKeyDown())
            or (IsMetaKeyDown and IsMetaKeyDown())
        local canCopy = not options.requireButton or armed
        pendingText = canCopy and modifier and key == "C" and self:GetText() ~= "" and self:GetText() or nil
        if pendingText then self:HighlightText() end
    end)
    edit:SetScript("OnKeyUp", function(self, key)
        if key ~= "C" or not pendingText then return end
        if self:GetText() == pendingText then
            if options.onCopied then options.onCopied() end
            self:SetText("")
            self:ClearFocus()
        end
        controls.Reset()
    end)
    edit:SetScript("OnEditFocusLost", controls.Reset)
    window:SetScript("OnHide", function()
        controls.Reset()
        edit:ClearFocus()
    end)
    return controls
end
