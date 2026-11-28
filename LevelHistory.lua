local ADDON_NAME, ns = ...

-- History is account data, independent of appearance profiles. Legacy records
-- are copied when each character logs in; unvisited characters cannot be read.
local samples
local completedMaxRun
local completedFinalInterval
---@alias GLUTimeRecordComparison {seconds: number, previous: number|nil, personal: boolean, guild: boolean}
local SAMPLE_LEVEL_SECONDS = 20 * 60 * 60

local function HistoryLevelCap(flavor)
    local cap = flavor == "forever" and 60 or (ns.GetLevelCap and ns.GetCurrentFlavor() == "retail" and ns.GetLevelCap() or 90)
    return math.max(2, math.min(1000, tonumber(cap) or 90))
end
local function ValidTime(value)
    return type(value) == "number" and value == value and value >= 0 and value < math.huge
end

local function CharacterIdentity()
    local wire, name, realm = ns.GetPlayerCharacterNames()
    local guid = type(UnitGUID) == "function" and UnitGUID("player")
    return guid or wire, ns.GetCurrentFlavor() == "forever" and name or name .. " - " .. realm
end

local function RefreshStoredNames(characters)
    if ns.GetCurrentFlavor() ~= "forever" or not GetNumGuildMembers or not GetGuildRosterInfo then return end
    for index = 1, math.min(1000, GetNumGuildMembers() or 0) do
        local member = { GetGuildRosterInfo(index) }
        local character = member[17] and characters[member[17]]
        if type(character) == "table" and type(member[1]) == "string" then
            character.name = ns.FormatCharacterName(member[1])
        end
    end
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
    local _, classToken = UnitClass("player")
    character.classToken = classToken or character.classToken
    local legacy = type(GnomeLevelUpCharacterDB) == "table" and GnomeLevelUpCharacterDB or {}
    -- A logged-out character still has its own older SavedVariables file.
    -- Apply account-side resets before importing those records on its next login.
    local reset = tonumber(character.timesResetRevision) or 0
    if (tonumber(legacy.levelHistoryResetRevision) or 0) < reset then
        legacy.levelTimes, legacy.levelBests, legacy.fastestLevelTimes, legacy.maxLevelTimes = nil, nil, nil, nil
        legacy.levelHistoryResetRevision = reset
    end
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
        local totals = type(legacy.maxLevelTimes) == "table" and legacy.maxLevelTimes[flavor]
        record.maxLevelTimes = type(record.maxLevelTimes) == "table" and record.maxLevelTimes or {}
        for cap, seconds in pairs(type(totals) == "table" and totals or {}) do
            if type(cap) == "number" and cap >= 2 and cap <= 1000 and cap % 1 == 0 and ValidTime(seconds) then
                record.maxLevelTimes[cap] = seconds
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

function ns.ResetAccountCharacterTimers(key)
    local current = CharacterIdentity()
    key = key or current
    local characters = Store()
    local character = characters[key]
    if type(character) ~= "table" then return false end
    character.flavors = {}
    character.timesResetRevision = (tonumber(character.timesResetRevision) or 0) + 1
    if key == current and type(GnomeLevelUpCharacterDB) == "table" then
        completedMaxRun = nil
        completedFinalInterval = nil
        GnomeLevelUpCharacterDB.levelTimes, GnomeLevelUpCharacterDB.levelBests, GnomeLevelUpCharacterDB.fastestLevelTimes, GnomeLevelUpCharacterDB.maxLevelTimes = nil, nil, nil, nil
        GnomeLevelUpCharacterDB.levelHistoryResetRevision = character.timesResetRevision
    end
    samples = nil
    if ns.RefreshLevelHistoryOptions then ns.RefreshLevelHistoryOptions() end
    return true
end

-- Reset saved records without touching LevelUp's pending event or /played cache.
function ns.ClearRecordedLevelTimes()
    ns.SyncLevelHistory()
    GnomeLevelUpCharacterDB = type(GnomeLevelUpCharacterDB) == "table" and GnomeLevelUpCharacterDB or {}
    GnomeLevelUpCharacterDB.levelTimes, GnomeLevelUpCharacterDB.fastestLevelTimes, GnomeLevelUpCharacterDB.levelBests = nil, nil, nil
    ns.ResetAccountCharacterTimers()
