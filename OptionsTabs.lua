local ADDON_NAME, ns = ...

-- Tabs filter the existing measured cells; controls and their saved values are
-- never rebuilt when switching pages. The strip wraps for narrow/localized UI.
function ns.CreateOptionsTabs(panel, chrome, scroll, layout)
    local tabs = { selected = "appearance", scrollPositions = {}, buttons = {} }
    local definitions = {
        {"appearance", "Appearance"}, {"colors", "Colors"}, {"animation", "Animation"},
        {"mode", "Mode"}, {"trainer_data", "Trainer Data"}, {"sound", "Sound"},
        {"profile", "Profile"}, {"cache_status", "Cache Status"}, {"debug", "Debug"},
    }
    panel.gluOptionsTabs = tabs
    layout.filterCell = function(cell)
        if cell.kind == "header" then return false end
        local key = cell.debugOnly and "debug" or cell.section and cell.section.key
        return key == tabs.selected
    end
    function tabs:Select(key)
        if key == "debug" and not ns.IsDebugEnabled() then return false end
        local found = false
        for _, definition in ipairs(definitions) do if definition[1] == key then found = true end end
        if not found then return false end
        local changed = self.selected ~= key
        if changed then
            if scroll then self.scrollPositions[self.selected] = scroll:GetVerticalScroll() end
            -- Hidden edit fields should commit and relinquish keyboard focus.
            for _, row in pairs(layout.rows) do for _, cell in ipairs(row) do
                if not cell.skip then for _, widget in ipairs(cell.widgets) do
                    if widget.HasFocus and widget:HasFocus() and widget.ClearFocus then widget:ClearFocus() end
                end end
            end end
            if GameTooltip then GameTooltip:Hide() end
            if type(CloseDropDownMenus) == "function" then CloseDropDownMenus() end
            self.selected = key
        end
        layout:Reflow()
        if scroll and changed then
            local maximum = math.max(0, layout.parent:GetHeight() - scroll:GetHeight())
            scroll:SetVerticalScroll(math.min(maximum, self.scrollPositions[key] or 0))
        end
        return true
    end
    for _, definition in ipairs(definitions) do
        local key, label = definition[1], definition[2]
        local button = CreateFrame("Button", nil, chrome, "UIPanelButtonTemplate")
        button:EnableMouse(true)
        button:RegisterForClicks("LeftButtonUp")
        button:SetText(ns.L(label));button.gluTabKey = key
        local selected = button:CreateTexture(nil, "OVERLAY")
        selected:SetColorTexture(1, .82, .2, .9)
        selected:SetHeight(2)
        selected:SetPoint("BOTTOMLEFT", button, "BOTTOMLEFT", 5, 2)
        selected:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -5, 2)
        button.gluSelectionLine = selected
        button:SetScript("OnClick", function() tabs:Select(key) end)
        tabs.buttons[#tabs.buttons + 1] = button
    end
    function tabs:Layout(width, top)
        if self.selected == "debug" and not ns.IsDebugEnabled() then self.selected = "mode" end
        local visible = {}
        for index, button in ipairs(self.buttons) do
            local key, label = definitions[index][1], definitions[index][2]
            local shown = key ~= "debug" or ns.IsDebugEnabled()
            button:SetShown(shown)
            if shown then
                if key == "trainer_data" and ns.GetCurrentFlavor() == "retail" then label = "Abilities" end
                button:SetText(ns.L(label));visible[#visible + 1] = button
            end
        end
        local columns = math.max(1, math.floor((width + 6) / 112))
        columns = math.min(columns, #visible)
        local cellWidth = (width - (columns - 1) * 6) / columns
        local cursor = top
        for first = 1, #visible, columns do
            local height = 26
            for column = 0, columns - 1 do
                local button = visible[first + column]
                if button then height = math.max(height, ns.WrapOptionsText(button:GetFontString(), cellWidth - 14, "CENTER") + 10) end
            end
            for column = 0, columns - 1 do
                local button = visible[first + column]
                if button then
                    button:SetSize(cellWidth, height);button:ClearAllPoints()
                    button:SetPoint("TOPLEFT", chrome, "TOPLEFT", 16 + column * (cellWidth + 6), -cursor)
                    button:GetFontString():SetTextColor(button.gluTabKey == self.selected and 1 or .8,
                        button.gluTabKey == self.selected and .82 or .8, button.gluTabKey == self.selected and .2 or .8)
                    button.gluSelectionLine:SetShown(button.gluTabKey == self.selected)
                end
            end
            cursor = cursor + height + 6
        end
        return cursor
    end
    return tabs
end
