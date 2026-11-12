local ADDON_NAME, ns = ...

-- All languages are available in the options menu. English is the fallback
-- for missing translations. Set a flag to false to hide a language.
local ENABLED_LOCALES = {
    enUS = true,  -- English (also enGB); keep enabled
    frFR = true,  -- Français
    esES = true,  -- Español (España)
    esMX = true,  -- Español (Latinoamérica)
    deDE = true,  -- Deutsch
    itIT = true,  -- Italiano
    ptBR = true,  -- Português (Brasil)
    ruRU = true,  -- Русский
    koKR = true,  -- 한국어
    zhCN = true,  -- 简体中文
    zhTW = true,  -- 繁體中文
    trTR = true,  -- Türkçe
}

local LANGUAGE_NAMES = {
    { "enUS", "English" }, { "frFR", "Français" },
    { "esES", "Español (España)" }, { "esMX", "Español (Latinoamérica)" },
    { "deDE", "Deutsch" }, { "itIT", "Italiano" },
    { "ptBR", "Português (Brasil)" }, { "ruRU", "Русский" },
    { "koKR", "한국어" }, { "zhCN", "简体中文" }, { "zhTW", "繁體中文" },
    { "trTR", "Türkçe" },
}

-- Add new UI strings to every non-English dictionary in Locales\.
-- English UI strings are the canonical keys. Never translate saved-variable
-- keys, API identifiers, slash commands, spell IDs or asset paths.
-- Keep canonical translation keys stable while using British English on screen.
local locales = { enUS = {} }
local localeBuilders = {}