end

function ns.ClearCharacterLevelTimes(key)
    if not key then return false end
    local current = ns.SyncLevelHistory()
    if key == current then ns.ResetLevelTimers(); return true end
    return ns.ResetAccountCharacterTimers(key)
end

function ns.RecordCompletedLevel(reachedLevel, seconds)
    reachedLevel, seconds = tonumber(reachedLevel), tonumber(seconds)
    if not reachedLevel or reachedLevel % 1 ~= 0 or reachedLevel < 2
        or not seconds or seconds ~= seconds or seconds < 0 or seconds == math.huge then return end
    ns.SyncLevelHistory()
    if ns.NoteGuildLevelCompletion then ns.NoteGuildLevelCompletion(reachedLevel, seconds) end
    if reachedLevel == ns.GetLevelCap() and seconds >= 1 then
        local flavor = ns.GetCurrentFlavor()
        if not completedFinalInterval or completedFinalInterval.level ~= reachedLevel or completedFinalInterval.flavor ~= flavor then
            local previous
            for _, character in pairs(Store()) do
                local record = type(character) == "table" and type(character.flavors) == "table" and character.flavors[flavor]
                local best = record and record.bests and record.bests[reachedLevel - 1]
                if ValidTime(best) and (not previous or best < previous) then previous = best end
            end
            completedFinalInterval = { level = reachedLevel, flavor = flavor, previous = previous }
        end
        completedFinalInterval.seconds = seconds
    end
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
    if ns.PublishGuildLevelTime then ns.PublishGuildLevelTime(reachedLevel - 1, seconds) end
    if ns.RefreshLevelHistoryOptions then ns.RefreshLevelHistoryOptions() end
end

-- Save only a measured completion, rather than a sum of partially recorded levels.
---@return GLUTimeRecordComparison|nil
function ns.GetFinalLevelRecordComparison(level)
    local result = completedFinalInterval
    if not result or result.level ~= level or result.flavor ~= ns.GetCurrentFlavor() then return end
    local personal = not result.previous or result.seconds < result.previous
    local guild = ns.GetGuildLevelCelebration and ns.GetGuildLevelCelebration(level, result.seconds)
    if not personal and not guild then return end
    local previous = result.previous
    if not personal then previous = guild.previous end
    return { seconds = result.seconds, previous = previous, personal = personal, guild = guild ~= nil }
end

---@return GLUTimeRecordComparison|nil
function ns.GetMaxLevelRecordComparison(level)
    local result = completedMaxRun
    if not result or result.level ~= level or result.flavor ~= ns.GetCurrentFlavor() then return end
    local guild = result.guild and ns.GuildRecords and ns.GuildRecords.Enabled()
        and ns.GuildRecords.Identity() == result.guildKey
    if guild then
        local best = ns.GetGuildLevelRecord(level, result.flavor)
        guild = (not best or best.seconds >= result.seconds)
            and not ns.GuildRecords.IsDeleted(level, result.seconds, ns.GuildRecords.OwnName(), result.flavor)
    end
    if not result.personal and not guild then return end
    local previous = result.guildPrevious
    if result.personal then previous = result.personalPrevious end
    return { seconds = result.seconds, previous = previous,
        guild = guild == true, personal = result.personal == true }
end

