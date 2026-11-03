local ADDON_NAME, ns = ...

-- History is account data, independent of appearance profiles. Legacy records
-- are copied when each character logs in; unvisited characters cannot be read.
local samples
local SAMPLE_LEVEL_SECONDS = 20 * 60 * 60

local function HistoryLevelCap(flavor)
    local cap = flavor == "forever" and 60 or (ns.GetLevelCap and ns.GetCurrentFlavor() == "retail" and ns.GetLevelCap() or 90)
    return math.max(2, math.min(1000, tonumber(cap) or 90))
end
local function ValidTime(value)
    return type(value) == "number" and value == value and value >= 0 and value < math.huge
end

local function CharacterIdentity()
    local name = type(UnitName) == "function" and UnitName("player") or "Player"
    local realm = type(GetRealmName) == "function" and GetRealmName() or "Realm"
    local guid = type(UnitGUID) == "function" and UnitGUID("player")
    return guid or (name .. "-" .. realm), name .. " - " .. realm
end

local function Store()
    if type(GnomeLevelUpHistoryDB) ~= "table" then GnomeLevelUpHistoryDB = {} end
    if type(GnomeLevelUpHistoryDB.characters) ~= "table" then GnomeLevelUpHistoryDB.characters = {} end
    return GnomeLevelUpHistoryDB.characters
end

local function FlavorRecord(character, flavor)
    if type(character.flavors) ~= "table" then character.flavors = {} end
    if type(character.flavors[flavor]) ~= "table" then character.flavors[flavor] = {} end
    local record = character.flavors[flavor]
    if type(record.times) ~= "table" then record.times = {} end
    if type(record.bests) ~= "table" then record.bests = {} end
    return record
end

function ns.SyncLevelHistory()
    local key, name = CharacterIdentity()
    local characters = Store()
    if type(characters[key]) ~= "table" then characters[key] = {} end
    local character = characters[key]
    character.name = name
    local legacy = type(GnomeLevelUpCharacterDB) == "table" and GnomeLevelUpCharacterDB or {}
    for _, flavor in ipairs({ "retail", "forever" }) do
        local record = FlavorRecord(character, flavor)
        local times = type(legacy.levelTimes) == "table" and legacy.levelTimes[flavor]
        local bests = type(legacy.levelBests) == "table" and legacy.levelBests[flavor]
        for level = 1, 999 do
            local seconds = type(times) == "table" and times[level]
            local best = type(bests) == "table" and bests[level] or seconds
            if ValidTime(seconds) then record.times[level] = seconds end
            if ValidTime(best) and (not ValidTime(record.bests[level]) or best < record.bests[level]) then
                record.bests[level] = best
            end
        end
        local fastest = type(legacy.fastestLevelTimes) == "table" and legacy.fastestLevelTimes[flavor]
        if ValidTime(fastest) and fastest >= 1 and (not ValidTime(record.fastest) or fastest < record.fastest) then
            record.fastest = fastest
        end
    end
    return key, character
end

function ns.GetAccountFastestLevelTime()
    ns.SyncLevelHistory()
    local fastest
    for _, character in pairs(Store()) do
        local record = type(character) == "table" and type(character.flavors) == "table"
            and character.flavors[ns.GetCurrentFlavor()]
        local value = type(record) == "table" and record.fastest
        if ValidTime(value) and value >= 1 and (not fastest or value < fastest) then fastest = value end
    end
    return fastest
end

function ns.RecordAccountLevelPace(seconds)
    local _, character = ns.SyncLevelHistory()
    local record = FlavorRecord(character, ns.GetCurrentFlavor())
    if not ValidTime(record.fastest) or seconds < record.fastest then record.fastest = seconds end
end

function ns.ResetAccountCharacterTimers()
    local key = CharacterIdentity()
    Store()[key] = nil
    samples = nil
    if ns.RefreshLevelHistoryOptions then ns.RefreshLevelHistoryOptions() end
end

-- Reset saved records without touching LevelUp's pending event or /played cache.
function ns.ClearRecordedLevelTimes()
    GnomeLevelUpCharacterDB = type(GnomeLevelUpCharacterDB) == "table" and GnomeLevelUpCharacterDB or {}
    GnomeLevelUpCharacterDB.levelTimes, GnomeLevelUpCharacterDB.fastestLevelTimes, GnomeLevelUpCharacterDB.levelBests = nil, nil, nil
    ns.ResetAccountCharacterTimers()
