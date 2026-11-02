local ADDON_NAME, ns = ...

-- One bounded snapshot per flavour, stored with this character rather than in
-- profiles. UI cleanup and later trainer scans must not mutate the saved event.
function ns.SaveLevelUpReplay(record)
    GnomeLevelUpCharacterDB = type(GnomeLevelUpCharacterDB) == "table" and GnomeLevelUpCharacterDB or {}
    local saved = GnomeLevelUpCharacterDB.lastLevelUp
    if type(saved) ~= "table" then saved = {}; GnomeLevelUpCharacterDB.lastLevelUp = saved end
    saved[ns.GetCurrentFlavor()] = ns.CopyValue(record)
end

function ns.ReplayLastLevelUp()
    ns.EnsureDatabase()
    local saved = type(GnomeLevelUpCharacterDB) == "table" and GnomeLevelUpCharacterDB.lastLevelUp
    local record = type(saved) == "table" and saved[ns.GetCurrentFlavor()]
    if type(record) ~= "table" or type(record.level) ~= "number" then
        print("|cff3fe0ffGnomeLevelUp|r: " .. ns.L("No recorded level-up to replay yet."))
        return false
    end
    record = ns.CopyValue(record)
    ns.ShowLevelUp(record.level, record.stats or {}, record.abilities or {}, record.weapons or {},
        record.seconds, record.pets or {}, true, record.milestone, record.previousFastest,
        record.maximum, record.previousFastest ~= nil, record.rangeStart, record.secondary, record)
    return true
end
