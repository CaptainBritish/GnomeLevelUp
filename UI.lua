local ADDON_NAME, ns = ...

-- Keep the panel readable at different animation speeds and resolutions.
local BASE_BG_FADE_DURATION = 0.25
local BASE_CONTENT_DELAY = 0.15
local BASE_CONTENT_FADE_DURATION = 0.30
local BASE_STAT_STAGGER_BASE = 0.30
local BASE_STAT_STAGGER_STEP = 0.08
local BASE_STAT_SLIDE_DURATION = 0.30
local STAT_SLIDE_DISTANCE_X = 50      -- pixels each stat line slides in from
local STAT_LINE_HEIGHT = 26
local DEFAULT_FONT_PATH = "Fonts\\FRIZQT__.TTF"

local FRAME_WIDTH = 460
local TEXT_WIDTH = FRAME_WIDTH - 60
local PAD_TOP, PAD_BOTTOM = 14, 24
local ICON_SIZE = 60
local RING_SIZE = ICON_SIZE + 6

local function Speed()
    local mult = (ns.db and ns.db.animSpeedMultiplier) or 1.0
    if mult <= 0 then mult = 1.0 end
    return mult
end

local frame = CreateFrame("Frame", "GnomeLevelUpFrame", UIParent)
frame:SetSize(FRAME_WIDTH, 300) -- height is recomputed to fit the content on every show
frame:SetPoint("CENTER", UIParent, "CENTER", 0, 90)
frame:SetFrameStrata("HIGH")
frame:SetClampedToScreen(true)
frame:EnableMouse(true)
frame:SetMovable(true)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", frame.StartMoving)
frame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    if not ns.db then return end
    local point, _, relativePoint, x, y = self:GetPoint(1)
    if point and relativePoint and x and y then
        ns.db.framePosition = {
            point = point,
            relativePoint = relativePoint,
            x = x,
            y = y,
        }
    end
end)
ns.levelUpFrame = frame
frame:Hide()

local closeButton = CreateFrame("Button", nil, frame)
closeButton:SetSize(30, 30)
closeButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -8, -8)
closeButton:SetFrameLevel(frame:GetFrameLevel() + 10)
local closeText = closeButton:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
closeText:SetAllPoints()
closeText:SetJustifyH("CENTER")
closeText:SetJustifyV("MIDDLE")
closeText:SetText("X")
closeText:SetTextColor(1, 1, 1, 1)
closeButton:SetScript("OnClick", function() ns.CloseLevelUp() end)

function ns.ApplyFrameStrata(strata)
    local ok = pcall(frame.SetFrameStrata, frame, strata or "HIGH")
    if not ok then
        frame:SetFrameStrata("HIGH")
    end
end

function ns.PositionFrame(f)
    local position = ns.db and ns.db.framePosition
    f:ClearAllPoints()
    if position and position.point and position.relativePoint then
        f:SetPoint(position.point, UIParent, position.relativePoint, position.x or 0, position.y or 90)
    else
        f:SetPoint("CENTER", UIParent, "CENTER", 0, 90)
    end
    return false
end

local BG_LAYERS = 28
local BG_FADE_FRACTION = 0.10 -- fade band thickness per side, as a fraction of that dimension

local bg = CreateFrame("Frame", nil, frame)
bg:SetAllPoints(frame)
bg.layers = {}
for k = 1, BG_LAYERS do
    local layer = bg:CreateTexture(nil, "BACKGROUND")
    layer:SetColorTexture(0, 0, 0, 0)
    bg.layers[k] = layer
end

local function LayoutBackground()
    local w, h = frame:GetWidth(), frame:GetHeight()
    local fadeX, fadeY = w * BG_FADE_FRACTION, h * BG_FADE_FRACTION
    for k, layer in ipairs(bg.layers) do
        local insetX = fadeX * (k - 1) / BG_LAYERS
        local insetY = fadeY * (k - 1) / BG_LAYERS
        layer:ClearAllPoints()
        layer:SetPoint("TOPLEFT", bg, "TOPLEFT", insetX, -insetY)
        layer:SetPoint("BOTTOMRIGHT", bg, "BOTTOMRIGHT", -insetX, insetY)
    end
end
LayoutBackground()

local function SmoothStep(t)
    return t * t * (3 - 2 * t)
end

    -- Keep the background opacity separate from the content animation.
function ns.ApplyBackgroundOpacity(opacity)
    opacity = math.max(0, math.min(0.995, opacity or 0.70))
    local previousCumulative = 0
    for k = 1, BG_LAYERS do
        local target = opacity * SmoothStep(k / BG_LAYERS)
        local layerAlpha = 1 - (1 - target) / (1 - previousCumulative)
        if layerAlpha < 0 then layerAlpha = 0 end
        bg.layers[k]:SetColorTexture(0, 0, 0, layerAlpha)
        previousCumulative = target
    end
