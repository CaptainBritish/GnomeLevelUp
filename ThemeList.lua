local ADDON_NAME, ns = ...

local TEXTURE_ROOT = "Interface\\AddOns\\GnomeLevelUp\\Textures\\"
local function Texture(path)
    return TEXTURE_ROOT .. path:gsub("/", string.char(92))
end

local function Atlas(name, useAtlasSize)
    return { atlas = name, useAtlasSize = useAtlasSize == true }
end
ns.AtlasTexture = Atlas

-- --------------------------------------------------------------------------
-- Selectable asset registries
-- --------------------------------------------------------------------------

local PORTRAIT_RING_TEXTURES = {
    NONE = { label = "No portrait ring", texture = nil, scale = 1.10, offsetX = 0, offsetY = 0 },
    ALLIANCE = { label = "Alliance ring", texture = Texture("Backgrounds/ally-circle-frame.tga"), scale = 1.10, offsetX = 0, offsetY = 0 },
    HORDE = { label = "Horde ring", texture = Texture("Backgrounds/horde-circle-frame.tga"), scale = 1.10, offsetX = 0, offsetY = 0 },
    STEEL = { label = "Steel ring", texture = Texture("Backgrounds/circle-frame.tga"), glintRadius = .43, scale = 1.10, offsetX = 0, offsetY = 0 },
    COPPER = { label = "Copper ring", texture = Texture("Backgrounds/copper-circle-frame.tga"), glintRadius = .43, scale = 1.10, offsetX = 0, offsetY = 0 },
}
ns.PORTRAIT_RING_TEXTURES = PORTRAIT_RING_TEXTURES
ns.PORTRAIT_RING_CHOICES = {
    { value = "NONE", label = "No portrait ring" },
    { value = "ALLIANCE", label = "Alliance ring" },
    { value = "HORDE", label = "Horde ring" },
    { value = "COPPER", label = "Copper ring" },
    { value = "STEEL", label = "Steel ring" },
}
function ns.GetPortraitRingReference(name)
    local ring = PORTRAIT_RING_TEXTURES[name]
    return ring and ring.texture
end

local FRAME_TEXTURES = {
    TRELLIS = {
        label = "Trellis", cornerSize = 92, edgeSize = 39,
        cornerSizes = {
            topLeft = { width = 92, height = 69 },
            topRight = { width = 92, height = 69 },
            bottomLeft = { width = 113, height = 77 },
            bottomRight = { width = 113, height = 77 },
        },
        topLeft = Texture("Backgrounds/Trellis/trellis-tl.tga"),
        bottomLeft = Texture("Backgrounds/Trellis/trellis-bl.tga"),
        top = Texture("Backgrounds/Trellis/trellis-top.tga"),
        left = Texture("Backgrounds/Trellis/trellis-side.tga"),
        transforms = {
            bottomLeft = { rotation = 0, flipX = false, flipY = false },
            bottomRight = { rotation = 0, flipX = true, flipY = false },
            left = { rotation = 0, flipX = false, flipY = false },
            right = { rotation = 0, flipX = true, flipY = false },
        },
    },
    BLACK_METAL = {
        label = "Black Metal", cornerSize = 120, edgeSize = 40,
        topLeft = Texture("Backgrounds/Metal/metalblack-tl.tga"),
        top = Texture("Backgrounds/Metal/metalblack-top.tga"),
        left = Texture("Backgrounds/Metal/metalblack-left.tga"),
    },
    WOOD_PANEL = {
        label = "Wood Panel", cornerSize = 100, edgeSize = 27,
        topLeft = Texture("Backgrounds/Wood/wood-corner.tga"),
        top = Texture("Backgrounds/Wood/wood-top.tga"),
        left = Texture("Backgrounds/Wood/wood-left.tga"),
    },
    ALLIANCE = {
        label = "Alliance", cornerSize = 163, edgeSize = 28,
        topLeft = Texture("Backgrounds/Alliance/allyframe-corner.tga"),
        top = Texture("Backgrounds/Alliance/allyframe-top.tga"),
        left = Texture("Backgrounds/Alliance/allyframe-side.tga"),
    },
    HORDE = {
        label = "Horde", cornerSize = 163, edgeSize = 28,
        topLeft = Texture("Backgrounds/Horde/hordecorner.tga"),
        top = Texture("Backgrounds/Horde/hordetop.tga"),
        left = Texture("Backgrounds/Horde/hordeside.tga"),
    },
    GNOMEREGAN = {
        label = "Gnomeregan", cornerSize = 163, edgeSize = 26,
        topLeft = Texture("Backgrounds/Gnome Metal/gnomer-corner.tga"),
        top = Texture("Backgrounds/Gnome Metal/gnomer-top.tga"),
        left = Texture("Backgrounds/Gnome Metal/gnomer-side.tga"),
    },
}
ns.FRAME_TEXTURES = FRAME_TEXTURES
ns.FRAME_CHOICES = {
    { value = "TRELLIS", label = "Trellis" },
    { value = "BLACK_METAL", label = "Black Metal" },
    { value = "WOOD_PANEL", label = "Wood Panel" },
    { value = "ALLIANCE", label = "Alliance" },
    { value = "HORDE", label = "Horde" },
    { value = "GNOMEREGAN", label = "Gnomeregan" },
}
function ns.GetFrameReference(name)
    return FRAME_TEXTURES[name]
