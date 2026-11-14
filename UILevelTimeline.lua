local ADDON_NAME, ns = ...

local MAX_SKILLS = 4
local TRACK_Y = -30
local OUTER_SKILL_TRAVEL = .08

local function BuildTimelineSkills(first, reached, last, cap, abilities, sample)
    local byLevel = { [first] = {}, [reached] = {}, [last] = {} }
    local nextUnlockLevel, nextUnlockSkills
    local function Add(level, id, texture, name, cost)
        if not (id or texture) then return end
        local list = byLevel[level]
        if not list and level and last > reached and level > last and (not cap or level <= cap) then
            if not nextUnlockLevel or level < nextUnlockLevel then
                nextUnlockLevel, nextUnlockSkills = level, {}
            end
            if level == nextUnlockLevel then list = nextUnlockSkills end
        end
        if not list or #list >= MAX_SKILLS then return end
        for _, skill in ipairs(list) do
            if id and skill.id == id then return end
        end
        list[#list + 1] = { id = id, texture = texture, name = name, cost = cost }
    end
    for _, ability in ipairs(abilities) do
        Add(sample and reached or ability.requiredLevel, ability.id, ability.icon, ability.name, ability.cost)
    end
    if ns.GetCurrentFlavor() == "retail" then
        for _, ability in ipairs(ns.GetRetailTimelineSpells(first, last > reached and (cap or math.huge) or last)) do
            Add(ability.requiredLevel, ability.id, ability.icon, ability.name)
        end
    else
        local catalogueByLevel = ns.GetTrainerCatalogLookups()
        local function AddCatalogueLevel(level)
            local entries = catalogueByLevel[level]
            if not entries then return end
            for _, item in ipairs(entries) do
                local talent = item.entry.requiredTalentId
                if not talent or ns.IsSpellKnownAcrossClients(talent) then
                    Add(level, item.id, item.icon, item.name, item.cost)
                end
            end
        end
        AddCatalogueLevel(first)
        if reached ~= first then AddCatalogueLevel(reached) end
        if last > reached then
            for level = last, cap or last do
                AddCatalogueLevel(level)
                if (level == last and #byLevel[last] < MAX_SKILLS)
                    or (level > last and (not nextUnlockSkills or #nextUnlockSkills < MAX_SKILLS)) then
                    for _, entry in ipairs(ns.GetBundledTimelineTraining(level)) do
                        Add(level, entry.spellID, entry.icon, entry.name, entry.cost)
                    end
                end
                if #byLevel[last] > 0 or nextUnlockLevel == level then break end
            end
        end
    end
    if #byLevel[last] > 0 then return byLevel end
    return byLevel, nextUnlockLevel, nextUnlockSkills
end

function ns.InstallLevelTimeline(render, popup, modernBottomLine, texturedBottomEdge)
    local timeline, markers, markerDot, spark, barFlash
    local source, startLevel, reachedLevel, endLevel, cap
    local progress, reveal = 0, 0
    local animationFinished = false
    local sparkDuration, barFlashDuration = .60, .38

    local function HideSkillTooltip(icon)
        if GameTooltip and GameTooltip.IsOwned and GameTooltip:IsOwned(icon) then GameTooltip:Hide() end
    end

    local function Create()
        timeline = CreateFrame("Frame", "GnomeLevelUpLevelTimeline", popup)
        timeline:SetHeight(118)
        timeline:SetClipsChildren(true)
        timeline:Hide()
        timeline:SetScript("OnHide", function() render.RefreshTimelineMouse() end)
        markers = {}
        for i = 1, 3 do
            local marker = CreateFrame("Frame", nil, timeline)
            marker:SetHeight(118)
            marker.icons = {}
            marker.label = marker:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            marker.label:SetPoint("TOP", marker, "TOP", 0, TRACK_Y - 8)
            marker.tick = marker:CreateTexture(nil, "ARTWORK")
            marker.tick:SetSize(2, 12)
            marker.tick:SetPoint("CENTER", marker, "TOP", 0, TRACK_Y)
            for j = 1, MAX_SKILLS do
                local icon = CreateFrame("Frame", nil, marker)
                icon.artwork = icon:CreateTexture(nil, "ARTWORK")
                icon.artwork:SetAllPoints(icon)
                icon.artwork:SetTexCoord(.08, .92, .08, .92)
                icon:EnableMouse(false)
                if i == 3 then
                    icon:SetScript("OnEnter", function(self)
                        local skill = self.skill
                        if not GameTooltip or not skill or popup.closingInputSuppressed or ns.db.clickThrough then return end
                        if skill.id and GameTooltip.SetSpellByID then
                            GameTooltip:SetOwner(self, "ANCHOR_TOP")
                            GameTooltip:SetSpellByID(skill.id)
                        elseif skill.name then
                            GameTooltip:SetOwner(self, "ANCHOR_TOP")
                            GameTooltip:SetText(skill.name, 1, 1, 1, 1)
                        else
                            return
                        end
                        if ns.TrainerCostsInTooltips() then
                            local cost = skill.cost
                            if cost == nil and skill.id then
                                -- Older replay snapshots do not include trainer prices.
                                local _, bySpellID = ns.GetTrainerCatalogLookups()
                                local item = bySpellID[skill.id]
                                cost = item and item.cost
                            end
                            local price = render.FormatTrainerCost(cost, 3)
                            if price then GameTooltip:AddLine(ns.L("Learning cost: %s", price), 1, 1, 1) end
                        end
                        GameTooltip:Show()
                    end)
                    icon:SetScript("OnLeave", HideSkillTooltip)
                    icon:SetScript("OnHide", HideSkillTooltip)
                end
                marker.icons[j] = icon
            end
            markers[i] = marker
        end
        markers[3].unlockLabel = markers[3]:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        markers[3].unlockLabel:SetPoint("TOP", markers[3], "TOP", 0, TRACK_Y - 27)
        markerDot = timeline:CreateTexture(nil, "OVERLAY")
        markerDot:SetSize(6, 10)
        barFlash = timeline:CreateTexture(nil, "ARTWORK")
        barFlash:SetTexture("Interface\\AddOns\\GnomeLevelUp\\Textures\\seperator")
        barFlash:SetVertexColor(1, 1, 1)
        barFlash:SetBlendMode("ADD")
        barFlash:Hide()
        spark = timeline:CreateTexture(nil, "OVERLAY", nil, 1)
        spark:SetTexture("Interface\\Cooldown\\star4")
        spark:SetBlendMode("ADD")
        spark:Hide()
    end

    function render.ClearLevelTimeline()
        source, startLevel, reachedLevel, endLevel = nil, nil, nil, nil
        progress, reveal = 0, 0
        animationFinished = false
        if timeline then timeline:Hide() end
    end

    function render.PrepareLevelTimeline(level, abilities, sample, saved)
        render.ClearLevelTimeline()
        reachedLevel = tonumber(level)
        if not reachedLevel or reachedLevel < 1 then return end
        cap = ns.GetLevelCap()
        startLevel = math.max(1, reachedLevel - 1)
        endLevel = cap and reachedLevel >= cap and reachedLevel or reachedLevel + 1
        source = { abilities = abilities, sample = sample, saved = saved }
    end

    function render.RefreshTimelineMouse()
        if not markers then return end
        local marker = markers[3]
        local interactive = timeline:IsShown() and timeline.opacity > 0 and marker:IsShown()
            and not ns.db.clickThrough and not popup.closingInputSuppressed
        for _, icon in ipairs(marker.icons) do
            local enabled = false
            if interactive and icon:IsShown() and icon.skill and (icon.skill.id or icon.skill.name) then
                local center = marker.timelineX + icon.gluPointX
                local halfWidth = icon:GetWidth() / 2
                enabled = center - halfWidth >= 0 and center + halfWidth <= timeline:GetWidth()
            end
            if icon:IsMouseEnabled() ~= enabled then icon:EnableMouse(enabled) end
            if not enabled then HideSkillTooltip(icon) end
        end
    end

    function render.IsTimelineSkillHovered()
        if not timeline or not timeline:IsShown() or not GameTooltip or not GameTooltip.IsOwned or not GameTooltip:IsShown() then return false end
        for _, icon in ipairs(markers[3].icons) do
            if GameTooltip:IsOwned(icon) then return true end
        end
        return false
    end

    local function PaintProgress()
        local eased = progress * progress * (3 - 2 * progress)
        -- The reached level keeps its number and tick when its skills disappear.
        local fade = math.max(0, math.min(1, (progress - .65) / .35))
        local reachedSkillAlpha = 1 - fade * fade * (3 - 2 * fade)
        local endpointDistance = .20
        local approaching = math.min(1, (1 - eased) / endpointDistance)
        -- The scrolling markers change size just outside their resting ticks.
        local departing = math.max(0, 1 - eased / OUTER_SKILL_TRAVEL)
        local arriving = math.max(0, 1 - (1 - eased) / OUTER_SKILL_TRAVEL)
        for i, marker in ipairs(markers) do
            local x = timeline.edge + timeline.span * (i - 1 - eased)
            marker.timelineX = x
            marker:SetPoint("TOP", timeline, "TOPLEFT", x, 0)
            local alpha = i == 1 and (1 - eased) or i == 3 and eased or 1
            if i ~= 2 then
                -- Fade the whole marker before its label or icons reach the clip edge.
                local distance = i == 1 and x or timeline:GetWidth() - x
                local fadeEnd = marker.fadeHalfWidth
                local t = math.max(0, math.min(1, (distance - fadeEnd) / (timeline.edge - fadeEnd)))
                alpha = math.min(alpha, t * t * (3 - 2 * t))
            end
            render.Alpha(marker, alpha)
            render.Shown(marker, marker.hasLevel and alpha > 0)
            local sizeProgress = i == 1 and departing or i == 2 and approaching or arriving
            local skillReveal = sizeProgress * sizeProgress * (3 - 2 * sizeProgress)
            for _, icon in ipairs(marker.icons) do
                if icon.skill then
                    local size = icon.fullSize * (.35 + .65 * skillReveal)
                    render.Size(icon, size, size)
                    if i == 2 then render.Alpha(icon, reachedSkillAlpha) end
                end
            end
        end
        render.ParticlePoint(markerDot, timeline, "TOPLEFT", timeline.edge + timeline.span * (1 - eased), TRACK_Y)
        render.RefreshTimelineMouse()
    end

    function render.UpdateLevelTimeline(age, barFinish, revealDuration, finish)
        if animationFinished or not timeline or not timeline:IsShown() then return false end
        local t = math.max(0, math.min(1, (age - barFinish) / revealDuration))
        reveal = t * t * (3 - 2 * t)
        render.Alpha(timeline, timeline.opacity * reveal)
        local scrollStart = barFinish + revealDuration
        finish = math.max(scrollStart + .01, finish)
        local nextProgress = math.max(0, math.min(1, (age - scrollStart) / (finish - scrollStart)))
        if progress ~= nextProgress then
            progress = nextProgress
            PaintProgress()
        end
        local elapsed = age - finish
        local sparkling = startLevel < reachedLevel and ns.DecorativeAnimationsEnabled()
            and elapsed >= 0 and elapsed < sparkDuration
        render.Shown(spark, sparkling)
        render.Shown(barFlash, sparkling and elapsed < barFlashDuration)
        if sparkling then
            local t = elapsed / sparkDuration
            local flare = t < .22 and 1 - (1 - t / .22)^3 or (1 - (t - .22) / .78)^2
            local size = 6 + 42 * flare
            render.Size(spark, size, size)
            local angle = t * math.pi * 2
            local radius = 7 * math.sin(math.pi * t)
            spark:SetRotation(angle)
            render.ParticlePoint(spark, timeline, "TOPLEFT", timeline.edge + math.sin(angle) * radius,
                TRACK_Y + (1 - math.cos(angle)) * radius * .5)
            render.Alpha(spark, flare^.45 * (.8 + .2 * math.cos(t * math.pi * 10)))
            local flash = math.min(1, elapsed / barFlashDuration)
            render.Alpha(barFlash, flash < .22 and 1 - (1 - flash / .22)^3 or (1 - (flash - .22) / .78)^2)
        end
        animationFinished = progress == 1 and elapsed >= sparkDuration
        return progress < 1 or sparkling
    end

    function render.FadeLevelTimeline(alpha)
        if timeline and timeline:IsShown() then timeline:SetAlpha(timeline.opacity * reveal * alpha) end
    end

    function ns.RefreshLevelTimeline()
        if not (ns.db and ns.db.showLevelTimeline and reachedLevel and source) then
            if timeline then timeline:Hide() end
            return
        end
        if not timeline then Create() end
        local showSkills = ns.NewAbilitiesEnabled()
        if showSkills and not source.levels then
            local saved = source.saved
            local recorded = saved and saved.levels
            local upcoming = recorded and recorded[endLevel]
            if recorded and (endLevel == reachedLevel or (upcoming and #upcoming > 0) or saved.nextUnlockLevel) then
                source.levels, source.nextUnlockLevel, source.nextUnlockSkills = recorded, saved.nextUnlockLevel, saved.nextUnlockSkills
            else
                source.levels, source.nextUnlockLevel, source.nextUnlockSkills = BuildTimelineSkills(
                    startLevel, reachedLevel, endLevel, cap, source.abilities or {}, source.sample)
                if recorded then
                    source.levels[startLevel] = recorded[startLevel] or source.levels[startLevel]
                    source.levels[reachedLevel] = recorded[reachedLevel] or source.levels[reachedLevel]
                end
            end
        end
        local count = showSkills and ns.OPTION_SETTINGS.timelineSkillCount.get() or 0
        local colour = ns.GetTimelineColour()
        local r, g, b = colour[1], colour[2], colour[3]
        timeline.opacity = ns.OPTION_SETTINGS.timelineOpacity.get() / 100
        timeline:SetAlpha(timeline.opacity * reveal)
        local bottomBar = ns.GetEffectiveBackgroundMode() == "MODERN" and modernBottomLine or texturedBottomEdge
        timeline:ClearAllPoints()
        timeline:SetPoint("TOP", bottomBar, "CENTER", 0, -TRACK_Y)
        -- Use the bar's final width even while its entrance animation draws it.
        local barWidth = math.max(1, bottomBar.fullWidth or bottomBar:GetWidth())
        local span = barWidth * .7
        local iconSize = math.max(10, math.min(21, span / 7))
        timeline.span = span
        local path = ns.GetPopupFontPath(ns.db.customFontPath)
        local levels = { startLevel < reachedLevel and startLevel or false, reachedLevel,
            endLevel > reachedLevel and endLevel or false }
        local widestMarker = 0
        for i, marker in ipairs(markers) do
            local level = levels[i]
            marker:SetWidth(2 * iconSize + 3)
            marker.hasLevel = level ~= false
            marker.label:SetFont(path, 14, "OUTLINE")
            marker.label:SetText(level and tostring(level) or "")
            marker.label:SetTextColor(r, g, b)
            marker.tick:SetColorTexture(r, g, b, .8)
            local skills = count > 0 and level and source.levels[level]
            local iconTop = TRACK_Y - 27
            if marker.unlockLabel then
                local showUnlock = level and count > 0 and source.nextUnlockLevel ~= nil
                render.Shown(marker.unlockLabel, showUnlock == true)
                if showUnlock then
                    marker.unlockLabel:SetFont(path, 12, "OUTLINE")
                    marker.unlockLabel:SetText(ns.L("Level %d", source.nextUnlockLevel))
                    marker.unlockLabel:SetTextColor(r, g, b)
                    skills, iconTop = source.nextUnlockSkills, TRACK_Y - 42
                end
            end
            marker.fadeHalfWidth = math.max(marker:GetWidth(), marker.label:GetStringWidth(),
                marker.unlockLabel and marker.unlockLabel:IsShown() and marker.unlockLabel:GetStringWidth() or 0) / 2
            widestMarker = math.max(widestMarker, marker.fadeHalfWidth)
            for j, icon in ipairs(marker.icons) do
                local skill = skills and j <= count and skills[j]
                if icon.skill ~= skill then HideSkillTooltip(icon) end
                icon.skill = skill
                if skill then
                    local texture = skill.texture or ns.GetSpellIconTexture(skill.id)
                    icon.artwork:SetTexture(texture or 134400)
                    icon.fullSize = iconSize
                    local rowStart = j > 2 and 3 or 1
                    local columns = math.min(2, math.min(count, #skills) - rowStart + 1)
                    local column = j - rowStart - (columns - 1) / 2
                    render.ParticlePoint(icon, marker, "TOP", column * (iconSize + 3), iconTop - iconSize / 2 - (rowStart == 3 and iconSize + 3 or 0))
                end
                render.Shown(icon, skill ~= nil and skill ~= false)
            end
        end
        -- Leave enough space to fade fully before even the widest marker clips.
        timeline.edge = math.max((barWidth - span) / 2, widestMarker + 12)
        local width = span + 2 * timeline.edge
        timeline:SetWidth(width)
        render.Size(barFlash, barWidth, 2)
        render.ParticlePoint(barFlash, timeline, "TOPLEFT", width / 2, TRACK_Y)
        markerDot:SetColorTexture(r, g, b, 1)
        spark:SetVertexColor(r + (1 - r) * .35, g + (1 - g) * .35, b + (1 - b) * .35)
        timeline:Show()
        PaintProgress()
        if reveal < 1 and ns.WakeAbilityEffects then ns.WakeAbilityEffects() end
    end

    function render.GetLevelTimelineReplay()
        return source and source.levels and {
            levels = source.levels, nextUnlockLevel = source.nextUnlockLevel, nextUnlockSkills = source.nextUnlockSkills,
        } or nil
    end
end
