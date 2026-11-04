# Changelog

## 1.5.5

* Fixed incorrect icon sizing in WoWF.
* Fixed incorrect test spell display in WoWF

## 1.5.4 - The Stability Patch!



##### New Features

* Added a Level History tab with recorded times!



##### Bug Fixes and Optimization

* Fixed inconsistent icon enlargement between new abilities and rank upgrades in sparse ability lists.

* Level-up previews now include Blizzard's native ding when it is unmuted.
* Debug history fill now uses 20-hour times for every level, allowing new records to replace the samples.

* Improved code readability, removed old controller helpers and obsolete history-view data.
* Popup, audio and profile-import failures now include translated recovery instructions.
* Added an option for milestone intervals of 5, 10 or 20 levels.
* Secondary stats now switch normally while Suspend Preview keeps the popup open in Options.
* Simplified the README to focus on essential features and options.
* Fixed invisible price labels reserving space in Retail.
* Routed shared menu settings through common values, removing some code clutter.



## 1.5.2 - The "Lessa fucked up and caused a memory leak" Patch!

##### New Features



* Added a percentage control for when secondary stats replace primary stats within the existing display duration.
* Reorganized the main Options menu into tabs with fixed navigation.
* Added hover help for every option, including detailed animation explanations and advanced tuning controls in all supported languages.



##### Customization Options

* Added Garden Trellis frame option.
* Added Solid Colour, Coral, and Scratched Stone backgrounds.



##### Bug Fixes and Optimization

* Background, frame and portrait-ring hues are remembered separately for each selected asset, added a Reset Hues button to Colours.
* Unified textured-frame rendering.
* Relevant stats only now defaults to on in Retail.
* Performance profiling is now separate from debug mode.
* Fixed fill mode that I somehow broke last patch, don't ask me how I did that.
* Background Hue transparency now affects only the background fill, independently of the frame.
* Skip decorative ability effects for icons outside the scrolling viewport.
* Split rendering helpers, stat measurements, heading layout and decorative effects into separate UI modules.
* Fixed a moderate memory leak caused by repeated use of the test frame.



## 1.5

##### New Features

* **Retail is now fully supported.**
* Added optional abbreviated stat totals and equal-width stat display.
* Added fastest-level records, every level time is cached so you can see when you beat your best time!
* Added secondary stats display.



##### Customization Options

* Classic Mode has been added. Classic Mode replicates the original version of GLU with no flashy animations.
* Added special Max Level Celebration animations!



###### Bug Fixes and Optimization

* Fixed several wiring issues in controller options.
* First-time setup now shows tooltips explaining what each option does.
* Options frames can be clicked and dragged again.
* Modern's fade-out animations now function correctly again.
* Options menus can now be clicked and dragged.
* Suspend Preview now checks actual visibility, preventing hidden Settings panels from holding previews open outside the menu.
* Closing popups immediately become click-through, including icons and scroll controls; hovering cannot restart the popup.
* Gaining two or more levels at once now coalesces into one popup.
* Added hover descriptors to options menu.
* Moved Classic Mode to the top of Animation, separated from other toggles.
* Right-clicking the minimap button now previews a level-up.
* Tightened the portrait spark path to match the visible Steel and Copper rings.
* Optimized particle animations by reusing anchors and cached sizes for a minor performance gain.







## 1.4.5

##### New Features

* Added more impactful Milestone celebrations every 10 levels.
* Added "screenshot on milestone" toggle.



##### Customization Options

* Added new Horizontal layout mode.
* Added new background and frame effects.
* Completely redesigned "Modern" theme. Modern now has unique animations compared to themed mode.
* Added 3D Portrait mode. (Thanks 3Zeah!)



###### Bug Fixes and Optimization

* Redesigned first time setup, updated it to include important settings.
* Further optimization to reduce and pool memory usage.
* Fixed a memory leak when /glu test is repeatedly fired.



## 1.4.0

##### New Features

* Added a bundled Forever trainer catalogue for all nine classes, including
updated Hunter and Warlock pet training. Available skills no longer require trainer scans. If you encounter any issues or are prompted for updated data, please let me know.
* Added trainer change detection and `/glu trainerreport` exports.
* Added translations for all supported Forever clients. Only French and Spanish (ES) have been human reviewed, if you're a native speaker and see any errors in the machine translation please let me know!

##### Customization Options

* Added a host of new animations, all customizable and togglable depending on your likes!
* Added profile import/export options and per-character profile saving.

##### Bug Fixes and Optimization

* Improved API compatibility, animation performance and popup cleanup.
* Removed the Classic level-up chat option now provided by Blizzard.
* Improved performance across all options, even with new animations enabled less resources are consumed!



## 1.3.8 - 15/10/2026

##### New Features

* Added Show Hunter pet abilities, enabled by default, under Trainer Data. Pet options remain visible but disabled for other classes.
* Further prepared addon for localization, coming in the next update.

##### Bug Fixes and Optimization

