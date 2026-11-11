local ADDON_NAME, ns = ...

local MAX_REPORTS, MAX_ADDONS = 5, 150
local PROMPT_INTERVAL = 30
local CHAT_PREFIX = "|cffff4040GnomeLevelUp|r: "
local labels = {
    stats = "Stat capture", portrait = "3D portrait rendering", popup = "Level-up popup",
    screenshot = "Screenshot", sound = "Sound",
}
local settings = {
    "forceFlavor", "language", "waitForCombatEnd", "horizontalMode", "compactMode", "frameStrata",
    "scale", "horizontalScale", "duration", "reducedMotion", "backgroundMode", "backgroundTheme",
    "backgroundChoice", "frameChoice", "portraitMode", "portraitRingChoice", "classColourPortraitBackground",
    "playerPortraitPosition", "playerPortraitScale", "backgroundAnimations", "milestoneAnimations",
    "maxLevelCelebration", "hideBlizzardLevelUp", "showSecondaryStats", "relevantRetailStatsOnly",
    "equalStatWidths", "abbreviateStatNames", "shortenRetailStatTotals", "showOnlyNewSkills",
    "showOnlyCurrentLevelSkills", "showTrainerCosts", "showWeaponSkills", "showWarlockPetSkills",
    "screenshotEveryLevel", "screenshotMilestones", "milestoneInterval", "soundChannel",
    "soundVolume", "playSound", "muteNativeDing", "useThemeSounds", "debugEnabled",
}
local portraitSettings = {
    "portraitModelRotation", "portraitModelX", "portraitModelY", "portraitModelZ",
    "portraitModelScale", "portraitModelMaskSize", "portraitModelViewportSize",
}
local lastPrompt = {}
local window, reportText, title, instructions

local function Read(func, ...)
    if type(func) ~= "function" then return nil end
    local ok, first, second, third, fourth = pcall(func, ...)
    if ok then return first, second, third, fourth end
end

local function SafeValue(limit, value)
    if issecretvalue and issecretvalue(value) then return "<restricted>" end
    local kind = type(value)
    if kind == "string" then
        if #value <= limit then return value end
        -- Drop the last UTF-8 character if the byte limit may have split it.
        return (value:sub(1, limit):gsub("[\194-\244][\128-\191]*$", ""))
    end
    if kind == "boolean" then return value end
    if kind == "number" and value == value and math.abs(value) < math.huge then return value end
end

local function Scalar(value)
    return SafeValue(180, value)
end

local function CopyDetails(source, depth)
    if (issecretvalue and issecretvalue(source)) or type(source) ~= "table" or depth == 0 then return Scalar(source) end
    local copy, count = {}, 0
    for key, value in pairs(source) do
        if type(key) == "string" or type(key) == "number" then
            copy[tostring(key)] = CopyDetails(value, depth - 1)
            count = count + 1
            if count == 40 then break end
        end
    end
    return copy
end

local function ReportStore(create)
    if type(GnomeLevelUpCharacterDB) ~= "table" then
        if not create then return nil end
        GnomeLevelUpCharacterDB = {}
    end
    local reports = GnomeLevelUpCharacterDB.errorReports
    if create and type(reports) ~= "table" then
        reports = {}
        GnomeLevelUpCharacterDB.errorReports = reports
    end
    return type(reports) == "table" and reports or nil
end