function ns.RecordMaxLevelTime(seconds)
    local cap, flavor = ns.GetLevelCap(), ns.GetCurrentFlavor()
    if not ValidTime(seconds) or seconds < 1 or seconds > ns.MAX_FULL_RUN_SECONDS then return false end
    ns.SyncLevelHistory()
    GnomeLevelUpCharacterDB = type(GnomeLevelUpCharacterDB) == "table" and GnomeLevelUpCharacterDB or {}
    local db = GnomeLevelUpCharacterDB
    db.maxLevelTimes = type(db.maxLevelTimes) == "table" and db.maxLevelTimes or {}
    db.maxLevelTimes[flavor] = type(db.maxLevelTimes[flavor]) == "table" and db.maxLevelTimes[flavor] or {}
    seconds = math.floor(seconds)
    local previous = db.maxLevelTimes[flavor][cap]
    if ValidTime(previous) and previous <= seconds then return false end
    local personalPrevious
    for _, character in pairs(Store()) do
        local record = type(character) == "table" and type(character.flavors) == "table" and character.flavors[flavor]
        local best = record and record.maxLevelTimes and record.maxLevelTimes[cap]
        if ValidTime(best) and (not personalPrevious or best < personalPrevious) then personalPrevious = best end
    end
    local guild = ns.GuildRecords and ns.GuildRecords.Enabled()
    local guildRecord = guild and ns.GetGuildLevelRecord(cap, flavor)
    local guildPrevious = guildRecord and guildRecord.seconds
    completedMaxRun = { level = cap, flavor = flavor, seconds = seconds,
        personal = not personalPrevious or seconds < personalPrevious, personalPrevious = personalPrevious,
        guild = guild and (not guildPrevious or seconds < guildPrevious), guildPrevious = guildPrevious,
        guildKey = guild and ns.GuildRecords.Identity() }
    db.maxLevelTimes[flavor][cap] = seconds
    ns.SyncLevelHistory()
    if ns.PublishGuildLevelTime then ns.PublishGuildLevelTime(cap, seconds) end
    local saved = db.lastLevelUp and db.lastLevelUp[flavor]
    if saved and saved.level == cap then
        saved.timeToCap, saved.totalComparison = seconds, ns.GetMaxLevelRecordComparison(cap)
        saved.finalComparison = ns.GetFinalLevelRecordComparison(cap)
        if not ValidTime(saved.seconds) and saved.finalComparison then saved.seconds = saved.finalComparison.seconds end
    end
    if ns.RefreshLevelHistoryOptions then ns.RefreshLevelHistoryOptions() end
    if ns.RefreshMaxLevelPlayedTime then ns.RefreshMaxLevelPlayedTime() end
    return true
end

