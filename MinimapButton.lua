local ADDON_NAME, ns = ...

local BUTTON_NAME = "GnomeLevelUp"
local ICON_PATH = "Interface\\AddOns\\GnomeLevelUp\\Textures\\minimap-button.tga"
local iconButton

local function GetButtonDatabase()
    if ns.EnsureDatabase then ns.EnsureDatabase() end

    -- LibDBIcon stores the minimap position as an angle in minimapPos.
    if ns.db.minimapPos == nil then
        ns.db.minimapPos = ns.db.minimapAngle or 225
    end
    ns.db.hide = ns.db.minimapButtonShown == false
    return ns.db
end

local function OnClick(_, mouseButton)
    if mouseButton == "RightButton" then
        if ns.SetAddonEnabled then
            ns.SetAddonEnabled(not ns.db.enabled)
        else
            ns.db.enabled = not ns.db.enabled
        end
        print("|cff3fe0ffGnomeLevelUp|r: addon " .. (ns.db.enabled and "ON" or "OFF"))
    elseif ns.ToggleOptions then
        ns.ToggleOptions()
    end
end

local function OnTooltipShow(tooltip)
    tooltip:AddLine("GnomeLevelUp")
    tooltip:AddLine("Click to open options", 1, 1, 1)
    tooltip:AddLine("Right-click to toggle the addon", 1, 1, 1)
    tooltip:AddLine("Drag to move", 1, 1, 1)
end

function ns.SetMinimapButtonShown(shown)
    if not iconButton then return end

    ns.db.minimapButtonShown = shown ~= false
    ns.db.hide = not ns.db.minimapButtonShown
    local dbIcon = LibStub("LibDBIcon-1.0", true)
    if not dbIcon then return end

    if ns.db.hide then
        dbIcon:Hide(BUTTON_NAME)
    else
        dbIcon:Show(BUTTON_NAME)
    end
end

local function CreateMinimapButton()
    if iconButton or not Minimap then return end

    local broker = LibStub("LibDataBroker-1.1")
    local dbIcon = LibStub("LibDBIcon-1.0")
    local db = GetButtonDatabase()
    local dataObject = broker:NewDataObject(BUTTON_NAME, {
        type = "launcher",
        icon = ICON_PATH,
        OnClick = OnClick,
        OnTooltipShow = OnTooltipShow,
    })

    db.showInCompartment = true
    dbIcon:Register(BUTTON_NAME, dataObject, db, ICON_PATH)
    iconButton = dbIcon:GetMinimapButton(BUTTON_NAME)
    ns.minimapButton = iconButton
    ns.SetMinimapButtonShown(ns.db.minimapButtonShown ~= false)
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", CreateMinimapButton)
