local ADDON_NAME, ns = ...

-- Shared help is keyed by source labels; widgets translate only when hovered.
ns.OPTION_DESCRIPTIONS = {
    ["Reset Theme Hues"] = "Restore the selected background, frame and portrait ring to their default hues. Other saved hue preferences are kept.",
    ["Level History"] = "Review recorded level times and your best times across characters. Hover a row to see which character set the personal best.",
    ["Character"] = "Choose a character whose recorded level times you want to view.",
    ["History mode"] = "View Retail or Forever history. Records are kept separate.",
    ["Reset this character's times"] = "Clear this character's recorded times and bests in both game modes. Other characters are kept.",
    ["Fill sample times (20h)"] = "Fill every level with temporary 20-hour times. New records replace the samples; existing history is not overwritten.",
    ["Clear sample history"] = "Remove the temporary sample times and show real records again.",
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
    ["Background Fill Mode"] = "Choose Fill to preserve proportions and crop excess, Stretch to resize to the frame, or Tile to repeat the artwork.",
    ["Background opacity"] = "Adjust how dark the background appears.",
    ["Display duration"] = "Seconds the popup stays visible after its entrance.",
    ["Popup scale"] = "Resize the whole popup in the current layout.",
    ["Stat text size"] = "Resize this text while keeping long lines inside the frame.",
    ["Heading text size"] = "Resize this text while keeping long lines inside the frame.",
    ["Time to Level text size"] = "Resize this text while keeping long lines inside the frame.",
    ["Lock Location"] = "Prevent dragging the popup to a new position.",
    ["Preview Level-Up"] = "Show a test popup without changing level history. Right-click to choose the number of abilities.",
    ["Reset Appearance"] = "Restore default appearance settings.",
    ["Enable addon"] = "Enable or disable the GLU level-up popup.",
    ["Hide Blizzard level-up toast"] = "Hide Blizzard's visual level-up notification.",
    ["Don't show until combat ends"] = "Delay the popup until combat ends.",
    ["Show minimap button"] = "Show the GLU shortcut on the minimap.",
    ["Allow click-through"] = "Let clicks pass through the popup to the game.",
    ["Frame strata"] = "Choose how high this window sits above other interface elements.",
    ["Equal-width stat text"] = "Align stat labels, totals, arrows and gains in shared columns.",
    ["Switch to secondary stats at"] = "Choose the percentage of display time spent on primary stats.",
    ["Abbreviate stat names"] = "Use short stat labels, including secondary stats.",
    ["Screenshot milestones"] = "Take a screenshot when a real level-up matches the selected milestone interval.",
    ["Screenshot every level"] = "Take a screenshot after every real level-up.",
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
    ["Milestone interval"] = "Choose how often milestone animations and screenshots trigger. Max-level animations use their own toggle.",
    ["Milestone Animations"] = "Add celebration effects at the selected milestone interval.",
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

-- Shared wording covers every mouse-menu control as well as controller rows.
-- Repeated tuning controls name their specific target in the tooltip title.
local extraDescriptions = {
    ["Section padding"] = "Adjust the space between popup sections.",
    ["Check trainer lists for catalogue changes"] = "Compare trainer services with the bundled catalogue and offer a report when they differ.",
    ["Export trainer report"] = "Open saved trainer differences and instructions for exporting a report.",
    ["Show all available grimoires"] = "Include available Warlock grimoires for every demon instead of only the active pet.",
    ["Custom sound file"] = "Enter an addon-relative OGG file path for the custom level-up sound.",
    ["Registered custom sound"] = "Choose a custom sound registered by this addon or SharedMedia.",
    ["Enable debug commands"] = "Show advanced tuning controls, test commands and performance counters.",
    ["Print performance report"] = "Print measured addon timings in chat. Debug mode must be enabled to collect them.",
    ["Reset performance data"] = "Clear performance counters before measuring another popup.",
    ["Mode"] = "Choose automatic client detection or force Retail or Forever rules.",
    ["Refresh Cache Status"] = "Update the displayed trainer-cache information.",
    ["Profile name"] = "Enter a name to create a profile or rename the current one.",
    ["Create profile"] = "Save the current options as a new profile with the entered name.",
    ["Rename profile"] = "Rename the selected profile. The Default profile cannot be renamed.",
    ["Delete profile"] = "Delete the selected profile after confirmation. The Default profile cannot be deleted.",
    ["Reset to Defaults"] = "Restore all options to their defaults; recorded level times and trainer reports remain.",
    ["3D model depth"] = "Move the 3D portrait closer to or farther from the camera.",
    ["3D model horizontal position"] = "Move the 3D portrait left or right inside its viewport.",
    ["3D model vertical position"] = "Move the 3D portrait up or down inside its viewport.",
    ["3D model rotation (degrees)"] = "Turn the 3D portrait around its vertical axis.",
    ["3D model scale (%)"] = "Change the size of the 3D character model.",
    ["3D mask size (%)"] = "Change the circular mask that clips the 3D portrait.",
    ["3D viewport size (%)"] = "Change the 3D rendering area around the portrait.",
    ["Portrait ring scale"] = "Resize the ring artwork without resizing the portrait.",
    ["Portrait ring offset X"] = "Move the ring artwork left or right.",
    ["Portrait ring offset Y"] = "Move the ring artwork up or down.",
    ["Frame inset (px)"] = "Adjust the empty inset between textured borders and popup content.",
    ["Flip H"] = "Mirror this frame piece horizontally.",
    ["Flip V"] = "Mirror this frame piece vertically.",
}
for label, description in pairs(extraDescriptions) do ns.OPTION_DESCRIPTIONS[label] = description end
for _, label in ipairs({"Background hue", "Frame hue", "Portrait ring hue", "Portrait border", "Title",
    "Level number", "Stats header", "Stat name / old value", "Improved value", "Abilities header",
    "Ability icon border", "Section divider", "Animated Elements"}) do
    ns.OPTION_DESCRIPTIONS[label] = "Change the colour of the named popup element. Class colours may override accent colours."
end
ns.OPTION_DESCRIPTIONS["Background hue"] = "Choose the background colour and transparency. Solid Colour uses this colour directly."
local texturePieces = {"Top-left corner", "Top edge", "Top-right corner", "Left edge", "Center",
    "Right edge", "Bottom-left corner", "Bottom edge", "Bottom-right corner"}
for _, label in ipairs(texturePieces) do
    ns.OPTION_DESCRIPTIONS[label .. " hue"] = "Tint this individual frame piece."
    ns.OPTION_DESCRIPTIONS[label .. " rotation"] = "Rotate this individual frame piece."
end
for _, spec in ipairs(ns.PARTICLE_SETTINGS) do
    ns.OPTION_DESCRIPTIONS[spec.countLabel] = "Set the number of particles for this effect. Zero hides them."
    ns.OPTION_DESCRIPTIONS[spec.sizeLabel] = "Resize this effect's particles as a percentage of their normal size."
    ns.OPTION_DESCRIPTIONS[spec.opacityLabel] = "Set how opaque this effect's particles appear. Zero makes them invisible."
end
ns.OPTION_DESCRIPTIONS[ns.FIREWORK_SETTINGS.sizeLabel] = "Resize this effect's particles as a percentage of their normal size."
ns.OPTION_DESCRIPTIONS[ns.FIREWORK_SETTINGS.opacityLabel] = "Set how opaque this effect's particles appear. Zero makes them invisible."
for _, spec in ipairs(ns.EFFECT_OPACITY_SETTINGS) do
    ns.OPTION_DESCRIPTIONS[spec.opacityLabel] = "Set the opacity of the named animation. Zero makes it invisible."
end
for _, spec in ipairs(ns.ANIMATION_SOUND_SETTINGS) do
    ns.OPTION_DESCRIPTIONS[spec.label .. " (ID)"] = "Enter a WoW sound file ID to override this cue. Enter 0 to clear the override."
end
local animationDescriptions = {
    ["Milestone Animations"] = "Celebrate the selected milestone interval with portrait anticipation, brighter accents and extra stat effects. Classic Mode disables this flair.",
    ["Max Level Celebration"] = "At the level cap, add curved class-coloured fireworks, portrait-ring sparks and stronger background motes. Classic Mode disables these effects.",
    ["Portrait pulse and starburst"] = "Pulse the portrait ring, then reveal a growing starburst behind the portrait. Milestones and max level also add a repeating portrait shine.",
    ["Highlight new abilities"] = "Add a reveal shine, glow and twinkling sparks to newly learned ability icons. Rank upgrades remain unhighlighted.",
    ["Emphasize stat gains"] = "Count stat totals up from their old values, then flash the changed numbers. Milestones also add sparks when counting finishes.",
    ["Portrait motes"] = "Release small drifting lights around the portrait after its starburst. Requires Portrait pulse and starburst.",
    ["Background motes"] = "Show rising particles behind the popup. Milestones and max level increase their density; max level also speeds them up.",
    ["Frame edge glow"] = "Sweep a fading glow along textured frame edges during the opening. This effect is unavailable with Modern.",
    ["Portrait and ring settle"] = "Start the portrait slightly enlarged, then ease it back to normal size. Milestones also add a brief anticipation flash.",
    ["Reveal dividers"] = "Expand the section divider lines as each section enters. Classic Mode keeps the text transitions but disables this decorative reveal.",
    ["Portrait ring glint"] = "Sweep a bright spark around the portrait ring, ending in a larger fading flare. Max level enlarges and flickers the finishing spark.",
}
for label, description in pairs(animationDescriptions) do ns.OPTION_DESCRIPTIONS[label] = description end

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
        for _, piece in ipairs(texturePieces) do
            lookup[ns.L("%s hue", ns.L(piece))] = piece .. " hue"
            lookup[ns.L("%s rotation", ns.L(piece))] = piece .. " rotation"
        end
        for _, spec in ipairs(ns.ANIMATION_SOUND_SETTINGS) do
            lookup[ns.L(spec.label) .. " (ID)"] = spec.label .. " (ID)"
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

local function ApplyOptionTooltipFont(tooltip, locale)
    local name = tooltip:GetName()
    if not name or not tooltip.NumLines then return end
    local count = math.max(tooltip.gluOptionFontLines or 0, tooltip:NumLines())
    if locale then tooltip.gluOptionFontLines = nil else tooltip.gluOptionFontLines = count end
    for line = 1, count do
        ns.ApplyLocaleFont(_G[name .. "TextLeft" .. line], locale)
    end
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
    if ns.GetLocaleFontPath() then
        if not GameTooltip.gluOptionFontHook then
            GameTooltip.gluOptionFontHook = true
            GameTooltip:HookScript("OnHide", function(tooltip) ApplyOptionTooltipFont(tooltip, "enUS") end)
        end
        ApplyOptionTooltipFont(GameTooltip)
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
