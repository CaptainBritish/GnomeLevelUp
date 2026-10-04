local ADDON_NAME, ns = ...

-- These are the settings used when the addon starts for the first time.
local defaults = {
    enabled = true,
    playSound = true,
    duration = 7,       -- seconds the cinematic stays up before auto-hiding
    scale = 1.0,
    frameStrata = "HIGH",
    printInstructions = true,
    introShown = false,
    waitForCombatEnd = true, -- delay showing the screen until combat ends
    soundChoice = "LEVELUP",  -- key into ns.SOUND_CHOICES
    soundChannel = "Master",  -- "Master" | "SFX" | "Music" | "Ambience" | "Dialog"
    customSoundFile = nil,    -- e.g. "Interface\\AddOns\\GnomeLevelUp\\Sounds\\MyJingle.ogg"
    forceFlavor = "auto", -- "auto" | "retail" | "forever"
    autoScanTrainers = true,
    scanProfessionTrainers = false,
    showWeaponSkills = false,
    showTrainerCosts = false,
    showOnlyCurrentLevelSkills = false,
    showLevelTime = false,
    hideBlizzardLevelUp = true,
    bgOpacity = 0.70,           -- background darkness at its peak (0-1)
    animSpeedMultiplier = 1.0,  -- higher = faster animations
    reducedMotion = false,       -- skip entrance/exit movement and fades
    statSlideDirection = "alternate", -- "alternate" | "left" | "right"
    customFontPath = nil,       -- nil = default (Friz Quadrata)
    framePosition = { point = "CENTER", relativePoint = "CENTER", x = 0, y = 90 },
    minimapButtonShown = true,
    minimapAngle = 225,
    portraitMode = "class",
    debugEnabled = false,

    colors = {
        title           = { 1.00, 0.82, 0.00 },
        level           = { 1.00, 0.82, 0.00 },
        statsHeader     = { 1.00, 0.82, 0.00 },
        statLabel       = { 1.00, 1.00, 1.00 },
        statNew         = { 0.18, 0.80, 0.44 },
        abilitiesHeader = { 1.00, 0.82, 0.00 },
        abilityName     = { 0.25, 0.88, 1.00 }, -- doubles as the icon border colour
    },
}
ns.defaults = defaults

local function PrintStartupInstructions()
    if not ns.db or ns.db.printInstructions == false or ns.db.introShown then return end
    print('GnomeLevelUp active! Make sure to visit your class trainer to cache available skills. If you\'re updating to a new version and experiencing any issues, use the "Clear Scanned Data" option in the menu or type /glu cleartraining.')
    ns.db.introShown = true
end
ns.PrintStartupInstructions = PrintStartupInstructions

-- Copy nested settings so a reset cannot share tables with the defaults.
local function CopySetting(value)
    if type(value) ~= "table" then return value end
    local out = {}
    for key, nestedValue in pairs(value) do out[key] = CopySetting(nestedValue) end
    return out
end
ns.CopyValue = CopySetting

-- Fill in settings added after an older version was saved.
local function MergeMissingSettings(db, defaultsTable)
    for key, defaultValue in pairs(defaultsTable) do
        if type(defaultValue) == "table" then
            if type(db[key]) ~= "table" then db[key] = {} end
            MergeMissingSettings(db[key], defaultValue)
        elseif db[key] == nil then
            db[key] = defaultValue
        end
    end
end

local function InitDB()
    -- Load saved settings and fill in anything that is missing.
    GnomeLevelUpDB = GnomeLevelUpDB or {}
    MergeMissingSettings(GnomeLevelUpDB, defaults)
    if GnomeLevelUpDB.forceFlavor ~= "auto"
        and GnomeLevelUpDB.forceFlavor ~= "retail"
        and GnomeLevelUpDB.forceFlavor ~= "forever" then
        GnomeLevelUpDB.forceFlavor = "auto"
    end
    ns.db = GnomeLevelUpDB
end
ns.InitDB = InitDB

local function EnsureDatabase()
    if not ns.db then InitDB() end
    return ns.db
end
ns.EnsureDatabase = EnsureDatabase

function ns.IsDebugEnabled()
    return ns.db and ns.db.debugEnabled == true
end

function ns.IsAddonEnabled()
    return not ns.db or ns.db.enabled ~= false
end