end
ns.ApplyBackgroundOpacity(0.70)

local content = CreateFrame("Frame", nil, frame)
content:SetAllPoints(frame)

    -- Store every text layer so a font change updates the whole panel.
content.fontElements = {}
local function RegisterFontElement(fs, sizeOverride, flagsOverride)
    local _, size, flags = fs:GetFont()
    content.fontElements[#content.fontElements + 1] = {
        fs = fs,
        size = sizeOverride or size,
        flags = flagsOverride or flags or "",
    }
end

function ns.ApplyFont(fontPath)
    fontPath = fontPath or DEFAULT_FONT_PATH
    for _, entry in ipairs(content.fontElements) do
        entry.fs:SetFont(fontPath, entry.size, entry.flags)
    end
end

local GLOW_ALPHA = 0.15
local GLOW_DIRS = {
    { -1, 0 }, { 1, 0 }, { 0, -1 }, { 0, 1 },
    { -1, -1 }, { 1, 1 }, { -1, 1 }, { 1, -1 },
}

local function NewText(parent, template, radius)
    local main = parent:CreateFontString(nil, "OVERLAY", template)
    main.glows = {}
    for i, dir in ipairs(GLOW_DIRS) do
        local glow = parent:CreateFontString(nil, "ARTWORK", template)
        glow:SetPoint("TOPLEFT", main, "TOPLEFT", dir[1] * radius, dir[2] * radius)
        glow:SetPoint("TOPRIGHT", main, "TOPRIGHT", dir[1] * radius, dir[2] * radius)
        glow:SetAlpha(GLOW_ALPHA)
        main.glows[i] = glow
    end
    return main
end

    -- Apply the same property to the main text and its glow copies.
local function ApplyToTextLayers(text, method, ...)
    text[method](text, ...)
    for _, glow in ipairs(text.glows) do
        glow[method](glow, ...)
    end
end

local function RegisterGlowFont(main, size, flags)
    RegisterFontElement(main, size, flags)
    for _, glow in ipairs(main.glows) do
        RegisterFontElement(glow, size, flags)
    end
end

local function ColorOf(key)
    local c = ns.db and ns.db.colors and ns.db.colors[key]
    return c or ns.defaults.colors[key]
end

local function Hex(c)
    return string.format("|cff%02x%02x%02x",
        math.floor(c[1] * 255 + 0.5), math.floor(c[2] * 255 + 0.5), math.floor(c[3] * 255 + 0.5))
end

local function SetTextColorKey(main, key)
    local c = ColorOf(key)
    ApplyToTextLayers(main, "SetTextColor", c[1], c[2], c[3])
end

local CIRCLE_MASK = "Interface\\CharacterFrame\\TempPortraitAlphaMask"
local CLASS_ICON_SHEET = "Interface\\GLUES\\CHARACTERCREATE\\UI-CHARACTERCREATE-CLASSES"

content.classRing = content:CreateTexture(nil, "ARTWORK", nil, 1)
content.classRing:SetSize(RING_SIZE, RING_SIZE)
content.classRing:SetPoint("TOP", content, "TOP", 0, -PAD_TOP)
content.classRing:SetColorTexture(1, 0.82, 0.2, 1)

content.classIcon = content:CreateTexture(nil, "ARTWORK", nil, 2)
content.classIcon:SetSize(ICON_SIZE, ICON_SIZE)
content.classIcon:SetPoint("CENTER", content.classRing, "CENTER", 0, 0)
content.classIcon:SetTexture(CLASS_ICON_SHEET)

