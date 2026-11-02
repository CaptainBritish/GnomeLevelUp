local ADDON_NAME, ns = ...

-- Decorative ring, portrait, ability and depth effects share the popup's clock
-- and pools. Extraction adds no timers or duplicate copies of mutable state.
function ns.CreatePopupDecorationUpdater(context)
    local render, content, frame = context.render, context.content, context.frame
    local Speed, ActiveColor = context.Speed, context.ActiveColor
    local IsPlayerPortrait, EnsureParticlePool = context.IsPlayerPortrait, context.EnsureParticlePool
    local RollBackgroundEmber, PortraitIconSize = context.RollBackgroundEmber, context.PortraitIconSize
    local PORTRAIT_PULSE_GAP, CIRCLE_MASK = context.PORTRAIT_PULSE_GAP, context.CIRCLE_MASK
    return function()
        local entranceTimeline, effectAge, portraitStage, starburstStartedAt, fadeFinished = context.GetState()
        local db, plan = ns.db or {}, entranceTimeline
        local enabled = frame:IsShown() and not db.reducedMotion and db.backgroundAnimations ~= false
        if not enabled or not plan then
            render.HideTrialEffects();render.TintTrialImpact(0)
            return false
        end
        local effects = content.trialEffects
        if not effects then
            effects = {glints={},depth={},impacts={}}
            content.trialEffects = effects
        end
        local active, speed = false, Speed()
        local perf = ns.PerfStart("ring_glint_frame", effectAge)
        local color = ActiveColor("animatedElements")
        local portrait = db.portraitMode ~= "none"
        local milestone = content.isMilestone and db.milestoneAnimations ~= false
        local maxLevel = content.isMaxLevel and db.maxLevelCelebration ~= false
        local glintAge = (effectAge-plan.portrait.finish-.08/speed)/(render.PortraitGlintDuration()/speed)
        local willStarburst = db.portraitAnimation and IsPlayerPortrait()
        local flareDuration = (milestone and .42 or .34) / speed
        local flare = (effectAge-render.PortraitGlintFinish())/flareDuration
        local holding = willStarburst and glintAge >= 1 and portraitStage ~= "starburst" and flare < 0
        local flaring = flare >= 0 and flare < 1
        -- A short attack creates a spark, followed by a shrinking, lightly flickering tail.
        local spark = flaring and (flare < .22 and 1-(1-flare/.22)^3 or (1-(flare-.22)/.78)^2) or 0
        local flicker = flaring and (maxLevel and .65+.35*math.cos(flare*math.pi*10) or .92+.08*math.cos(flare*math.pi*6)) or 1
        if db.portraitRingGlint and portrait and (glintAge < 1.12 or holding or flaring) then
            if not effects.glintLayer then
                effects.glintLayer = CreateFrame("Frame", nil, content.portraitArtwork)
                effects.glintLayer:SetAllPoints(content.portraitArtwork)
            end
            effects.glintLayer:SetFrameLevel(math.max(content.portraitArtwork:GetFrameLevel(),
                content.playerModel and content.playerModel:GetFrameLevel() or 0)+3)
            EnsureParticlePool(effects.glints, effects.glintLayer, 3)
            local ring = db.portraitRingEnabled and content.classRingGraphic or content.classRing
            for i, texture in ipairs(effects.glints) do
                local t = glintAge-(i-1)*.04
                local onPath = t>=0 and t<1
                local visible = onPath or holding and i == 1 or flaring
                render.Shown(texture, visible)
                if visible then
                    local angle = onPath and math.pi/2-t*math.pi*2 or math.pi/2
                    local radius = ring:GetWidth() * (ring == content.classRingGraphic and render.portraitGlintRadius or .5)
                    texture:ClearAllPoints();texture:SetPoint("CENTER", ring, "CENTER", math.cos(angle)*radius,math.sin(angle)*radius)
                    local size = (22-(i-1)*6) * (flaring and .18+((maxLevel and 6.4 or milestone and 2.4 or 1.45)-.18)*spark or 1)
                    render.ParticleSize(texture,size,size)
                    texture:SetRotation(maxLevel and flaring and (flare-.22)*.6 or 0)
                    local alpha = flaring and spark^.45*flicker*(milestone and 1 or .9)
                        or onPath and math.sin(math.pi*t)^.5 or .35
                    texture:SetAlpha(alpha*(.75^(i-1)))
                    local white = flaring and milestone and .8 or .45
                    texture:SetVertexColor(white+(1-white)*color[1],white+(1-white)*color[2],white+(1-white)*color[3])
                end
            end
            active = true
        else for _, texture in ipairs(effects.glints) do texture:Hide() end end

        ns.PerfEnd(perf)
        perf = ns.PerfStart("portrait_shimmer_frame", effectAge)
        local shimmerAge = render.ringSurgeStartedAt and effectAge-render.ringSurgeStartedAt-.28/speed or -1
        local shimmerDuration = .85/speed
        local shimmerCycle = math.max(4, shimmerDuration+.5)
        local shimmerTime = shimmerAge >= 0 and (shimmerAge % shimmerCycle)/shimmerDuration or -1
        local shimmerVisible = (milestone or maxLevel) and db.portraitAnimation and IsPlayerPortrait()
            and shimmerTime >= 0 and shimmerTime < 1
        if shimmerVisible and not effects.portraitShimmer then
            local clip = CreateFrame("Frame", nil, content.portraitArtwork)
            clip:SetClipsChildren(true)
            clip.texture = render.TrialSpark(clip)
            clip.texture:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
            clip.texture:SetRotation(-math.pi/4)
            if clip.CreateMaskTexture then
                clip.mask = clip:CreateMaskTexture()
                clip.mask:SetAllPoints(clip)
                clip.mask:SetTexture(CIRCLE_MASK, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
                clip.texture:AddMaskTexture(clip.mask)
            end
            effects.portraitShimmer = clip
        end
        if effects.portraitShimmer then
            local clip = effects.portraitShimmer
            render.Shown(clip, shimmerVisible == true)
            if shimmerVisible then
                local target = db.portraitMode == "player3d" and content.modelBacking or content.classIcon
                local width, height = target:GetWidth(), target:GetHeight()
                clip:SetFrameLevel(math.max(content.portraitArtwork:GetFrameLevel(),
                    content.playerModel and content.playerModel:GetFrameLevel() or 0)+4)
                clip:ClearAllPoints();clip:SetPoint("CENTER", target, "CENTER")
                render.Size(clip,width,height);render.Alpha(clip,1)
                local texture = clip.texture
                texture:Show();render.ParticleSize(texture,width*1.8,18)
                render.ParticlePoint(texture,clip,"CENTER",(-.8+1.6*shimmerTime)*width,(-.8+1.6*shimmerTime)*height)
                texture:SetVertexColor(.6+.4*color[1],.6+.4*color[2],.6+.4*color[3])
                texture:SetAlpha(.85*math.sin(math.pi*shimmerTime)^.5)
                active = true
            end
        end

        ns.PerfEnd(perf)
        perf = ns.PerfStart("ability_shine_frame", effectAge)
        if not effects.shinesFinished then
        local pending=false
        for _, pool in ipairs(render.abilityPools) do
            for _, icon in ipairs(pool) do
                local t = (effectAge-(icon.entranceEnd or 0)+.10/speed)/(.70/speed)
                local visible = db.highlightNewAbilities and icon:IsShown() and icon.effectVisible ~= false and icon.isNewAbility == true
                    and not icon.skipEntrance and t>=0 and t<1
                if visible and not icon.revealShine then
                    local clip = CreateFrame("Frame", nil, icon)
                    clip:SetAllPoints(icon);clip:SetClipsChildren(true);clip:SetFrameLevel(icon:GetFrameLevel()+4)
                    clip.texture = render.TrialSpark(clip)
                    clip.texture:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
                    clip.texture:SetRotation(-math.pi/4)
                    icon.revealShine = clip
                end
                if icon.revealShine then
                    render.Shown(icon.revealShine, visible == true)
                    if visible then
                        local texture,w,h = icon.revealShine.texture,icon:GetWidth(),icon:GetHeight()
                        texture:Show();render.ParticleSize(texture,w*1.8,16)
                        render.ParticlePoint(texture,icon,"CENTER",(-.8+1.6*t)*w,(-.8+1.6*t)*h)
                        texture:SetAlpha(.95*math.sin(math.pi*t)^.5)
                    end
                end
                if db.highlightNewAbilities and icon:IsShown() and icon.effectVisible ~= false and icon.isNewAbility == true and not icon.skipEntrance and t<1 then pending=true end
            end
        end

        effects.shinesFinished=not pending
        active=active or pending
        end

        ns.PerfEnd(perf)
        perf = ns.PerfStart("stat_impacts_frame", effectAge)
        if not effects.impactsFinished then
        local enabled = milestone and db.emphasizeStatGains
        local pending=false
        for _, row in ipairs(content.statLinePool) do
            local age = row.countFinishAt and effectAge-row.countFinishAt or -1
            local visible = enabled and row:IsShown() and age>=0 and age<.65/speed
            if visible and not effects.impacts[row] then
                effects.impacts[row] = {}
                for i=1,3 do effects.impacts[row][i]=render.TrialSpark(row.slideFrame) end
            end
            local pool = effects.impacts[row]
            if pool then for i, texture in ipairs(pool) do
                render.Shown(texture,visible == true)
                if visible then
                    local t,angle = age/(.65/speed),(i-1)*math.pi*2/3
                    local distance=6+28*(1-(1-t)^2)
                    render.ParticlePoint(texture,row.gainCounter,"RIGHT",math.cos(angle)*distance,math.sin(angle)*distance)
                    render.ParticleSize(texture,15-i*2,15-i*2);texture:SetAlpha(math.sin(math.pi*t)^.5*(1-.45*t))
                end
            end end
            if enabled and row:IsShown() and row.countFinishAt and age<.65/speed then pending=true end
        end

        effects.impactsFinished=not pending
        active=active or pending
        end

        ns.PerfEnd(perf)
        perf = ns.PerfStart("depth_particles_frame", effectAge)
        local ambient = effectAge-fadeFinished-.50
        local depth = db.backgroundEmbers and render.particleSettings[3].count>0
        if depth then
            local maxLevel = content.isMaxLevel and db.maxLevelCelebration ~= false
            local depthCount = maxLevel and 60 or milestone and 36 or 24
            EnsureParticlePool(effects.depth,content,depthCount,"BACKGROUND")
            local settings = render.particleSettings[3]
            local width,height = content:GetWidth(),content:GetHeight()
            local span,rise = math.max(1,width-50),math.max(1,height-36)
            local fade = math.min(1,ambient/.3)
            for i,texture in ipairs(effects.depth) do
                local far = i > depthCount / 2
                if texture.depthFar ~= far then
                    texture:SetDrawLayer("BACKGROUND",far and -2 or -1)
                    texture.depthFar = far
                end
                render.Shown(texture,ambient>=0 and i<=depthCount)
                if ambient>=0 and i<=depthCount then
                    if not texture.depthStart or texture.emberSpeedMultiplier ~= render.backgroundMoteSpeed or ambient-texture.depthStart>=texture.emberDuration then
                        RollBackgroundEmber(texture,i)
                        texture.emberDuration=texture.emberDuration*(far and 2.2 or 1.6)
                        texture.depthStart=texture.depthStart and ambient or -((i*.9)%texture.emberDuration)
                    end
                    local t=math.max(0,math.min(1,(ambient-texture.depthStart)/texture.emberDuration))
                    local progress=(t-.15*t*t)/.85
                    local size=texture.moteSize*settings.size*(far and 1.4 or 2.5)
                    local limit=math.max(0,width/2-size)
                    local x=(((i*.61803398875)%1)-.5)*span+math.sin(texture.wanderPhase+progress*3)*12
                    render.ParticlePoint(texture,content,"BOTTOM",math.max(-limit,math.min(limit,x)),18+progress*rise)
                    local opacity = render.backgroundMoteOpacity
                    render.ParticleSize(texture,size,size);texture:SetAlpha((opacity > 0 and math.max(0, math.min(1, opacity + texture.opacityVariation)) or 0)*(far and .14 or .22)*math.sin(math.pi*t)^2*fade)
                end
            end
            active=true
        else for _,texture in ipairs(effects.depth) do texture:Hide() end end

        ns.PerfEnd(perf)
        perf = ns.PerfStart("portrait_anticipation_frame", effectAge)
        local afterGlint = db.portraitRingGlint and portraitStage == "glint"
        local pre = afterGlint and (effectAge-render.PortraitStarburstTime()+.18/speed)/(.18/speed)
            or (effectAge-plan.portrait.finish)/(PORTRAIT_PULSE_GAP/speed)
        if milestone and db.portraitRingSettle and db.portraitAnimation and IsPlayerPortrait() and pre>=0 and pre<1
            and (afterGlint or not db.portraitRingGlint and portraitStage=="waiting") then
            local size=PortraitIconSize()*2.2*render.milestoneStarburstScale*(.65-.47*pre)
            content.portraitStarburst:Show();render.Size(content.portraitStarburst,size,size)
            content.portraitStarburst:SetAlpha(render.starburstOpacity*(.45-.30*pre))
            active=true
        end
        if milestone and db.portraitRingSettle and not db.portraitRingGlint and db.portraitAnimation and IsPlayerPortrait() and portraitStage=="pulse" then
            local size=PortraitIconSize()*2.2*render.milestoneStarburstScale*.18
            content.portraitStarburst:Show();render.Size(content.portraitStarburst,size,size)
            content.portraitStarburst:SetAlpha(render.starburstOpacity*.15)
            active=true
        end
        local impact = portraitStage == "starburst" and (effectAge-starburstStartedAt)/(1.2/speed) or -1
        local white=milestone and portrait and db.portraitAnimation and impact>=0 and impact<1 and .95*(1-impact)^2 or 0
        render.TintTrialImpact(white)
        if milestone and portrait and db.portraitAnimation and impact<1 then active=true end
        ns.PerfEnd(perf)
        return active
    end
end
