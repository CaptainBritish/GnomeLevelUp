local ADDON_NAME, ns = ...

-- Width comes first: measuring text before assigning its column width gives a
-- single-line height and lets long translations collide with the next row.
function ns.WrapOptionsText(text, width, alignment)
    text:SetWidth(math.max(1, width))
    text:SetWordWrap(true)
    if text.SetNonSpaceWrap then text:SetNonSpaceWrap(true) end
    text:SetJustifyH(alignment or "LEFT")
    text:SetJustifyV("TOP")
    text:SetHeight(0)
    local height = math.max(14, math.ceil(text:GetStringHeight() or 0))
    text:SetHeight(height)
    return height
end

function ns.CreateOptionsLayout(parent)
    local layout = { parent = parent, rows = {}, ready = false }

    function layout:Replace(widgets, cell)
        for _, widget in ipairs(widgets) do
            if widget.gluOptionsCell then widget.gluOptionsCell.skip = true end
        end
        cell.widgets = widgets
        local row = self.rows[cell.y]
        if not row then row = {}; self.rows[cell.y] = row end
        row[#row + 1] = cell
        for _, widget in ipairs(widgets) do widget.gluOptionsCell = cell end
        return cell
    end

    local function Place(widget, x, top)
        widget:ClearAllPoints()
        widget:SetPoint("TOPLEFT", parent, "TOPLEFT", x, -top)
    end

    local function ButtonHeight(button, width)
        button:SetWidth(width)
        local text = button:GetFontString()
        local height = text and ns.WrapOptionsText(text, width - 20) or 14
        if text then
            text:ClearAllPoints()
            text:SetPoint("TOPLEFT", button, "TOPLEFT", 10, -5)
        end
        height = math.max(24, height + 10)
        button:SetHeight(height)
        return height
    end

    local function LayoutCell(cell, x, top, width)
        local label, control = cell.label, cell.control
        local kind = cell.kind
        if kind == "header" then
            local height = ns.WrapOptionsText(label, width - 12) + 12
            control:SetSize(width, height)
            Place(control, x, top)
            label:ClearAllPoints()
            label:SetPoint("TOPLEFT", control, "TOPLEFT", 4, -6)
            return height
        elseif kind == "text" then
            local height = ns.WrapOptionsText(label, width)
            Place(label, x, top)
            return height
        elseif kind == "button" then
            local height = ButtonHeight(control, math.min(width, cell.preferredWidth or width))
            Place(control, x, top)
            return height
        elseif kind == "checkbox" then
            local height = math.max(26, ns.WrapOptionsText(label, width - 34) + 6)
            Place(control, x, top)
            Place(label, x + 30, top + 4)
            return height
        elseif kind == "color" then
            local height = math.max(24, ns.WrapOptionsText(label, width - 54))
            Place(label, x, top)
            Place(control, x + width - 40, top)
            return height
        elseif kind == "dropdown" then
            local labelHeight = ns.WrapOptionsText(label, width)
            Place(label, x, top)
            local dropdownWidth = math.max(40, math.min(cell.preferredWidth or 180, width - 32))
            UIDropDownMenu_SetWidth(control, dropdownWidth)
            local name = control:GetName()
            local text = control.Text or (name and _G[name .. "Text"])
            local textHeight = text and ns.WrapOptionsText(text, dropdownWidth - 32) or 14
            local height = math.max(32, textHeight + 18)
            control:SetHeight(height)
            if text then
                text:ClearAllPoints()
                text:SetPoint("TOPLEFT", control, "TOPLEFT", 20, -(height - textHeight) / 2)
            end
            -- The native border is drawn inside a 64px texture with transparent
            -- margins, anchored 17px ABOVE the 32px frame. Giving that texture
            -- the frame's height compresses it into a strip over the label.
            -- Scale its height and offset together when the caption wraps.
            local scale = height / 32
            local left = control.Left or (name and _G[name .. "Left"])
            if left then
                left:ClearAllPoints()
                left:SetPoint("TOPLEFT", control, "TOPLEFT", 0, 17 * scale)
            end
            for _, suffix in ipairs({ "Left", "Middle", "Right" }) do
                local part = control[suffix] or (name and _G[name .. suffix])
                if part then part:SetHeight(64 * scale) end
            end
            local button = control.Button or (name and _G[name .. "Button"])
            if button then
                button:ClearAllPoints()
                button:SetPoint("TOPRIGHT", control, "TOPRIGHT", -16, -(height - 24) / 2)
                button:SetSize(24, 24)
            end
            Place(control, x - 16, top + labelHeight + 6)
            return labelHeight + 6 + height + 4
        elseif kind == "stepper" then
            local labelWidth = math.min(label:GetStringWidth(), math.max(24, width - 122))
            local labelHeight = ns.WrapOptionsText(label, labelWidth)
            -- Numeric values are single-line controls, not wrapping labels.
            cell.value:SetWordWrap(false)
            if cell.value.SetNonSpaceWrap then cell.value:SetNonSpaceWrap(false) end
            cell.value:SetSize(56, 24)
            cell.value:SetJustifyH("CENTER")
            cell.value:SetJustifyV("MIDDLE")
            local height = math.max(labelHeight, 24)
            local controlX = x + labelWidth + 10
            Place(label, x, top + (height - labelHeight) / 2)
            for _, button in ipairs({ cell.minus, cell.plus }) do
                button:SetSize(24, 24)
                local caption = button:GetFontString()
                caption:ClearAllPoints()
                caption:SetWordWrap(false)
                caption:SetSize(24, 24)
                caption:SetPoint("CENTER", button, "CENTER", 0, 0)
                caption:SetJustifyH("CENTER")
                caption:SetJustifyV("MIDDLE")
            end
            Place(cell.minus, controlX, top + (height - 24) / 2)
            Place(cell.plus, controlX + 88, top + (height - 24) / 2)
            cell.value:ClearAllPoints()
            cell.value:SetPoint("CENTER", parent, "TOPLEFT", controlX + 56, -(top + height / 2))
            return height
        elseif kind == "buttons" then
            local labelHeight = ns.WrapOptionsText(label, width)
            Place(label, x, top)
            local buttonWidth = (width - (#cell.buttons - 1) * 6) / #cell.buttons
            local height = 24
            for i, button in ipairs(cell.buttons) do
                height = math.max(height, ButtonHeight(button, buttonWidth))
                Place(button, x + (i - 1) * (buttonWidth + 6), top + labelHeight + 6)
            end
            return labelHeight + 6 + height
        elseif kind == "slider" then
            local labelHeight = ns.WrapOptionsText(label, width)
            Place(label, x, top)
            local sliderWidth = math.max(40, (width - 72) * 0.25)
            control:SetWidth(sliderWidth)
            Place(control, x + 8, top + labelHeight + 12)
            local valueHeight = ns.WrapOptionsText(cell.value, 52)
            Place(cell.value, x + 8 + sliderWidth + 12, top + labelHeight + 10)
            return labelHeight + 12 + math.max(26, valueHeight)
        elseif kind == "edit" then
            local labelHeight = ns.WrapOptionsText(label, width)
            Place(label, x, top)
            local fieldWidth = math.max(40, width - 12)
            control:SetWidth(cell.widthFraction and math.max(40, fieldWidth * cell.widthFraction) or fieldWidth)
            Place(control, x + 6, top + labelHeight + 8)
            return labelHeight + 8 + control:GetHeight()
        end
        Place(control, x, top)
        return control:GetHeight() or 24
    end

    function layout:Reflow()
        if not self.ready or self.running or self.defer then return end
        self.running = true
        local width = math.max(160, parent:GetWidth() or 560) - 32
        local order = {}
        for originalY in pairs(self.rows) do order[#order + 1] = originalY end
        table.sort(order, function(a, b) return a > b end)
        local top = self.topPadding and self.topPadding(width) or 84
        local debugEnabled = not ns.IsDebugEnabled or ns.IsDebugEnabled()
        for _, originalY in ipairs(order) do
            local cells = {}
            for _, cell in ipairs(self.rows[originalY]) do
                if not cell.skip then
                    local shown = (cell.kind == "header" or not (cell.section and cell.section.collapsed))
                        and (not cell.debugOnly or debugEnabled)
                    for _, widget in ipairs(cell.widgets) do widget:SetShown(shown) end
                    if shown then cells[#cells + 1] = cell end
                end
            end
            table.sort(cells, function(a, b) return a.x < b.x end)
            if #cells > 0 then
                local columns = math.min(#cells, math.max(1, math.floor((width + 16) / 256)))
                if cells[1].columns then
                    columns = math.min(cells[1].columns, math.max(1, math.floor((width + 16) / 160)))
                end
                if #cells == 3 and cells[1].kind == "checkbox" and cells[2].kind == "checkbox"
                    and cells[3].kind == "checkbox" and width >= 482 then columns = 3 end
                local cellWidth = (width - (columns - 1) * 16) / columns
                local allButtons, buttonWidth = true, 0
                for _, cell in ipairs(cells) do
                    allButtons = allButtons and cell.kind == "button"
                    buttonWidth = math.max(buttonWidth, cell.preferredWidth or 0)
                end
                if allButtons and buttonWidth > 0 then cellWidth = math.min(cellWidth, buttonWidth) end
                for first = 1, #cells, columns do
                    local height = 0
                    for column = 0, columns - 1 do
                        local cell = cells[first + column]
                        if cell then
                            local slot = cell.column and columns == cell.columns and (cell.column - 1) or column
                            height = math.max(height, LayoutCell(cell, 16 + slot * (cellWidth + 16), top, cellWidth))
                        end
                    end
                    top = top + height + 10
                end
            end
        end
        parent:SetHeight(math.max(260, top + 16))
        if self.onReflow then self.onReflow() end
        self.running = false
    end
    return layout
end
