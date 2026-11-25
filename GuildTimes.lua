local _, ns = ...
local data = ns.GuildRecords
local PREFIX, VERSION = "GLUTimeSync", "T4"
local queue, jobs, order, peers, synced, confirmations = {}, {}, {}, {}, {}, {}
local guild, flavor, query, queryUntil, queryDeadline, pending, wait = nil, nil, nil, nil, nil, nil, 0
local pulses = {}
local sentClasses = {}
local completedLevel
local awaitingAuthority, rosterRequested = {}, nil
local frame = CreateFrame("Frame")
frame:Hide()

local function RefreshHistory()
    if ns.RefreshLevelHistoryOptions then ns.RefreshLevelHistoryOptions() end
    if ns.RefreshGuildRecordCelebration then ns.RefreshGuildRecordCelebration() end
end

function ns.NoteGuildLevelCompletion(reached, seconds)
    if not data.ready or not data.Enabled() or not data.ValidInterval(reached - 1, seconds, ns.GetCurrentFlavor()) then return end
    if not completedLevel or completedLevel.reached ~= reached then
        local previous = ns.GetGuildLevelRecord(reached - 1, ns.GetCurrentFlavor())
        completedLevel = { reached = reached, previous = previous and previous.seconds }
    end
    completedLevel.seconds = math.floor(seconds)
end

function ns.GetGuildLevelCelebration(reached, seconds)
    local record = completedLevel
    if not data.Enabled() or not record or record.reached ~= reached or type(seconds) ~= "number"
        or math.floor(seconds) ~= record.seconds or record.previous and record.seconds >= record.previous then return end
    local current = ns.GetGuildLevelRecord(reached - 1, ns.GetCurrentFlavor())
    if current and current.seconds < record.seconds then return end
    if data.IsDeleted(reached - 1, record.seconds, data.OwnName(), ns.GetCurrentFlavor()) then return end
    return { previous = record.previous, seconds = record.seconds }
end

