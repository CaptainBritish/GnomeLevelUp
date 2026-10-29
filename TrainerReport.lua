local ADDON_NAME, ns = ...

-- Observations are evidence for the author, never runtime catalogue overrides.
local MAX_REPORTS = 250
local indexByClass = {}
local reportWindow, reportEdit, copyHint
local copyArmed, copyText
local revision = ns.ForeverTrainingRevision or "1.4.0-custom"
local REPORT_PATH = "WTF/Account/<account>/SavedVariables/" .. ADDON_NAME .. ".lua"

function ns.GetTrainerReportPath()
    -- Account folder names are not exposed to addons. This path is relative
    -- to the active client folder; WoW owns writing it on reload/logout.
    return REPORT_PATH
end

function ns.PrintTrainerReportLocation()
    print("|cff3fe0ffGnomeLevelUp|r: " .. ns.L(
        "Saved report file after /reload or logout (inside your current WoW client folder): %s", REPORT_PATH))
end

local function PositiveInteger(value)
    return type(value) == "number" and value == value and value > 0
        and value < math.huge and value == math.floor(value)
end

local function CatalogueIndex(classToken)
    if indexByClass[classToken] then return indexByClass[classToken] end
    local index = {}
    for level, entries in pairs(ns.ClassTrainingForever[classToken] or {}) do
        for _, entry in ipairs(entries) do
            if PositiveInteger(entry.spellID) then
                index[entry.spellID] = index[entry.spellID] or {}
                index[entry.spellID][tonumber(level)] = true
            end
        end
    end
    indexByClass[classToken] = index
    return index
end

local function Store()
    if type(GnomeLevelUpDB) ~= "table" then return end
    local store = GnomeLevelUpDB.trainerChangeReports
    if type(store) ~= "table" or store.schemaVersion ~= 1 or type(store.changes) ~= "table" then
        store = { schemaVersion = 1, changes = {} }
        GnomeLevelUpDB.trainerChangeReports = store
    end
    return store
end

local function Text(value, limit)
    return type(value) == "string" and value:sub(1, limit) or nil
end