if content.CreateMaskTexture then
    local ringMask = content:CreateMaskTexture()
    ringMask:SetAllPoints(content.classRing)
    ringMask:SetTexture(CIRCLE_MASK, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    content.classRing:AddMaskTexture(ringMask)

    local iconMask = content:CreateMaskTexture()
    iconMask:SetAllPoints(content.classIcon)
    iconMask:SetTexture(CIRCLE_MASK, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    content.classIcon:AddMaskTexture(iconMask)
end

local FALLBACK_CLASS_COORDS = {
    WARRIOR = { 0, 0.25, 0, 0.25 },       MAGE = { 0.25, 0.5, 0, 0.25 },
    ROGUE = { 0.5, 0.75, 0, 0.25 },       DRUID = { 0.75, 1, 0, 0.25 },
    HUNTER = { 0, 0.25, 0.25, 0.5 },      SHAMAN = { 0.25, 0.5, 0.25, 0.5 },
    PRIEST = { 0.5, 0.75, 0.25, 0.5 },    WARLOCK = { 0.75, 1, 0.25, 0.5 },
    PALADIN = { 0, 0.25, 0.5, 0.75 },     DEATHKNIGHT = { 0.25, 0.5, 0.5, 0.75 },
    MONK = { 0.5, 0.75, 0.5, 0.75 },      DEMONHUNTER = { 0.75, 1, 0.5, 0.75 },
}

function ns.RefreshClassIcon()
    -- The portrait choice changes only the texture, not the layout.
    local portraitMode = ns.db and ns.db.portraitMode or "class"
    if portraitMode == "player" then
        content.classIcon:SetTexCoord(0, 1, 0, 1)
        if SetPortraitTexture then
            SetPortraitTexture(content.classIcon, "player")
        else
            content.classIcon:SetTexture("Interface\\CHARACTERFRAME\\TempPortrait")
        end
        content.classIcon:Show()
        content.classRing:Show()
        return
    end

    local _, classToken = UnitClass("player")
    local coords = (CLASS_ICON_TCOORDS and CLASS_ICON_TCOORDS[classToken])
        or FALLBACK_CLASS_COORDS[classToken]
    if coords then
        content.classIcon:SetTexture(CLASS_ICON_SHEET)
        content.classIcon:SetTexCoord(coords[1], coords[2], coords[3], coords[4])
        content.classIcon:Show()
        content.classRing:Show()
    else
        content.classIcon:Hide()
        content.classRing:Hide()
    end
end

-- The addon panel starts with the player's icon and level. Blizzard's own
-- congratulatory title is disabled separately in HideBlizzardLevelUp.lua.
content.title = NewText(content, "GameFontNormalHuge", 3)
content.title:SetPoint("TOP", content, "TOP", 0, -(PAD_TOP + RING_SIZE + 6))
ApplyToTextLayers(content.title, "SetText", "")
ApplyToTextLayers(content.title, "SetShown", false)
RegisterGlowFont(content.title)

content.levelText = NewText(content, "GameFontNormalLarge", 2)
content.levelText:SetPoint("TOP", content.classRing, "BOTTOM", 0, -6)
RegisterGlowFont(content.levelText)

content.statsHeader = NewText(content, "GameFontNormalLarge", 2)
content.statsHeader:SetPoint("TOP", content.levelText, "BOTTOM", 0, -22)
ApplyToTextLayers(content.statsHeader, "SetText", "Stats Gained")
RegisterGlowFont(content.statsHeader)

content.statsContainer = CreateFrame("Frame", nil, content)
content.statsContainer:SetPoint("TOP", content.statsHeader, "BOTTOM", 0, -10)
content.statsContainer:SetWidth(TEXT_WIDTH)
content.statsContainer:SetHeight(1)
content.statLinePool = {}

content.spellsHeader = NewText(content, "GameFontNormal", 2)
ApplyToTextLayers(content.spellsHeader, "SetText", "Abilities")
RegisterGlowFont(content.spellsHeader)

content.levelTimeText = NewText(content, "GameFontHighlightSmall", 1.5)
content.levelTimeText:SetWidth(TEXT_WIDTH)
content.levelTimeText:SetHeight(18)
ApplyToTextLayers(content.levelTimeText, "SetJustifyH", "CENTER")
ApplyToTextLayers(content.levelTimeText, "SetJustifyV", "TOP")
ApplyToTextLayers(content.levelTimeText, "SetTextColor", 0.25, 1.0, 0.25)
RegisterGlowFont(content.levelTimeText)
content.levelTimeText:SetPoint("BOTTOM", content.spellsHeader, "TOP", 0, 4)
content.levelTimeText:Hide()

local ABILITY_ICON_SIZE = 36
local ABILITY_ICON_GAP = 10
local ABILITY_COST_HEIGHT = 14
local ABILITY_COST_GAP = 1

local MONEY_ICON_PATHS = {
    gold = "Interface\\MoneyFrame\\UI-GoldIcon",
    silver = "Interface\\MoneyFrame\\UI-SilverIcon",
    copper = "Interface\\MoneyFrame\\UI-CopperIcon",
}

local function FormatTrainerCost(cost)
    cost = tonumber(cost)
    if not cost or cost <= 0 then return nil end

    local gold = math.floor(cost / 10000)
    local silver = math.floor((cost % 10000) / 100)
    local copper = cost % 100
    local parts = {}
    local function AddPart(amount, currency)
        if amount > 0 then
            parts[#parts + 1] = string.format("%d|T%s:10:10:0:0|t", amount, MONEY_ICON_PATHS[currency])
        end
    end
    AddPart(gold, "gold")
    AddPart(silver, "silver")
    AddPart(copper, "copper")
    return #parts > 0 and table.concat(parts, " ") or nil
end

local function FormatPlayedTime(seconds)
    seconds = math.max(0, math.floor(tonumber(seconds) or 0))
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local remainingSeconds = seconds % 60
    if hours > 0 then
        return string.format("Time this level: %dh %02dm", hours, minutes)
    elseif minutes > 0 then
        return string.format("Time this level: %dm %02ds", minutes, remainingSeconds)
    end
    return string.format("Time this level: %ds", remainingSeconds)
end

local function AbilityCellHeight()
    if ns.db and ns.db.showTrainerCosts then
        return ABILITY_ICON_SIZE + ABILITY_COST_GAP + ABILITY_COST_HEIGHT
    end
    return ABILITY_ICON_SIZE
end

content.abilityRow = CreateFrame("Frame", nil, content)
content.abilityRow:SetPoint("BOTTOM", content, "BOTTOM", 0, PAD_BOTTOM)
content.abilityRow:SetSize(TEXT_WIDTH, ABILITY_ICON_SIZE)
content.abilityIconPool = {}

content.weaponSkillsText = NewText(content, "GameFontHighlightSmall", 1.5)
content.weaponSkillsText:SetWidth(TEXT_WIDTH)
content.weaponSkillsText:SetHeight(36)
ApplyToTextLayers(content.weaponSkillsText, "SetJustifyH", "CENTER")
ApplyToTextLayers(content.weaponSkillsText, "SetJustifyV", "TOP")
ApplyToTextLayers(content.weaponSkillsText, "SetWordWrap", true)
RegisterGlowFont(content.weaponSkillsText)
content.weaponSkillsText:SetPoint("BOTTOM", content, "BOTTOM", 0, PAD_BOTTOM)
content.weaponSkillsText:Hide()

local function PositionAbilityRows()
    content.abilityRow:ClearAllPoints()
    if content.weaponSkillsText:IsShown() then
        content.abilityRow:SetPoint("BOTTOM", content.weaponSkillsText, "TOP", 0, 8)
    else
        content.abilityRow:SetPoint("BOTTOM", content, "BOTTOM", 0, PAD_BOTTOM)
    end
end

content.noAbilitiesText = NewText(content.abilityRow, "GameFontHighlightSmall", 1.5)
content.noAbilitiesText:SetPoint("CENTER", content.abilityRow, "CENTER", 0, 0)
RegisterGlowFont(content.noAbilitiesText)
ApplyToTextLayers(content.noAbilitiesText, "SetText", "No unlearned skills available")

content.spellsHeader:SetPoint("BOTTOM", content.abilityRow, "TOP", 0, 10)

-- Choose the direction used by each stat line animation.
local function LineDirection(index)
    local mode = (ns.db and ns.db.statSlideDirection) or "alternate"
    if mode == "left" then return -1 end
    if mode == "right" then return 1 end
    return (index % 2 == 1) and -1 or 1
end

local activeLineAnims = {}
local lineAnimDriver = CreateFrame("Frame")
lineAnimDriver:Hide()

local function EaseOutQuad(p) return 1 - (1 - p) * (1 - p) end
local function EaseInQuad(p) return p * p end

local function SetLineAlpha(fs, alpha)
    fs:SetAlpha(alpha)
    for _, glow in ipairs(fs.glows) do
        glow:SetAlpha(alpha * GLOW_ALPHA)
    end
end

local function SetLineShown(fs, shown)
    ApplyToTextLayers(fs, "SetShown", shown)
end

lineAnimDriver:SetScript("OnUpdate", function(self, elapsed)
    local stillActive = false
    for fs, anim in pairs(activeLineAnims) do
        anim.t = anim.t + elapsed
        if anim.t < anim.delay then
            stillActive = true
        else
            if not anim.started then
                anim.started = true
                SetLineAlpha(fs, 0)
                SetLineShown(fs, true)
            end
            local p = (anim.t - anim.delay) / anim.duration
            if p >= 1 then
                p = 1
                activeLineAnims[fs] = nil
            else
                stillActive = true
            end
            local x = anim.startX * (1 - EaseOutQuad(p))
            fs:ClearAllPoints()
            fs:SetPoint("TOP", anim.container, "TOP", x, anim.y)
            SetLineAlpha(fs, EaseInQuad(p))
        end
    end
    if not stillActive then
        self:Hide()
    end
end)

local function StartLineAnimation(fs, container, startX, y, delay, duration)
    if ns.db and ns.db.reducedMotion then
        activeLineAnims[fs] = nil
        fs:ClearAllPoints()
        fs:SetPoint("TOP", container, "TOP", 0, y)
        SetLineAlpha(fs, 1)
        SetLineShown(fs, true)
        return
    end
    activeLineAnims[fs] = { t = 0, delay = delay, duration = duration, startX = startX, container = container, y = y }
    fs:ClearAllPoints()
    fs:SetPoint("TOP", container, "TOP", startX, y)
    SetLineAlpha(fs, 0)
    SetLineShown(fs, false)
    lineAnimDriver:Show()
end

local function GetStatLine(index)
    local pool = content.statLinePool
    if pool[index] then return pool[index] end

    local fontPath = (ns.db and ns.db.customFontPath) or DEFAULT_FONT_PATH
    local fs = NewText(content.statsContainer, "GameFontHighlight", 2)
    fs:SetWidth(TEXT_WIDTH)
    ApplyToTextLayers(fs, "SetJustifyH", "CENTER")
    RegisterGlowFont(fs, 20, "")
    ApplyToTextLayers(fs, "SetFont", fontPath, 20, "")
    SetLineShown(fs, false)

    pool[index] = fs
    return fs
end

-- Ability icons share one animation setup so reduced motion can skip it cleanly.
local ABILITY_POP_DISTANCE = 24  -- how far below its resting spot an icon starts
local ABILITY_POP_START_SCALE = 0.4
local ABILITY_ICON_COLUMNS = math.max(1, math.floor((TEXT_WIDTH + ABILITY_ICON_GAP) / (ABILITY_ICON_SIZE + ABILITY_ICON_GAP)))

local activeIconAnims = {}
local iconAnimDriver = CreateFrame("Frame")
iconAnimDriver:Hide()

iconAnimDriver:SetScript("OnUpdate", function(self, elapsed)
    local stillActive = false
    for icon, anim in pairs(activeIconAnims) do
        anim.t = anim.t + elapsed
        if anim.t < anim.delay then
            stillActive = true
        else
            if not anim.started then
                anim.started = true
                icon:Show()
            end
            local p = (anim.t - anim.delay) / anim.duration
            if p >= 1 then
                p = 1
                activeIconAnims[icon] = nil
            else
                stillActive = true
            end
            local eased = EaseOutQuad(p)
            icon:ClearAllPoints()
            icon:SetPoint("CENTER", anim.container, "CENTER", anim.x,
                anim.y - anim.startY * (1 - eased))
            icon:SetScale(ABILITY_POP_START_SCALE + (1 - ABILITY_POP_START_SCALE) * eased)
            icon:SetAlpha(EaseInQuad(p))
        end
    end
    if not stillActive then
        self:Hide()
    end
end)

local function StartIconPop(icon, container, x, y, delay, duration)
    if ns.db and ns.db.reducedMotion then
        activeIconAnims[icon] = nil
        icon:ClearAllPoints()
        icon:SetPoint("CENTER", container, "CENTER", x, y)
        icon:SetScale(1)
        icon:SetAlpha(1)
        icon:Show()
        return
    end
    activeIconAnims[icon] = {
        t = 0, delay = delay, duration = duration, container = container,
        x = x, y = y, startY = ABILITY_POP_DISTANCE,
    }
    icon:ClearAllPoints()
    icon:SetPoint("CENTER", container, "CENTER", x, y - ABILITY_POP_DISTANCE)
    icon:SetScale(ABILITY_POP_START_SCALE)
    icon:SetAlpha(0)
    icon:Hide()
    iconAnimDriver:Show()
end

local function GetAbilityIcon(index)
    local pool = content.abilityIconPool
    if pool[index] then return pool[index] end

    local btn = CreateFrame("Button", nil, content.abilityRow)
    btn:SetSize(ABILITY_ICON_SIZE, ABILITY_ICON_SIZE)

    local tex = btn:CreateTexture(nil, "ARTWORK")
    tex:SetAllPoints()
    tex:SetTexCoord(0.08, 0.92, 0.08, 0.92) -- trim the default spell-icon border
    btn.icon = tex

    local costText = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    costText:SetSize(ABILITY_ICON_SIZE, ABILITY_COST_HEIGHT)
    costText:SetPoint("TOP", btn, "BOTTOM", 0, -ABILITY_COST_GAP)
    costText:SetJustifyH("CENTER")
    costText:SetJustifyV("TOP")
    costText:SetWordWrap(false)
    RegisterFontElement(costText, 10)
    costText:SetTextColor(1, 1, 1, 1)
    costText:Hide()
    btn.costText = costText

    local border = btn:CreateTexture(nil, "OVERLAY")
    border:SetAllPoints()
    border:SetColorTexture(1, 0.82, 0.2, 0.9)
    border:SetPoint("TOPLEFT", -1, 1)
    border:SetPoint("BOTTOMRIGHT", 1, -1)
    border:SetDrawLayer("BORDER")
    btn.border = border

    btn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        if self.spellID and GameTooltip.SetSpellByID then
            GameTooltip:SetSpellByID(self.spellID)
        elseif self.spellName then
            GameTooltip:SetText(self.spellName)
        end
        GameTooltip:Show()
    end)
    btn:SetScript("OnLeave", function() GameTooltip:Hide() end)
    btn:Hide()

    pool[index] = btn
    return btn
end

-- Fill the ability row with the current unlearned skills.
local function UpdateTrainerAbilityIcons(trainerAbilities)
    local pool = content.abilityIconPool
    local count = #trainerAbilities
    local speed = Speed()
    local staggerBase = BASE_STAT_STAGGER_BASE / speed
    local staggerStep = BASE_STAT_STAGGER_STEP / speed
    local popDuration = BASE_STAT_SLIDE_DURATION / speed

    if count == 0 then
        content.abilityRow:SetHeight(ABILITY_ICON_SIZE)
        for _, icon in ipairs(pool) do
            activeIconAnims[icon] = nil
            icon:Hide()
        end
        ApplyToTextLayers(content.noAbilitiesText, "SetText",
            ns.db and ns.db.showOnlyCurrentLevelSkills
                and "No new skills this level"
                or "No unlearned skills available")
        ApplyToTextLayers(content.noAbilitiesText, "Show")
        return
    end

    ApplyToTextLayers(content.noAbilitiesText, "Hide")

    local columns = math.min(count, ABILITY_ICON_COLUMNS)
    local rows = math.ceil(count / ABILITY_ICON_COLUMNS)
    local totalWidth = columns * ABILITY_ICON_SIZE + (columns - 1) * ABILITY_ICON_GAP
    local cellHeight = AbilityCellHeight()
    local totalHeight = rows * cellHeight + (rows - 1) * ABILITY_ICON_GAP
    content.abilityRow:SetHeight(totalHeight)
    local startX = -totalWidth / 2 + ABILITY_ICON_SIZE / 2
    local startY = totalHeight / 2 - cellHeight / 2

    for i, spell in ipairs(trainerAbilities) do
        local icon = GetAbilityIcon(i)
        icon.spellID = spell.id
        icon.spellName = spell.name
        local formattedCost = ns.db and ns.db.showTrainerCosts and FormatTrainerCost(spell.cost)
        if formattedCost then
            icon.costText:SetText(formattedCost)
            icon.costText:Show()
        else
            icon.costText:SetText("")
            icon.costText:Hide()
        end
        local texture = spell.icon or (spell.id and (
            (C_Spell and C_Spell.GetSpellTexture and C_Spell.GetSpellTexture(spell.id))
            or (GetSpellTexture and GetSpellTexture(spell.id))
        ))
        icon.icon:SetTexture(texture or "Interface\\Icons\\INV_Misc_QuestionMark")

        local zeroIndex = i - 1
        local column = zeroIndex % ABILITY_ICON_COLUMNS
        local row = math.floor(zeroIndex / ABILITY_ICON_COLUMNS)
        local x = startX + column * (ABILITY_ICON_SIZE + ABILITY_ICON_GAP)
        local iconY = startY + (cellHeight - ABILITY_ICON_SIZE) / 2
            - row * (cellHeight + ABILITY_ICON_GAP)
        local delay = staggerBase + (i - 1) * staggerStep
        StartIconPop(icon, content.abilityRow, x, iconY, delay, popDuration)
    end

    for i = count + 1, #pool do
        activeIconAnims[pool[i]] = nil
        pool[i]:Hide()
    end
end

local function UpdateWeaponSkillText(unlearnedWeaponSkills)
    local enabled = ns.db and ns.db.showWeaponSkills ~= false
    if not enabled or type(unlearnedWeaponSkills) ~= "table" or #unlearnedWeaponSkills == 0 then
        content.weaponSkillsText:Hide()
        ApplyToTextLayers(content.weaponSkillsText, "SetText", "")
        PositionAbilityRows()
        return false
    end

    local names = {}
    for _, skill in ipairs(unlearnedWeaponSkills) do
        if type(skill) == "table" and skill.name then
            names[#names + 1] = skill.name
        elseif type(skill) == "string" then
            names[#names + 1] = skill
        end
    end
    if #names == 0 then
        content.weaponSkillsText:Hide()
        ApplyToTextLayers(content.weaponSkillsText, "SetText", "")
        PositionAbilityRows()
        return false
    end

    ApplyToTextLayers(content.weaponSkillsText, "SetText", "Weapon skills: " .. table.concat(names, ", "))
    SetTextColorKey(content.weaponSkillsText, "statLabel")
    content.weaponSkillsText:Show()
    PositionAbilityRows()
    return true
end

local function ApplyStatLineText(fs)
    local d = fs.statData
    local text
    if d then
        text = string.format("%s: %d %s-> %d|r", d.name, d.old, Hex(ColorOf("statNew")), d.new)
    else
        text = fs.plainText or ""
    end
    ApplyToTextLayers(fs, "SetText", text)
    SetTextColorKey(fs, "statLabel")
end

function ns.ApplyColors()
    SetTextColorKey(content.title, "title")
    SetTextColorKey(content.levelText, "level")
    SetTextColorKey(content.statsHeader, "statsHeader")
    SetTextColorKey(content.spellsHeader, "abilitiesHeader")
    SetTextColorKey(content.weaponSkillsText, "statLabel")
    for _, fs in ipairs(content.statLinePool) do
        ApplyStatLineText(fs)
    end
    local borderColor = ColorOf("abilityName")
    for _, icon in ipairs(content.abilityIconPool) do
        icon.border:SetColorTexture(borderColor[1], borderColor[2], borderColor[3], 0.9)
    end
end
ns.ApplyColors()

local function UpdateStatLines(statChanges)
    local pool = content.statLinePool
    local count = #statChanges
    local speed = Speed()
    local staggerBase = BASE_STAT_STAGGER_BASE / speed
    local staggerStep = BASE_STAT_STAGGER_STEP / speed
    local slideDuration = BASE_STAT_SLIDE_DURATION / speed

    local function LayoutStatLine(i, statChange, plainText)
        local fs = GetStatLine(i)
        fs.statData = statChange
        fs.plainText = plainText
        ApplyStatLineText(fs)
        local dir = LineDirection(i)
        local y = -((i - 1) * STAT_LINE_HEIGHT)
        local delay = staggerBase + (i - 1) * staggerStep
        StartLineAnimation(fs, content.statsContainer, dir * STAT_SLIDE_DISTANCE_X, y, delay, slideDuration)
    end

    if count == 0 then
        LayoutStatLine(1, nil, "No stat changes")
        count = 1
    else
        for i = 1, count do
            LayoutStatLine(i, statChanges[i])
        end
    end

    for i = count + 1, #pool do
        activeLineAnims[pool[i]] = nil
        SetLineShown(pool[i], false)
    end

    content.statsContainer:SetHeight(count * STAT_LINE_HEIGHT)
    return count
end

local function TextHeight(fs, fallback)
    local h = fs:GetStringHeight()
    if not h or h < 1 then h = fallback end
    return h
end

-- Fit the frame to its content so empty sections do not leave excess space.
local function LayoutFrame(statCount)
    local h = PAD_TOP + RING_SIZE + 6
    h = h + 4 + TextHeight(content.levelText, 18)
    h = h + 22 + TextHeight(content.statsHeader, 18)
    h = h + 10 + statCount * STAT_LINE_HEIGHT
    if content.levelTimeText:IsShown() then
        h = h + 4 + TextHeight(content.levelTimeText, 18)
    end
    h = h + 20 + TextHeight(content.spellsHeader, 16)
    h = h + 10 + (content.abilityRow:GetHeight() or ABILITY_ICON_SIZE)
    if content.weaponSkillsText:IsShown() then
        h = h + 8 + math.max(18, TextHeight(content.weaponSkillsText, 18))
    end
    h = h + PAD_BOTTOM
    frame:SetHeight(h)
    LayoutBackground()
end


frame:SetAlpha(1)
bg:SetAlpha(0)
content:SetAlpha(0)

local bgAnim = bg:CreateAnimationGroup()
local bgFade = bgAnim:CreateAnimation("Alpha")
bgFade:SetFromAlpha(0)
bgFade:SetToAlpha(1)
bgFade:SetSmoothing("OUT")
bgAnim:SetScript("OnPlay", function() bg:SetAlpha(0) end)
bgAnim:SetScript("OnFinished", function() bg:SetAlpha(1) end)

local contentAnim = content:CreateAnimationGroup()
local contentFade = contentAnim:CreateAnimation("Alpha")
contentFade:SetFromAlpha(0)
contentFade:SetToAlpha(1)
contentFade:SetSmoothing("OUT")
contentAnim:SetScript("OnPlay", function() content:SetAlpha(0) end)
contentAnim:SetScript("OnFinished", function() content:SetAlpha(1) end)

local fadeOutGroup = frame:CreateAnimationGroup()
local fadeOut = fadeOutGroup:CreateAnimation("Alpha")
fadeOut:SetFromAlpha(1)
fadeOut:SetToAlpha(0)
fadeOut:SetDuration(0.5)
fadeOut:SetSmoothing("IN")
fadeOutGroup:SetScript("OnFinished", function() frame:Hide() end)
frame.fadeOutGroup = fadeOutGroup

local hideToken = 0

local function IsHovered()
    if frame.IsMouseOver and frame:IsMouseOver() then return true end
    return MouseIsOver and MouseIsOver(frame) or false
end

local function TryFadeOut(token)
    if token ~= hideToken or not frame:IsShown() then return end
    if IsHovered() then
        C_Timer.After(0.15, function() TryFadeOut(token) end)
        return
    end
    frame.fadeOutGroup:Play()
end

local function ScheduleFadeOut(delay)
    hideToken = hideToken + 1
    local token = hideToken
    if ns.db and ns.db.reducedMotion then
        C_Timer.After(delay, function()
            if token == hideToken and frame:IsShown() then frame:Hide() end
        end)
        return
    end
    C_Timer.After(delay, function() TryFadeOut(token) end)
end

function ns.CloseLevelUp()
    hideToken = hideToken + 1
    activeLineAnims = {}
    activeIconAnims = {}
    bgAnim:Stop()
    contentAnim:Stop()
    if frame.fadeOutGroup:IsPlaying() then frame.fadeOutGroup:Stop() end
    frame:SetAlpha(1)
    frame:Hide()
end


frame:SetScript("OnEnter", function()
    if frame.fadeOutGroup:IsPlaying() then
        frame.fadeOutGroup:Stop()
        frame:SetAlpha(1)
        ScheduleFadeOut(0.15) -- polls until the mouse leaves, then fades
    end
end)


local function ShowLevelUpImpl(currentLevel, statChanges, trainerAbilities, unlearnedWeaponSkills, timePlayedThisLevel)
    -- Prepare the content, play the animations, and show the panel.
    local db = ns.db or {}
    if db.enabled == false then return end

    local speed = Speed()

    frame:SetScale(db.scale or 1.0)
        ns.RefreshClassIcon()
    ApplyToTextLayers(content.levelText, "SetText", string.format("Level %d", currentLevel))
    ns.ApplyColors()

    local statCount = UpdateStatLines(statChanges or {})

    if db.showLevelTime and tonumber(timePlayedThisLevel) then
        ApplyToTextLayers(content.levelTimeText, "SetText", FormatPlayedTime(timePlayedThisLevel))
        content.levelTimeText:Show()
    else
        ApplyToTextLayers(content.levelTimeText, "SetText", "")
        content.levelTimeText:Hide()
    end

    UpdateTrainerAbilityIcons(trainerAbilities or {})
    UpdateWeaponSkillText(unlearnedWeaponSkills or {})

    LayoutFrame(statCount)

    bgFade:SetDuration(BASE_BG_FADE_DURATION / speed)
    contentFade:SetDuration(BASE_CONTENT_FADE_DURATION / speed)
    contentFade:SetStartDelay(BASE_CONTENT_DELAY / speed)

    bgAnim:Stop()
    contentAnim:Stop()
    if db.reducedMotion then
        bg:SetAlpha(1)
        content:SetAlpha(1)
    else
        bgAnim:Play()
        contentAnim:Play()
    end

    ns.PositionFrame(frame)

    frame:SetAlpha(1) -- undo any leftover fade-out alpha from a previous close
    if frame.fadeOutGroup:IsPlaying() then
        frame.fadeOutGroup:Stop()
    end
    frame:Show()

    ns.PlayLevelUpSound()
    ScheduleFadeOut(db.duration or 7)
end

function ns.ShowLevelUp(currentLevel, statChanges, trainerAbilities, unlearnedWeaponSkills, timePlayedThisLevel)
    if ns.EnsureDatabase then ns.EnsureDatabase() end
    local ok, err = pcall(ShowLevelUpImpl, currentLevel, statChanges, trainerAbilities, unlearnedWeaponSkills, timePlayedThisLevel)
    if not ok then
        print("|cffff4040GnomeLevelUp error:|r " .. tostring(err))
        print("|cffff4040GnomeLevelUp:|r the level-up screen failed to display (see above). Please report this error.")
    end
end