* Hunter pet-training skills now appear only at their unlock level, independently of the general current-level setting. Filtering no longer depends on the summoned pet’s spellbook.
* Corrected the Lua pattern used to parse parenthesized skill ranks.
* Updated API access and optional-global checks after review with Ketho's WoW API extension.
* Updated the legacy learned-spell check.
* Improved rank filtering.
* Improved the legacy options-menu fallback.
* Removed the hidden gnome (for real.)



## 1.3.4 - 13/10/2026

Pushing this update early because of a critical error that broke a profile.

##### New Features

* Split background, frame, and portrait ring hue controls, with independent texture tint controls.
* Added “Suspend Preview” to pause a manual preview’s timeout while options are open.
* When class trainer data is missing, the empty skills message now asks the player to visit their class trainer.

##### Bug Fixes

* Fixed critical failure if the player gets to level 6 without class trainer data.
* Theme switching now preserves the saved frame position and lock state when Lock Location is enabled.
* The hidden gnome has been removed.

## 1.3.2 - 11/10/2026

##### New Features

* Added the Gnomeregan theme.
* Added an “Only display new skills” option that hides later ranks once a ranked ability chain has been learned. (Still needs testing.)
* Added better controller support, the top right close icon should now dynamically switch to the B/Circle button when controller mode is enabled.
* Added a dedicated controller options menu. (This is in heavy beta, please report any issues.)

##### Customization Options

* Background elements can now be chosen independently, as well as by theme.
* Added collapsible options sections and improved two-column Appearance/Trainer Data layout.
* Made Compact Layout independent of theme selection.
* Added controller glyph selection.
* Added two more player icon frames.

##### Optimization \& Bug Fixes

* Weapon skills should now correctly reflect the player's current state.
* Options menu has been reformatted for better readability and alignment.
* Fixed edge texture strip warping and improved corner texture transitions.
* Optimized theme textures for smaller file size.
* Replaced Lua per-frame animation updates with WoW AnimationGroups.
* Coalesced popup layout refreshes to reduce repeated work during event bursts.
* Reformatted the texture system to better allow for future additions and custom themes.
* Added support for Atlas textures.
* Centralized appearance refreshes so theme changes and resets cannot leave stale a texture state behind.
* Added safer fallbacks for invalid themes, missing texture references, and sound API failures.
* Added debug performance diagnostics with `/glu perf` and `/glu perf reset`.



## 1.3 - 07/10/2026

##### New Features

* Added optional Classic-style level-up text in chat with configurable colour.
* Added Forever Warlock grimoire tracking from the demon-trainer catalog.
* Added optional filtering of grimoires by the currently active pet.
* Added the embedded LibSharedMedia-3.0 library for shared font and sound registration.

##### Customization Options

* Added new Black Metal, Wood Panel, Alliance, and Horde background themes.
* Implemented early support for robust theming.
* Added optional horizontal scrolling for overflowing ability and grimoire rows.
* Added a compact popup layout option.
* Added customizable popup background colour.
* Added a reskinnable, recolourable divider texture.
* Added optional class colours.
* Added a Reset Appearance button.
* Added Ignore Mouseover Delay mode support.
* Added Allow Click-Through mode support.

##### Optimization

* Reduced repeated UI colour updates and background layout work.
* Combined repeated stat-change events into a single delayed snapshot refresh.
* Cached spellbook snapshots and refreshed them when spells or skills change.
* Combined stat and ability animations into one update loop.
* Added trainer cache status information to the options panel.
* Reorganized the options panel.
* Improved Retail spell tracking, preparing for Retail flavour launch.

## 1.2.8 - 05/10/2026

* Updated the release version and packaging for the embedded LibDBIcon-1.0 minimap button library.

## 1.2.7 - 05/10/2026

* Added font previews directly in the font dropdown.
* Improved custom sound registration and selection, including clearer handling when no sounds are registered.
* Replaced the custom minimap button positioning code with the embedded LibDBIcon-1.0 library.
* Replaced the preview placeholder ability with Teleport to Gnomeregan (spell ID 11362).
* Added hidden gnome mode. Don't worry about it.

## 1.2.5 - 05/09/2026

* Added optional LibSharedMedia support for fonts and sounds.
* Added a toggle to hide the level-up panel's text glow.
* Added an option to close the level-up panel with a right-click.
* Improved custom sound registration and menu handling.
* Added a temporary controller-mode options workaround for WoW: Forever's gamepad UI.

## 1.2 - 05/09/2026

* Added optional trainer skill costs with gold, silver, and copper icons.
* Added an option to show only skills that unlock at the player's current level.
* Added trainer-cache migration so 1.1 data is rescanned for skill costs after updating.
* Added an optional line showing time played on the level that just ended.
* Added a first-boot setup reminder.
* Set the default level-up frame strata to High.
* Fixed level-up sound suppression so the sound does not play twice.

## 1.1 - 05/08/2026

* Added Reduced Motion option.
* Improved stat snapshots and handling of protected or secret values.
* Improved profession trainer handling.
* Improved trainer-service parsing, caching and reset behavior.
* Added hardcoded Forever weapon skills.
* Improved Blizzard's level-up popup suppression and anchoring.