function ns.SetAddonEnabled(enabled)
    EnsureDatabase()
    ns.db.enabled = enabled ~= false
    if not ns.db.enabled then
        ns.CloseLevelUp()
        if ns.RestoreBlizzardBanner then ns.RestoreBlizzardBanner() end
    elseif ns.SuppressBlizzardBanner then
        ns.SuppressBlizzardBanner()
    end
end

function ns.ResetOptionsToDefaults()
    -- Restore the settings page to the default values.
    for _, key in ipairs({
        "playSound", "soundChoice", "soundChannel", "customSoundFile",
        "enabled", "duration", "scale", "autoScanTrainers", "scanProfessionTrainers", "showWeaponSkills", "showTrainerCosts", "showOnlyCurrentLevelSkills", "showLevelTime", "hideBlizzardLevelUp",
        "bgOpacity", "animSpeedMultiplier", "reducedMotion", "statSlideDirection", "customFontPath",
        "waitForCombatEnd", "forceFlavor", "frameStrata", "printInstructions",
        "framePosition", "minimapButtonShown", "minimapAngle", "portraitMode", "debugEnabled",
    }) do
        ns.db[key] = CopySetting(defaults[key])
    end
    ns.db.colors = CopySetting(defaults.colors)
    ns.ApplyBackgroundOpacity(ns.db.bgOpacity)
    ns.ApplyFont(ns.db.customFontPath)
    ns.ApplyColors()
    ns.ApplyFrameStrata(ns.db.frameStrata)
    ns.SuppressBlizzardBanner()
    ns.SetMinimapButtonShown(ns.db.minimapButtonShown)
    ns.RefreshClassIcon()
    ns.PositionFrame(ns.levelUpFrame)
    ns.RefreshBlizzardSuppression()
    ns.RefreshOptionsPanel()
end


ns.SOUND_CHOICES = {
    { value = "LEVELUP", label = "Level Up (default)",  id = (SOUNDKIT and SOUNDKIT.LEVELUP) or 888 },
    { value = "QUEST",   label = "Quest Complete",      id = (SOUNDKIT and SOUNDKIT.IG_QUEST_LIST_COMPLETE) or 878 },
    { value = "READY",   label = "Ready Check",         id = (SOUNDKIT and SOUNDKIT.READY_CHECK) or 8960 },
    { value = "AUCTION", label = "Auction Window Open", id = (SOUNDKIT and SOUNDKIT.AUCTION_WINDOW_OPEN) or 5274 },
    { value = "ALARM",   label = "Alarm Clock",         id = (SOUNDKIT and SOUNDKIT.ALARM_CLOCK_WARNING_3) or 18871 },
}

-- Sound channels that the player can choose from.
ns.SOUND_CHANNELS = {
    { value = "Master",   label = "Master" },
    { value = "SFX",      label = "Sound Effects" },
    { value = "Music",    label = "Music" },
    { value = "Ambience", label = "Ambience" },
    { value = "Dialog",   label = "Dialog" },
}

ns.MODE_CHOICES = {
    { value = "auto",    label = "Auto-detect" },
    { value = "retail",  label = "Retail" },
    { value = "forever", label = "WoW: Forever" },
}

-- The two portrait styles shown at the top of the level-up panel.
ns.PORTRAIT_CHOICES = {
    { value = "class",  label = "Class icon" },
    { value = "player", label = "Player portrait" },
}


ns.STRATA_CHOICES = {
    { value = "BACKGROUND",          label = "Background" },
    { value = "LOW",                 label = "Low" },
    { value = "MEDIUM",              label = "Medium" },
    { value = "HIGH",                label = "High" },
    { value = "DIALOG",              label = "Dialog" },
    { value = "FULLSCREEN",          label = "Fullscreen" },
    { value = "FULLSCREEN_DIALOG",   label = "Fullscreen Dialog" },
    { value = "TOOLTIP",             label = "Tooltip (highest)" },
}

