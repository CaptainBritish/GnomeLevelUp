local ADDON_NAME, ns = ...

-- Saved-setting conversions live here; Core owns defaults and current validation.
-- Helpers resolve shared defaults at call time, after Core has loaded.

function ns.RemoveObsoleteAnimationSounds(settings)
    for key in pairs(settings) do
        if type(key) == "string" and key:match("^animationSound_") and ns.defaults[key] == nil then settings[key] = nil end
    end
end

function ns.MigrateLevelUpSoundPreference(settings)
    local choice = settings.soundChoice
    if choice == "THEME" then
        settings.soundChoice = ns.defaults.soundChoice
        settings.useThemeLevelUpSound = true
    end
    if settings.levelUpSoundCustomized ~= nil then return end
    settings.levelUpSoundCustomized = (type(choice) == "string" and choice ~= "" and choice ~= "LEVELUP")
        or (type(settings.customSoundFile) == "string" and settings.customSoundFile ~= "")
        or (type(settings.customSoundChoice) == "string" and settings.customSoundChoice ~= "")
end

function ns.MigrateTrainerPriceSettings(settings)
    if settings.showTrainerCostsInTooltips == nil then
        settings.showTrainerCostsInTooltips = settings.showTrainerCosts == true
        if settings.trainerCostsTooltipOnly == true then settings.showTrainerCosts = false end
    end
    settings.trainerCostsTooltipOnly = nil
end

function ns.MigratePortraitMaskDefaults(settings)
    if type(settings) ~= "table" or (tonumber(settings.portraitMaskDefaultsVersion) or 0) >= 1 then return end
    settings.portraitModelMaskSize = ns.defaults.portraitModelMaskSize
    settings.portraitMaskDefaultsVersion = 1
end

-- Replace the withdrawn atlas background without changing the frame selection.
function ns.RetireDustyStoneBackground(settings)
    if settings.backgroundChoice ~= "DUSTY_STONE" then return end
    settings.backgroundChoice = "SCRATCHED_STONE"
    settings.backgroundTheme = nil
    settings.backgroundStyle, settings.backgroundFillMode = "fill", "scale"
    local preferences = settings.themeHuePreferences
    local saved = preferences and preferences.background and preferences.background.SCRATCHED_STONE
    settings.backgroundColor = ns.CopyValue(saved and saved.color or ns.GetBackgroundReference("SCRATCHED_STONE").defaultHue)
    settings.backgroundHueOpacity = saved and saved.opacity or 1
end

-- Merge the duplicate Horde background into Wood Panel, keeping an existing
-- Wood Panel preference when both assets have separately saved hues.
function ns.RetireHordeBackground(settings)
    local preferences = settings.themeHuePreferences
    local backgrounds = preferences and preferences.background
    if backgrounds and backgrounds.HORDE then
        if not backgrounds.WOOD_PANEL then backgrounds.WOOD_PANEL = ns.CopyValue(backgrounds.HORDE) end
        backgrounds.HORDE = nil
    end
    if settings.backgroundChoice == "HORDE" then
        settings.backgroundChoice = "WOOD_PANEL"
        local saved = backgrounds and backgrounds.WOOD_PANEL
        if saved then
            settings.backgroundColor = ns.CopyValue(saved.color)
            settings.backgroundHueOpacity = saved.opacity or 1
        end
    end
end

-- Repair only the original rotated-strip defaults; preserve other custom tuning.
-- Profiles load after InitDB, so both settings entry points use this repair.
function ns.NormalizeTrellisSideTransforms(settings)
    if settings.frameChoice ~= "TRELLIS" then return end
    local transforms = settings.backgroundTextureTransforms
    local left = transforms and transforms.left
    local right = transforms and transforms.right
    if left and right and left.rotation == 270 and right.rotation == 90
        and not left.flipX and not left.flipY and not right.flipX and not right.flipY then
        transforms.left = { rotation = 0, flipX = false, flipY = false }
        transforms.right = { rotation = 0, flipX = true, flipY = false }
    end
