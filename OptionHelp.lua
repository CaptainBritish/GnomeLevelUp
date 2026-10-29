local ADDON_NAME, ns = ...

-- Shared help is keyed by source labels; widgets translate only when hovered.
ns.OPTION_DESCRIPTIONS = {
    ["Language"] = "Choose the language used by GLU.",
    ["Theme"] = "Choose the popup background and frame style.",
    ["Portrait"] = "Choose the artwork shown in the portrait ring.",
    ["Show pet skills"] = "Show Hunter pet skills and Warlock pet training.",
    ["Ignore mouseover delay"] = "Allow the popup to close while the pointer is over it.",
    ["Use class colors"] = "Use your class colour for popup accents and text.",
    ["Controller glyphs"] = "Choose the controller button symbols shown in hints.",
    ["Show unlearned weapon skills"] = "Show weapon training available to your character.",
    ["Show learning costs"] = "Show the money required to learn abilities.",
    ["Portrait ring"] = "Choose the artwork around the portrait.",
    ["Background"] = "Choose artwork for textured themes.",
    ["Frame"] = "Choose artwork for textured themes.",
    ["Background texture"] = "Stretch or tile the background artwork.",
    ["Background opacity"] = "Adjust how dark the background appears.",
    ["Display duration"] = "Seconds the popup stays visible after its entrance.",
    ["Popup scale"] = "Resize the whole popup in the current layout.",
    ["Stat text size"] = "Resize this text while keeping long lines inside the frame.",
    ["Heading text size"] = "Resize this text while keeping long lines inside the frame.",
    ["Time to Level text size"] = "Resize this text while keeping long lines inside the frame.",
    ["Lock Location"] = "Prevent dragging the popup to a new position.",
    ["Preview Level-Up"] = "Show a test popup without changing level history.",
    ["Reset Appearance"] = "Restore default appearance settings.",
    ["Enable addon"] = "Enable or disable the GLU level-up popup.",
    ["Hide Blizzard level-up toast"] = "Hide Blizzard's visual level-up notification.",
    ["Don't show until combat ends"] = "Delay the popup until combat ends.",
    ["Show minimap button"] = "Show the GLU shortcut on the minimap.",
    ["Allow click-through"] = "Let clicks pass through the popup to the game.",
    ["Frame strata"] = "Choose how high this window sits above other interface elements.",
    ["Equal-width stat text"] = "Align stat labels, totals, arrows and gains in shared columns.",
    ["Abbreviate stat names"] = "Use short stat labels, including secondary stats.",
    ["Screenshot milestones"] = "Take a screenshot after a real milestone popup opens.",
    ["Automatically save trainer data"] = "Save available training information when visiting trainers.",
    ["Include profession trainers"] = "Include profession training in trainer scans.",
    ["Only skills unlocked at this level"] = "Show unlocks from the gained level instead of earlier levels.",
    ["Only display new skills"] = "Hide rank upgrades and show only new abilities.",
    ["Show Warlock pet abilities"] = "Include training abilities for your character's pet.",
    ["Show Hunter pet abilities"] = "Include training abilities for your character's pet.",
    ["Filter grimoires by active pet"] = "Show grimoires for your currently summoned pet.",
    ["Use horizontal scrolling"] = "Scroll long ability lists sideways instead of adding more rows.",
    ["Play sound on level up"] = "Play the selected replacement sound on level-up.",
    ["Mute Blizzard level-up sound"] = "Silence Blizzard's ding when using a replacement sound.",
    ["Sound"] = "Choose a level-up sound; Default keeps Blizzard audio unchanged.",
    ["Sound channel"] = "Choose which game audio channel plays GLU sounds.",
    ["Sound volume"] = "Adjust GLU sound volume where the client supports it.",
    ["Play sound"] = "Preview the selected sound.",
    ["Milestone Animations"] = "Add celebration effects when crossing a ten-level milestone.",
    ["Max Level Celebration"] = "Add celebration effects when reaching the level cap.",
    ["Portrait pulse and starburst"] = "Play the portrait pulse and starburst during the entrance.",
    ["Highlight new abilities"] = "Make newly learned ability icons shine.",
    ["Emphasize stat gains"] = "Animate stat totals and highlight their changes.",
    ["Portrait motes"] = "Show decorative particles around the portrait.",
    ["Background motes"] = "Show drifting particles behind the popup content.",
    ["Frame edge glow"] = "Animate a glow around textured frame edges.",
    ["Portrait and ring settle"] = "Let the portrait ring settle into place during the entrance.",
    ["Reveal dividers"] = "Animate the section divider lines.",
    ["Portrait ring glint"] = "Sweep a bright glint around the portrait ring.",
    ["Slide direction"] = "Choose the direction stat rows slide in from.",
    ["Animation speed"] = "Change animation speed without changing display duration.",
    ["Show text shadows"] = "Add shadows and glow behind popup text.",
    ["Save per Character"] = "Use a separate selected profile for this character.",
    ["Profile"] = "Choose the settings profile to use.",
    ["Clear trainer cache"] = "Remove scanned trainer data; bundled trainer lists remain.",
    ["Reset all options"] = "Restore default addon settings.",
    ["Manage profiles"] = "Open controls to create, rename or delete profiles.",
    ["Changes apply after reloading the UI."] = "Reload the interface to apply pending changes.",
    ["Reload UI"] = "Reload the interface to apply pending changes.",
    ["Import / export"] = "Share settings by copying a profile code.",
    ["Font"] = "Choose the font used by popup text.",
    ["Suspend Preview"] = "Pause a test popup's timeout only while Options is open.",
}
for _, setting in pairs(ns.OPTION_SETTINGS) do
    if setting.description then ns.OPTION_DESCRIPTIONS[setting.label] = setting.description end