function ns.PlayLevelUpSound(force)
    -- Play a custom sound or one of the built-in sounds.
    local db = ns.db or {}
    if db.playSound == false and not force then return end

    local function PlaySelectedSound()
        local channel = db.soundChannel or "Master"
        if db.customSoundFile and db.customSoundFile ~= "" then
            PlaySoundFile(db.customSoundFile, channel)
            return
        end

        local wanted = db.soundChoice or "LEVELUP"
        for _, choice in ipairs(ns.SOUND_CHOICES) do
            if choice.value == wanted then
                PlaySound(choice.id, channel)
                return
            end
        end
        PlaySound(ns.SOUND_CHOICES[1].id, channel)
    end

    local wanted = db.soundChoice or "LEVELUP"
    if wanted == "LEVELUP" and not db.customSoundFile
        and db.hideBlizzardLevelUp ~= false
        and ns.WithLevelUpSoundsUnmuted then
        -- The native files stay muted; briefly unmute only for our replacement.
        ns.WithLevelUpSoundsUnmuted(PlaySelectedSound)
    else
        PlaySelectedSound()
    end
end


function ns.PreviewLevelUp()
    -- Use a predictable example so the options preview does not depend on live data.
    EnsureDatabase()
    -- A preview does not fire PLAYER_LEVEL_UP, so queue the popup cleanup below.
    local currentLevel = UnitLevel("player")

    local trainerAbilities = { { id = 0, name = "Example Ability" } }
    for _, trainingAbility in ipairs(ns.GetAllTrainableUpToLevel(currentLevel)) do
        trainerAbilities[#trainerAbilities + 1] = trainingAbility
    end

    local unlearnedWeaponSkills = ns.GetUnlearnedWeaponSkills(currentLevel)
    if ns.SuppressBlizzardBanner then ns.SuppressBlizzardBanner() end
    ns.ShowLevelUp(currentLevel, {
        { name = STRENGTH or "Strength", old = 20, new = 23 },
        { name = STAMINA or "Stamina", old = 22, new = 27 },
        { name = INTELLECT or "Intellect", old = 15, new = 17 },
    }, trainerAbilities, unlearnedWeaponSkills, ns.GetCurrentLevelPlayedTime and ns.GetCurrentLevelPlayedTime())
    if ns.QueueBlizzardSuppression then ns.QueueBlizzardSuppression() end
end


local frame = CreateFrame("Frame")
ns.eventFrame = frame

-- Listen for addon setup, login, and level-up events.
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("PLAYER_LEVEL_UP")

frame:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" then
        local loadedAddon = ...
        if loadedAddon == ADDON_NAME then
            InitDB()
            if ns.MergeSavedTrainerData then
                ns.MergeSavedTrainerData()
            end
            PrintStartupInstructions()
            if ns.ApplyBackgroundOpacity then
                ns.ApplyBackgroundOpacity(ns.db.bgOpacity)
            end
            if ns.ApplyFont then
                ns.ApplyFont(ns.db.customFontPath)
            end
            if ns.ApplyColors then
                ns.ApplyColors()
            end
            if ns.ApplyFrameStrata then
                ns.ApplyFrameStrata(ns.db.frameStrata)
            end
        end
    elseif event == "PLAYER_LOGIN" then
        EnsureDatabase()
        if ns.RefreshBaseline then
            ns.RefreshBaseline()
        end
        if ns.GetTrainerCatalogIndex and #ns.GetTrainerCatalogIndex() > 0
            and ns.MarkKnownTrainerSkills and ns.SnapshotSpellBook then
            ns.MarkKnownTrainerSkills(ns.SnapshotSpellBook())
        end
    elseif event == "PLAYER_LEVEL_UP" then
        if ns.HandleLevelUp then
            ns.HandleLevelUp(...)
        end
    end
end)