end

local BACKGROUND_TEXTURES = {
    -- Interface/Glues/CharacterSelect/GlueAnnouncementPopupBackground.blp
    SCRATCHED_STONE = { label = "Scratched Stone", center = 3775278, width = 512, height = 512, defaultStyle = "fill", defaultHue = { 176/255, 176/255, 176/255 } },
    -- Interface/FrameGeneral/UIFrameMarineBackground.blp
    CORAL = { label = "Coral", center = 2921659, width = 512, height = 512, defaultStyle = "tile" },
    SOLID = { label = "Solid Colour", center = "Interface\\Buttons\\WHITE8X8", defaultStyle = "stretch" },
    BLACK_METAL = { label = "Black Metal", center = Texture("Backgrounds/Metal/warwithinbackground.tga"), width = 256, height = 256 },
    WOOD_PANEL = { label = "Wood Panel", center = Texture("Backgrounds/Wood/uiframehordebackground.tga"), width = 256, height = 256 },
    ALLIANCE = { label = "Alliance Brick", center = Texture("Backgrounds/Alliance/allyframe-bg.tga"), width = 256, height = 256, defaultStyle = "tile" },
    GNOMEREGAN = { label = "Gnomeregan", center = Texture("Backgrounds/Gnome Metal/gnomer-bg.tga"), width = 400, height = 400, defaultStyle = "fill" },
}
ns.BACKGROUND_TEXTURES = BACKGROUND_TEXTURES
ns.BACKGROUND_TEXTURE_CHOICES = {
    { value = "SCRATCHED_STONE", label = "Scratched Stone" },
    { value = "CORAL", label = "Coral" },
    { value = "SOLID", label = "Solid Colour" },
    { value = "BLACK_METAL", label = "Black Metal" },
    { value = "WOOD_PANEL", label = "Wood Panel" },
    { value = "ALLIANCE", label = "Alliance Brick" },
    { value = "GNOMEREGAN", label = "Gnomeregan" },
}
function ns.GetBackgroundReference(name)
    return BACKGROUND_TEXTURES[name]
end

-- --------------------------------------------------------------------------
-- Theme declarations
-- --------------------------------------------------------------------------

local THEME_DEFINITIONS = {
    { value = "Trellis", label = "Trellis", portraitRing = "COPPER", frame = "TRELLIS", background = "WOOD_PANEL", backgroundStyle = "tile" },
    { value = "Black Metal", label = "Black Metal", portraitRing = "NONE", frame = "BLACK_METAL", background = "BLACK_METAL", backgroundStyle = "tile" },
    { value = "Wood Panel", label = "Wood Panel", portraitRing = "COPPER", frame = "WOOD_PANEL", background = "WOOD_PANEL", backgroundStyle = "tile" },
    { value = "Alliance", label = "Alliance", portraitRing = "ALLIANCE", frame = "ALLIANCE", background = "ALLIANCE", backgroundStyle = "tile" },
    { value = "Horde", label = "Horde", portraitRing = "HORDE", frame = "HORDE", background = "WOOD_PANEL", backgroundStyle = "tile" },
    { value = "Gnomeregan", label = "Gnomeregan", portraitRing = "STEEL", frame = "GNOMEREGAN", background = "GNOMEREGAN", backgroundStyle = "fill" },
}