local function CaptureAddOns(getMetadata)
    local getCount = C_AddOns and C_AddOns.GetNumAddOns or GetNumAddOns
    local getInfo = C_AddOns and C_AddOns.GetAddOnInfo or GetAddOnInfo
    local isLoaded = C_AddOns and C_AddOns.IsAddOnLoaded or IsAddOnLoaded
    local addons, loadedCount = {}, 0
    local count = Scalar(Read(getCount))
    for index = 1, type(count) == "number" and count or 0 do
        if Scalar(Read(isLoaded, index)) == true then
            loadedCount = loadedCount + 1
            if #addons < MAX_ADDONS then
                local name = Scalar(Read(getInfo, index))
                if type(name) == "string" then
                    addons[#addons + 1] = { name = name, version = Scalar(Read(getMetadata, name, "Version")) }
                end
            end
        end
    end
    table.sort(addons, function(a, b) return a.name < b.name end)
    return addons, loadedCount
end

function ns.IsDialogueUIVisible()
    return Scalar(Read(DUIQuestFrame and DUIQuestFrame.IsVisible, DUIQuestFrame))
end

local function CaptureEnvironment()
    local getMetadata = C_AddOns and C_AddOns.GetAddOnMetadata or GetAddOnMetadata
    local version, build, _, interface = Read(GetBuildInfo)
    local _, race = Read(UnitRace, "player")
    local _, class = Read(UnitClass, "player")
    local screenWidth, screenHeight = Read(GetPhysicalScreenSize)
    local popup = ns.levelUpFrame
    local context = {
        addonVersion = Scalar(Read(getMetadata, ADDON_NAME, "Version")),
        clientVersion = Scalar(version), clientBuild = Scalar(build), interface = Scalar(interface),
        project = Scalar(WOW_PROJECT_ID), clientLocale = Scalar(Read(GetLocale)), locale = Scalar(Read(ns.GetLocale)),
        flavor = Scalar(Read(ns.GetCurrentFlavor)), level = Scalar(Read(UnitLevel, "player")),
        race = Scalar(race), class = Scalar(class), sex = Scalar(Read(UnitSex, "player")),
        specialization = Scalar(Read(C_SpecializationInfo and C_SpecializationInfo.GetSpecialization or GetSpecialization)),
        inCombat = Scalar(Read(UnitAffectingCombat, "player")), combatLockdown = Scalar(Read(InCombatLockdown)),
        form = Scalar(Read(GetShapeshiftFormID)), inVehicle = Scalar(Read(UnitInVehicle, "player")),
        uiAlpha = Scalar(Read(UIParent and UIParent.GetAlpha, UIParent)),
        uiScale = Scalar(Read(UIParent and UIParent.GetEffectiveScale, UIParent)),
        popupVisible = Scalar(Read(popup and popup.IsVisible, popup)),
        popupAlpha = Scalar(Read(popup and popup.GetAlpha, popup)),
        popupWidth = Scalar(Read(popup and popup.GetWidth, popup)),
        popupHeight = Scalar(Read(popup and popup.GetHeight, popup)),
        dialogueOpen = ns.IsDialogueUIVisible(),
        frameRate = Scalar(Read(GetFramerate)), graphicsAPI = Scalar(Read(GetCVar, "gxApi")),
        screenWidth = Scalar(screenWidth), screenHeight = Scalar(screenHeight),
    }
    context.settings = {}
    local db = ns.db or {}
    for _, key in ipairs(settings) do context.settings[key] = Scalar(db[key]) end
    if db.portraitMode == "player3d" then
        for _, key in ipairs(portraitSettings) do context.settings[key] = Scalar(Read(ns.GetPlayerModelSetting, key)) end
    end
    local soundChoice = Scalar(Read(ns.GetLevelUpSoundChoice))
    context.settings.soundChoice = type(soundChoice) == "string" and soundChoice:match("^[%u%d_]+$") or nil
    context.settings.hasCustomSound = type(db.customSoundFile) == "string" and db.customSoundFile ~= ""
    context.addons, context.loadedAddOnCount = CaptureAddOns(getMetadata)
    return context
end

-- xpcall invokes this before unwinding. Keep error objects and protected values out of saved data.
function ns.CaptureErrorTrace(err)
    local stack = Read(debugstack, 2, 24, 8)
    if not stack and debug then stack = Read(debug.traceback, "", 2) end
    return { message = SafeValue(1000, err) or "<unavailable error>", stack = SafeValue(4500, stack) }
end

local function SaveError(code, reason, details, failure)
    local reports = ReportStore(true)
    local now = Read(GetServerTime) or Read(time)
    local context = CopyDetails(details, 4)
    local last = reports[#reports]
    local message = failure and failure.message
    if type(last) == "table" and type(last.details) == "table"
        and last.code == code and last.reason == reason and last.message == message
        and last.details.level == context.level and last.details.source == context.source then
        last.count = (last.count or 1) + 1
        last.lastSeen, last.details = now, context
    else
        reports[#reports + 1] = {
            code = code, reason = reason, message = message, stack = failure and failure.stack,
            count = 1, firstSeen = now, lastSeen = now, uptime = Scalar(Read(GetTime)),
            details = context, environment = CaptureEnvironment(),
        }
        if #reports > MAX_REPORTS then table.remove(reports, 1) end
    end
end

function ns.RecordError(code, reason, details, failure)
    if ns.db and ns.db.enabled == false then return end
    -- Reporting is best effort so a broken optional diagnostic cannot block recovery.
    local ok = pcall(SaveError, code, reason, details or {}, failure)
    if not ok then return end
    local now = Read(GetTime) or 0
    if lastPrompt[code] and now - lastPrompt[code] < PROMPT_INTERVAL then return end
    lastPrompt[code] = now
    print(CHAT_PREFIX .. ns.L("%s error has occurred, please type /glu debugreport and send the information to me!",
        ns.L(labels[code] or "Debug")))
end

function ns.GetDebugReportJSON()
    local reports = ReportStore(false)
    if reports and #reports > 0 then
        return ns.EncodeReportJSON({ addon = ADDON_NAME, schemaVersion = 1, reports = reports,
            statOrder = { "Strength", "Agility", "Stamina", "Intellect", "Spirit" },
        })
    end
end

local function SelectReportText()
    reportText:SetFocus()
    reportText:HighlightText()
end

local function CreateReportWindow()
    window = CreateFrame("Frame", "GnomeLevelUpErrorReport", UIParent, "BackdropTemplate")
    window:SetSize(640, 420)
    window:SetPoint("CENTER")
    window:SetFrameStrata("FULLSCREEN_DIALOG")
    window:SetClampedToScreen(true)
    window:EnableMouse(true)
    window:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", tile = true, tileSize = 32, edgeSize = 24,
        insets = { left = 8, right = 8, top = 8, bottom = 8 },
    })
    local close = CreateFrame("Button", nil, window, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", -2, -2)
    close:SetScript("OnClick", function() window:Hide() end)
    title = window:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 22, -20)
    instructions = window:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    instructions:SetPoint("TOPLEFT", 22, -48)
    instructions:SetWidth(580)
    instructions:SetJustifyH("LEFT")
    local copy = CreateFrame("Button", nil, window, "UIPanelButtonTemplate")
    copy:SetPoint("BOTTOMLEFT", 22, 18)
    copy:SetSize(140, 28)
    copy:SetText(ns.L("Copy"))
    copy:SetScript("OnClick", SelectReportText)
    local scroll = CreateFrame("ScrollFrame", nil, window, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", instructions, "BOTTOMLEFT", 0, -12)
    scroll:SetPoint("BOTTOMRIGHT", window, "BOTTOMRIGHT", -42, 58)
    reportText = CreateFrame("EditBox", nil, scroll)
    reportText:SetMultiLine(true)
    reportText:SetAutoFocus(false)
    reportText:SetMaxLetters(0)
    reportText:SetFontObject(ChatFontNormal)
    reportText:SetWidth(565)
    reportText:SetHeight(260)
    reportText:SetScript("OnEscapePressed", function() window:Hide() end)
    reportText:SetScript("OnTextChanged", function() scroll:UpdateScrollChildRect() end)
    scroll:SetScrollChild(reportText)
    window:SetScript("OnHide", function() reportText:ClearFocus() end)
end

function ns.OpenDebugReport()
    local report = ns.GetDebugReportJSON()
    if not report then
        print(CHAT_PREFIX .. ns.L("No GnomeLevelUp errors have been recorded."))
        return
    end
    if not window then CreateReportWindow() end
    title:SetText(ns.L("Debug report"))
    instructions:SetText(ns.L("Press Ctrl+C to copy."))
    window:Show()
    reportText:SetText(report)
    SelectReportText()
end
