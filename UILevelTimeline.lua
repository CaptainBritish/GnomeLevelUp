local ADDON_NAME, ns = ...

local MAX_SKILLS = 4
local MAX_STEPS = 4
local TRACK_Y = -30
local SKILL_FADE_SECONDS = .16
local SKILL_STAGGER_SECONDS = .065
local MIN_SCROLL_SECONDS = .20

local function ClampProgress(value)
    return math.max(0, math.min(1, value))
end

local function Smooth(progress)
    return progress * progress * (3 - 2 * progress)
end

local function SkillSequenceDuration(count)
    if count == 0 then return 0 end
    return SKILL_FADE_SECONDS + (count - 1) * SKILL_STAGGER_SECONDS
end

local function SkillFade(age, order)
    return Smooth(ClampProgress((age - (order - 1) * SKILL_STAGGER_SECONDS) / SKILL_FADE_SECONDS))
end

local function BuildTimelineSkills(first, reached, last, cap, abilities, sample)
    local byLevel = {}
    for level = first, last do byLevel[level] = {} end
    local nextUnlockLevel, nextUnlockSkills
    local function Add(level, id, texture, name, cost)
        if not level or level <= 1 or not (id or texture) then return end
        local list = byLevel[level]
        if not list and last > reached and level > last and (not cap or level <= cap) then
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
            for level = reached + 1, cap or last do
                AddCatalogueLevel(level)
                if (level <= last and #byLevel[level] < MAX_SKILLS)
                    or (level > last and (not nextUnlockSkills or #nextUnlockSkills < MAX_SKILLS)) then
                    for _, entry in ipairs(ns.GetBundledTimelineTraining(level)) do
                        Add(level, entry.spellID, entry.icon, entry.name, entry.cost)
                    end
                end
                if level >= last and (#byLevel[last] > 0 or nextUnlockLevel == level) then break end
            end
        end
    end
    if #byLevel[last] > 0 then return byLevel end
    return byLevel, nextUnlockLevel, nextUnlockSkills
end

function ns.InstallLevelTimeline(render, popup, modernBottomLine, texturedBottomEdge)
    local timeline, markers, markerDot, barFlash
    local source, startLevel, reachedLevel, cap, steps
    local progress, reveal = 0, 0
    local initialAge, exitAge, upcomingAge = 0, 0, 0
    local initialCount, upcomingCount = 0, 0
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
        for i = 1, MAX_STEPS + 1 do
            local marker = CreateFrame("Frame", nil, timeline)
            marker:SetHeight(118)
            marker.icons = {}
            marker.label = marker:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            marker.label:SetPoint("TOP", marker, "TOP", 0, TRACK_Y - 8)
            marker.tick = marker:CreateTexture(nil, "ARTWORK")
            marker.tick:SetSize(2, 12)
            marker.tick:SetPoint("CENTER", marker, "TOP", 0, TRACK_Y)
            if i > 1 then
                marker.spark = marker:CreateTexture(nil, "OVERLAY", nil, 1)
                marker.spark:SetTexture("Interface\\Cooldown\\star4")
                marker.spark:SetBlendMode("ADD")
                marker.spark:SetPoint("CENTER", marker.tick, "CENTER")
                marker.spark:Hide()
            end
            if i >= 3 then
                marker.unlockLabel = marker:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
                marker.unlockLabel:SetPoint("TOP", marker, "TOP", 0, TRACK_Y - 27)
            end
            for j = 1, MAX_SKILLS do
                local icon = CreateFrame("Frame", nil, marker)
                icon.artwork = icon:CreateTexture(nil, "ARTWORK")
                icon.artwork:SetAllPoints(icon)
                icon.artwork:SetTexCoord(.08, .92, .08, .92)
                icon:EnableMouse(false)
                if i >= 3 then
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
        markerDot = timeline:CreateTexture(nil, "OVERLAY")
        markerDot:SetSize(6, 10)
        barFlash = timeline:CreateTexture(nil, "ARTWORK")
        barFlash:SetTexture("Interface\\AddOns\\GnomeLevelUp\\Textures\\seperator")
        barFlash:SetVertexColor(1, 1, 1)
        barFlash:SetBlendMode("ADD")
        barFlash:Hide()
    end

    function render.ClearLevelTimeline()
        source, startLevel, reachedLevel = nil, nil, nil
        progress, reveal = 0, 0
        initialAge, exitAge, upcomingAge = 0, 0, 0
        initialCount, upcomingCount = 0, 0
        animationFinished = false
        if timeline then
            for i = 2, #markers do markers[i].spark:Hide() end
            barFlash:Hide()
            timeline:Hide()
        end
    end

    function render.PrepareLevelTimeline(level, abilities, sample, saved)
        render.ClearLevelTimeline()
        reachedLevel = tonumber(level)
        if not reachedLevel or reachedLevel < 1 then return end
        cap = ns.GetLevelCap()
        startLevel = math.max(1, reachedLevel - 1)
        source = { abilities = abilities, sample = sample, saved = saved }
    end

    function render.RefreshTimelineMouse()
        if not markers then return end
        local interactive = timeline:IsShown() and timeline.opacity > 0
            and not ns.db.clickThrough and not popup.closingInputSuppressed
        for i = 3, #markers do
            local marker = markers[i]
            for _, icon in ipairs(marker.icons) do
                local enabled = false
                if interactive and marker:IsShown() and icon:IsShown() and icon.timelineOpacity == 1 then
                    local center = marker.timelineX + icon.gluPointX
                    local halfWidth = icon:GetWidth() / 2
                    enabled = center - halfWidth >= 0 and center + halfWidth <= timeline:GetWidth()
                end
                if icon:IsMouseEnabled() ~= enabled then icon:EnableMouse(enabled) end
                if not enabled then HideSkillTooltip(icon) end
            end
        end
    end

    function render.IsTimelineSkillHovered()
        if not timeline or not timeline:IsShown() or not GameTooltip or not GameTooltip.IsOwned or not GameTooltip:IsShown() then return false end
        for i = 3, steps + 1 do
            for _, icon in ipairs(markers[i].icons) do
                if GameTooltip:IsOwned(icon) then return true end
            end
        end
        return false
    end

    local function PaintSkills(first, last, age, fadeOutAge)
        for i = first, last do
            local marker = markers[i]
            for _, icon in ipairs(marker.icons) do
                local opacity = 0
                if icon.skill then
                    opacity = SkillFade(age, icon.sequenceOrder)
                    if fadeOutAge then opacity = opacity * (1 - SkillFade(fadeOutAge, icon.sequenceOrder)) end
                    local size = icon.fullSize * (.35 + .65 * opacity)
                    render.Size(icon, size, size)
                    render.Alpha(icon, opacity)
                end
                icon.timelineOpacity = opacity
                render.Shown(icon, opacity > 0)
            end
            if marker.unlockLabel then
                local opacity = marker.hasUnlockLabel and marker.icons[1].timelineOpacity or 0
                render.Shown(marker.unlockLabel, opacity > 0)
                render.Alpha(marker.unlockLabel, opacity)
            end
        end
    end

    local function PaintProgress()
        local eased = Smooth(progress)
        for i = 1, steps + 1 do
            local marker = markers[i]
            local x = timeline.edge + timeline.spacing * (i - 1 - eased)
            marker.timelineX = x
            marker:SetPoint("TOP", timeline, "TOPLEFT", x, 0)
            local alpha = i == 1 and (1 - eased) or i == steps + 1 and eased or 1
            if i == 1 or i == steps + 1 then
                -- Fade the whole marker before its label or icons reach the clip edge.
                local distance = i == 1 and x or timeline:GetWidth() - x
                local fadeEnd = marker.fadeHalfWidth
                alpha = math.min(alpha, Smooth(ClampProgress((distance - fadeEnd) / (timeline.edge - fadeEnd))))
            end
            render.Alpha(marker, alpha)
            render.Shown(marker, marker.hasLevel and alpha > 0)
        end
        render.ParticlePoint(markerDot, timeline, "TOPLEFT", timeline.edge + timeline.spacing * (1 - eased), TRACK_Y)
    end

    function render.UpdateLevelTimeline(age, barFinish, revealDuration, finish)
        if animationFinished or not timeline or not timeline:IsShown() then return false end
        local sinceBar = age - barFinish
        reveal = Smooth(ClampProgress(sinceBar / revealDuration))
        render.Alpha(timeline, timeline.opacity * reveal)
        local initialDuration = SkillSequenceDuration(initialCount)
        local exitStart = math.max(revealDuration, initialDuration)
        local scrollStart = barFinish + exitStart + initialDuration
        finish = math.max(scrollStart + MIN_SCROLL_SECONDS, finish)
        local nextInitialAge = math.max(0, math.min(initialDuration, sinceBar))
        local nextExitAge = math.max(0, math.min(initialDuration, sinceBar - exitStart))
        if initialAge ~= nextInitialAge or exitAge ~= nextExitAge then
            initialAge, exitAge = nextInitialAge, nextExitAge
            PaintSkills(1, 2, initialAge, exitAge)
        end
        local nextProgress = ClampProgress((age - scrollStart) / (finish - scrollStart))
        if progress ~= nextProgress then
            progress = nextProgress
            PaintProgress()
        end
        local elapsed = age - finish
        local upcomingDuration = SkillSequenceDuration(upcomingCount)
        local previousUpcomingAge = upcomingAge
        upcomingAge = math.max(0, elapsed)
        if previousUpcomingAge < upcomingDuration and upcomingAge ~= previousUpcomingAge then
            PaintSkills(3, steps + 1, upcomingAge)
            render.RefreshTimelineMouse()
        end
        local sparkling = startLevel < reachedLevel and ns.DecorativeAnimationsEnabled()
            and elapsed >= 0 and elapsed < sparkDuration
        render.Shown(barFlash, sparkling and elapsed < barFlashDuration)
        local sparkProgress = sparkling and elapsed / sparkDuration or 0
        local flare = sparkProgress < .22 and 1 - (1 - sparkProgress / .22)^3
            or (1 - (sparkProgress - .22) / .78)^2
        for i = 2, steps + 1, steps - 1 do
            local marker = markers[i]
            local showSpark = sparkling and marker.hasLevel
            render.Shown(marker.spark, showSpark)
            if showSpark then
                local size = 6 + 42 * flare
                render.Size(marker.spark, size, size)
                marker.spark:SetRotation(sparkProgress * math.pi * 2)
                render.Alpha(marker.spark, flare^.45 * (.8 + .2 * math.cos(sparkProgress * math.pi * 10)))
            end
        end
        if sparkling and elapsed < barFlashDuration then
            local flash = math.min(1, elapsed / barFlashDuration)
            render.Alpha(barFlash, flash < .22 and 1 - (1 - flash / .22)^3 or (1 - (flash - .22) / .78)^2)
        end
        local active = progress < 1 or sparkling or upcomingAge < upcomingDuration
        animationFinished = not active
        return active
    end

    function render.FadeLevelTimeline(alpha)
        if not timeline or not timeline:IsShown() then return end
        timeline:SetAlpha(timeline.opacity * reveal * alpha)
        local fade = 1 - math.sqrt(alpha)
        for i = 1, steps + 1 do
            local marker = markers[i]
            local duration = SkillSequenceDuration(i < 3 and initialCount or upcomingCount)
            for _, icon in ipairs(marker.icons) do
                if icon:IsShown() then
                    render.Alpha(icon, icon.timelineOpacity * (1 - SkillFade(fade * duration, icon.sequenceOrder)))
                end
            end
            if marker.hasUnlockLabel then render.Alpha(marker.unlockLabel, marker.icons[1]:GetAlpha()) end
        end
    end

    function ns.RefreshLevelTimeline()
        if not (ns.db and ns.db.showLevelTimeline and reachedLevel and source) then
            if timeline then timeline:Hide() end
            return
        end
        if not timeline then Create() end
        steps = ns.OPTION_SETTINGS.timelineSteps.get()
        local lastLevel = reachedLevel + steps - 1
        if cap then
            lastLevel = math.max(reachedLevel, math.min(lastLevel, cap))
            steps = math.max(2, lastLevel - reachedLevel + 1)
        end
        local showSkills = ns.NewAbilitiesEnabled()
        if showSkills and source.lastLevel ~= lastLevel then
            local saved = source.saved
            local recorded = saved and saved.levels
            local levels, nextUnlock, nextSkills = BuildTimelineSkills(
                startLevel, reachedLevel, lastLevel, cap, source.abilities or {}, source.sample)
            for level = startLevel, lastLevel do
                local skills = recorded and recorded[level]
                if level > 1 and skills and (level <= reachedLevel or #skills > 0) then levels[level] = skills end
            end
            if saved and saved.nextUnlockLevel and saved.nextUnlockSkills then
                local level = saved.nextUnlockLevel
                if level <= lastLevel and level > reachedLevel and #levels[level] == 0 then
                    levels[level] = saved.nextUnlockSkills
                elseif level > lastLevel and (not nextUnlock or level <= nextUnlock) and (not cap or level <= cap) then
                    nextUnlock, nextSkills = level, saved.nextUnlockSkills
                end
            end
            source.levels, source.nextUnlockLevel, source.nextUnlockSkills = levels, nextUnlock, nextSkills
            source.lastLevel = lastLevel
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
        local spacing = span / (steps - 1)
        local iconSize = math.max(10, math.min(21, span / 7, (spacing - 9) / 2))
        timeline.span, timeline.spacing = span, spacing
        local path = ns.GetPopupFontPath(ns.db.customFontPath)
        local widestMarker = 0
        initialCount, upcomingCount = 0, 0
        for i, marker in ipairs(markers) do
            local level = reachedLevel + i - 2
            marker.hasLevel = level >= startLevel and level <= lastLevel
            if not marker.hasLevel then marker:Hide() end
            if marker.spark and i ~= 2 and i ~= steps + 1 then marker.spark:Hide() end
            marker:SetWidth(2 * iconSize + 3)
            marker.label:SetFont(path, 14, "OUTLINE")
            marker.label:SetText(marker.hasLevel and tostring(level) or "")
            marker.label:SetTextColor(r, g, b)
            marker.tick:SetColorTexture(r, g, b, .8)
            -- Older replay snapshots may still include starter spells.
            local skills = count > 0 and marker.hasLevel and level > 1 and source.levels[level]
            local iconTop = TRACK_Y - 27
            if marker.unlockLabel then
                marker.hasUnlockLabel = marker.hasLevel and i == steps + 1 and count > 0
                    and (not skills or #skills == 0) and source.nextUnlockLevel ~= nil
                if marker.hasUnlockLabel then
                    marker.unlockLabel:SetFont(path, 12, "OUTLINE")
                    marker.unlockLabel:SetText(ns.L("Level %d", source.nextUnlockLevel))
                    marker.unlockLabel:SetTextColor(r, g, b)
                    skills, iconTop = source.nextUnlockSkills, TRACK_Y - 42
                end
            end
            marker.fadeHalfWidth = math.max(marker:GetWidth(), marker.label:GetStringWidth(),
                marker.hasUnlockLabel and marker.unlockLabel:GetStringWidth() or 0) / 2
            widestMarker = math.max(widestMarker, marker.fadeHalfWidth)
            for j, icon in ipairs(marker.icons) do
                local skill = skills and j <= count and skills[j] or nil
                if icon.skill ~= skill then HideSkillTooltip(icon) end
                icon.skill = skill
                if skill then
                    if i < 3 then
                        initialCount = initialCount + 1
                        icon.sequenceOrder = initialCount
                    else
                        upcomingCount = upcomingCount + 1
                        icon.sequenceOrder = upcomingCount
                    end
                    local texture = skill.texture or ns.GetSpellIconTexture(skill.id)
                    icon.artwork:SetTexture(texture or 134400)
                    icon.fullSize = iconSize
                    local rowStart = j > 2 and 3 or 1
                    local columns = math.min(2, math.min(count, #skills) - rowStart + 1)
                    local column = j - rowStart - (columns - 1) / 2
                    render.ParticlePoint(icon, marker, "TOP", column * (iconSize + 3), iconTop - iconSize / 2 - (rowStart == 3 and iconSize + 3 or 0))
                end
                if not skill then
                    icon.timelineOpacity = 0
                    render.Shown(icon, false)
                end
            end
        end
        -- Leave enough space to fade fully before even the widest marker clips.
        timeline.edge = math.max((barWidth - span) / 2, widestMarker + 12)
        local width = span + 2 * timeline.edge
        timeline:SetWidth(width)
        render.Size(barFlash, barWidth, 2)
        render.ParticlePoint(barFlash, timeline, "TOPLEFT", width / 2, TRACK_Y)
        markerDot:SetColorTexture(r, g, b, 1)
        for i = 2, #markers do
            markers[i].spark:SetVertexColor(r + (1 - r) * .35, g + (1 - g) * .35, b + (1 - b) * .35)
        end
        timeline:Show()
        PaintProgress()
        if animationFinished then
            initialAge = SkillSequenceDuration(initialCount)
            exitAge = initialAge
            upcomingAge = SkillSequenceDuration(upcomingCount)
        end
        PaintSkills(1, 2, initialAge, exitAge)
        PaintSkills(3, steps + 1, upcomingAge)
        render.RefreshTimelineMouse()
        if not animationFinished and ns.WakeAbilityEffects then
            ns.WakeAbilityEffects()
        end
    end

    function render.GetLevelTimelineReplay()
        return source and source.levels and {
            levels = source.levels, nextUnlockLevel = source.nextUnlockLevel, nextUnlockSkills = source.nextUnlockSkills,
        } or nil
    end
end