function ns.RecordTrainerObservation(observation)
    if type(observation) ~= "table" or not ns.db or ns.db.monitorTrainerChanges == false
        or ns.db.enabled == false or not ns.GetCurrentFlavor or ns.GetCurrentFlavor() ~= "forever" then return false end
    local classToken, spellID, level = observation.classToken, observation.spellID, observation.level
    if not ns.ClassTrainingForever or not ns.ClassTrainingForever[classToken]
        or not PositiveInteger(spellID) or not PositiveInteger(level) or level > 100 then return false end
    local knownLevels = CatalogueIndex(classToken)[spellID]
    if knownLevels and knownLevels[level] then return false end
    local store = Store()
    if not store then return false end
    local key = revision .. ":" .. classToken .. ":" .. spellID .. ":" .. level
    local entry = store.changes[key]
    local isNew = entry == nil
    if isNew then
        local count = 0
        for _ in pairs(store.changes) do count = count + 1 end
        if count >= MAX_REPORTS then store.truncated = true; return false end
        local baseline = {}
        for baselineLevel in pairs(knownLevels or {}) do baseline[#baseline + 1] = baselineLevel end
        table.sort(baseline)
        entry = {
            kind = knownLevels and "required_level_changed" or "new_spell",
            catalogueRevision = revision, classToken = classToken, spellID = spellID,
            observedLevel = level, baselineLevels = knownLevels and baseline or nil, sightings = 0,
        }
        store.changes[key] = entry
    end
    local now = type(time) == "function" and time() or nil
    entry.firstSeen = entry.firstSeen or now
    entry.lastSeen = now
    entry.sightings = math.min(1000000000, (tonumber(entry.sightings) or 0) + 1)
    entry.name = Text(observation.name, 200)
    entry.npcName = Text(observation.npcName, 100)
    entry.status = Text(observation.status, 20)
    entry.clientLocale = type(GetLocale) == "function" and GetLocale() or nil
    entry.faction = type(UnitFactionGroup) == "function" and UnitFactionGroup("player") or nil
    if type(UnitRace) == "function" then local _, race = UnitRace("player"); entry.race = race end
    if type(GetBuildInfo) == "function" then
        local version, build, _, interface = GetBuildInfo()
        entry.clientVersion, entry.clientBuild, entry.interface = version, build, interface
    end
    -- Offered prices may include reputation discounts; they never trigger a diff.
    local cost = observation.cost
    if type(cost) == "number" and cost >= 0 and cost < math.huge and cost == math.floor(cost) then
        entry.observedCost = cost
    end
    return isNew
end

local function JSON(value)
    local kind = type(value)
    if kind == "string" then
        return '"' .. value:gsub('[%z\1-\31\\"]', function(char)
            if char == '"' then return '\\"' end
            if char == '\\' then return '\\\\' end
            return string.format('\\u%04x', string.byte(char))
        end) .. '"'
    elseif kind == "number" then
        return value == value and math.abs(value) < math.huge and tostring(value) or "null"
    elseif kind == "boolean" then return value and "true" or "false"
    elseif kind ~= "table" then return "null" end
    local parts = {}
    if #value > 0 then
        for _, item in ipairs(value) do parts[#parts + 1] = JSON(item) end
        return "[" .. table.concat(parts, ",") .. "]"
    end
    local keys = {}
    for key in pairs(value) do keys[#keys + 1] = key end
    table.sort(keys)
    for _, key in ipairs(keys) do parts[#parts + 1] = JSON(tostring(key)) .. ":" .. JSON(value[key]) end
    return "{" .. table.concat(parts, ",") .. "}"
end

function ns.GetTrainerReportJSON()
    local store = Store()
    return JSON({ addon = ADDON_NAME, addonVersion = "1.5", schemaVersion = 1,
        catalogueRevision = revision, changes = store and store.changes or {},
        truncated = store and store.truncated == true or false })
end

function ns.GetTrainerReportCount()
    local store, count = Store(), 0
    for _ in pairs(store and store.changes or {}) do count = count + 1 end
    return count
end

function ns.ClearTrainerReports()
    if GnomeLevelUpDB then GnomeLevelUpDB.trainerChangeReports = nil end
    if reportWindow then reportWindow:Hide() end
end

function ns.OpenTrainerReport()
    if ns.GetTrainerReportCount() == 0 then
        print("|cff3fe0ffGnomeLevelUp|r: " .. ns.L("No trainer catalogue differences have been recorded."))
        return
    end
    ns.PrintTrainerReportLocation()
    if not reportWindow then
        reportWindow = CreateFrame("Frame", "GnomeLevelUpTrainerReport", UIParent, "BackdropTemplate")
        reportWindow:SetSize(640, 500)
        reportWindow:SetPoint("CENTER")
        reportWindow:SetFrameStrata("DIALOG")
        reportWindow:SetClampedToScreen(true)
        reportWindow:SetBackdrop({bgFile="Interface\\DialogFrame\\UI-DialogBox-Background",
            edgeFile="Interface\\DialogFrame\\UI-DialogBox-Border",tile=true,tileSize=32,edgeSize=24,
            insets={left=8,right=8,top=8,bottom=8}})
        CreateFrame("Button", nil, reportWindow, "UIPanelCloseButton"):SetPoint("TOPRIGHT", -2, -2)
        local title = reportWindow:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        title:SetPoint("TOPLEFT", 20, -18)
        title:SetText(ns.L("Export trainer report"))
        local instructions = reportWindow:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        instructions:SetPoint("TOPLEFT", 20, -48)
        instructions:SetWidth(600)
        instructions:SetWordWrap(true)
        instructions:SetJustifyH("LEFT")
        instructions:SetText(ns.L("After /reload or logout, send the saved file to the addon author on GitHub or Curseforge. It includes your GnomeLevelUp settings. Alternatively, copy the report-only JSON below."))
        local pathText = reportWindow:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        pathText:SetPoint("TOPLEFT", instructions, "BOTTOMLEFT", 0, -10)
        pathText:SetWidth(600)
        pathText:SetWordWrap(true)
        pathText:SetJustifyH("LEFT")
        pathText:SetText(ns.L("Report file: %s", REPORT_PATH))
        local reload = CreateFrame("Button", nil, reportWindow, "UIPanelButtonTemplate")
        reload:SetSize(160, 26)
        reload:SetPoint("TOPLEFT", pathText, "BOTTOMLEFT", 0, -12)
        reload:SetText(ns.L("Reload UI"))
        reload:SetScript("OnClick", function() ReloadUI() end)
        local copy = CreateFrame("Button", nil, reportWindow, "UIPanelButtonTemplate")
        copy:SetSize(160, 26)
        copy:SetPoint("LEFT", reload, "RIGHT", 10, 0)
        copy:SetText(ns.L("Copy"))
        copy:SetScript("OnClick", function()
            if reportEdit:GetText() == "" then return end
            copyArmed, copyText = true, nil
            reportEdit:SetFocus()
            reportEdit:HighlightText()
            copyHint:SetText(ns.L("Press Ctrl+C to copy. The field clears afterward."))
        end)
        copyHint = reportWindow:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        copyHint:SetPoint("TOPLEFT", reload, "BOTTOMLEFT", 0, -6)
        copyHint:SetSize(600, 28)
        copyHint:SetWordWrap(true)
        copyHint:SetJustifyH("LEFT")
        copyHint:SetText("")
        local scroll = CreateFrame("ScrollFrame", nil, reportWindow, "UIPanelScrollFrameTemplate")
        scroll:SetPoint("TOPLEFT", copyHint, "BOTTOMLEFT", 0, -8)
        scroll:SetPoint("BOTTOMRIGHT", reportWindow, "BOTTOMRIGHT", -40, 20)
        reportEdit = CreateFrame("EditBox", nil, scroll)
        reportEdit:SetMultiLine(true)
        reportEdit:SetAutoFocus(false)
        reportEdit:SetMaxLetters(0)
        reportEdit:SetFontObject(ChatFontNormal)
        reportEdit:SetWidth(570)
        reportEdit:SetHeight(260)
        reportEdit:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
        -- Clipboard writes are restricted to secure UI code. Let the edit box
        -- perform its native copy, then clear on key release after Ctrl+C.
        reportEdit:SetScript("OnKeyDown", function(self, key)
            local modifier = (IsControlKeyDown and IsControlKeyDown())
                or (IsMetaKeyDown and IsMetaKeyDown())
            copyText = copyArmed and modifier and key == "C" and self:GetText() or nil
            if copyText then self:HighlightText() end
        end)
        reportEdit:SetScript("OnKeyUp", function(self, key)
            if key ~= "C" or not copyText then return end
            if copyText ~= "" and self:GetText() == copyText then
                self:SetText("")
                self:ClearFocus()
            end
            copyArmed, copyText = false, nil
            copyHint:SetText("")
        end)
        reportEdit:SetScript("OnEditFocusLost", function()
            copyArmed, copyText = false, nil
            copyHint:SetText("")
        end)
        scroll:SetScrollChild(reportEdit)
        reportWindow:SetScript("OnHide", function()
            copyArmed, copyText = false, nil
            reportEdit:ClearFocus()
            copyHint:SetText("")
        end)
    end
    copyArmed, copyText = false, nil
    copyHint:SetText("")
    reportWindow:Show()
    reportEdit:SetText(ns.GetTrainerReportJSON())
    reportEdit:HighlightText()
    reportEdit:SetFocus()
end