local function Queue(key, text, target)
    for _, packet in ipairs(queue) do
        if packet.key == key then packet.text, packet.target = text, target; return true end
    end
    if #queue >= 128 then return false end
    queue[#queue + 1] = { key = key, text = text, target = target }
    frame:Show()
    return true
end

local function Header(kind, token)
    return VERSION .. "\t" .. kind .. "\t" .. flavor .. "\t" .. (token and token .. "\t" or "")
end

local function QueueClass(owner, classToken, target, token)
    if not data.ValidClass(classToken) then return end
    local key = (target or "GUILD") .. ":" .. (token or "") .. ":" .. owner
    if sentClasses[key] == classToken then return end
    local count = 0; for _ in pairs(sentClasses) do count = count + 1 end
    if count >= 4096 then sentClasses = {} end
    -- Optional metadata is a separate message so older 2.0 clients can still
    -- read the unchanged record and comparison packets.
    if Queue("class:" .. key, Header("K", token) .. owner .. "=" .. classToken, target) then
        sentClasses[key] = classToken
    end
end

local function QueueJob(key, job, firstLevel)
    local previous = jobs[key]
    if not previous then
        if #order >= 1000 then return end
        order[#order + 1] = key
    elseif previous.token == job.token then
        job.nextLevel = math.min(previous.nextLevel, firstLevel or 1)
    end
    job.nextLevel = job.nextLevel or firstLevel or 1
    jobs[key] = job
    frame:Show()
end

local function LevelParts(job, level)
    if job.kind == "S" then
        local seconds = data.Best(level, flavor)
        return { level .. "=" .. (seconds or 0) .. "=" .. data.Fingerprint(level, flavor) }
    end
    if job.kind == "N" then return job.levels[level] and { tostring(level) } or {} end
    if not job.levels[level] then return {} end
    local entries = data.Entries(level, flavor)
    local limit = job.limits and job.limits[level] or 0
    if limit > 0 then
        for index = #entries, 1, -1 do
            local seconds = tonumber(entries[index]:match("^r:%d+=(%d+)="))
            if seconds and seconds > limit then table.remove(entries, index) end
        end
    end
    return entries
end

local function NextJobPacket()
    while #order > 0 do
        local key = table.remove(order, 1)
        local job, entries, size = jobs[key], {}, 0
        while job.nextLevel < data.Cap(flavor) do
            local parts = job.parts or LevelParts(job, job.nextLevel)
            job.parts, job.part = parts, job.part or 1
            while job.part <= #parts do
                local entry = parts[job.part]
                if size + #entry + 1 > 200 then break end
                entries[#entries + 1], size = entry, size + #entry + 1
                local level, owner = entry:match("^r:(%d+)=%d+=(.+)$")
                if owner then QueueClass(owner, data.RecordClass(tonumber(level), owner, flavor), job.target, job.token) end
                job.part = job.part + 1
            end
            if job.part <= #parts then break end
            job.parts, job.part = nil, nil
            job.nextLevel = job.nextLevel + 1
        end
        if job.nextLevel >= data.Cap(flavor) then jobs[key] = nil else order[#order + 1] = key end
        if #entries > 0 then
            return { key = key, target = job.target, text = Header(job.kind, job.token) .. table.concat(entries, ",") }
        end
    end
end

local function MergeLevels(kind, target, token, levels, knownTimes)
    local key = kind .. ":" .. target
    local previous = jobs[key]
    local merged, first = previous and previous.token == token and previous.levels or {}, data.Cap(flavor)
    local limits = previous and previous.token == token and previous.limits or {}
    for level in pairs(levels) do
        merged[level], first = true, math.min(first, level)
        limits[level] = knownTimes and knownTimes[level] or 0
    end
    QueueJob(key, { kind = kind, target = target, token = token, levels = merged, limits = limits }, first)
end

local function StartLoginSync()
    if not data.ready or not data.Enabled() then return end
    local context = data.Identity() .. ":" .. ns.GetCurrentFlavor()
    if synced[context] then return end
    synced[context] = true
    query = string.format("%x%x", math.floor(GetTime() * 1000), math.random(1, 2147483647))
    queryUntil, queryDeadline = GetTime() + 120, GetTime() + 600
    -- Summaries include best times and removal fingerprints, but no names.
    -- Peers exchange full state only for levels whose fingerprints differ.
    local changed = false
    for level = 1, data.Cap(flavor) - 1 do
        local seconds, owner = data.Best(level, flavor)
        if seconds then changed = data.Save(level, seconds, owner, flavor) or changed end
    end
    QueueJob("summary", { kind = "S", token = query })
    wait = math.max(wait, math.random() * 3)
    if changed then RefreshHistory() end
end

local function SendDeletion(level, seconds, owner)
    if not ns.CanDeleteGuildRecords() then return false end
    local _, issuer = data.Authority(data.OwnName())
    if not data.IsDeleted(level, seconds, owner, flavor)
        and not data.AddDeletion(level, seconds, owner, issuer, flavor) then return false end
    Queue("delete:" .. level .. ":" .. seconds .. ":" .. owner,
        Header("X") .. "x:" .. level .. "=" .. seconds .. "=" .. owner .. "=" .. issuer)
    RefreshHistory()
    return true
end

function ns.DeleteGuildLevelRecord(level, mode, expectedSeconds, expectedOwner, expectedGuild)
    if mode ~= ns.GetCurrentFlavor() or not ns.CanDeleteGuildRecords() then return false end
    if expectedGuild and expectedGuild ~= data.Identity() then return false end
    local record = ns.GetGuildLevelRecord(level, mode)
    if not record or record.seconds ~= expectedSeconds or record.owner ~= expectedOwner then return false end
    return SendDeletion(level, record.seconds, record.owner)
end

function ns.PublishGuildLevelTime(level, seconds)
    if not data.ready or not data.Enabled() or not data.ValidInterval(level, seconds, ns.GetCurrentFlavor()) then return end
    if guild ~= data.Identity() or flavor ~= ns.GetCurrentFlavor() then ns.RefreshGuildTimeSync() end
    seconds = math.floor(seconds)
    data.Save(level, seconds, data.OwnName(), ns.GetCurrentFlavor())
    Queue("level:" .. level, VERSION .. "\tP\t" .. ns.GetCurrentFlavor() .. "\t" .. level .. "=" .. seconds)
    QueueClass(data.OwnName(), data.RecordClass(level, data.OwnName(), ns.GetCurrentFlavor()))
end

function ns.RefreshGuildTimeSync()
    if ns.db then ns.db.guildTimeSyncInterval = nil end
    data.Store(false)
    if type(GnomeLevelUpHistoryDB) == "table" then GnomeLevelUpHistoryDB.guilds = nil end
    local nextGuild, nextFlavor = data.Enabled() and data.Identity() or nil, ns.GetCurrentFlavor()
    if guild == nextGuild and flavor == nextFlavor then if guild then StartLoginSync() end; return end
    guild, flavor = nextGuild, nextFlavor
    queue, jobs, order, peers, confirmations, pulses, pending, wait = {}, {}, {}, {}, {}, {}, nil, 0
    awaitingAuthority = {}
    sentClasses = {}
    completedLevel = nil
    query, queryUntil, queryDeadline = nil, nil, nil
    data.RefreshAuthority()
    if guild then StartLoginSync() else frame:Hide(); RefreshHistory() end
end

local function Retryable(result)
    if result == false then return true end
    local codes = Enum and Enum.SendAddonMessageResult
    if codes then
        return codes.AddonMessageThrottle ~= nil and result == codes.AddonMessageThrottle
            or codes.ChannelThrottle ~= nil and result == codes.ChannelThrottle
            or codes.GeneralError ~= nil and result == codes.GeneralError
    end
    -- Forever/older clients may return a boolean instead of an enum.
    return result == false
end

local function DropTarget(target)
    if not target then return end
    for index = #queue, 1, -1 do if queue[index].target == target then table.remove(queue, index) end end
    for index = #order, 1, -1 do
        local key = order[index]
        if jobs[key].target == target then jobs[key] = nil; table.remove(order, index) end
    end
end

local function TargetOnline(target)
    if not target or not GetNumGuildMembers or not GetGuildRosterInfo then return true end
    local canonical = ns.CanonicalCharacterName(target)
    local found = false
    for index = 1, math.min(1000, GetNumGuildMembers() or 0) do
        local member = { GetGuildRosterInfo(index) }
        local name = member[1]
        if name and ns.CanonicalCharacterName(name) == canonical then found = true; return member[9] ~= false end
    end
    return not found -- A partial roster must not discard a valid reply.
end

frame:SetScript("OnUpdate", function(_, elapsed)
    if not pending and #queue == 0 and #order == 0 then frame:Hide(); return end
    if not data.Enabled() or data.Identity() ~= guild then
        queue, jobs, order, pending = {}, {}, {}, nil; frame:Hide(); return
    end
    wait = wait - elapsed
    if wait > 0 then return end
    pending = pending or table.remove(queue, 1) or NextJobPacket()
    if not pending then frame:Hide(); return end
    if not TargetOnline(pending.target) then DropTarget(pending.target); pending = nil; wait = .5; return end
    local ok, result = pcall(C_ChatInfo.SendAddonMessage, PREFIX, pending.text,
        pending.target and "WHISPER" or "GUILD", pending.target)
    if (not ok or Retryable(result)) and (pending.attempts or 0) < 5 then
        pending.attempts = (pending.attempts or 0) + 1
        wait = math.min(16, 2 ^ (pending.attempts - 1))
    else
        local codes = Enum and Enum.SendAddonMessageResult
        if codes and codes.TargetOffline ~= nil and result == codes.TargetOffline then DropTarget(pending.target) end
        pending, wait = nil, .5
    end
end)

local function ParseEntries(values, attributed)
    local entries = {}
    for text in (values .. ","):gmatch("(.-),") do
        local kind, level, seconds, owner, issuer
        if attributed then
            kind, level, seconds, owner, issuer = text:match("^([rx]):(%d+)=(%d+)=([^=]+)=?(.*)$")
            if kind == "r" and issuer ~= "" then return end
            if kind == "x" and not data.ValidGUID(issuer) then return end
        else level, seconds = text:match("^(%d+)=(%d+)$"); kind = "r" end
        level, seconds = tonumber(level), tonumber(seconds)
        if not data.ValidInterval(level, seconds, flavor) or attributed and not data.ValidOwner(owner) then return end
        entries[#entries + 1] = { kind = kind, level = level, seconds = seconds, owner = owner, issuer = issuer }
    end
    return entries
end

local function Peer(sender, token, create)
    local peer = peers[sender]
    if peer and peer.token == token and peer.expires >= GetTime() then return peer end
    if not create then return end
    if peer and GetTime() - peer.started < 30 then return end
    local count = 0; for _ in pairs(peers) do count = count + 1 end
    if not peer and count >= 1000 then return end
    peer = { token = token, hashes = {}, asked = {}, started = GetTime(), expires = GetTime() + 600 }
    peers[sender] = peer
    return peer
end

local function ValidTransaction(sender, token)
    return query and token == query and GetTime() <= queryUntil or Peer(sender, token, false) ~= nil
end

local function HandleSummary(sender, token, values)
    local hashes, times = {}, {}
    for text in (values .. ","):gmatch("(.-),") do
        local level, seconds, hash = text:match("^(%d+)=(%d+)=(%x+)$")
        level, seconds = tonumber(level), tonumber(seconds)
        if not level or level % 1 ~= 0 or level < 1 or level >= data.Cap(flavor) or #hash > 8
            or seconds ~= 0 and not data.ValidInterval(level, seconds, flavor) then return end
        hashes[level], times[level] = hash, seconds
    end
    local peer = Peer(sender, token, true)
    if not peer then return end
    local differing, request = {}, {}
    for level, hash in pairs(hashes) do
        peer.hashes[level] = hash
        if data.Fingerprint(level, flavor) ~= hash then
            differing[level] = true
            if peer.asked[level] ~= hash then request[level], peer.asked[level] = true, hash end
        end
    end
    if next(differing) then MergeLevels("R", sender, token, differing, times) end
    if next(request) then MergeLevels("N", sender, token, request) end
    wait = math.max(wait, math.random() * 3)
end

local function CancelComparison(entry)
    for index = #queue, 1, -1 do
        local packet = queue[index]
        if packet.key == "comparison:" .. entry.level then
            local seconds, owner = packet.text:match("\t%d+=(%d+)=(.+)$")
            seconds = tonumber(seconds)
            if seconds and (entry.seconds < seconds or entry.seconds == seconds and entry.owner <= owner) then table.remove(queue, index) end
        end
    end
end

frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("PLAYER_GUILD_UPDATE")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("GUILD_ROSTER_UPDATE")
frame:RegisterEvent("GUILD_RANKS_UPDATE")
frame:RegisterEvent("CHAT_MSG_ADDON")
frame:SetScript("OnEvent", function(_, event, prefix, text, channel, sender)
    if event ~= "CHAT_MSG_ADDON" then
        if event == "PLAYER_LOGIN" or event == "PLAYER_ENTERING_WORLD" then data.ready = true end
        if C_ChatInfo and C_ChatInfo.RegisterAddonMessagePrefix then C_ChatInfo.RegisterAddonMessagePrefix(PREFIX) end
        data.RefreshAuthority()
        ns.RefreshGuildTimeSync()
        if (event == "PLAYER_LOGIN" or event == "PLAYER_GUILD_UPDATE") and data.Identity()
            and (not rosterRequested or GetTime() - rosterRequested >= 10) then
            local request = C_GuildInfo and C_GuildInfo.GuildRoster or GuildRoster
            if request then rosterRequested = GetTime(); pcall(request) end
        end
        if event == "GUILD_ROSTER_UPDATE" or event == "GUILD_RANKS_UPDATE" then
            local saved = awaitingAuthority; awaitingAuthority = {}
            for _, packet in ipairs(saved) do
                if packet.expires >= GetTime() then
                    if data.Authority(packet.sender) == nil then awaitingAuthority[#awaitingAuthority + 1] = packet
                    else frame:GetScript("OnEvent")(frame, "CHAT_MSG_ADDON", PREFIX, packet.text, packet.channel, packet.sender) end
                end
            end
        end
        if event == "GUILD_ROSTER_UPDATE" or event == "GUILD_RANKS_UPDATE" then RefreshHistory() end
        return
    end
    if prefix ~= PREFIX or not data.ready or not data.Enabled() or data.Identity() ~= guild
        or (channel ~= "GUILD" and channel ~= "WHISPER") or type(text) ~= "string" or #text > 255
        or not data.ValidOwner(sender)
        or ns.CanonicalCharacterName(sender) == ns.CanonicalCharacterName(data.OwnName()) then return end
    local kind, mode, rest = text:match("^T4\t([SNRPCXVK])\t(%a+)\t(.+)$")
    if mode ~= flavor then return end
    if kind == "K" then
        local values = rest
        if channel == "WHISPER" then
            local token
            token, values = rest:match("^(%x+)\t(.+)$")
            if not token or not ValidTransaction(sender, token) then return end
        end
        local owner, classToken = values:match("^([^=]+)=(%u+)$")
        if data.UpdateClass(owner, classToken, flavor) then RefreshHistory() end
        return
    end
    local token, values
    if kind == "S" or kind == "N" or kind == "R" then
        token, values = rest:match("^(%x+)\t(.+)$")
        if not token or #token > 32 then return end
        if kind == "S" then if channel == "GUILD" then HandleSummary(sender, token, values) end; return end
        if channel ~= "WHISPER" or not ValidTransaction(sender, token) then return end
        if kind == "N" then
            local levels = {}
            for textLevel in (values .. ","):gmatch("(.-),") do
                local level = tonumber(textLevel:match("^%d+$"))
                if not level or level < 1 or level >= data.Cap(flavor) then return end
                levels[level] = true
            end
            MergeLevels("R", sender, token, levels)
            return
        end
    else
        if channel ~= "GUILD" then return end
        values = rest
    end
    local attributed = kind == "R" or kind == "X" or kind == "V"
    local entries
    if kind == "C" then
        local level, seconds, owner = values:match("^(%d+)=(%d+)=(.+)$")
        level, seconds = tonumber(level), tonumber(seconds)
        if not data.ValidInterval(level, seconds, flavor) or not data.ValidOwner(owner) then return end
        entries = { { kind = "r", level = level, seconds = seconds, owner = owner } }
    else entries = ParseEntries(values, attributed) end
    if not entries or ((kind == "P" or kind == "X" or kind == "V") and #entries ~= 1) then return end
    if (kind == "X" or kind == "V") and entries[1].kind ~= "x" then return end
    local changed, ignored = false, {}
    local officer, issuer = data.Authority(sender)
    if kind == "X" and officer == nil then
        if #awaitingAuthority < 128 then
            awaitingAuthority[#awaitingAuthority + 1] = { text = text, channel = channel, sender = sender, expires = GetTime() + 60 }
        end
        return
    end
    for _, entry in ipairs(entries) do
        if entry.kind == "x" then
            if kind == "V" then
                if ns.CanDeleteGuildRecords() and data.IsDeleted(entry.level, entry.seconds, entry.owner, flavor) then
                    SendDeletion(entry.level, entry.seconds, entry.owner)
                end
                return
            end
            if kind == "X" and (officer ~= true or issuer ~= entry.issuer) then return end
            if officer == true then
                -- A verified current officer endorses forwarded historical markers.
                changed = data.AddDeletion(entry.level, entry.seconds, entry.owner, issuer, flavor) or changed
            elseif not data.IsDeleted(entry.level, entry.seconds, entry.owner, flavor) then
                -- Ordinary clients cannot authenticate a new deletion. Ask an
                -- officer with an already trusted copy to confirm it on GUILD.
                local key = entry.level .. "=" .. entry.seconds .. "=" .. entry.owner
                ignored[key] = true
                local count = 0; for _ in pairs(confirmations) do count = count + 1 end
                if not confirmations[key] and count < 4096 then
                    confirmations[key] = true
                    Queue("confirm:" .. key, Header("V") .. "x:" .. key .. "=" .. entry.issuer)
                end
            end
        end
    end
    for _, entry in ipairs(entries) do
        if entry.kind == "r" then
            entry.owner = entry.owner or sender
            local key = entry.level .. "=" .. entry.seconds .. "=" .. entry.owner
            if not ignored[key] then changed = data.Save(entry.level, entry.seconds, entry.owner, flavor, sender) or changed end
            CancelComparison(entry)
        end
    end
    if kind == "R" and token == query then queryUntil = math.min(queryDeadline, GetTime() + 120) end
    if kind == "P" then
        local entry = entries[1]
        local best, owner = data.Best(entry.level, flavor)
        if best and best < entry.seconds and (not pulses[entry.level] or GetTime() - pulses[entry.level] >= 5) then
            pulses[entry.level] = GetTime()
            changed = data.Save(entry.level, best, owner, flavor) or changed
            Queue("comparison:" .. entry.level, Header("C") .. entry.level .. "=" .. best .. "=" .. owner)
            QueueClass(owner, data.RecordClass(entry.level, owner, flavor))
            wait = math.max(wait, .5 + math.random() * 2)
        end
    end
    if kind == "X" and changed then
        local level = entries[1].level
        local best, owner = data.Best(level, flavor)
        if best then
            data.Save(level, best, owner, flavor)
            Queue("comparison:" .. level, Header("C") .. level .. "=" .. best .. "=" .. owner)
            QueueClass(owner, data.RecordClass(level, owner, flavor))
            wait = math.max(wait, .5 + math.random() * 2)
        end
    end
    if changed then RefreshHistory() end
end)