function ns.GetTimeToMaxLevel()
    local cap = ns.GetLevelCap()
    local totals = type(GnomeLevelUpCharacterDB) == "table" and GnomeLevelUpCharacterDB.maxLevelTimes
    totals = type(totals) == "table" and totals[ns.GetCurrentFlavor()]
    if type(totals) == "table" and ValidTime(totals[cap]) then return totals[cap] end
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
    ns.SyncLevelHistory()
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
    else
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
    RefreshStoredNames(Store())
    local choices = {}
    for key, character in pairs(Store()) do
        if type(character) == "table" and type(character.name) == "string"
            and (HasRecordedIntervals(character) or key == current and samples and ns.IsDebugEnabled()) then
            choices[#choices + 1] = { value = key, label = ns.FormatCharacterName(character.name, nil, ns.GetCurrentFlavor() ~= "forever") }
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
    if ns.GuildRecords then ns.GuildRecords.Store(false) end
    local characters = Store()
    RefreshStoredNames(characters)
    key = characters[key] and key or current
    local character = characters[key]
    local record = FlavorRecord(character, flavor)
    local sample = samples and ns.IsDebugEnabled() and key == current
    if sample then record = samples[flavor] end
    local cap = HistoryLevelCap(flavor)
    local view = { name = character.name, classToken = character.classToken, rows = {}, total = 0, count = 0, cap = cap, sample = sample }
    for level = 1, cap do
        local totalRun = level == cap
        local row = { level = level, totalRun = totalRun,
            time = totalRun and record.maxLevelTimes and record.maxLevelTimes[cap] or not totalRun and record.times[level] or nil }
        if not ValidTime(row.time) then row.time = nil end
        if sample and not totalRun then
            row.accountBest, row.owner, row.ownBest = record.bests[level], character.name, true
        elseif not sample then
            for otherKey, other in pairs(characters) do
                local otherRecord = type(other) == "table" and type(other.flavors) == "table" and other.flavors[flavor]
                local bests
                if type(otherRecord) == "table" then
                    if totalRun then bests = otherRecord.maxLevelTimes else bests = otherRecord.bests end
                end
                local best = type(bests) == "table" and bests[level]
                if ValidTime(best) and (not row.accountBest or best < row.accountBest
                    or best == row.accountBest and otherKey == key) then
                    row.accountBest, row.owner, row.ownBest = best, other.name, otherKey == key
                end
            end
        end
        if row.time and not totalRun then view.total, view.count = view.total + row.time, view.count + 1 end
        view.rows[#view.rows + 1] = row
        local guild, guildKey
        if key == current and ns.GetGuildLevelRecord then
            guild = ns.GetGuildLevelRecord(level, flavor)
            guildKey = ns.GuildRecords.Identity()
        elseif ns.GuildRecords then
            guild, guildKey = ns.GuildRecords.CharacterRecord(key, level, flavor)
        end
        if guild then
            row.guildRecord = { level = level, totalRun = totalRun, time = guild.seconds,
                owner = guild.owner, guild = true, flavor = flavor,
                classToken = guild.classToken,
                guildKey = guildKey,
                receivedFrom = guild.receivedFrom, receivedAt = guild.receivedAt }
        end
    end
    return view
end

function ns.FormatLevelClock(seconds)
    seconds = math.max(0, math.floor(tonumber(seconds) or 0))
    if seconds >= 3600 then return string.format("%d:%02d:%02d", math.floor(seconds / 3600), math.floor(seconds / 60) % 60, seconds % 60) end
    return string.format("%02d:%02d", math.floor(seconds / 60), seconds % 60)
end

local function FormatTime(seconds)
    return ValidTime(seconds) and ns.FormatLevelClock(seconds) or "-"
end

local HISTORY_LABELS = { "Level", "Recorded time", "Personal best", "Guild record" }
local HISTORY_COLUMN_STARTS = { 0, .12, .34, .67 }
local HISTORY_COLUMN_WIDTHS = { .12, .22, .33, .33 }
local UNKNOWN_CLASS_COLOR = { .55, .55, .55 }

local function ConfirmGuildRecordDeletion(record)
    if not ns.CanDeleteGuildRecords or not ns.CanDeleteGuildRecords()
        or not StaticPopupDialogs or not StaticPopup_Show then return end
    StaticPopupDialogs.GLU_DELETE_GUILD_RECORD = {
        text = ns.L("Warning: You are about to remove this record for everyone online right now. This is not reversable."),
        button1 = ns.L("Delete"), button2 = ns.L("Cancel"),
        OnAccept = function(_, data)
            if data then ns.DeleteGuildLevelRecord(data.level, data.flavor, data.time, data.owner, data.guildKey) end
        end,
        timeout = 0, whileDead = true, hideOnEscape = true, preferredIndex = 3,
    }
    -- Copy the selection: pooled rows can be reused while the dialog is open.
    StaticPopup_Show("GLU_DELETE_GUILD_RECORD", nil, nil,
        { level = record.level, flavor = record.flavor, time = record.time, owner = record.owner, guildKey = record.guildKey })
end

local function UpdateHistorySummary(frame, view, width)
    frame.summary = frame.summary or frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.summary:SetText((view.sample and ("|cffffcc33" .. ns.L("Sample history (not saved)") .. "|r\n") or "")
        .. ns.FormatCharacterName(view.name, nil, ns.GetCurrentFlavor() ~= "forever") .. "\n"
        .. ns.L("Recorded: %d / %d", view.count, view.cap - 1) .. "   " .. ns.L("Total: %s", FormatTime(view.total)))
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
        header:SetText(ns.L(label));header:ClearAllPoints()
        header:SetPoint("TOPLEFT", frame, "TOPLEFT", 8 + width * HISTORY_COLUMN_STARTS[column], -top)
        headerHeight = math.max(headerHeight, ns.WrapOptionsText(header, width * HISTORY_COLUMN_WIDTHS[column] - 16))
    end
    return top + headerHeight + 8
end

local function ShowRecordTooltip(owner, record, guild)
    if not GameTooltip or not record then return end
    GameTooltip:SetOwner(owner, "ANCHOR_RIGHT")
    GameTooltip:SetText(record.totalRun and ("1–" .. record.level) or ns.L("Level") .. " " .. tostring(record.level + 1), 1, 1, 1)
    GameTooltip:AddLine(ns.L(guild and "Guild record" or "Personal best") .. ": "
        .. FormatTime(guild and record.time or record.accountBest), .4, .85, 1)
    if record.owner then GameTooltip:AddLine(ns.FormatCharacterName(record.owner), 1, 1, 1) end
    if guild and ns.IsDebugEnabled() then
        local source = record.receivedFrom
        local kind = source and (ns.CanonicalCharacterName(source) == ns.CanonicalCharacterName(ns.GuildRecords.OwnName()) and "Local"
            or ns.CanonicalCharacterName(source) == ns.CanonicalCharacterName(record.owner) and "Direct" or "Relayed") or "Unknown"
        GameTooltip:AddLine(ns.L("Received from: %s", source and ns.FormatCharacterName(source) or ns.L("Unknown")), .7, .7, .7)
        local clock, stamp = date or os and os.date, record.receivedAt
        local received = type(stamp) == "number" and stamp > 0 and clock and clock("%Y-%m-%d %H:%M:%S", stamp) or ns.L("Unknown")
        GameTooltip:AddLine(ns.L("Received at: %s", received), .7, .7, .7)
        GameTooltip:AddLine(ns.L("Record source: %s", ns.L(kind)), .7, .7, .7)
    end
    GameTooltip:Show()
end

local function HideTooltip() if GameTooltip then GameTooltip:Hide() end end

local function CreateHistoryRow(frame)
    local row = CreateFrame("Frame", nil, frame)
    row.background = row:CreateTexture(nil, "BACKGROUND");row.background:SetAllPoints(row)
    row.bestHighlight = row:CreateTexture(nil, "BORDER", nil, -1)
    row.guildShade = row:CreateTexture(nil, "BORDER", nil, -1)
    row.bar = row:CreateTexture(nil, "BORDER")
    row.bar:SetColorTexture(.15, .65, .7, .12);row.bar:SetPoint("BOTTOMLEFT", row, "BOTTOMLEFT", 0, 0);row.bar:SetHeight(2)
    row.texts = {}
    for column = 1, 4 do row.texts[column] = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall") end
    row.ownerText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.guildOwnerText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.guildHit = CreateFrame("Frame", nil, row);row.guildHit:EnableMouse(true)
    row.guildHit:SetScript("OnEnter", function(self) ShowRecordTooltip(self, row.data.guildRecord, true) end)
    row.guildHit:SetScript("OnLeave", HideTooltip)
    row.delete = CreateFrame("Button", nil, row.guildHit)
    row.delete:SetSize(24, 20);row.delete:SetPoint("TOPRIGHT", row.guildHit, "TOPRIGHT", -2, -3)
    row.delete.label = row.delete:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.delete.label:SetAllPoints(row.delete);row.delete.label:SetText("[X]");row.delete.label:SetTextColor(1, .4, .4)
    row.delete:SetScript("OnClick", function()
        if row.data and row.data.guildRecord then ConfirmGuildRecordDeletion(row.data.guildRecord) end
    end)
    row.delete:SetScript("OnEnter", function(self)
        if not GameTooltip then return end
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT");GameTooltip:SetText(ns.L("Delete this record for all online users."));GameTooltip:Show()
    end)
    row.delete:SetScript("OnLeave", HideTooltip)
    row:EnableMouse(true)
    row:SetScript("OnEnter", function(self) ShowRecordTooltip(self, self.data, false) end)
    row:SetScript("OnLeave", HideTooltip);row:SetScript("OnHide", HideTooltip)
    return row
end

local function LayoutHistoryRow(row, record, index, width, top, longestTime, classColor)
    row.data = record
    row:ClearAllPoints();row:SetPoint("TOPLEFT", row:GetParent(), "TOPLEFT", 0, -top)
    local guild = record.guildRecord
    local canDelete = guild and guild.guildKey == ns.GuildRecords.Identity()
        and guild.flavor == ns.GetCurrentFlavor() and ns.CanDeleteGuildRecords and ns.CanDeleteGuildRecords()
    row.delete:SetShown(canDelete == true)
    local height = 28
    for column, owner in pairs({ [3] = record.owner or false, [4] = guild and guild.owner or false }) do
        local text = column == 3 and row.ownerText or row.guildOwnerText
        text:ClearAllPoints();text:SetPoint("TOPLEFT", row, "TOPLEFT", 8 + width * HISTORY_COLUMN_STARTS[column], -22)
        text:SetText(owner and ns.FormatCharacterName(owner) or "");text:SetShown(owner ~= false)
        if owner then
            height = math.max(height, 28 + ns.WrapOptionsText(text, width * HISTORY_COLUMN_WIDTHS[column] - 16 - (column == 4 and canDelete and 26 or 0)))
        end
    end
    row:SetSize(width, height)
    row.background:SetColorTexture(1, 1, 1, index % 2 == 0 and .045 or .015)
    row.bestHighlight:ClearAllPoints();row.bestHighlight:SetPoint("TOPLEFT", row, "TOPLEFT", width * HISTORY_COLUMN_STARTS[3], 0)
    row.bestHighlight:SetSize(width * HISTORY_COLUMN_WIDTHS[3], height)
    row.bestHighlight:SetShown(record.ownBest == true and classColor ~= nil)
    if record.ownBest and classColor then row.bestHighlight:SetColorTexture(classColor[1], classColor[2], classColor[3], .30) end
    row.guildHit:ClearAllPoints();row.guildHit:SetPoint("TOPLEFT", row, "TOPLEFT", width * HISTORY_COLUMN_STARTS[4], 0)
    row.guildHit:SetSize(width * HISTORY_COLUMN_WIDTHS[4], height);row.guildHit:SetShown(guild ~= nil)
    row.guildShade:ClearAllPoints();row.guildShade:SetPoint("TOPLEFT", row.guildHit, "TOPLEFT")
    row.guildShade:SetSize(width * HISTORY_COLUMN_WIDTHS[4], height);row.guildShade:SetShown(guild ~= nil)
    local color = guild and ns.CLASS_COLORS[guild.classToken] or UNKNOWN_CLASS_COLOR
    local r,g,b = color[1],color[2],color[3]
    local textR,textG,textB = r+(1-r)*.18,g+(1-g)*.18,b+(1-b)*.18
    row.guildShade:SetColorTexture(r*.82,g*.82,b*.82,.20)
    row.guildOwnerText:SetTextColor(textR,textG,textB);row.ownerText:SetTextColor(.65,.75,.68)
    row.bar:SetWidth(math.max(1, width * (record.time or 0) / longestTime));row.bar:SetShown(record.time ~= nil)
    local values = { record.totalRun and ("1–" .. record.level) or tostring(record.level + 1), FormatTime(record.time), FormatTime(record.accountBest), FormatTime(guild and guild.time) }
    for column,text in ipairs(row.texts) do
        text:ClearAllPoints()
        text:SetPoint("TOPLEFT", row, "TOPLEFT", 8 + width * HISTORY_COLUMN_STARTS[column], -5)
        text:SetWidth(width * HISTORY_COLUMN_WIDTHS[column] - 16 - (column == 4 and canDelete and 26 or 0))
        text:SetWordWrap(false);text:SetJustifyH("LEFT");text:SetText(values[column])
        if column == 4 and guild then text:SetTextColor(textR,textG,textB)
        elseif column == 3 then text:SetTextColor(.4,1,.55)
        else text:SetTextColor(.9,.9,.9) end
    end
    row:Show()
    return height
end

function ns.LayoutLevelHistory(frame, width)
    local mode = ns.IsDebugEnabled() and frame.flavor or ns.GetCurrentFlavor()
    local view = ns.GetLevelHistoryView(frame.character, mode or ns.GetCurrentFlavor())
    local top = LayoutHistoryHeaders(frame, width, UpdateHistorySummary(frame, view, width))
    local classColor = ns.CLASS_COLORS and ns.CLASS_COLORS[view.classToken] or ns.GetClassColor("title")
    local longestTime = 1
    for _,record in ipairs(view.rows) do longestTime = math.max(longestTime, record.time or 0) end
    frame.rows = frame.rows or {}
    for index,record in ipairs(view.rows) do
        local row = frame.rows[index] or CreateHistoryRow(frame);frame.rows[index] = row
        top = top + LayoutHistoryRow(row, record, index, width, top, longestTime, classColor)
    end
    for index = #view.rows+1,#frame.rows do frame.rows[index]:Hide() end
    frame:SetHeight(top+8)
    return top+8
end