SLASH_GNOMELEVELUP1 = "/glu"
SlashCmdList["GNOMELEVELUP"] = function(msg)
    EnsureDatabase()
    msg = (msg or ""):lower()
    msg = msg:match("^%s*(.-)%s*$") -- trim

    if msg == "test" then
        ns.PreviewLevelUp()
    elseif msg == "sound" then
        ns.db.playSound = not ns.db.playSound
        print("|cff3fe0ffGnomeLevelUp|r: sound " .. (ns.db.playSound and "ON" or "OFF"))
    elseif msg:match("^duration") then
        local n = tonumber(msg:match("(%d+)"))
        if n then
            ns.db.duration = math.max(1, math.min(60, n))
            print("|cff3fe0ffGnomeLevelUp|r: duration set to " .. ns.db.duration .. "s")
        else
            print("|cff3fe0ffGnomeLevelUp|r: current duration is " .. (ns.db.duration or 7) .. "s. Use /glu duration <seconds>")
        end
    elseif msg:match("^flavor") or msg:match("^mode") then
        local choice = msg:match("%s+(%a+)")
        if choice == "retail" or choice == "forever" or choice == "auto" then
            ns.db.forceFlavor = choice
            if ns.InvalidateTrainerIndex then ns.InvalidateTrainerIndex() end
            print("|cff3fe0ffGnomeLevelUp|r: mode set to " .. choice
                .. " (currently resolves to \"" .. ns.GetCurrentFlavor() .. "\")")
        else
            print("|cff3fe0ffGnomeLevelUp|r: currently \"" .. (ns.db.forceFlavor or "auto")
                .. "\" (resolves to \"" .. ns.GetCurrentFlavor() .. "\"). Use /glu mode <retail|forever|auto>")
        end
    elseif msg == "scan" then
        ns.db.autoScanTrainers = not ns.db.autoScanTrainers
        print("|cff3fe0ffGnomeLevelUp|r: trainer auto-scan " .. (ns.db.autoScanTrainers and "ON" or "OFF"))
    elseif msg:match("^scanprof") then
        ns.db.scanProfessionTrainers = not ns.db.scanProfessionTrainers
        if ns.InvalidateTrainerIndex then ns.InvalidateTrainerIndex() end
        print("|cff3fe0ffGnomeLevelUp|r: scanning profession trainers "
            .. (ns.db.scanProfessionTrainers and "ON" or "OFF"))
    elseif msg == "cleartraining" then
        if ns.ClearScannedTrainerData then
            ns.ClearScannedTrainerData()
            print("|cff3fe0ffGnomeLevelUp|r: cleared all scanned trainer data. Visit a trainer again to re-scan it.")
        end
    elseif msg == "debug" or msg:match("^debug%s+") then
        local value = msg:match("^debug%s+(%a+)$")
        if value == "on" then
            ns.db.debugEnabled = true
        elseif value == "off" then
            ns.db.debugEnabled = false
        else
            ns.db.debugEnabled = not ns.db.debugEnabled
        end
        if ns.RefreshOptionsPanel then ns.RefreshOptionsPanel() end
        print("|cff3fe0ffGnomeLevelUp|r: debug " .. (ns.db.debugEnabled and "ON" or "OFF"))
    elseif msg == "dumptraining" then
        if not ns.IsDebugEnabled() then
            print("|cff3fe0ffGnomeLevelUp|r: debug is OFF. Use /glu debug on first.")
        elseif ns.DumpTrainerData then
            ns.DumpTrainerData()
        end
    elseif msg == "testtrainer" then
        if not ns.IsDebugEnabled() then
            print("|cff3fe0ffGnomeLevelUp|r: debug is OFF. Use /glu debug on first.")
        elseif ns.TestTrainerList then
            ns.TestTrainerList()
        end
    elseif msg == "combat" then
        ns.db.waitForCombatEnd = not ns.db.waitForCombatEnd
        print("|cff3fe0ffGnomeLevelUp|r: waiting for combat to end before showing - "
            .. (ns.db.waitForCombatEnd and "ON" or "OFF"))
    elseif msg == "options" or msg == "config" then
        if ns.ToggleOptions then
            ns.ToggleOptions()
        end
    else
        print("|cff3fe0ffGnomeLevelUp|r commands:")
        print("  /glu test          - preview the level-up screen")
        print("  /glu options       - open the settings page (also under Options > AddOns)")
        print("  /glu sound         - toggle the level-up sound")
        print("  /glu duration N    - set how long the screen stays up (seconds)")
        print("  /glu mode <x>      - use retail/forever training data, or auto-detect")
        print("  /glu scan          - toggle auto-saving trainer data when you visit a trainer")
        print("  /glu scanprof      - toggle including profession trainers in that scan")
        print("  /glu cleartraining - wipe all scanned trainer data (fixes old bad/duplicate entries)")
        print("  /glu debug [on|off] - enable or disable debug commands (off by default)")
        print("  /glu dumptraining - print cached skills and learned status")
        print("  /glu testtrainer   - print the current unlearned skill list")
        print("  /glu combat        - toggle waiting for combat to end before showing")
    end
end