-- Keep the constructors, not ten populated dictionaries. Switching language
-- releases the previous dictionary while keeping every language available.
local function RegisterLocaleBuilder(locale, build)
    if not ENABLED_LOCALES[locale] then return end
    local builders = localeBuilders[locale]
    if not builders then builders = {}; localeBuilders[locale] = builders end
    builders[#builders + 1] = build
end
-- Locales\*.lua register their dictionaries through this; Locales\Init.lua
-- selects the client language once every file has loaded.
ns.RegisterLocaleBuilder = RegisterLocaleBuilder
local clientLocale = type(GetLocale) == "function" and GetLocale() or "enUS"
local activeLocale = "enUS"
local function CanonicalLocale(locale)
    return locale == "enGB" and "enUS" or locale
end

function ns.IsLocaleEnabled(locale)
    locale = CanonicalLocale(locale)
    return locale == "enUS" or ENABLED_LOCALES[locale] == true
end

function ns.GetLanguageChoices()
    local choices = { { value = "auto", label = "Auto Detect" } }
    for _, language in ipairs(LANGUAGE_NAMES) do
        if ns.IsLocaleEnabled(language[1]) then
            choices[#choices + 1] = { value = language[1], label = language[2], fontLocale = language[1] }
        end
    end
    return choices
end

-- Show the actual English fallback if a stored manual selection was disabled.
-- Preserve the stored choice so re-enabling that locale restores it on reload.
function ns.GetLanguageSelection(selection)
    if selection == nil or selection == "auto" then return "auto" end
    selection = CanonicalLocale(selection)
    return ns.IsLocaleEnabled(selection) and selection or "enUS"
end

function ns.RegisterLocale(locale, translations)
    if type(locale) ~= "string" or type(translations) ~= "table" then return end
    if not ns.IsLocaleEnabled(locale) then return end
    locales[locale] = locales[locale] or {}
    for source, translated in pairs(translations) do
        if type(source) == "string" and type(translated) == "string" then
            locales[locale][source] = translated
        end
    end
end

function ns.SetLocale(locale)
    if locale == nil or locale == "auto" then locale = clientLocale end
    locale = CanonicalLocale(locale)
    locale = ns.IsLocaleEnabled(locale) and (locale == "enUS" or localeBuilders[locale] or locales[locale]) and locale or "enUS"
    if activeLocale == locale and locales[locale] then return end
    if activeLocale ~= "enUS" then locales[activeLocale] = nil end
    if not locales[locale] then
        local entries
        for _, build in ipairs(localeBuilders[locale] or {}) do
            local translations = build()
            if not entries then
                entries = translations
            else
                for source, translated in pairs(translations) do entries[source] = translated end
            end
        end
        locales[locale] = entries or {}
    end
    activeLocale = locale
end

function ns.GetLocale()
    return activeLocale
end

local CYRILLIC_FONTS = {
    ["FONTS\\FRIZQT__.TTF"] = "Fonts\\FRIZQT___CYR.TTF",
    ["FONTS\\MORPHEUS.TTF"] = "Fonts\\MORPHEUS_CYR.TTF",
    ["FONTS\\SKURRI.TTF"] = "Fonts\\SKURRI_CYR.TTF",
}
local EAST_ASIAN_FONTS = {
    koKR = "Fonts\\2002.TTF",
    zhCN = "Fonts\\ARKai_T.ttf",
    zhTW = "Fonts\\blei00d.TTF",
}
-- The game's Friz Quadrata lacks Turkish glyphs (ğ, ş, ı, İ); this bundled
-- copy has them. Only Friz is replaced; other fonts are left as chosen.
local TURKISH_FRIZ_FONT = "Interface\\AddOns\\GnomeLevelUp\\Fonts\\friz-quadrata-bt-58703370183b3.ttf"
local BUILTIN_LATIN_FONTS = { ["FONTS\\ARIALN.TTF"] = true }
for path in pairs(CYRILLIC_FONTS) do BUILTIN_LATIN_FONTS[path] = true end

function ns.GetLocaleFontPath(locale)
    locale = locale or activeLocale
    if locale == "trTR" then return TURKISH_FRIZ_FONT end
    return EAST_ASIAN_FONTS[locale]
        or (locale == "ruRU" and CYRILLIC_FONTS["FONTS\\FRIZQT__.TTF"] or nil)
end

function ns.GetPopupFontPath(path)
    if type(path) ~= "string" or path == "" then path = ns.DEFAULT_FONT_PATH end
    local fontKey = path:gsub("/", "\\"):upper()
    -- Game-supplied names may use the client script even when GLU is in English.
    local locale = ns.GetLocaleFontPath(activeLocale) and activeLocale or clientLocale
    if locale == "trTR" then
        return fontKey == "FONTS\\FRIZQT__.TTF" and TURKISH_FRIZ_FONT or path
    end
    if BUILTIN_LATIN_FONTS[fontKey] then
        if EAST_ASIAN_FONTS[locale] then return EAST_ASIAN_FONTS[locale] end
        if locale == "ruRU" then return CYRILLIC_FONTS[fontKey] or path end
    end
    return path
end

-- Keep size and styling from the original widget font, including when the
-- first-time setup switches languages without a reload.
function ns.ApplyLocaleFont(text, locale)
    if not text or not text.GetFont then return end
    local path = ns.GetLocaleFontPath(locale)
    if path == text.gluLocaleFont then return end
    local original, size, flags = text:GetFont()
    if not original or not size then return end
    if path then
        text.gluOriginalFont = text.gluOriginalFont or original
        if text:SetFont(path, size, flags) ~= false then text.gluLocaleFont = path end
    elseif text.gluOriginalFont then
        text:SetFont(text.gluOriginalFont, size, flags)
        text.gluOriginalFont, text.gluLocaleFont = nil, nil
    end
end

local function ApplyTooltipLinesFont(tooltip, locale)
    local name = tooltip:GetName()
    if not name or not tooltip.NumLines then return end
    local count = math.max(tooltip.gluLocaleFontLines or 0, tooltip:NumLines())
    if locale then tooltip.gluLocaleFontLines = nil else tooltip.gluLocaleFontLines = count end
    for line = 1, count do
        ns.ApplyLocaleFont(_G[name .. "TextLeft" .. line], locale)
        ns.ApplyLocaleFont(_G[name .. "TextRight" .. line], locale)
    end
end

-- Call after adding lines and before Show(). Shared tooltips get their
-- original fonts back on hide so other addons are unaffected.
function ns.ApplyTooltipLocaleFont(tooltip)
    if not tooltip or not tooltip.HookScript or not ns.GetLocaleFontPath() then return end
    if not tooltip.gluLocaleFontHook then
        tooltip.gluLocaleFontHook = true
        tooltip:HookScript("OnHide", function(self) ApplyTooltipLinesFont(self, "enUS") end)
    end
    ApplyTooltipLinesFont(tooltip)
end

function ns.L(source, ...)
    if type(source) ~= "string" then return source end
    local translated = locales[activeLocale][source] or source
    if select("#", ...) > 0 then
        local ok, formatted = pcall(string.format, translated, ...)
        if ok then return formatted end
        -- A malformed translation must not leave unexpanded format tokens.
        ok, formatted = pcall(string.format, source, ...)
        if ok then return formatted end
    end
    return translated
end

function ns.LocalizeChoiceLabel(choice)
    if type(choice) ~= "table" then return ns.L(choice) end
    if choice.literal then return choice.label or choice.value or "" end
    return ns.L(choice.label or choice.value or "")
end