ns.THEME_CHOICES = {
    { value = "MODERN", label = "Modern" },
    { value = "Black Metal", label = "Black Metal" },
    { value = "Wood Panel", label = "Wood Panel" },
    { value = "Alliance", label = "Alliance" },
    { value = "Horde", label = "Horde" },
    { value = "Gnomeregan", label = "Gnomeregan" },
    { value = "Trellis", label = "Trellis" },
}

local function Copy(value)
    if type(value) ~= "table" then return value end
    local out = {}
    for key, child in pairs(value) do out[key] = Copy(child) end
    return out
end

local SHARED_TRANSFORMS = {
    topLeft = { rotation = 0, flipX = false, flipY = false },
    top = { rotation = 0, flipX = false, flipY = false },
    topRight = { rotation = 0, flipX = true, flipY = false },
    left = { rotation = 0, flipX = false, flipY = false },
    center = { rotation = 0, flipX = false, flipY = false },
    right = { rotation = 0, flipX = true, flipY = false },
    bottomLeft = { rotation = 90, flipX = false, flipY = false },
    bottom = { rotation = 0, flipX = false, flipY = true },
    bottomRight = { rotation = 180, flipX = false, flipY = false },
}

-- Frame-specific defaults also apply when selecting a frame independently.
function ns.GetFrameTransforms(frameName)
    local transforms = Copy(SHARED_TRANSFORMS)
    local frame = FRAME_TEXTURES[frameName]
    for key, transform in pairs(frame and frame.transforms or {}) do
        transforms[key] = Copy(transform)
    end
    return transforms
end

local function Appearance(ringName, backgroundStyle)
    local ring = PORTRAIT_RING_TEXTURES[ringName] or PORTRAIT_RING_TEXTURES.NONE
    return {
        playerPortraitPosition = { x = 0, y = 0 },
        playerPortraitScale = 1.0,
        portraitRingEnabled = ring.texture ~= nil,
        portraitRingTexture = ring.texture,
        portraitRingChoice = PORTRAIT_RING_TEXTURES[ringName] and ringName or "NONE",
        portraitRingScale = ring.scale or 1.10,
        portraitRingOffset = { x = ring.offsetX or 0, y = ring.offsetY or 0 },
        bgOpacity = 0.95,
        backgroundColor = { 0, 0, 0 },
        frameColor = { 1, 1, 1 },
        portraitRingColor = { 1, 1, 1 },
        backgroundStyle = backgroundStyle or "tile",
        backgroundFillMode = backgroundStyle == "tile" and "tile" or "scale",
        backgroundTextureColors = {
            topLeft = { 1, 1, 1 }, top = { 1, 1, 1 }, topRight = { 1, 1, 1 },
            left = { 1, 1, 1 }, center = { 1, 1, 1 }, right = { 1, 1, 1 },
            bottomLeft = { 1, 1, 1 }, bottom = { 1, 1, 1 }, bottomRight = { 1, 1, 1 },
        },
        backgroundTextureTransforms = Copy(SHARED_TRANSFORMS),
        customFontPath = false,
        frameStrata = "HIGH",
        framePosition = { point = "CENTER", relativePoint = "CENTER", x = 0, y = 90 },
        lockFramePosition = false,
        sectionPadding = 8,
        scale = 1.0,
        compactMode = false,
    }
end

