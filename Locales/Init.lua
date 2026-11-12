local _, ns = ...

-- Load the client language only after every Locales\*.lua file has registered.
-- Core applies the saved override at ADDON_LOADED, before building Options.
ns.SetLocale("auto")