end

function ns.MigrateSettingsBeforeDefaults(settings)
    local savedSchemaVersion = tonumber(settings.schemaVersion) or 0
    -- Capture the pre-1.3.2 selectors before defaults add the new independent
    -- fields. This lets the migration distinguish an old custom theme from a
    -- deliberately selected Modern appearance.
    local legacyBackgroundMode = settings.backgroundMode
    local legacyBackgroundTheme = settings.backgroundTheme
    if type(legacyBackgroundTheme) == "string" then
        legacyBackgroundTheme = legacyBackgroundTheme:gsub("^CUSTOM:", "")
    end
    local legacyBackgroundChoice = settings.backgroundChoice
    local legacyFrameChoice = settings.frameChoice
    local legacyBackgroundStyle = settings.backgroundStyle
    local legacyBackgroundFillMode = settings.backgroundFillMode
    -- Early 1.3.4 builds saved a white frame default before migrating the
    -- shared hue. Repair that case once, as well as a direct 1.3.2 upgrade.
    local legacyHue = settings.backgroundColor
    local savedFrameHue = settings.frameColor
    local frameHueMissing = savedFrameHue == nil
    local frameHueIsDefault = type(savedFrameHue) == "table"
        and savedFrameHue[1] == 1 and savedFrameHue[2] == 1 and savedFrameHue[3] == 1
    if settings.sharedHueMigrationVersion ~= 1
        and (frameHueMissing or (savedSchemaVersion <= 6 and frameHueIsDefault))
        and type(legacyHue) == "table"
        and type(legacyHue[1]) == "number" and type(legacyHue[2]) == "number"
        and type(legacyHue[3]) == "number" then
        -- Legacy black meant no tint, so use the new frame's neutral white.
        if legacyHue[1] == 0 and legacyHue[2] == 0 and legacyHue[3] == 0 then
            settings.frameColor = { 1, 1, 1 }
        else
            settings.frameColor = ns.CopyValue(legacyHue)
        end
    end
    settings.sharedHueMigrationVersion = 1
    -- Combine the two portrait effects, retaining a fully disabled old profile.
    if settings.portraitAnimation == nil
        and (settings.portraitRingPulse ~= nil or settings.portraitStarburst ~= nil) then
        settings.portraitAnimation = settings.portraitRingPulse ~= false
            or settings.portraitStarburst ~= false
    end
    settings.portraitRingPulse = nil
    settings.portraitStarburst = nil
    -- Emphasis now controls counting too; preserve its existing preference.
    settings.countStatGains = nil
    settings.statTickerSounds = nil
    settings.portraitImpactSound, settings.starburstSound = nil, nil
    -- Retire the shipped experiment once; later debug selections remain editable.
    if not settings.effectSoundDefaultsRemoved then
        if settings.animationSound_portraitImpact == 4177602 then settings.animationSound_portraitImpact = 0 end
        if settings.animationSound_starburst == 979016 then settings.animationSound_starburst = 0 end
        settings.effectSoundDefaultsRemoved = true
    end
    -- Migrate the particle defaults once; preserve later debug edits.
    if settings.particleTuningPresetVersion ~= 1 then
        settings.particlePortraitCount = 5
        settings.particlePortraitSize = 200
        settings.particleStarburstCount = 5
        settings.particleEmberCount = 20
        settings.particleEmberSize = 150
        settings.particleTuningPresetVersion = 1
    end
    -- Apply the new visual preset once, then preserve later debug tuning.
    if settings.effectReadabilityPresetVersion ~= 1 then
        settings.starburstOpacity = 50
        settings.particleSparkleSize = 200
        settings.particleEmberOpacity = 40
        settings.effectReadabilityPresetVersion = 1
    end
    -- Refresh the old defaults without replacing custom debug values.
    if settings.effectPolishPresetVersion ~= 1 then
        if settings.fireworkSize == nil or settings.fireworkSize == 80 then settings.fireworkSize = 60 end
        if settings.portraitPulseOpacity == nil or settings.portraitPulseOpacity == 71.5 then settings.portraitPulseOpacity = 50 end
        if settings.particleEmberOpacity == nil or settings.particleEmberOpacity == 30 then settings.particleEmberOpacity = 40 end
        settings.effectPolishPresetVersion = 1
    end
    return {
        savedSchemaVersion = savedSchemaVersion,
        legacyBackgroundMode = legacyBackgroundMode,
        legacyBackgroundTheme = legacyBackgroundTheme,
        legacyBackgroundChoice = legacyBackgroundChoice,
        legacyFrameChoice = legacyFrameChoice,
        legacyBackgroundStyle = legacyBackgroundStyle,
        legacyBackgroundFillMode = legacyBackgroundFillMode,
    }
