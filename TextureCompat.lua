local ADDON_NAME, ns = ...

-- Forever and Retail differ in atlas availability and SetTexture wrap support.
function ns.SetTextureFile(texture, path, wrapH, wrapV)
    if wrapH ~= nil or wrapV ~= nil then
        local ok = pcall(texture.SetTexture, texture, path,
            wrapH and "REPEAT" or "CLAMP", wrapV and "REPEAT" or "CLAMP")
        if ok then return true end
    end
    return pcall(texture.SetTexture, texture, path)
end

local function HasTextureFile(texture)
    if texture.GetTextureFileID then
        local ok, fileID = pcall(texture.GetTextureFileID, texture)
        if ok then return fileID ~= nil and fileID ~= 0 end
    end
    return true
end

function ns.ApplyAtlasCandidates(texture, candidates, useAtlasSize, checkFileID)
    -- Metadata preserves sub-rectangle coordinates for flips and rotation.
    if C_Texture and type(C_Texture.GetAtlasInfo) == "function" then
        for _, atlas in ipairs(candidates or {}) do
            local ok, info = pcall(C_Texture.GetAtlasInfo, atlas)
            if ok and info and (info.file or info.filename)
                and info.leftTexCoord and info.rightTexCoord
                and info.topTexCoord and info.bottomTexCoord then
                local applied = ns.SetTextureFile(texture, info.file or info.filename)
                if applied and (not checkFileID or HasTextureFile(texture)) then
                    return true, info.leftTexCoord, info.rightTexCoord,
                        info.topTexCoord, info.bottomTexCoord
                end
            end
        end
    end
    if texture.SetAtlas then
        for _, atlas in ipairs(candidates or {}) do
            local ok = pcall(texture.SetAtlas, texture, atlas, useAtlasSize == true)
            if ok then return true end
        end
    end
    return false
end

function ns.ApplyTextureReference(texture, reference, wrapH, wrapV)
    if type(reference) == "table" and type(reference.atlas) == "string" then
        return ns.ApplyAtlasCandidates(texture, { reference.atlas }, reference.useAtlasSize)
    end
    if type(reference) == "string" and reference ~= "" then
        return ns.SetTextureFile(texture, reference, wrapH, wrapV)
    end
    return false
end

function ns.ApplyPortraitRingTexture(texture, reference)
    -- Rings are complete images; keep native atlas coordinates and avoid wrapping.
    if type(reference) == "table" and reference.atlas and texture.SetAtlas then
        return pcall(texture.SetAtlas, texture, reference.atlas, reference.useAtlasSize == true)
    elseif type(reference) == "string" then
        return ns.SetTextureFile(texture, reference)
    end
    return false
end

local CONTROLLER_GLYPHS = {
    back = {
        xbox = { atlases = { "gamepad_ltr_b_64", "Gamepad_Ltr_B_64" }, file = "Interface\\Gamepad\\gamepadltr.blp" },
        playstation = { atlases = { "gamepad_shp_circle_64", "Gamepad_Shp_Circle_64" }, file = "Interface\\Gamepad\\gamepadshp.blp" },
        nintendo = { atlases = { "gamepad_rev_a_64", "Gamepad_Rev_A_64" }, file = "Interface\\Gamepad\\gamepadrev.blp" },
    },
    select = {
        xbox = { atlases = { "gamepad_ltr_a_64", "Gamepad_Ltr_A_64" }, file = "Interface\\Gamepad\\gamepadltr.blp" },
        playstation = { atlases = { "gamepad_shp_cross_64", "Gamepad_Shp_Cross_64" }, file = "Interface\\Gamepad\\gamepadshp.blp" },
        nintendo = { atlases = { "gamepad_rev_b_64", "Gamepad_Rev_B_64" }, file = "Interface\\Gamepad\\gamepadrev.blp" },
    },
}

function ns.ApplyControllerGlyph(texture, action, style)
    local choices = CONTROLLER_GLYPHS[action]
    local reference = choices[style] or choices.xbox
    local applied, left, right, top, bottom = ns.ApplyAtlasCandidates(texture, reference.atlases, false)
    if applied then
        if left then texture:SetTexCoord(left, right, top, bottom) end
        return true
    end
    if ns.SetTextureFile(texture, reference.file) and HasTextureFile(texture) then
        texture:SetTexCoord(0, 1, 0, 1)
        return true
    end
    return false
end

-- The logo artwork occupies 750x202 pixels in a losslessly padded 1024x256 TGA.
ns.MENU_LOGO_ASPECT = 750 / 202
function ns.CreateMenuLogo(parent)
    local logo = parent:CreateTexture(nil, "ARTWORK", nil, 4)
    logo:SetTexture("Interface\\AddOns\\GnomeLevelUp\\Textures\\logo-nobot.tga", "CLAMP", "CLAMP")
    logo:SetTexCoord(0, 750 / 1024, 0, 202 / 256)
    return logo
end