end

function ns.RecordCompletedLevel(reachedLevel, seconds)
    reachedLevel, seconds = tonumber(reachedLevel), tonumber(seconds)
    if not reachedLevel or reachedLevel % 1 ~= 0 or reachedLevel < 2
        or not seconds or seconds ~= seconds or seconds < 0 or seconds == math.huge then return end
    GnomeLevelUpCharacterDB = type(GnomeLevelUpCharacterDB) == "table" and GnomeLevelUpCharacterDB or {}
    local history = GnomeLevelUpCharacterDB.levelTimes
    if type(history) ~= "table" then history = {}; GnomeLevelUpCharacterDB.levelTimes = history end
    local flavor = ns.GetCurrentFlavor()
    if type(history[flavor]) ~= "table" then history[flavor] = {} end
    -- Keys are the level completed: 1 means the full 1 -> 2 interval.
    if history[flavor][reachedLevel - 1] == nil then
        history[flavor][reachedLevel - 1] = seconds
    end
    local bests = GnomeLevelUpCharacterDB.levelBests
    if type(bests) ~= "table" then bests = {}; GnomeLevelUpCharacterDB.levelBests = bests end
    if type(bests[flavor]) ~= "table" then bests[flavor] = {} end
    local previous = bests[flavor][reachedLevel - 1] or history[flavor][reachedLevel - 1]
    if type(previous) ~= "number" or previous ~= previous or previous < 0 or seconds < previous then
        previous = seconds
    end
    bests[flavor][reachedLevel - 1] = previous
    local sample = samples and ns.IsDebugEnabled() and samples[flavor]
    if sample then
        local level = reachedLevel - 1
        sample.times[level] = seconds
        sample.bests[level] = math.min(sample.bests[level] or SAMPLE_LEVEL_SECONDS, seconds)
    end
    ns.SyncLevelHistory()
    if ns.RefreshLevelHistoryOptions then ns.RefreshLevelHistoryOptions() end
end

function ns.GetTimeToMaxLevel()
    local cap = ns.GetLevelCap()
    local history = type(GnomeLevelUpCharacterDB) == "table" and GnomeLevelUpCharacterDB.levelTimes
    local times = type(history) == "table" and history[ns.GetCurrentFlavor()]
    if not cap or type(times) ~= "table" then return nil end
    local total = 0
    for level = 1, cap - 1 do
        local seconds = times[level]
        if type(seconds) ~= "number" or seconds ~= seconds or seconds < 0 or seconds == math.huge then return nil end
        total = total + seconds
    end
    return total < math.huge and total or nil
end

function ns.RecordLevelPace(seconds)
    seconds = tonumber(seconds)
    if not seconds or seconds ~= seconds or seconds == math.huge or seconds < 1 then return nil end
    seconds = math.floor(seconds)
    GnomeLevelUpCharacterDB = type(GnomeLevelUpCharacterDB) == "table" and GnomeLevelUpCharacterDB or {}
    local records = GnomeLevelUpCharacterDB.fastestLevelTimes
    if type(records) ~= "table" then records = {}; GnomeLevelUpCharacterDB.fastestLevelTimes = records end
    local flavor = ns.GetCurrentFlavor()
    local previous = tonumber(records[flavor])
    local comparison = previous
    if samples and ns.IsDebugEnabled() then
        -- A diagnostic seed changes the comparison, never the saved best time.
        comparison = SAMPLE_LEVEL_SECONDS
    elseif ns.db and ns.db.compareAccountLevelTimes then
        comparison = ns.GetAccountFastestLevelTime()
    end
    ns.RecordAccountLevelPace(seconds)
    if not previous or previous ~= previous or previous == math.huge or previous < 1 then
        records[flavor] = seconds
    elseif seconds < previous then
        records[flavor] = seconds
    end
    if type(comparison) == "number" and comparison == comparison and comparison >= 1 and comparison < math.huge then
        return comparison
    end
    return nil
end

local function HasRecordedIntervals(character)
    if type(character.flavors) ~= "table" then return false end
    for _, flavor in ipairs({ "retail", "forever" }) do
        local record = character.flavors[flavor]
        if type(record) == "table" then
            for _, field in ipairs({ "times", "bests" }) do
                if type(record[field]) == "table" then
                    for level, seconds in pairs(record[field]) do
                        if type(level) == "number" and level >= 1 and level <= 999
                            and level % 1 == 0 and ValidTime(seconds) then return true end
                    end
                end
            end
        end
    end
    return false