end

function ns.MigrateLegacyAppearance(settings, previous)
    local savedSchemaVersion = previous.savedSchemaVersion
    local legacyBackgroundMode = previous.legacyBackgroundMode
    local legacyBackgroundTheme = previous.legacyBackgroundTheme
    local legacyBackgroundChoice = previous.legacyBackgroundChoice
    local legacyFrameChoice = previous.legacyFrameChoice
    local legacyBackgroundStyle = previous.legacyBackgroundStyle
    local legacyBackgroundFillMode = previous.legacyBackgroundFillMode
    -- 1.3 stored one theme value for the whole custom appearance. Preserve
    -- that exact pairing while introducing independent frame/background keys.
    -- This is deliberately based on the values captured above; using the
    -- merged defaults here would make an old profile look like a fresh default
    -- profile and leave the background renderer without a valid nine-slice.
    local oldTheme = ns.FindBackgroundTheme(legacyBackgroundTheme)
    local hadIndependentSelectors = legacyBackgroundChoice ~= nil or legacyFrameChoice ~= nil
    if legacyBackgroundMode == "MODERN" and not legacyBackgroundTheme then
        settings.backgroundTheme = nil
        settings.backgroundChoice = legacyBackgroundChoice or "NONE"
        settings.frameChoice = legacyFrameChoice or "BLACK_METAL"
    elseif oldTheme and (not hadIndependentSelectors or savedSchemaVersion < 2) then
        settings.backgroundMode = "CUSTOM"
        settings.backgroundTheme = oldTheme.value
        settings.backgroundChoice = oldTheme.backgroundName
        settings.frameChoice = oldTheme.frameName or oldTheme.backgroundName
        if not legacyBackgroundStyle then
            local appearance = oldTheme.appearance or {}
            settings.backgroundStyle = appearance.backgroundStyle
                or (legacyBackgroundFillMode == "tile" and "tile" or "stretch")
        end
    elseif legacyBackgroundMode == "CUSTOM" and not hadIndependentSelectors then
        -- A removed or manually edited 1.3 theme must not leave CUSTOM mode
        -- pointing at missing textures. Fall back cleanly to Modern.
        settings.backgroundMode = "MODERN"
        settings.backgroundTheme = nil
        settings.backgroundChoice = "NONE"
        settings.frameChoice = "BLACK_METAL"
    elseif hadIndependentSelectors and not legacyBackgroundTheme then
        settings.backgroundTheme = nil
    elseif not hadIndependentSelectors and (legacyBackgroundMode ~= nil or legacyBackgroundTheme ~= nil or savedSchemaVersion > 0) then
        settings.backgroundMode = "MODERN"
        settings.backgroundTheme = nil
        settings.backgroundChoice = "NONE"
        settings.frameChoice = "BLACK_METAL"
    end
    -- Discard stale selectors left by removed themes or manually edited
    -- profiles before the renderer tries to resolve them.
    if savedSchemaVersion < 3 and tonumber(settings.portraitRingScale) == 1.0 then
        settings.portraitRingScale = 1.10
    end
    -- 1.3.4 uses a neutral white default for authored portrait rings. Migrate
    -- the previous built-in gold default while preserving an intentional tint.
    local savedRingColor = settings.portraitRingColor
    if type(savedRingColor) == "table"
        and savedRingColor[1] == 1 and savedRingColor[2] == 0.82 and savedRingColor[3] == 0.20 then
        settings.portraitRingColor = { 1, 1, 1 }
    end
