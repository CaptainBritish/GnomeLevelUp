local ADDON_NAME, ns = ...

-- Forever 1.60.1.70938 has snow presets at .75 and rain/sand presets
-- at .80 before full intensity. Use those steps for the popup's haze.
local WEATHER_STYLES = {
    [0] = { count = 0 },
    [1] = { count = 66, opacity = .82, duration = .78, tint = { .58, .77, 1 }, haze = { .50, .65, .80 }, hazeStart = .80 },
    [2] = { count = 60, opacity = .85, duration = 3.6, tint = { .88, .95, 1 }, haze = { .78, .88, 1 }, hazeStart = .75 },
    [3] = { count = 64, opacity = .79, duration = 2.2, tint = { .87, .67, .37 }, haze = { .71, .48, .23 }, hazeStart = .80 },
    [4] = { count = 0 },
}

local WEATHER_TILES = {
    [1] = { name = "rain", x = .08, y = -.22 },
    [2] = { name = "snow", x = -.04, y = -.12 },
    [3] = { name = "dust", x = -.19, y = -.03 },
}

local LIGHTNING_RAIN_INTENSITY = 0.9641922712326

function ns.InstallPopupWeather(render, content, background, particles, insetForTheme)
    local distant = particles.distant
    local kind, intensity, nextRead, haze, hazeMask
    local lightning, nextFlash, flashStarted
    local tile
    local motionAge, lastAge = 0, 0
    local idlePoll
    local pollInterval = .75

    local function HideWeather()
        for _, particle in ipairs(particles) do particle:Hide() end
        for _, particle in ipairs(distant) do particle:Hide() end
        if haze then haze:Hide() end
        if lightning then lightning:Hide() end
        if tile then tile:Hide() end
        nextFlash, flashStarted = nil, nil
    end

    function render.ResetWeatherMotes()
        kind, intensity, nextRead, idlePoll = nil, 0, nil, nil
        motionAge, lastAge = 0, 0
        HideWeather()
    end

    local function ReadWeather()
        local weather = content.weatherTest
        if not weather then
            local ok, value = pcall(C_Weather.GetCurrentWeather)
            if ok then weather = value end
        end
        if type(issecretvalue) == "function" and issecretvalue(weather) then return end
        if type(weather) ~= "table" then return end
        local weatherType, amount = weather.type, weather.intensity
        if type(issecretvalue) == "function" and (issecretvalue(weatherType) or issecretvalue(amount)) then return end
        if type(weatherType) == "number" and type(amount) == "number" and amount >= 0 and amount <= 1
            and WEATHER_STYLES[weatherType] then
            return weatherType, amount
        end
    end

    local function HasMovingWeather()
        return WEATHER_TILES[kind] ~= nil and intensity > 0
    end

    local function PollIdleWeather()
        if idlePoll or content.weatherTest then return end
        local function Poll()
            if idlePoll ~= Poll then return end
            local popup = ns.levelUpFrame
            if not popup or not popup:IsShown() or popup.closingInputSuppressed
                or not ns.db.weatherMotes or not ns.DecorativeAnimationsEnabled() or not ns.HasWeatherAPI() then
                idlePoll, nextRead = nil, nil
                return
            end
            local weatherType, amount = ReadWeather()
            kind, intensity = weatherType, amount or 0
            if HasMovingWeather() then
                idlePoll, nextRead, lastAge = nil, nil, nil
                ns.WakeAbilityEffects()
            else
                C_Timer.After(pollInterval, Poll)
            end
        end
        idlePoll = Poll
        C_Timer.After(pollInterval, Poll)
    end

    local function ApplyHazeMask(texture, modern, width, height)
        if not content.CreateMaskTexture then return end
        if not hazeMask then
            hazeMask = content:CreateMaskTexture()
            hazeMask:SetTexture("Interface\\AddOns\\GnomeLevelUp\\Textures\\modern-veil.tga",
                "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
        end
        if hazeMask.gluModern ~= modern then
            hazeMask:ClearAllPoints()
            if modern then
                hazeMask:SetAllPoints(background.modern)
            else
                hazeMask:SetPoint("CENTER", content, "CENTER")
            end
            hazeMask.gluModern = modern
        end
        if not modern then render.ParticleSize(hazeMask, width, height) end
        if not texture.gluHazeMask then
            texture:AddMaskTexture(hazeMask)
            texture.gluHazeMask = hazeMask
        end
    end

    local function PaintHaze(tint, strength, width, height, inset, fade, modern)
        if strength <= 0 then
            if haze then haze:Hide() end
            return
        end
        if not haze then
            haze = content:CreateTexture(nil, "BACKGROUND", nil, -3)
            haze:SetTexture("Interface\\AddOns\\GnomeLevelUp\\Textures\\weather-haze.tga")
            particles.haze = haze
        end
        ApplyHazeMask(haze, modern, width, height)
        local bandHeight = height * .68
        render.ParticleSize(haze, width, bandHeight)
        if modern then
            render.ParticlePoint(haze, background.modern, "BOTTOM", 0, bandHeight / 2)
        else
            render.ParticlePoint(haze, content, "BOTTOM", 0, inset + bandHeight / 2)
        end
        if haze.weatherTint ~= tint then
            haze:SetVertexColor(tint[1], tint[2], tint[3])
            haze.weatherTint = tint
        end
        render.Alpha(haze, strength * fade)
        render.Shown(haze, true)
    end

    local function PaintWeatherTile(style, width, height, inset, fade)
        local pattern = WEATHER_TILES[kind]
        if not pattern or intensity <= 0 then
            if tile then render.Shown(tile, false) end
            return
        end
        if not tile then
            tile = content:CreateTexture(nil, "BACKGROUND", nil, -4)
            particles.tile = tile
        end
        if tile.weatherKind ~= kind then
            tile.weatherKind = kind
            ns.SetTextureFile(tile, "Interface\\AddOns\\GnomeLevelUp\\Textures\\weather-" .. pattern.name .. "-tile.tga", true, true)
            tile:SetVertexColor(style.tint[1], style.tint[2], style.tint[3])
        end
        -- Scroll UVs on a fixed quad. The seamless tile wraps without moving frames.
        local u = (motionAge * pattern.x) % 1
        local v = (motionAge * pattern.y) % 1
        tile:SetTexCoord(u, u + width / 288, v, v + height / 288)
        render.ParticleSize(tile, width, height)
        render.ParticlePoint(tile, content, "BOTTOM", 0, inset + height / 2)
        render.Alpha(tile, .33 * intensity * fade)
        render.Shown(tile, true)
    end

    local function PaintParticles(pool, count, width, height, inset, fade, far)
        local style = WEATHER_STYLES[kind]
        local rain, snow, sand = kind == 1, kind == 2, kind == 3
        local horizontal = not rain and not snow
        local sizeScale = far and .62 or 1
        local durationScale = far and 1.9 or 1
        local opacityScale = far and .38 or 1
        local phaseOffset = far and .17 or 0

        for i = 1, math.max(count, #pool) do
            local particle = pool[i]
            if i > count then
                render.Shown(particle, false)
            else
                if not particle then
                    particle = content:CreateTexture(nil, "BACKGROUND", nil, far and -2 or -1)
                    -- Independent sequences keep fast, bright particles from sharing one lane.
                    particle.lane = (i * .61803398875 + (far and .27 or 0)) % 1
                    particle.sizeSeed = (i * .75487766625) % 1
                    particle.speedSeed = (i * .56984029099) % 1
                    particle.opacitySeed = (i * .41421356237) % 1
                    pool[i] = particle
                end
                local size = 2 + particle.sizeSeed ^ 1.5 * 11
                local particleWidth = rain and (1.2 + particle.sizeSeed * 2.2) or sand and size * 2 or size
                local particleHeight = rain and (9 + particle.sizeSeed * 25) or sand and size * .55 or size
                particleWidth, particleHeight = particleWidth * sizeScale, particleHeight * sizeScale
                if particle.weatherKind ~= kind then
                    particle.weatherKind = kind
                    particle:SetTexture(rain and "Interface\\AddOns\\GnomeLevelUp\\Textures\\modern-row.tga"
                        or "Interface\\Cooldown\\star4")
                    -- The built-in star sprite needs additive blending to drop its black backing.
                    particle:SetBlendMode(rain and "BLEND" or "ADD")
                    particle:SetVertexColor(style.tint[1], style.tint[2], style.tint[3])
                    if rain then
                        particle:SetTexCoord(0, 1, 1, 1, 0, 0, 1, 0)
                    else
                        particle:SetTexCoord(0, 1, 0, 1)
                    end
                    render.ParticleSize(particle, particleWidth, particleHeight)
                end
                local phase = (motionAge / (style.duration * (.58 + particle.speedSeed * .95) * durationScale) + i * .381966 + phaseOffset) % 1
                local xSpan = math.max(0, width - particleWidth)
                local ySpan = math.max(0, height - particleHeight)
                local sway = math.sin(phase * (5 + particle.speedSeed * 6) + i)
                local drift = snow and sway * (6 + 30 * intensity) * (.4 + particle.sizeSeed)
                    or (phase - .5) * (rain and -(12 + 44 * intensity) or 7)
                if sand then drift = drift + sway * (4 + 14 * intensity) end
                drift = drift * sizeScale
                local x = horizontal and (phase - .5) * xSpan
                    or math.max(-xSpan / 2, math.min(xSpan / 2, (particle.lane - .5) * xSpan + drift))
                local y = horizontal and math.max(0, math.min(ySpan, particle.lane * ySpan + drift)) or (1 - phase) * ySpan
                render.ParticlePoint(particle, content, "BOTTOM", x, inset + particleHeight / 2 + y)
                render.Alpha(particle, style.opacity * opacityScale * fade * math.sin(phase * math.pi)
                    * (.48 + particle.opacitySeed * .52)
                    * (.25 + intensity * .75))
                render.Shown(particle, true)
            end
        end
    end

    local function UpdateLightning(age, inset)
        -- Observed storm rain intensity is the provisional lightning signal.
        if kind ~= 1 or intensity < LIGHTNING_RAIN_INTENSITY then
            if lightning then render.Shown(lightning, false) end
            nextFlash, flashStarted = nil, nil
            return
        end
        if not nextFlash then
            nextFlash = age + 3 + math.random() * 2
        elseif age >= nextFlash then
            flashStarted = age
            nextFlash = age + 3 + math.random() * 2
        end
        local elapsed = flashStarted and age - flashStarted
        if not elapsed or elapsed >= .42 then
            if lightning then render.Shown(lightning, false) end
            return
        end
        if not lightning then
            lightning = background:CreateTexture(nil, "BACKGROUND", nil, -4)
            particles.lightning = lightning
        end
        local modern = background.modern:IsShown()
        local margin = modern and 0 or inset
        if lightning.modern ~= modern or lightning.margin ~= margin then
            lightning.modern, lightning.margin = modern, margin
            lightning:ClearAllPoints()
            if modern then
                lightning:SetTexture("Interface\\AddOns\\GnomeLevelUp\\Textures\\modern-veil.tga")
                lightning:SetAllPoints(background.modern)
            else
                lightning:SetColorTexture(1, 1, 1)
                lightning:SetPoint("TOPLEFT", background, "TOPLEFT", margin, -margin)
                lightning:SetPoint("BOTTOMRIGHT", background, "BOTTOMRIGHT", -margin, margin)
            end
        end
        render.Alpha(lightning, .34 * math.min(1, elapsed / .04) * (1 - elapsed / .42) ^ 1.5)
        render.Shown(lightning, true)
    end

    function render.UpdateWeatherMotes(age, enabled)
        if not enabled then
            if nextRead or idlePoll then render.ResetWeatherMotes() end
            return false
        end
        if age < 0 then return true end
        if idlePoll then return false end
        if nextRead and not HasMovingWeather() then return false end
        -- Advance from the previous speed so a fresh reading never jumps particles ahead.
        local speed = kind == 0 and 1 or .65 + .7 * intensity
        if kind and kind ~= 0 then
            speed = speed * (1 + intensity * (.16 * math.sin(age * 2.1) + .08 * math.sin(age * 4.7)))
        end
        motionAge = motionAge + (age - (lastAge or age)) * speed
        lastAge = age
        if not nextRead and HasMovingWeather() then
            nextRead = age + pollInterval
        elseif not nextRead or age >= nextRead then
            local newKind, newIntensity = ReadWeather()
            kind, intensity, nextRead = newKind, newIntensity or 0, age + pollInterval
        end
        if not HasMovingWeather() then
            HideWeather()
            PollIdleWeather()
            return false
        end
        local style = WEATHER_STYLES[kind]
        local count = style and math.ceil(style.count * intensity) or 0
        local rain, snow, sand = kind == 1, kind == 2, kind == 3
        local inset = math.max(8, insetForTheme())
        local width = math.max(1, content:GetWidth() - 2 * inset)
        local height = math.max(1, content:GetHeight() - 2 * inset)
        local fade = math.min(1, age / .35)
        local hazeStrength = 0
        if style and style.hazeStart and intensity >= style.hazeStart - .000001 then
            local heavy = math.max(0, (intensity - style.hazeStart) / (1 - style.hazeStart))
            hazeStrength = .065 + heavy * .24
        end
        PaintWeatherTile(style, width, height, inset, fade)
        local modernHaze = background.modern:IsShown() and content.CreateMaskTexture ~= nil
        local lightWidth = modernHaze and background.modern:GetWidth() or width
        local lightHeight = modernHaze and background.modern:GetHeight() or height
        PaintHaze(style and style.haze, hazeStrength,
            lightWidth, lightHeight, inset, fade, modernHaze)
        UpdateLightning(age, inset)

        PaintParticles(particles, count, width, height, inset, fade, false)
        local distantCount = (rain or snow or sand) and math.ceil(count * .45) or 0
        PaintParticles(distant, distantCount, width, height, inset, fade, true)
        return true
    end
end

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
        local enabled = frame:IsShown() and ns.DecorativeAnimationsEnabled()
        if not enabled or not plan then
            render.HideDecorationEffects();render.TintDecorationImpact(0)
            return false
        end
        local effects = content.decorationEffects
        if not effects then
            effects = {glints={},depth={},impacts={}}
            content.decorationEffects = effects
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
            clip.texture = render.DecorationSpark(clip)
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
                    clip.texture = render.DecorationSpark(clip)
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
            if visible and not row.statGlintSoundPlayed then
                row.statGlintSoundPlayed = true
                ns.PlayAnimationSound("statGlint")
            end
            if visible and not effects.impacts[row] then
                effects.impacts[row] = {}
                for i=1,3 do effects.impacts[row][i]=render.DecorationSpark(row.slideFrame) end
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
        local depth = db.backgroundEmbers and not content.weatherTest and render.particleSettings[3].count>0
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
        render.TintDecorationImpact(white)
        if milestone and portrait and db.portraitAnimation and impact<1 then active=true end
        ns.PerfEnd(perf)
        return active
    end
end