local function ResolveTheme(frameName, backgroundName, ringName, style, value, label)
    local frame = FRAME_TEXTURES[frameName]
    local background = BACKGROUND_TEXTURES[backgroundName]
    if not frame or not background then return nil end
    local textures = {
        topLeft = frame.topLeft, top = frame.top, topRight = frame.topRight or frame.topLeft,
        left = frame.left, center = background.center, right = frame.right or frame.left,
        bottomLeft = frame.bottomLeft or frame.topLeft, bottom = frame.bottom or frame.top,
        bottomRight = frame.bottomRight or frame.bottomLeft or frame.topLeft,
    }
    local appearance = Appearance(ringName or "NONE", style or background.defaultStyle or "tile")
    appearance.backgroundTextureTransforms = ns.GetFrameTransforms(frameName)
    return {
        value = value or "CUSTOM", label = label or "Custom",
        frameName = frameName, backgroundName = backgroundName,
        cornerSize = frame.cornerSize, cornerSizes = Copy(frame.cornerSizes),
        edgeSize = frame.edgeSize, edgeMaskInset = frame.edgeMaskInset or 5,
        textures = textures,
        appearance = appearance,
    }
end

-- Resolved declarations are read-only. Mutable appearance settings are copied
-- into the player's DB by the selection helpers, never written into this cache.
local compositeThemes = {}
function ns.GetCompositeTheme(frameName, backgroundName)
    if not FRAME_TEXTURES[frameName] or not BACKGROUND_TEXTURES[backgroundName] then return nil end
    local frames = compositeThemes[frameName]
    if not frames then frames = {}; compositeThemes[frameName] = frames end
    local theme = frames[backgroundName]
    if not theme then
        theme = ResolveTheme(frameName, backgroundName, "NONE", nil)
        frames[backgroundName] = theme
    end
    return theme
end

ns.CUSTOM_BACKGROUND_THEMES = {}
for _, definition in ipairs(THEME_DEFINITIONS) do
    ns.CUSTOM_BACKGROUND_THEMES[#ns.CUSTOM_BACKGROUND_THEMES + 1] = ResolveTheme(
        definition.frame, definition.background, definition.portraitRing,
        definition.backgroundStyle, definition.value, definition.label)
end

-- Public helper for migration and callers that need a named declaration.
function ns.GetThemeDefinition(value)
    for _, definition in ipairs(THEME_DEFINITIONS) do
        if definition.value == value then return definition end
    end
end