end

local descriptionLookup, descriptionLocale

function ns.GetOptionDescription(label)
    if ns.OPTION_DESCRIPTIONS[label] then return ns.OPTION_DESCRIPTIONS[label], label end
    local locale = ns.GetLocale()
    if not descriptionLookup or descriptionLocale ~= locale then
        local lookup = {}
        for key in pairs(ns.OPTION_DESCRIPTIONS) do lookup[ns.L(key)] = key end
        for _, key in ipairs({"Allow click-through", "Ignore mouseover delay"}) do
            lookup[ns.L("%s (recommended for gamepad)", ns.L(key))] = key
        end
        -- Retain only the active language, never arbitrary hovered strings.
        descriptionLookup, descriptionLocale = lookup, locale
    end
    local key = descriptionLookup[label]
    if key then return ns.OPTION_DESCRIPTIONS[key], key end
end

function ns.GetOptionTooltipAnchor(owner)
    local x = owner.GetCenter and owner:GetCenter()
    if type(x) ~= "number" then return "ANCHOR_RIGHT" end
    local ownerScale = owner.GetEffectiveScale and owner:GetEffectiveScale() or 1
    local screenScale = UIParent.GetEffectiveScale and UIParent:GetEffectiveScale() or 1
    return x * ownerScale > UIParent:GetWidth() * screenScale / 2 and "ANCHOR_LEFT" or "ANCHOR_RIGHT"
end

local function ClampOptionTooltip(tooltip)
    if not tooltip.SetClampedToScreen then return end
    if not tooltip.gluHelpClampHook and tooltip.HookScript then
        tooltip.gluHelpClampHook = true
        tooltip:HookScript("OnHide", function(self)
            if self.gluHelpClampWas ~= nil then
                local previous = self.gluHelpClampWas
                self.gluHelpClampWas = nil
                self:SetClampedToScreen(previous)
            end
        end)
    end
    if tooltip.gluHelpClampWas == nil and tooltip.IsClampedToScreen then
        tooltip.gluHelpClampWas = tooltip:IsClampedToScreen()
    end
    tooltip:SetClampedToScreen(true)
end

function ns.ShowOptionTooltip(owner, label, description)
    local shared, key = ns.GetOptionDescription(label)
    description = description or shared
    if not description or not GameTooltip then return end
    GameTooltip:SetOwner(owner, ns.GetOptionTooltipAnchor(owner))
    ClampOptionTooltip(GameTooltip)
    GameTooltip:SetText(ns.L(label))
    GameTooltip:AddLine(ns.L(description), 1, 1, 1, true)
    if (key or label) == "Portrait" then
        GameTooltip:AddLine(ns.L(ns.PORTRAIT_MEMORY_WARNING), 1, .2, .2, true)
    end
    GameTooltip:Show()
end

function ns.BindOptionTooltip(widget, label, isLabel)
    if not widget or not ns.GetOptionDescription(label) then return end
    local owner = widget
    if isLabel then
        owner = widget.gluTooltipFrame
        if not owner then
            owner = CreateFrame("Frame", nil, widget:GetParent())
            owner:SetAllPoints(widget)
            owner.gluHelpOverlay = true
            owner:EnableMouse(true)
            if owner.SetPropagateMouseClicks then owner:SetPropagateMouseClicks(true) end
            widget.gluTooltipFrame = owner
        end
    end
    owner.gluHelpLabel = label
    if not owner.gluHelpBound then
        owner.gluHelpBound = true
        owner:HookScript("OnEnter", function(self) ns.ShowOptionTooltip(self, self.gluHelpLabel) end)
        owner:HookScript("OnLeave", function() GameTooltip:Hide() end)
        owner:HookScript("OnHide", function() GameTooltip:Hide() end)
    end
    return owner
end