end

function ns.GetLevelHistoryCharacters()
    local current = ns.SyncLevelHistory()
    local choices = {}
    for key, character in pairs(Store()) do
        if type(character) == "table" and type(character.name) == "string"
            and (HasRecordedIntervals(character) or key == current and samples and ns.IsDebugEnabled()) then
            choices[#choices + 1] = { value = key, label = character.name }
        end
    end
    table.sort(choices, function(a, b)
        if a.value == current then return b.value ~= current end
        if b.value == current then return false end
        return a.label < b.label
    end)
    return choices, current
end

function ns.SetLevelHistorySamples(enabled)
    if enabled and not ns.IsDebugEnabled() then return false end
    samples = enabled and {} or nil
    if samples then
        for _, flavor in ipairs({ "retail", "forever" }) do
            local record = { times = {}, bests = {} }
            for level = 1, HistoryLevelCap(flavor) - 1 do
                record.times[level], record.bests[level] = SAMPLE_LEVEL_SECONDS, SAMPLE_LEVEL_SECONDS
            end
            samples[flavor] = record
        end
    end
    if ns.RefreshLevelHistoryOptions then ns.RefreshLevelHistoryOptions(enabled == true) end
    return true
end

function ns.GetLevelHistoryView(key, flavor)
    local current = ns.SyncLevelHistory()
    local characters = Store()
    key = characters[key] and key or current
    local character = characters[key]
    local record = FlavorRecord(character, flavor)
    local sample = samples and ns.IsDebugEnabled() and key == current
    if sample then record = samples[flavor] end
    local cap = HistoryLevelCap(flavor)
    local view = { name = character.name, rows = {}, total = 0, count = 0, cap = cap, sample = sample }
    for level = 1, cap - 1 do
        local row = { level = level, time = record.times[level] }
        if not ValidTime(row.time) then row.time = nil end
        if sample then
            row.accountBest, row.owner = record.bests[level], character.name
        else
            for _, other in pairs(characters) do
                local otherRecord = type(other) == "table" and type(other.flavors) == "table" and other.flavors[flavor]
                local best = type(otherRecord) == "table" and type(otherRecord.bests) == "table" and otherRecord.bests[level]
                if ValidTime(best) and (not row.accountBest or best < row.accountBest) then
                    row.accountBest, row.owner = best, other.name
                end
            end
        end
        if row.time then view.total, view.count = view.total + row.time, view.count + 1 end
        view.rows[#view.rows + 1] = row
    end
    return view
end

local function FormatTime(seconds)
    if not ValidTime(seconds) then return "-" end
    seconds = math.floor(seconds)
    if seconds >= 3600 then return string.format("%d:%02d:%02d", math.floor(seconds / 3600), math.floor(seconds / 60) % 60, seconds % 60) end
    return string.format("%02d:%02d", math.floor(seconds / 60), seconds % 60)
end

local HISTORY_LABELS = { "Level", "Recorded time", "Personal best" }
local HISTORY_COLUMN_STARTS = { 0, .30, .65 }

local function UpdateHistorySummary(frame, view, width)
    frame.summary = frame.summary or frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.summary:SetText((view.sample and ("|cffffcc33" .. ns.L("Sample history (not saved)") .. "|r\n") or "")
        .. view.name .. "\n" .. ns.L("Recorded: %d / %d", view.count, view.cap - 1)
        .. "   " .. ns.L("Total: %s", FormatTime(view.total)))
    frame.summary:ClearAllPoints()
    frame.summary:SetPoint("TOPLEFT", frame, "TOPLEFT", 8, -6)
    return ns.WrapOptionsText(frame.summary, width - 16) + 20
end

local function LayoutHistoryHeaders(frame, width, top)
    frame.headers = frame.headers or {}
    local headerHeight = 0
    for column, label in ipairs(HISTORY_LABELS) do
        local header = frame.headers[column] or frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        frame.headers[column] = header
        header:SetText(ns.L(label))
        header:ClearAllPoints()
        header:SetPoint("TOPLEFT", frame, "TOPLEFT", 8 + width * HISTORY_COLUMN_STARTS[column], -top)
        local columnWidth = width * (column == 1 and .30 or .35) - 16
        headerHeight = math.max(headerHeight, ns.WrapOptionsText(header, columnWidth))
    end
    return top + headerHeight + 8
end

local function CreateHistoryRow(frame)
    local row = CreateFrame("Frame", nil, frame)
    row.background = row:CreateTexture(nil, "BACKGROUND")
    row.background:SetAllPoints(row)
    row.bar = row:CreateTexture(nil, "BORDER")
    row.bar:SetColorTexture(.15, .65, .7, .12)
    row.bar:SetPoint("BOTTOMLEFT", row, "BOTTOMLEFT", 0, 0)
    row.bar:SetHeight(2)
    row.texts = {}
    for column = 1, 3 do
        row.texts[column] = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    end
    row.ownerText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.ownerText:SetTextColor(.65, .75, .68)
    row:EnableMouse(true)
    row:SetScript("OnEnter", function(self)
        if not GameTooltip then return end
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(self.texts[1]:GetText())
        GameTooltip:AddLine(ns.L("Personal best") .. ": " .. FormatTime(self.data.accountBest), .4, .85, 1)
        if self.data.owner then GameTooltip:AddLine(self.data.owner, 1, 1, 1) end
        GameTooltip:Show()
    end)
    row:SetScript("OnLeave", function() if GameTooltip then GameTooltip:Hide() end end)
    row:SetScript("OnHide", function() if GameTooltip then GameTooltip:Hide() end end)
    return row
end

local function LayoutHistoryRow(row, record, index, width, top, longestTime)
    row.data = record
    row:ClearAllPoints()
    row:SetPoint("TOPLEFT", row:GetParent(), "TOPLEFT", 0, -top)
    -- Keep the realm in the tooltip; the list only needs the character's name.
    local recordHolder = record.owner and (record.owner:match("^(.-) %- ") or record.owner)
    local ownerWidth = width * .35 - 16
    row.ownerText:ClearAllPoints()
    row.ownerText:SetPoint("TOPLEFT", row, "TOPLEFT", 8 + width * HISTORY_COLUMN_STARTS[3], -22)
    row.ownerText:SetText(recordHolder or "")
    row.ownerText:SetShown(recordHolder ~= nil)
    local height = recordHolder and math.max(28, 28 + ns.WrapOptionsText(row.ownerText, ownerWidth)) or 28
    row:SetSize(width, height)
    row.background:SetColorTexture(1, 1, 1, index % 2 == 0 and .045 or .015)
    row.bar:SetWidth(math.max(1, width * (record.time or 0) / longestTime))
    row.bar:SetShown(record.time ~= nil)
    local values = {
        tostring(record.level) .. " - " .. tostring(record.level + 1),
        FormatTime(record.time), FormatTime(record.accountBest),
    }
    for column, text in ipairs(row.texts) do
        text:ClearAllPoints()
        local columnStart = 8 + width * HISTORY_COLUMN_STARTS[column]
        if column == 3 and recordHolder then
            text:SetPoint("TOPLEFT", row, "TOPLEFT", columnStart, -5)
        else
            text:SetPoint("LEFT", row, "LEFT", columnStart, 0)
        end
        text:SetWidth(width * (column == 1 and .30 or .35) - 16)
        text:SetWordWrap(false)
        text:SetJustifyH("LEFT")
        text:SetText(values[column])
        if column == 3 then text:SetTextColor(.4, 1, .55)
        else text:SetTextColor(.9, .9, .9) end
    end
    row:Show()
    return height
end

-- Rows stay in the native Options scroll frame and are reused between visits.
function ns.LayoutLevelHistory(frame, width)
    local view = ns.GetLevelHistoryView(frame.character, frame.flavor or ns.GetCurrentFlavor())
    local top = LayoutHistoryHeaders(frame, width, UpdateHistorySummary(frame, view, width))
    local longestTime = 1
    for _, record in ipairs(view.rows) do longestTime = math.max(longestTime, record.time or 0) end
    frame.rows = frame.rows or {}
    for index, record in ipairs(view.rows) do
        local row = frame.rows[index] or CreateHistoryRow(frame)
        frame.rows[index] = row
        top = top + LayoutHistoryRow(row, record, index, width, top, longestTime)
    end
    for index = #view.rows + 1, #frame.rows do frame.rows[index]:Hide() end
    frame:SetHeight(top + 8)
    return top + 8
end