-- A pack's folder and local ID form the saved key for its theme and custom assets.
local PACK_PREFIX = "GLUTheme:"
local registeredPacks = {}
function ns.IsThemePackKey(key)
    return type(key) == "string" and key:sub(1, #PACK_PREFIX) == PACK_PREFIX
end

local function MissingPackAsset(registry, key)
    return not registry[key] and ns.IsThemePackKey(key)
end

function ns.GetEffectiveBackgroundMode()
    local db = ns.db
    if not db then return "MODERN" end
    if db.backgroundMode == "CUSTOM" and (MissingPackAsset(registeredPacks, db.backgroundTheme)
        or MissingPackAsset(FRAME_TEXTURES, db.frameChoice)
        or MissingPackAsset(BACKGROUND_TEXTURES, db.backgroundChoice)) then return "MODERN" end
    return db.backgroundMode
end

function ns.HasPortraitRingArtwork()
    local db = ns.db
    return db and db.portraitRingEnabled == true and not MissingPackAsset(PORTRAIT_RING_TEXTURES, db.portraitRingChoice)
end

function ns.GetSelectedPortraitRingReference()
    local db = ns.db or {}
    local reference = db.portraitRingTexture
    if ns.IsThemePackKey(db.portraitRingChoice) or type(reference) ~= "string" or reference == "" then
        return ns.GetPortraitRingReference(db.portraitRingChoice)
    end
    return reference
end

local function PackTexture(addonName, path)
    if type(path) ~= "string" then return nil end
    path = path:gsub("/", "\\")
    if #path > 220 or not path:match("^[%w_][%w_%. %-\\]*$") or path:find("..", 1, true) then return nil end
    local extension = path:lower():match("%.(%a+)$")
    if extension == "tga" or extension == "blp" then return "Interface\\AddOns\\" .. addonName .. "\\" .. path end
end

local function InRange(value, minimum, maximum)
    return type(value) == "number" and value >= minimum and value <= maximum
end

local function ReadHue(hue)
    if type(hue) == "table" and InRange(hue[1], 0, 1) and InRange(hue[2], 0, 1) and InRange(hue[3], 0, 1) then
        return { hue[1], hue[2], hue[3] }
    end
end

local function ReadPackFrame(addonName, frame)
    if type(frame) ~= "table" then return nil end
    local cornerSize, edgeSize = frame.cornerSize or 48, frame.edgeSize or 16
    local edgeMaskInset = frame.edgeMaskInset or 5
    local hue = ReadHue(frame.hue)
    if not InRange(cornerSize, 1, 1024) or not InRange(edgeSize, 1, cornerSize) or not InRange(edgeMaskInset, 0, 64)
        or (frame.hue ~= nil and not hue) then return nil end
    local result = { cornerSize = cornerSize, edgeSize = edgeSize, edgeMaskInset = edgeMaskInset,
        defaultHue = hue, transforms = {}, cornerSizes = {} }
    for piece, transform in pairs(SHARED_TRANSFORMS) do
        if piece ~= "center" and frame[piece] ~= nil then
            result[piece] = PackTexture(addonName, frame[piece])
            if not result[piece] then return nil end
            -- Authored pieces already face the right way. Reused pieces mirror as usual.
            if transform.rotation ~= 0 or transform.flipX or transform.flipY then
                result.transforms[piece] = { rotation = 0, flipX = false, flipY = false }
            end
        end
    end
    if result.bottomLeft and not result.bottomRight then
        result.transforms.bottomRight = { rotation = 0, flipX = true, flipY = false }
    end
    if frame.transforms ~= nil and type(frame.transforms) ~= "table" then return nil end
    for piece, transform in pairs(frame.transforms or {}) do
        if piece == "center" or not SHARED_TRANSFORMS[piece] or type(transform) ~= "table"
            or not InRange(transform.rotation or 0, -360, 360)
            or (transform.flipX ~= nil and type(transform.flipX) ~= "boolean")
            or (transform.flipY ~= nil and type(transform.flipY) ~= "boolean") then return nil end
        result.transforms[piece] = { rotation = transform.rotation or 0, flipX = transform.flipX == true, flipY = transform.flipY == true }
    end
    if frame.cornerSizes ~= nil and type(frame.cornerSizes) ~= "table" then return nil end
    for corner, size in pairs(frame.cornerSizes or {}) do
        if (corner ~= "topLeft" and corner ~= "topRight" and corner ~= "bottomLeft" and corner ~= "bottomRight")
            or type(size) ~= "table" or not InRange(size.width, 1, 1024) or not InRange(size.height, 1, 1024) then return nil end
        result.cornerSizes[corner] = { width = size.width, height = size.height }
    end
    if result.topLeft and result.top and result.left then return result end
end

local function ReadPackBackground(addonName, background)
    if type(background) ~= "table" then return nil end
    local texture = PackTexture(addonName, background.texture)
    local style = background.style or "tile"
    local hue, opacity = ReadHue(background.hue), background.opacity or 1
    if not texture or (style ~= "tile" and style ~= "fill" and style ~= "stretch")
        or not InRange(opacity, 0, 1) or (background.hue ~= nil and not hue) then return nil end
    if (style == "fill" or background.width ~= nil or background.height ~= nil)
        and not (InRange(background.width, 1, 8192) and InRange(background.height, 1, 8192)) then return nil end
    return { center = texture, defaultStyle = style, width = background.width, height = background.height,
        defaultHue = hue, defaultOpacity = opacity }
end

local function ReadPackRing(addonName, ring)
    if type(ring) ~= "table" then return nil end
    local texture = PackTexture(addonName, ring.texture)
    local scale = ring.scale or 1.10
    local offsetX, offsetY = ring.offsetX or 0, ring.offsetY or 0
    local hue, glintRadius = ReadHue(ring.hue), ring.glintRadius or .5
    if not texture or not InRange(scale, .5, 2) or not InRange(offsetX, -300, 300) or not InRange(offsetY, -300, 300)
        or not InRange(glintRadius, 0, 1) or (ring.hue ~= nil and not hue) then return nil end
    return { texture = texture, scale = scale, offsetX = offsetX, offsetY = offsetY,
        glintRadius = glintRadius, defaultHue = hue }
end

local function AddPackChoice(registry, choices, key, label, asset)
    asset.label = label
    registry[key] = asset
    choices[#choices + 1] = { value = key, label = label, literal = true }
end

local SOUND_CUES = {
    levelUp = true, portraitImpact = true, starburst = true, idleMotes = true,
    statGlint = true, fireworks = true, fadeIn = true, fadeOut = true,
}

local function ReadPackSounds(sounds)
    if sounds == nil then return {} end
    if type(sounds) ~= "table" then return nil end
    local result = {}
    for cue, sound in pairs(sounds) do
        if not SOUND_CUES[cue] or type(sound) ~= "table" then return nil end
        local media, kit, volume, loop = sound.media, sound.soundKit, sound.volume, sound.loopSeconds
        if media ~= nil then
            if kit ~= nil or type(media) ~= "string" or not media:find("%S") or #media > 100 or media:find("%c") then return nil end
        elseif not InRange(kit, 1, 2147483647) or kit % 1 ~= 0 then return nil end
        if volume ~= nil and not InRange(volume, 0, 1) then return nil end
        if cue == "idleMotes" then
            if not InRange(loop, .1, 60) then return nil end
        elseif loop ~= nil then return nil end
        result[cue] = { media = media, soundKit = kit, volume = volume, loopSeconds = loop }
    end
    return result
end

local function RegisterTheme(addonName, id, definition)
    if type(addonName) ~= "string" or not addonName:match("^[%w_%-]+$")
        or type(id) ~= "string" or not id:match("^[%w_%-]+$") then return nil, "Invalid addon folder or theme ID." end
    local key = PACK_PREFIX .. addonName:lower() .. ":" .. id:lower()
    if #key > 80 then return nil, "Theme key exceeds 80 characters." end
    if registeredPacks[key] then return nil, "Theme ID is already registered." end
    local label = type(definition) == "table" and definition.label
    if type(label) ~= "string" or not label:find("%S") or #label > 80 or label:find("%c") then
        return nil, "A theme requires a display label of up to 80 bytes."
    end
    local opacity = definition.opacity or .95
    if not InRange(opacity, 0, 1) then return nil, "Invalid theme opacity." end
    local sounds = ReadPackSounds(definition.sounds)
    if not sounds then return nil, "Invalid theme sounds." end

    local frameName, backgroundName, ringName = definition.frame, definition.background, definition.portraitRing or "NONE"
    local frame = ReadPackFrame(addonName, frameName)
    local background = ReadPackBackground(addonName, backgroundName)
    local ring = ReadPackRing(addonName, ringName)
    if not frame and not FRAME_TEXTURES[frameName] then return nil, "Invalid theme frame." end
    if not background and not BACKGROUND_TEXTURES[backgroundName] then return nil, "Invalid theme background." end
    if not ring and not PORTRAIT_RING_TEXTURES[ringName] then return nil, "Invalid theme portrait ring." end

    if frame then frameName = key; AddPackChoice(FRAME_TEXTURES, ns.FRAME_CHOICES, key, label, frame) end
    if background then backgroundName = key; AddPackChoice(BACKGROUND_TEXTURES, ns.BACKGROUND_TEXTURE_CHOICES, key, label, background) end
    if ring then ringName = key; AddPackChoice(PORTRAIT_RING_TEXTURES, ns.PORTRAIT_RING_CHOICES, key, label, ring) end
    local resolved = ResolveTheme(frameName, backgroundName, ringName, nil, key, label)
    resolved.appearance.bgOpacity = opacity
    THEME_DEFINITIONS[#THEME_DEFINITIONS + 1] = {
        value = key, label = label, frame = frameName, background = backgroundName, portraitRing = ringName,
        sounds = sounds,
    }
    ns.CUSTOM_BACKGROUND_THEMES[#ns.CUSTOM_BACKGROUND_THEMES + 1] = resolved
    ns.THEME_CHOICES[#ns.THEME_CHOICES + 1] = { value = key, label = label, literal = true }
    registeredPacks[key] = true
    if ns.db and ns.ApplyCurrentAppearance then ns.ApplyCurrentAppearance() end
    return key
end

GnomeLevelUpThemeAPI = { version = 1, RegisterTheme = RegisterTheme }
