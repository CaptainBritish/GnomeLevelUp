local ADDON_NAME, ns = ...

-- Translations are keyed by the English source text so translators can work
-- through the addon without changing saved-variable names or code identifiers.
-- Additional locale files can call RegisterLocale at any time before a string
-- is rendered; English remains the safe fallback for every missing key.
local locales = {
    enUS = {},
}
local activeLocale = (type(GetLocale) == "function" and GetLocale()) or "enUS"

function ns.RegisterLocale(locale, translations)
    if type(locale) ~= "string" or type(translations) ~= "table" then return end
    locales[locale] = locales[locale] or {}
    for source, translated in pairs(translations) do
        if type(source) == "string" and type(translated) == "string" then
            locales[locale][source] = translated
        end
    end
end

function ns.SetLocale(locale)
    if type(locale) == "string" and locales[locale] then activeLocale = locale end
end

function ns.GetLocale()
    return activeLocale
end

function ns.L(source, ...)
    if type(source) ~= "string" then return source end
    local translated = (locales[activeLocale] and locales[activeLocale][source])
        or locales.enUS[source] or source
    if select("#", ...) > 0 then
        local ok, formatted = pcall(string.format, translated, ...)
        if ok then return formatted end
    end
    return translated
end

-- Choice tables keep stable values but receive localized display labels when
-- they are consumed by a menu.
function ns.LocalizeChoiceLabel(choice)
    if type(choice) ~= "table" then return ns.L(choice) end
    return ns.L(choice.label or choice.value or "")
end
