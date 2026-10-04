local ADDON_NAME, ns = ...

-- Keep the button position in saved settings so it stays where the player leaves it.
local button
local dragging = false

local function PositionButton()
    if not button or not Minimap then return end
    local angle = math.rad((ns.db and ns.db.minimapAngle) or 225)
    local radius = Minimap:GetWidth() / 2 + 6
    button:ClearAllPoints()
    button:SetPoint("CENTER", Minimap, "CENTER", math.cos(angle) * radius, math.sin(angle) * radius)
end

local function UpdateAngle()
    -- Save the button's angle around the minimap.
    if not button or not Minimap then return end
    local x, y = GetCursorPosition()
    local scale = Minimap:GetEffectiveScale()
    local centerX, centerY = Minimap:GetCenter()
    x, y = x / scale, y / scale
    ns.db.minimapAngle = math.deg(math.atan2(y - centerY, x - centerX))
    PositionButton()
end

function ns.SetMinimapButtonShown(shown)
    if not button then return end
    if shown == false then
        button:Hide()
    else
        button:Show()
        PositionButton()
    end
end

local function CreateMinimapButton()
    if button or not Minimap then return end
    if ns.EnsureDatabase then ns.EnsureDatabase() end

    button = CreateFrame("Button", "GnomeLevelUpMinimapButton", Minimap)
    button:SetSize(32, 32)
    button:SetFrameStrata("MEDIUM")
    button:SetFrameLevel(8)
    local highlight = button:CreateTexture(nil, "HIGHLIGHT")
    highlight:SetAllPoints()
    highlight:SetTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
    highlight:SetBlendMode("ADD")
    button:SetHighlightTexture(highlight)
    button:SetNormalTexture("Interface\\AddOns\\GnomeLevelUp\\Textures\\minimap-button.tga")
    button:RegisterForDrag("LeftButton")
    button:RegisterForClicks("AnyUp")

    button:SetScript("OnClick", function(_, mouseButton)
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
    end)
    button:SetScript("OnDragStart", function()
        dragging = true
    end)
    button:SetScript("OnDragStop", function()
        dragging = false
        UpdateAngle()
    end)
    button:SetScript("OnUpdate", function()
        if dragging then UpdateAngle() end
    end)
    button:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:SetText("GnomeLevelUp")
        GameTooltip:AddLine("Click to open options", 1, 1, 1)
        GameTooltip:AddLine("Right-click to toggle the addon", 1, 1, 1)
        GameTooltip:AddLine("Drag to move", 1, 1, 1)
        GameTooltip:Show()
    end)
    button:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    ns.SetMinimapButtonShown(ns.db.minimapButtonShown ~= false)
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", CreateMinimapButton)
