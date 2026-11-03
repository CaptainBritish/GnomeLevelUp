local ADDON_NAME, ns = ...

function ns.InstallPopupRenderHelpers(render)
    function render.Alpha(region, alpha)
        if region:GetAlpha() ~= alpha then region:SetAlpha(alpha) end
    end

    function render.Shown(region, shown)
        if region:IsShown() ~= shown then region:SetShown(shown) end
    end

    function render.Size(region, width, height)
        if region:GetWidth() ~= width or region:GetHeight() ~= height then region:SetSize(width, height) end
    end

    -- ClearAllPoints is expensive in particle loops; change anchors only when
    -- the target changes, and update offsets on subsequent frames.
    function render.ParticlePoint(texture, relative, relativePoint, x, y)
        if texture.gluPointTarget ~= relative or texture.gluPointName ~= relativePoint then
            texture:ClearAllPoints()
            texture.gluPointTarget, texture.gluPointName = relative, relativePoint
            texture.gluPointX, texture.gluPointY = nil, nil
        end
        if texture.gluPointX ~= x or texture.gluPointY ~= y then
            texture:SetPoint("CENTER", relative, relativePoint, x, y)
            texture.gluPointX, texture.gluPointY = x, y
        end
    end

    -- Particle dimensions are owned by this renderer. Cache logical sizes in Lua
    -- instead of querying two native dimensions for every moving texture/frame.
    -- General layout regions keep render.Size, since other code can resize them.
    function render.ParticleSize(texture, width, height)
        if texture.gluParticleWidth ~= width or texture.gluParticleHeight ~= height then
            texture:SetSize(width, height)
            texture.gluParticleWidth, texture.gluParticleHeight = width, height
        end
    end

    -- Refresh only when layout or scroll offsets change. Particle ticks read the
    -- cached flag, avoiding repeated screen-coordinate queries for every icon.
    function render.RefreshAbilityVisibility(viewport, offset)
        if offset ~= nil then viewport.effectScroll = offset end
        local row = viewport.row
        if not row then return end
        local scrolling = (viewport.scrollMaximum or 0) > 0
        local value = viewport.effectScroll or 0
        for _, icon in ipairs(viewport.effectPool or {}) do
            local visible = icon:IsShown()
            if visible and scrolling and icon.animationX and icon.animationY then
                local halfWidth, halfHeight = icon:GetWidth()/2, icon:GetHeight()/2
                local x = row:GetWidth()/2 + icon.animationX - (viewport.verticalLayout and 0 or value)
                local y = row:GetHeight()/2 - icon.animationY - (viewport.verticalLayout and value or 0)
                -- Retain partially visible icons and their entrance displacement.
                visible = x + halfWidth > 0 and x - halfWidth < viewport:GetWidth()
                    and y + halfHeight + 24 > 0 and y - halfHeight - 24 < viewport:GetHeight()
            end
            icon.effectVisible = visible
            if not visible then
                render.Shown(icon.newAbilityGlow, false)
                render.Shown(icon.ambientSparkle, false)
                for _, texture in ipairs(icon.cornerSparkles or {}) do render.Shown(texture, false) end
                if icon.revealShine then render.Shown(icon.revealShine, false) end
            end
        end
        render.glowWake, render.sparkleWake, render.ambientWake = nil, nil, nil
    end

end