end

function ns.MigrateLegacyLayout(settings, previous)
    local savedSchemaVersion = previous.savedSchemaVersion
    local legacyBackgroundMode = previous.legacyBackgroundMode
    local legacyBackgroundStyle = previous.legacyBackgroundStyle
    local legacyBackgroundFillMode = previous.legacyBackgroundFillMode
    local oldTheme = ns.FindBackgroundTheme(previous.legacyBackgroundTheme)
    local hadIndependentSelectors = previous.legacyBackgroundChoice ~= nil or previous.legacyFrameChoice ~= nil
    -- Older profiles only stored the center fill mode. Preserve that choice
    -- when introducing the per-theme style setting.
    if not legacyBackgroundStyle and not oldTheme
        and (legacyBackgroundMode ~= nil or legacyBackgroundFillMode ~= nil or hadIndependentSelectors) then
        settings.backgroundStyle = settings.backgroundFillMode == "tile"
            and "tile" or "stretch"
    end
    -- Move the first layout defaults forward without overwriting a custom divider color.
    if savedSchemaVersion < 2 and (settings.uiDefaultsVersion or 0) < 2 then
        if settings.sectionPadding == 6 then
            settings.sectionPadding = 8
        end
        local divider = settings.colors and settings.colors.divider
        if divider and divider[1] == 1 and divider[2] == 1 and divider[3] == 1 then
            divider[1], divider[2], divider[3] = 106 / 255, 106 / 255, 106 / 255
        end
        settings.uiDefaultsVersion = 2
    end
    -- Profiles from the pre-versioned format may contain partial or removed
    -- selectors. A versioned pass makes later migrations deterministic while
    -- preserving every user-owned setting that still has a valid meaning.
    if savedSchemaVersion < 4 then
        if not settings.backgroundStyle then
            settings.backgroundStyle = settings.backgroundFillMode == "tile"
                and "tile" or "stretch"
        end
        if not settings.frameChoice then settings.frameChoice = "BLACK_METAL" end
        if not settings.backgroundChoice then settings.backgroundChoice = "NONE" end
    end
    -- Blizzard owns level-up chat now; retire the addon-only settings.
    settings.printClassicLevelUpText = nil
    settings.classicLevelUpTextColor = nil
    settings.popupClosingAnimation = nil
    settings.milestoneColorTransition = nil
    settings.statImpactSparks = nil
    settings.newAbilitySparkles = nil
    settings.abilityRevealShine = nil
    settings.backgroundDepth = nil
    settings.milestoneAnticipation = nil
    settings.levelNumberReveal = nil
    settings.persistentOptionsPreview = nil
    settings.themePreview = nil
end

function ns.MigrateSavedThemeTextures(settings)
    -- Retire the deleted placeholder in profiles saved by older theme builds.
    local savedRingTexture = settings.portraitRingTexture
    if type(savedRingTexture) == "string"
        and savedRingTexture:lower():match("portrait%-ring%-placeholder%.tga$") then
        settings.portraitRingTexture = nil
        settings.portraitRingChoice = "NONE"
        settings.portraitRingEnabled = false
    end

    -- Existing saved themes keep their appearance transforms in SavedVariables.
    -- Refresh only the nine-slice transform map so the shared corner/edge
    -- textures take effect without resetting the user's other appearance work.
    local themeTextureVersion = 1
    if (tonumber(settings.backgroundThemeTextureVersion) or 0) < themeTextureVersion then
        local theme = ns.FindBackgroundTheme(settings.backgroundTheme)
        local transforms = theme and theme.appearance and theme.appearance.backgroundTextureTransforms
        if transforms then
            settings.backgroundTextureTransforms = ns.CopyValue(transforms)
        end
        settings.backgroundThemeTextureVersion = themeTextureVersion
    end
end
