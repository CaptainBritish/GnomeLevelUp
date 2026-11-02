local ADDON_NAME, ns = ...

-- Layout helpers receive their dependencies explicitly; width remains live.
function ns.CreatePopupHeadingFitter(context)
    local render, content = context.render, context.content
    local IsHorizontalLayout, TrainingWidth = context.IsHorizontalLayout, context.TrainingWidth
    local ApplyToTextLayers, DEFAULT_FONT_PATH = context.ApplyToTextLayers, context.DEFAULT_FONT_PATH
    local SyncTextGeometry = context.SyncTextGeometry
    return function()
        local TEXT_WIDTH = context.GetTextWidth()
        local scale = ns.GetTextScale("headingTextScale")
        if scale == 1 then return end
        local horizontal = IsHorizontalLayout()
        local specs = {{content.statsHeader, TEXT_WIDTH}}
        if ns.GetCurrentFlavor() ~= "retail" or #(content.currentTrainerAbilities or {}) > 0 then
            specs[#specs + 1] = {content.spellsHeader, horizontal and TrainingWidth(content.abilityViewport) or TEXT_WIDTH}
        end
        if ns.GetCurrentFlavor() ~= "retail" and #(content.currentWarlockPetAbilities or {}) > 0 then
            specs[#specs + 1] = {content.petSpellsHeader, horizontal and TrainingWidth(content.petAbilityViewport) or TEXT_WIDTH}
        end
        local parts = {tostring(scale)}
        for _, spec in ipairs(specs) do
            local path, _, flags = spec[1]:GetFont()
            parts[#parts + 1] = table.concat({path or DEFAULT_FONT_PATH, flags or "", spec[1]:GetText(), tostring(spec[2])}, "\031")
        end
        local key = table.concat(parts, "\030")
        if render.headingFitKey == key then return end
        local fit = 1
        for _, spec in ipairs(specs) do
            local text, width = spec[1], spec[2]
            local path, _, flags = text:GetFont()
            local naturalWidth = render.MeasureTextWidth(path, text.gluFontBaseSize * scale, flags, text:GetText())
            fit = math.min(fit, math.max(1, width - 8) / math.max(1, naturalWidth))
        end
        -- One fit factor keeps all section headings the same size.
        for _, text in ipairs({content.statsHeader, content.spellsHeader, content.petSpellsHeader}) do
            local path, _, flags = text:GetFont()
            ApplyToTextLayers(text, "SetFont", path or DEFAULT_FONT_PATH, math.max(1, text.gluFontBaseSize * scale * fit), flags or "")
            SyncTextGeometry(text)
        end
        render.headingFitKey = key
    end
end

-- Reposition sections without owning the popup's current width or anchors.
function ns.CreatePopupSectionPositioner(context)
    local render, content = context.render, context.content
    local IsHorizontalLayout, TrainingWidth = context.IsHorizontalLayout, context.TrainingWidth
    local ApplyToTextLayers, AnchorBelow = context.ApplyToTextLayers, context.AnchorBelow
    local SectionGap, PortraitColumnWidth = context.SectionGap, context.PortraitColumnWidth
    return function()
        local TEXT_WIDTH = context.GetTextWidth()
        render.FitSectionHeadings()
        local current = content.statsContainer
        local gap = SectionGap()
        content.statsHeader:ClearAllPoints()
        if IsHorizontalLayout() then
            local statsX = 24 + PortraitColumnWidth() + 18 + TEXT_WIDTH / 2
            content.statsHeader:SetPoint("TOP", content, "TOPLEFT", statsX, -24)
        else
            content.statsHeader:SetPoint("TOP", content.levelText, "BOTTOM", 0, -22)
        end
        AnchorBelow(content.statsHeaderDivider, content.statsHeader, gap)
        local topGap = IsHorizontalLayout() and 8 / math.max(.001, content:GetScale()) or gap
        AnchorBelow(content.statsContainer, content.statsHeaderDivider, topGap)
        AnchorBelow(content.statsBottomDivider, current, gap)
        content.statsBottomDivider:SetShown(not IsHorizontalLayout())
        current = IsHorizontalLayout() and content.statsContainer or content.statsBottomDivider

        if content.levelTimeText:IsShown() then
            if IsHorizontalLayout() then
                -- Section refreshes must preserve the footer anchor too.
                content.levelTimeText:ClearAllPoints()
                content.levelTimeText:SetPoint("BOTTOM", content, "BOTTOMLEFT",
                    24 + PortraitColumnWidth() + 18 + TEXT_WIDTH / 2, 26 / math.max(.001, content:GetScale()))
            else
                AnchorBelow(content.levelTimeText, current, gap + 2)
            end
            if IsHorizontalLayout() then
                content.timeBottomDivider:Hide()
                current = content.levelTimeText
            else
                AnchorBelow(content.timeBottomDivider, content.levelTimeText, gap)
                content.timeBottomDivider:Show()
                current = content.timeBottomDivider
            end
        else
            content.levelTimeText:ClearAllPoints()
            content.timeBottomDivider:Hide()
        end

        local showAbilities = ns.GetCurrentFlavor() ~= "retail" or #(content.currentTrainerAbilities or {}) > 0
        ApplyToTextLayers(content.spellsHeader, "SetShown", showAbilities)
        content.abilitiesDivider:SetShown(showAbilities)
        content.abilityViewport:SetShown(showAbilities)
        if showAbilities then
            if IsHorizontalLayout() then
                content.spellsHeader:ClearAllPoints()
                content.spellsHeader:SetPoint("TOP", content, "TOPLEFT", 24 + PortraitColumnWidth() + 36 + TEXT_WIDTH + TrainingWidth(content.abilityViewport) / 2, -24)
            else
                AnchorBelow(content.spellsHeader, current, gap)
            end
            AnchorBelow(content.abilitiesDivider, content.spellsHeader, gap)
            AnchorBelow(content.abilityViewport, content.abilitiesDivider, IsHorizontalLayout() and topGap or render.AbilitySectionPadding())
            current = content.abilityViewport
        end

        if content.petSpellsHeader:IsShown() then
            content.petDivider:Show()
            content.petHeaderDivider:Show()
            if IsHorizontalLayout() then
                content.petDivider:Hide()
                content.petSpellsHeader:ClearAllPoints()
                content.petSpellsHeader:SetPoint("TOP", content, "TOPLEFT", 24 + PortraitColumnWidth() + 36 + TEXT_WIDTH + TrainingWidth(content.abilityViewport) + 28 + TrainingWidth(content.petAbilityViewport) / 2, -24)
            else
                AnchorBelow(content.petDivider, current, gap)
                AnchorBelow(content.petSpellsHeader, content.petDivider, gap)
            end
            AnchorBelow(content.petHeaderDivider, content.petSpellsHeader, gap)
            AnchorBelow(content.petAbilityViewport, content.petHeaderDivider, IsHorizontalLayout() and topGap or render.AbilitySectionPadding())
            content.petAbilityViewport:Show()
            if not IsHorizontalLayout() then current = content.petAbilityViewport end
        else
            content.petDivider:Hide()
            content.petHeaderDivider:Hide()
            content.petAbilityViewport:Hide()
            content.petAbilityViewport:ClearAllPoints()
        end

        if content.weaponSkillsText:IsShown() then
            content.weaponDivider:Show()
            AnchorBelow(content.weaponDivider, current, gap)
            AnchorBelow(content.weaponSkillsText, content.weaponDivider, gap)
        else
            content.weaponDivider:Hide()
            content.weaponSkillsText:ClearAllPoints()
        end
    end
end
