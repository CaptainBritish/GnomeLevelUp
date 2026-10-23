local ADDON_NAME, ns = ...

local pending = {}
local invalidationQueued = false

local function QueueCatalogInvalidation()
    if invalidationQueued then return end
    invalidationQueued = true
    local function Flush()
        invalidationQueued = false
        if ns.InvalidateTrainerIndex then ns.InvalidateTrainerIndex() end
    end
    -- Multiple spell-data replies in one frame need only one index rebuild.
    if C_Timer and type(C_Timer.After) == "function" then
        C_Timer.After(0, Flush)
    else
        Flush()
    end
end

function ns.HasBuiltInTrainerData()
    if not ns.GetCurrentFlavor or ns.GetCurrentFlavor() ~= "forever" then return false end
    local _, class = UnitClass("player")
    return ns.ClassTrainingForever and ns.ClassTrainingForever[class] ~= nil
end

function ns.CanCaptureTrainerData()
    return not ns.HasBuiltInTrainerData() or (ns.IsDebugEnabled and ns.IsDebugEnabled()) == true
end

local function RequestSpell(id)
    if pending[id] or not C_Spell or not C_Spell.RequestLoadSpellData then return end
    pending[id] = true
    local ok = pcall(C_Spell.RequestLoadSpellData, id)
    if not ok then pending[id] = nil end
end

function ns.ResolveTrainingEntry(entry)
    if entry.name or not entry.spellID then return entry.name end
    local id = entry.spellID
    local name, icon
    if C_Spell and C_Spell.GetSpellInfo then
        local ok, info = pcall(C_Spell.GetSpellInfo, id)
        if ok and type(info) == "table" then name, icon = info.name, info.iconID end
    elseif type(_G.GetSpellInfo) == "function" then
        local ok, spellName, _, texture = pcall(_G.GetSpellInfo, id)
        if ok then name, icon = spellName, texture end
    end
    if not name or name == "" then RequestSpell(id); return nil end
    local subtext
    if C_Spell and C_Spell.GetSpellSubtext then
        local ok, value = pcall(C_Spell.GetSpellSubtext, id)
        if ok then subtext = value end
    end
    entry.name = name .. (subtext and subtext ~= "" and (" (" .. subtext .. ")") or "")
    entry.icon, entry.bundled = icon, true
    return entry.name
end

function ns.IsTrainingEntryEligible(entry)
    if type(entry) ~= "table" then return true end
    if entry.faction and entry.faction ~= UnitFactionGroup("player") then return false end
    if entry.race or entry.races then
        local _, _, race = UnitRace("player")
        if entry.race and entry.race ~= race then return false end
        if entry.races then
            local matches = false
            for _, allowed in ipairs(entry.races) do if allowed == race then matches = true; break end end
            if not matches then return false end
        end
    end
    return true
end

-- A character cannot change class without reloading the addon. Keep its
-- catalogue even on Retail, so the developer flavour override still works.
function ns.ReleaseUnusedClassTraining()
    local _, class = UnitClass("player")
    if not class or not ns.ClassTrainingForever then return end
    for token in pairs(ns.ClassTrainingForever) do
        if token ~= class then ns.ClassTrainingForever[token] = nil end
    end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("SPELL_DATA_LOAD_RESULT")
frame:SetScript("OnEvent", function(_, event, id)
    if event == "PLAYER_LOGIN" then
        ns.ReleaseUnusedClassTraining()
        if not ns.HasBuiltInTrainerData() then return end
        local _, class = UnitClass("player")
        -- Warm only this character's class before the next level-up event.
        for _, entries in pairs(ns.ClassTrainingForever[class]) do
            for _, entry in ipairs(entries) do
                if ns.IsTrainingEntryEligible(entry) then ns.ResolveTrainingEntry(entry) end
            end
        end
    elseif pending[id] then
        pending[id] = nil
        QueueCatalogInvalidation()
    end
end)
