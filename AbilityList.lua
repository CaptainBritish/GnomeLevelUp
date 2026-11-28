local ADDON_NAME, ns = ...

-- The popup supplies sizing and animation hooks; this module owns list layout,
-- input routing and restoration of the scroll position after a rebuild.
function ns.InstallAbilityList(render, content, frame, style)
    local GRID = { columns = 3, rows = 3, denseRows = 4, denseThreshold = 6 }
    local function PreferredRows(count, singleColumn)
        if count == 2 and not singleColumn then return 2 end
        return not singleColumn and count > GRID.denseThreshold and GRID.denseRows or GRID.rows
    end
    local function TotalGridRows(count, rows, columns)
        return math.min(count, rows) + math.ceil(math.max(0, count - rows * columns) / columns)
    end
    local function GridPosition(index, rows, columns)
        local zero = index - 1
        if zero < rows * columns then return math.floor(zero / rows), zero % rows end
        local overflow = zero - rows * columns
        return overflow % columns, rows + math.floor(overflow / columns)
    end
    function render.AbilityScrollRange(viewport)
        if viewport.scrollController then return content.abilityViewport.sharedMaximum or 0 end
        return viewport.scrollMaximum or 0
    end

    function render.ScrollAbilities(viewport, steps)
        if frame.closingInputSuppressed or ns.db and ns.db.clickThrough then return end
        local maximum = render.AbilityScrollRange(viewport)
        if maximum <= 0 then return end
        local slider = viewport.scrollController or viewport.slider
        local value = slider:GetValue() + steps * (viewport.scrollStep or 40)
        slider:SetValue(math.max(0, math.min(maximum, value)))
        -- Apply the native offset even if SetValue did not emit OnValueChanged.
        slider:GetScript("OnValueChanged")(slider, slider:GetValue())
    end

    function render.CreateAbilityViewport()
        local viewport = CreateFrame("ScrollFrame", nil, content)
        viewport:SetWidth(style.GetTextWidth())
        if viewport.SetClipsChildren then viewport:SetClipsChildren(true) end

        local track = viewport:CreateTexture(nil, "BACKGROUND")
        track:SetColorTexture(1, 1, 1, 0.15)
        track:SetPoint("BOTTOMLEFT", viewport, "BOTTOMLEFT", 0, 0)
        track:SetPoint("BOTTOMRIGHT", viewport, "BOTTOMRIGHT", 0, 0)
        track:SetHeight(2)
        viewport.scrollTrack = track

        local slider = CreateFrame("Slider", nil, viewport)
        slider:EnableMouse(true)
        slider:SetHitRectInsets(-style.metrics.scrollbarHitInsetX, -style.metrics.scrollbarHitInsetX,
            -style.metrics.abilityScrollbarHitInsetY, -style.metrics.abilityScrollbarHitInsetY)
        slider:SetFrameLevel(content:GetFrameLevel() + 12)
        slider:SetOrientation("HORIZONTAL")
        slider:SetPoint("BOTTOMLEFT", viewport, "BOTTOMLEFT", 0, 0)
        slider:SetPoint("BOTTOMRIGHT", viewport, "BOTTOMRIGHT", 0, 0)
        slider:SetHeight(style.metrics.scrollbarThickness)
        slider:SetMinMaxValues(0, 0)
        slider:SetValue(0)
        slider:SetValueStep(1)
        slider:SetThumbTexture("Interface\\Buttons\\WHITE8X8")
        local thumb = slider.GetThumbTexture and slider:GetThumbTexture()
        if thumb then thumb:SetVertexColor(1, 1, 1, 0.8) end
        slider:SetScript("OnValueChanged", function(self, value)
            -- Native range changes can emit temporary values while a list is
            -- rebuilt. Only settled input updates the position we restore later.
            if viewport.restoringScroll then return end
            viewport.requestedScroll = value or 0
            if viewport.verticalLayout then
                if viewport.sharedScroll then
                    for _, target in ipairs({content.abilityViewport, content.petAbilityViewport}) do
                        local offset = math.min(value or 0, target.scrollMaximum or 0)
                        if target ~= viewport then target.requestedScroll = offset end
                        target:SetVerticalScroll(offset)
                        if render.RefreshAbilityVisibility then render.RefreshAbilityVisibility(target, offset) end
                    end
                else
                    viewport:SetVerticalScroll(value or 0)
                    if render.RefreshAbilityVisibility then render.RefreshAbilityVisibility(viewport, value or 0) end
                end
            else
                viewport:SetHorizontalScroll(value or 0)
                if render.RefreshAbilityVisibility then render.RefreshAbilityVisibility(viewport, value or 0) end
            end
            if ns.WakeAbilityEffects then ns.WakeAbilityEffects() end
        end)
        slider:SetObeyStepOnDrag(false)
        viewport:EnableMouseWheel(true)
        local function ScrollWithWheel(_, delta)
            render.ScrollAbilities(viewport, -delta)
        end
        viewport:SetScript("OnMouseWheel", ScrollWithWheel)
        slider:EnableMouseWheel(true)
        slider:SetScript("OnMouseWheel", ScrollWithWheel)
        slider:Hide()
        viewport.slider = slider
        viewport.scrollTrack:Hide()

        local row = CreateFrame("Frame", nil, viewport)
        row:SetSize(style.GetTextWidth(), style.ABILITY_ICON_SIZE)
        row:SetPoint("TOPLEFT", viewport, "TOPLEFT", 0, 0)
        viewport:SetScrollChild(row)
        viewport.row = row
        row.viewport = viewport
        row:EnableMouseWheel(true)
        row:SetScript("OnMouseWheel", ScrollWithWheel)
        viewport:Hide()
        return viewport, row
    end



    function render.InstallAbilityController()
        if type(frame.EnableGamePadStick) == "function" and type(frame.IsMouseOver) == "function" then
            local target, stickX, stickY
            local function SetTarget(viewport)
                if target == viewport then return end
                if (target == nil) ~= (viewport == nil) then frame:EnableGamePadStick(viewport ~= nil) end
                target, stickX, stickY = viewport, 0, 0
            end
            frame:SetScript("OnGamePadStick", function(_, stick, x, y)
                if stick == "RightStick" or stick == "Right" then stickX, stickY = x, y end
            end)
            frame:HookScript("OnUpdate", function(_, elapsed)
                if frame.closingInputSuppressed or not ns.db or ns.db.clickThrough or not frame:IsMouseOver()
                    or (ns.IsControllerOptionsShown and ns.IsControllerOptionsShown()) then
                    SetTarget(nil)
                    return
                end
                local main, pet = content.abilityViewport, content.petAbilityViewport
                local mainScrolls = main:IsShown() and render.AbilityScrollRange(main) > 0
                local petScrolls = pet:IsShown() and render.AbilityScrollRange(pet) > 0
                local statsScroll = (content.statScrollMaximum or 0) > 0
                if not (mainScrolls or petScrolls or statsScroll) or not frame.gluControllerActive then
                    SetTarget(nil)
                    return
                end
                if statsScroll and (content.statsContainer:IsMouseOver() or not (mainScrolls or petScrolls)) then
                    SetTarget(content.statsContainer)
                elseif petScrolls and (pet:IsMouseOver() or not mainScrolls) then
                    SetTarget(pet)
                else
                    SetTarget(main)
                end
                local axis = (target == content.statsContainer or target.verticalLayout) and -stickY or stickX
                if math.abs(axis) >= .25 then
                    local step = axis * math.min(elapsed, .05) * 8
                    if target == content.statsContainer then render.ScrollStats(target, -step)
                    else render.ScrollAbilities(target, step) end
                end
            end)
            frame:HookScript("OnHide", function() SetTarget(nil) end)
        end
    end


    local function AbilityIconColumns(cellWidth)
        local gap = style.AbilityIconGap()
        local columns = math.max(1, math.floor((style.GetTextWidth() + gap) / (cellWidth + gap)))
        return style.IsCompactLayout() and math.min(style.COMPACT_MAX_SKILLS, columns) or columns
    end



    local function EmptyTrainerSkillsMessage()
        -- An empty unlearned list can also mean everything is already learned.
        -- Check the full class catalog before asking the player to scan a trainer.
        if ns.GetCurrentFlavor() == "forever" then
            local hasClassData = false
            for _, item in ipairs(ns.GetTrainerCatalogIndex()) do
                if type(item.entry) ~= "table" or not item.entry.profession then
                    hasClassData = true
                    break
                end
            end
            if not hasClassData then
                return ns.L("No trainer data for this class.\nVisit your class trainer."), 2
            end
        end
        return ns.L(ns.db and ns.db.showOnlyCurrentLevelSkills
            and "No new skills this level" or "No unlearned skills available")
    end

    local function UpdateAbilityIcons(row, pool, emptyText, abilities, showEmptyText, skipAnimation)
        row.viewport.effectPool = pool
        local newIconSize = style.NewAbilityIconSize()
        local normalIconSize = style.NormalAbilityIconSize()
        local count = #abilities
        row.viewport.abilityCount = count
        local speed = style.Speed()
        local staggerBase = style.BASE_STAT_STAGGER_BASE / speed
        local staggerStep = style.BASE_STAT_STAGGER_STEP / speed
        local popDuration = style.BASE_STAT_SLIDE_DURATION / speed
        local vertical = style.IsHorizontalLayout()
        local singleColumn = vertical and row == content.petAbilityRow
        local gridRows = vertical and PreferredRows(count, singleColumn) or GRID.rows
        row.viewport.minimumRows = GRID.rows
        row.viewport.preferredRows = gridRows
        row.viewport.visibleSlots = gridRows * (singleColumn and 1 or GRID.columns)
        local controller = row.viewport.scrollController or row.viewport.slider
        local previousValue = skipAnimation and row.viewport.verticalLayout == vertical and controller:GetValue() or 0
        row.viewport.requestedScroll = previousValue
        row.viewport.restoringScroll = true
        row.viewport.cellHeight = style.AbilityCellHeight(style.NewAbilityIconSize())
        row.viewport.layoutScale = 1
        row.viewport.sharedScroll, row.viewport.scrollController = nil, nil
        row.viewport.slider:SetParent(row.viewport)
        row.viewport.scrollTrack:SetParent(row.viewport)
        -- Horizontal controls live outside the clipped viewport. Preserve their
        -- reveal alpha when a live layout refresh rebuilds this list.
        local scrollAlpha = vertical and row.viewport:GetAlpha() or 1
        render.Alpha(row.viewport.slider, scrollAlpha)
        render.Alpha(row.viewport.scrollTrack, scrollAlpha)
        row.viewport:SetScale(1)
        row.viewport.verticalLayout = vertical
        row.viewport.scrollMaximum = 0
        row.viewport:SetHorizontalScroll(0)
        row.viewport:SetVerticalScroll(0)

        if count == 0 then
            local emptyWidth = showEmptyText and (style.NewAbilityIconSize() * 3 + style.AbilityIconGap() * 2 + 16) or 120
            row.viewport.horizontalWidth = emptyWidth
            row.viewport:SetWidth(vertical and emptyWidth or style.GetTextWidth())
            row:SetWidth(vertical and emptyWidth or style.GetTextWidth())
            row:SetHeight(style.ABILITY_ICON_SIZE)
            row.viewport:SetHeight(style.ABILITY_ICON_SIZE)
            row.viewport:SetHorizontalScroll(0)
            row.viewport.slider:SetMinMaxValues(0, 0)
            row.viewport.slider:SetValue(0)
            row.viewport.slider:Hide()
            row.viewport.scrollTrack:Hide()
            for _, icon in ipairs(pool) do
                render.StopIconAnimation(icon)
                icon:Hide()
            end
            if emptyText then
                local message, lineCount = EmptyTrainerSkillsMessage()
                emptyText.wrapLineCount = lineCount or 0
                style.ApplyToTextLayers(emptyText, "SetWidth", style.GetTextWidth())
                style.ApplyToTextLayers(emptyText, "SetWordWrap", true)
                style.ApplyToTextLayers(emptyText, "SetJustifyH", "CENTER")
                style.ApplyToTextLayers(emptyText, "SetText", message)
                local emptyHeight = math.max(style.ABILITY_ICON_SIZE, emptyText:GetHeight() or 0, emptyText:GetStringHeight() or 0)
                row:SetHeight(emptyHeight)
                row.viewport:SetHeight(emptyHeight)
                style.ApplyToTextLayers(emptyText, showEmptyText and "Show" or "Hide")
            end
            return
        end

        if emptyText then style.ApplyToTextLayers(emptyText, "Hide") end

        -- Measure the actual selected-font price before laying out the row. Labels
        -- may be wider than the icon; reserve that space instead of truncating or
        -- letting neighboring prices overlap (including compact/scroll layouts).
        local cellWidth = normalIconSize
        local rowIconSize = normalIconSize
        local costRole = row == content.petAbilityRow and "petAbilityCosts" or "abilityCosts"
        local costFontSize = ns.GetPopupAbilityCostSize(costRole)
        local showCosts = style.TrainerCostsVisible()
        local showInlineCosts = style.TrainerCostsVisible(true)
        for i, spell in ipairs(abilities) do
            local icon = render.GetAbilityIcon(i, row, pool)
            local iconSize = spell.isNewAbility == true and newIconSize or normalIconSize
            icon:SetSize(iconSize, iconSize)
            icon.newAbilityGlow:SetSize(iconSize * 1.85, iconSize * 1.85)
            cellWidth = math.max(cellWidth, iconSize)
            rowIconSize = math.max(rowIconSize, iconSize)
            ---@type string|boolean|nil
            local formattedCost = showInlineCosts and render.FormatTrainerCost(spell.cost)
            icon.trainerCost = showCosts and spell.cost or nil
            if formattedCost ~= icon.formattedCost then
                icon.costText:SetText(formattedCost or "")
                icon.formattedCost = formattedCost
            end
            icon.costText:SetShown(formattedCost ~= nil and formattedCost ~= false)
            if formattedCost then
                local fontPath, fontSize, fontFlags = icon.costText:GetFont()
                icon.costFont.size = ns.GetAbilityCostSize()
                icon.costText.gluThemeFontRole = costRole
                if fontSize ~= costFontSize then
                    icon.costText:SetFont(fontPath or style.DEFAULT_FONT_PATH, costFontSize, fontFlags)
                end
                icon.costText:SetHeight(style.AbilityCostHeight())
                icon.costText:SetWidth(0)
                local costWidth = math.ceil(icon.costText:GetStringWidth()) + 2
                icon.costText:SetWidth(costWidth)
                cellWidth = math.max(cellWidth, costWidth)
            end
        end
        local gap = style.AbilityIconGap()
        local viewportWidth = not vertical and style.IsCompactLayout()
            and math.min(style.GetTextWidth(), style.COMPACT_MAX_SKILLS * cellWidth + (style.COMPACT_MAX_SKILLS - 1) * gap)
            or style.GetTextWidth()
        row.viewport:SetWidth(viewportWidth)
        local horizontalGrid = vertical and not singleColumn
        local maxColumns = vertical and (horizontalGrid and GRID.columns or 1) or AbilityIconColumns(cellWidth)
        local shouldScroll = not vertical and style.UseHorizontalAbilityScroll() and count > maxColumns
        local columns = shouldScroll and count or math.min(count, maxColumns)
        local rows = shouldScroll and 1 or math.ceil(count / maxColumns)
        if horizontalGrid then
            columns = GRID.columns
            rows = TotalGridRows(count, gridRows, columns)
        end
        local totalWidth = columns * cellWidth + (columns - 1) * gap
        local cellHeight = style.AbilityCellHeight(rowIconSize)
        local cellGap = vertical and not style.TrainerCostsVisible(true) and gap or 0
        local verticalGap = vertical and 0 or gap
        row.viewport.cellHeight = cellHeight
        row.viewport.rowIconSize = rowIconSize
        row.viewport.baseCellHeight = cellHeight
        row.viewport.baseRowIconSize = rowIconSize
        row.viewport.iconFitScale = 1
        row.viewport.cellWidth = cellWidth
        row.viewport.gridColumns = columns
        row.viewport.cellGap = cellGap
        local totalHeight = rows * cellHeight - cellGap + (rows - 1) * verticalGap
        row.viewport.rowContentHeight = totalHeight
        local viewportHeight = totalHeight
        if vertical then
            -- Keep a fixed viewport height while additional entries scroll vertically.
            local visibleRows = gridRows
            viewportHeight = math.min(totalHeight, visibleRows * cellHeight - cellGap + (visibleRows - 1) * verticalGap)
            shouldScroll = count > row.viewport.visibleSlots and totalHeight > viewportHeight
        end
        if vertical then
            viewportWidth = totalWidth + 16
            if singleColumn then
                local header = content.petSpellsHeader
                local path, _, flags = header:GetFont()
                local size = math.max(1, ns.GetThemeFontSize(header.gluThemeFontRole or "headings", header.gluFontBaseSize) * ns.GetTextScale("headingTextScale"))
                viewportWidth = math.max(viewportWidth, math.ceil(render.MeasureTextWidth(path, size, flags, header:GetText())) + 8)
            end
            row.viewport.horizontalWidth = viewportWidth
            row.viewport:SetWidth(viewportWidth)
        end
        row:SetWidth(vertical and viewportWidth or (shouldScroll and totalWidth or viewportWidth))
        -- Keep the scroll child at the native origin. Put the scrollbar clearance
        -- inside the child so horizontal scrolling cannot change the vertical inset.
        local scrollbarSpace = not vertical and shouldScroll and style.SCROLLBAR_HEIGHT or 0
        row:SetHeight(totalHeight + scrollbarSpace)
        row:ClearAllPoints()
        row:SetPoint("TOPLEFT", row.viewport, "TOPLEFT", 0, 0)
        row.viewport:SetHeight(viewportHeight + scrollbarSpace)
        local slider, track = row.viewport.slider, row.viewport.scrollTrack
        slider:ClearAllPoints()
        track:ClearAllPoints()
        slider:SetOrientation(vertical and "VERTICAL" or "HORIZONTAL")
        slider:SetValueStep(0.01)
        if vertical then
            slider:SetPoint("TOPRIGHT", row.viewport, "TOPRIGHT", -2, 0)
            slider:SetPoint("BOTTOMRIGHT", row.viewport, "BOTTOMRIGHT", -2, 0)
            slider:SetWidth(style.metrics.scrollbarThickness)
            track:SetPoint("TOPRIGHT", row.viewport, "TOPRIGHT", -6, 0)
            track:SetPoint("BOTTOMRIGHT", row.viewport, "BOTTOMRIGHT", -6, 0)
            track:SetWidth(2)
        else
            slider:SetPoint("BOTTOMLEFT", row.viewport, "BOTTOMLEFT", 0, 0)
            slider:SetPoint("BOTTOMRIGHT", row.viewport, "BOTTOMRIGHT", 0, 0)
            slider:SetHeight(style.metrics.scrollbarThickness)
            track:SetPoint("BOTTOMLEFT", row.viewport, "BOTTOMLEFT", 0, 0)
            track:SetPoint("BOTTOMRIGHT", row.viewport, "BOTTOMRIGHT", 0, 0)
            track:SetHeight(2)
        end
        local thumb = slider:GetThumbTexture()
        if thumb then
            if vertical then thumb:SetSize(style.metrics.scrollbarThickness, render.ScrollThumbLength(viewportHeight, totalHeight))
            else thumb:SetSize(math.min(24, viewportWidth * .45), style.metrics.scrollbarThickness) end
        end
        local maximum = shouldScroll and math.max(0, vertical and totalHeight - viewportHeight or totalWidth - viewportWidth) or 0
        row.viewport.scrollMaximum = maximum
        row.viewport.scrollStep = vertical and cellHeight + verticalGap or cellWidth + gap
        row.viewport:UpdateScrollChildRect()
        slider:SetMinMaxValues(0, maximum)
        local value = math.max(0, math.min(maximum, previousValue))
        slider:SetValue(value)
        -- A same-value SetValue need not emit OnValueChanged after a rebuild.
        slider:GetScript("OnValueChanged")(slider, value)
        slider:SetShown(shouldScroll)
        track:SetShown(shouldScroll)
        local startX = -totalWidth / 2 + cellWidth / 2
        local startY = totalHeight / 2 - cellHeight / 2

        for i, spell in ipairs(abilities) do
            local icon = render.GetAbilityIcon(i, row, pool)
            local spellID = spell.id
            local spellName = spell.name
            if icon.previousRankSpellID ~= spell.previousRankSpellID or icon.spellID ~= spellID then
                if render.rankTooltipOwner == icon then render.HideAbilityTooltips(icon) end
            end
            icon.spellID = spellID
            icon.previousRankSpellID = spell.previousRankSpellID
            icon.spellName = spellName
            icon.isNewAbility = spell.isNewAbility
            icon.savedBeastTraining = spell.savedBeastTraining
            icon.beastTrainingKey = spell.beastTrainingKey
            icon.beastTrainingPetGUID = spell.beastTrainingPetGUID
            local formattedCost = icon.formattedCost
            local texture = spell.icon
            if not texture and icon.textureSpellID == spellID then
                texture = icon.texturePath
            elseif not texture then
                local spellTextureFunc = C_Spell and C_Spell.GetSpellTexture
                if not spellTextureFunc then
                    spellTextureFunc = rawget(_G, "GetSpellTexture")
                end
                texture = spellID and spellTextureFunc and spellTextureFunc(spellID)
                icon.textureSpellID = spellID
            else
                icon.textureSpellID = nil
            end
            texture = texture or "Interface\\Icons\\INV_Misc_QuestionMark"
            if texture ~= icon.texturePath then
                icon.icon:SetTexture(texture)
                icon.texturePath = texture
            end

            local zeroIndex = i - 1
            local column = zeroIndex % columns
            local rowIndex = math.floor(zeroIndex / columns)
            if horizontalGrid then column, rowIndex = GridPosition(i, gridRows, columns) end
            icon.layoutRow = rowIndex
            local x = startX + column * (cellWidth + gap)
            if horizontalGrid and count <= GRID.denseThreshold then
                local occupiedColumns = math.ceil(count / gridRows)
                x = x + (columns - occupiedColumns) * (cellWidth + gap) / 2
            end
            if not vertical and not shouldScroll then
                local rowColumns = math.min(columns, count - rowIndex * columns)
                x = -(rowColumns * cellWidth + (rowColumns - 1) * gap) / 2
                    + cellWidth / 2 + column * (cellWidth + gap)
            end
            local iconSize = spell.isNewAbility == true and newIconSize or normalIconSize
            local visibleCellHeight = formattedCost and cellHeight or rowIconSize
            local iconY = startY + (visibleCellHeight - iconSize) / 2
                - rowIndex * (cellHeight + verticalGap)
            if formattedCost and not vertical then iconY = iconY - style.ABILITY_COST_TOP_PADDING end
            local delay = staggerBase + (i - 1) * staggerStep
            icon.skipEntrance = count > row.viewport.visibleSlots and shouldScroll and (vertical
                and rowIndex * (cellHeight + verticalGap) >= viewportHeight
                or not vertical and column * (cellWidth + gap) >= viewportWidth)
            icon.entranceEnd = delay + popDuration
            render.StartIconPop(icon, row, x, iconY, delay, popDuration, skipAnimation or style.IsPortraitPreparing())
        end

        for i = count + 1, #pool do
            render.StopIconAnimation(pool[i])
            pool[i]:Hide()
        end
    end

    -- Fit visible icon groups after the normal frame geometry has been finalized.
    -- must never feed back into column widths, row heights or the popup's scale.
    function render.FitSparseAbilityIcons(viewport, pool)
        local count = viewport.abilityCount or 0
        local vertical = style.IsHorizontalLayout()
        local growGrid = vertical and not style.TrainerCostsVisible(true)
            and render.AbilityScrollRange(viewport) <= 0
        if count < 1 or count > 3 and not growGrid or (viewport.scrollMaximum or 0) > 0 then return end
        local gap = style.AbilityIconGap()
        local width, height = viewport:GetWidth(), viewport:GetHeight()
        local base = style.NewAbilityIconSize()
        local function IconSize(icon, size)
            return icon.isNewAbility == true and size or style.NormalAbilityIconSize() * size / base
        end
        local function GroupPosition(index)
            if not vertical then return index, 1 end
            local column, row = GridPosition(index, viewport.gridRows, viewport.gridColumns)
            return column + 1, row + 1
        end
        local function Measure(size, position)
            local columns, rows = {}, {}
            for i = 1, count do
                local icon = pool[i]
                local iconSize = IconSize(icon, size)
                local column, row = GroupPosition(i)
                local cellWidth = math.max(iconSize, icon.formattedCost and icon.costText:GetWidth() or 0)
                local cellHeight = iconSize + (icon.formattedCost and style.ABILITY_COST_GAP + style.AbilityCostHeight() or 0)
                columns[column] = math.max(columns[column] or 0, cellWidth)
                rows[row] = math.max(rows[row] or 0, cellHeight)
            end
            local groupWidth, groupHeight = gap * (#columns - 1), gap * (#rows - 1)
            for _, value in ipairs(columns) do groupWidth = groupWidth + value end
            for _, value in ipairs(rows) do groupHeight = groupHeight + value end
            if position then
                for i = 1, count do
                    local icon = pool[i]
                    local iconSize = IconSize(icon, size)
                    local column, row = GroupPosition(i)
                    local x, y = -groupWidth / 2 + columns[column] / 2, (vertical and viewport.row:GetHeight() or groupHeight) / 2 - iconSize / 2
                    if vertical and count == 1 then
                        local lift = 18 / math.max(.001, content:GetScale() * viewport:GetScale())
                        y = math.min(lift, math.max(0, (viewport.row:GetHeight() - iconSize) / 2))
                    elseif vertical and count == 2 then
                        y = groupHeight / 2 - iconSize / 2
                    end
                    for j = 1, column - 1 do x = x + columns[j] + gap end
                    for j = 1, row - 1 do y = y - rows[j] - gap end
                    render.Size(icon, iconSize, iconSize)
                    render.Size(icon.newAbilityGlow, iconSize * 1.85, iconSize * 1.85)
                    icon.animationX, icon.animationY = x, y
                    icon:ClearAllPoints()
                    icon:SetPoint("CENTER", viewport.row, "CENTER", x, y - (render.IsAbilityIconAnimating(icon) and style.ABILITY_POP_DISTANCE or 0))
                end
            end
            local centeredCost = vertical and count == 1 and pool[1].formattedCost and style.ABILITY_COST_GAP + style.AbilityCostHeight() or 0
            return groupWidth + (vertical and 16 or 0), groupHeight + centeredCost
        end
        local low, high = base, base * 1.5
        local baseWidth, baseHeight = Measure(base)
        if baseWidth > width or baseHeight > height then low = 0 end
        local capWidth, capHeight = Measure(high)
        if capWidth <= width and capHeight <= height then
            low = high
        else
            for _ = 1, 18 do
                local mid = (low + high) / 2
                local neededWidth, neededHeight = Measure(mid)
                if neededWidth <= width and neededHeight <= height then low = mid else high = mid end
            end
        end
        Measure(math.max(.1, math.floor(low * 100) / 100), true)
    end

    function render.UpdateTrainerAbilityIcons(trainerAbilities, skipAnimation)
        local displayed
        trainerAbilities, displayed = ns.BuildPopupAbilityList(trainerAbilities)
        content.currentTrainerAbilities = trainerAbilities
        if not ns.NewAbilitiesEnabled() then
            UpdateAbilityIcons(content.abilityRow, content.abilityIconPool, nil, {}, false, skipAnimation)
            style.ApplyToTextLayers(content.noAbilitiesText, "Hide")
            render.RefreshAbilityHeader()
            return
        end
        UpdateAbilityIcons(content.abilityRow, content.abilityIconPool, content.noAbilitiesText, displayed, true, skipAnimation)
        if ns.GetCurrentFlavor() == "retail" then
            style.ApplyToTextLayers(content.noAbilitiesText, "Hide")
        end
        render.RefreshAbilityHeader()
    end

    function render.UpdateWarlockPetAbilityIcons(petAbilities, skipAnimation)
        local hideRetailPets = not ns.SupportsTrainerData()
        --@do-not-package@
        -- SSTEST: local screenshot presentation only.
        if content.screenshotPreview and content.screenshotPreview.grimoires then hideRetailPets = false end
        --@end-do-not-package@
        if hideRetailPets then petAbilities = {} end
        content.currentWarlockPetAbilities = petAbilities or {}
        if not ns.NewAbilitiesEnabled() then petAbilities = {} end
        local hasAbilities = type(petAbilities) == "table" and #petAbilities > 0
        if not hasAbilities then
            style.ApplyToTextLayers(content.petSpellsHeader, "Hide")
            content.petAbilityRow:Hide()
            UpdateAbilityIcons(content.petAbilityRow, content.petAbilityIconPool, nil, {}, false, skipAnimation)
            return
        end

        style.ApplyToTextLayers(content.petSpellsHeader, "Show")
        content.petAbilityRow:Show()
        UpdateAbilityIcons(content.petAbilityRow, content.petAbilityIconPool, nil, petAbilities, false, skipAnimation)
    end



    function render.LayoutHorizontalAbilities(naturalHeight, bottomAbilityInset, abilityPadding, topGap, gap, hasPet)
        local main, pet = content.abilityViewport, content.petAbilityViewport
        for _, viewport in ipairs({main, pet}) do
            local count = viewport.abilityCount or 0
            if count > 0 then
                local header = viewport == main and content.spellsHeader or content.petSpellsHeader
                local divider = viewport == main and content.abilitiesDivider or content.petHeaderDivider
                local abilityTop = 24 + render.TextHeight(header, 18) + gap + style.SECTION_DIVIDER_HEIGHT + topGap
                local height = math.max(1, naturalHeight - bottomAbilityInset - abilityPadding - abilityTop)
                viewport:ClearAllPoints()
                viewport:SetPoint("TOP", divider, "BOTTOM", 0, -topGap)
                viewport.abilityPadding = abilityPadding
                local columns = viewport == main and GRID.columns or 1
                if viewport == main and (count > GRID.denseThreshold or count == 2) then
                    local baseHeight, baseIcon = viewport.baseCellHeight, viewport.baseRowIconSize
                    local fittedHeight = math.min(baseHeight, (height + (viewport.cellGap or 0)) / viewport.preferredRows)
                    viewport.rowIconSize = math.max(1, baseIcon - (baseHeight - fittedHeight))
                    viewport.cellHeight = baseHeight - baseIcon + viewport.rowIconSize
                    viewport.iconFitScale = viewport.rowIconSize / baseIcon
                end
                local rows = math.max(1, math.floor((height + (viewport.cellGap or 0)) / viewport.cellHeight))
                if viewport == main then rows = math.min(rows, viewport.preferredRows) end
                viewport.gridRows, viewport.gridColumns = rows, columns
                viewport.visibleSlots = rows * columns
                viewport.scrollStep = viewport.cellHeight
                local totalRows = TotalGridRows(count, rows, columns)
                viewport.rowContentHeight = totalRows * viewport.cellHeight - (viewport.cellGap or 0)
                viewport:SetHeight(height)
                viewport.row:SetHeight(math.max(height, viewport.rowContentHeight))
                viewport.row:ClearAllPoints()
                viewport.row:SetPoint("TOPLEFT", viewport, "TOPLEFT", 0, 0)
                viewport.scrollMaximum = math.max(0, viewport.rowContentHeight - height)
            end
        end
        main.sharedScroll = true
        main.sharedMaximum = math.max(main.scrollMaximum or 0, hasPet and pet.scrollMaximum or 0)
        main.scrollController = main.slider
        pet.scrollController = hasPet and main.slider or nil
        main.slider:SetParent(content)
        main.scrollTrack:SetParent(content)
        main.slider:ClearAllPoints()
        main.scrollTrack:ClearAllPoints()
        local barX = hasPet and 14 or 10
        main.slider:SetOrientation("VERTICAL")
        main.slider:SetWidth(style.metrics.scrollbarThickness)
        main.scrollTrack:SetWidth(2)
        main.slider:SetPoint("TOP", main, "TOPRIGHT", barX, 0)
        main.slider:SetHeight(math.max(main:GetHeight(), hasPet and pet:GetHeight() or 0))
        main.scrollTrack:SetPoint("TOP", main.slider, "TOP", 0, 0)
        main.scrollTrack:SetHeight(main.slider:GetHeight())
        main:UpdateScrollChildRect()
        pet:UpdateScrollChildRect()
        main.slider:SetMinMaxValues(0, main.sharedMaximum)
        local value = math.max(0, math.min(main.sharedMaximum, main.requestedScroll or 0))
        main.slider:SetValue(value)
        main.slider:GetScript("OnValueChanged")(main.slider, value)
        main.slider:SetShown(main.sharedMaximum > 0)
        main.scrollTrack:SetShown(main.sharedMaximum > 0)
        pet.slider:Hide()
        pet.scrollTrack:Hide()
        local thumb = main.slider:GetThumbTexture()
        if thumb then
            local height = main.slider:GetHeight()
            thumb:SetSize(style.metrics.scrollbarThickness, render.ScrollThumbLength(height, height + main.sharedMaximum))
        end
    end


    function render.SetAbilityDividerHeight(height)
        style.SECTION_DIVIDER_HEIGHT = height
    end

    function render.FinishAbilityLayout()
        if style.IsHorizontalLayout() then
            for _, entry in ipairs({
                { content.abilityViewport, content.abilityIconPool },
                { content.petAbilityViewport, content.petAbilityIconPool },
            }) do
                local viewport, pool = entry[1], entry[2]
                if (viewport.abilityCount or 0) > 0 then
                    local occupiedColumns = math.min(viewport.gridColumns, math.ceil(viewport.abilityCount / viewport.gridRows))
                    local width = occupiedColumns * viewport.cellWidth + (occupiedColumns - 1) * style.AbilityIconGap()
                    for i = 1, viewport.abilityCount do
                        local icon = pool[i]
                        local rows, columns = viewport.gridRows, viewport.gridColumns
                        local column, rowIndex = GridPosition(i, rows, columns)
                        icon.layoutRow = rowIndex
                        icon.skipEntrance = rowIndex >= rows
                        if (viewport.iconFitScale or 1) < 1 then
                            local base = icon.isNewAbility == true and style.NewAbilityIconSize() or style.NormalAbilityIconSize()
                            local size = base * viewport.iconFitScale
                            render.Size(icon, size, size)
                            render.Size(icon.newAbilityGlow, size * 1.85, size * 1.85)
                        end
                        local x = -width / 2 + viewport.cellWidth / 2 + column * (viewport.cellWidth + style.AbilityIconGap())
                        -- Align icon bottoms so prices share a baseline in each row.
                        local alignedHeight = style.TrainerCostsVisible(true) and icon:GetHeight() or viewport.rowIconSize
                        local y = viewport.row:GetHeight() / 2 - viewport.rowIconSize
                            + alignedHeight / 2 - icon.layoutRow * viewport.cellHeight
                        icon.animationX = x
                        icon.animationY = y
                        icon:ClearAllPoints()
                        icon:SetPoint("CENTER", viewport.row, "CENTER", x,
                            y - (render.IsAbilityIconAnimating(icon) and style.ABILITY_POP_DISTANCE or 0))
                    end
                end
            end
        end
        render.FitSparseAbilityIcons(content.abilityViewport, content.abilityIconPool)
        render.FitSparseAbilityIcons(content.petAbilityViewport, content.petAbilityIconPool)
        content.abilityViewport:UpdateScrollChildRect()
        content.petAbilityViewport:UpdateScrollChildRect()
        -- Pooled icons change the native scroll rectangle when they move into
        -- their final grid. Restore offsets after layout, without rebuilding that
        -- rectangle on wheel/drag input and moving the thumb under the cursor.
        content.abilityViewport.restoringScroll = false
        content.petAbilityViewport.restoringScroll = false
        for _, viewport in ipairs({content.abilityViewport, content.petAbilityViewport}) do
            if not viewport.scrollController or viewport.scrollController == viewport.slider then
                local slider = viewport.scrollController or viewport.slider
                local value = math.max(0, math.min(render.AbilityScrollRange(viewport), viewport.requestedScroll or 0))
                slider:SetValue(value)
                slider:GetScript("OnValueChanged")(slider, value)
            end
        end
        render.RefreshAbilityVisibility(content.abilityViewport)
        render.RefreshAbilityVisibility(content.petAbilityViewport)
    end
end
