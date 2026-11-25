# Changelog

## 2.0

##### New Features

* Added guild level-time sharing, enabled by default. Times sync once on login, with a separate comparison when you level up.
* Guild records have their own class-coloured column in Level History, with lighter text and the original holder's name. Guildmates can share saved records from offline and former members too.
* Added a **New Guild Record!** celebration to the level-up popup. Preview it with `/glu debugtime guild` while debug mode is enabled.
* Guild leaders and ranks allowed to edit officer notes can delete shared records with an **[X]** and a confirmation prompt.
* Guild record tooltips show who supplied the record and when it was received in debug mode.

##### Customization Options

* Added **FE Path of Radiance** as a second example theme, with a gold frame, matching portrait ring and dividers, tiled blue background, custom font and level-up sound.
* Simplified the theme-pack setup guide, with advanced settings in a separate reference.
* Added a Druid-only option to use 2D portraits in forms, enabled by default.
* Set the default 3D mask size to 98%, with a one-time update for existing profiles and saved portrait tuning.
* Expanded custom theme support to include fonts, individual popup text sizes, divider textures and custom sounds, alongside frames, backgrounds and portrait rings.
* Themes can declare whether they include custom sounds, so artwork-only packs keep the normal sound fallback.
* Replaced the old example themes with **FFIV Blue Atlas**, featuring a silver frame and dividers, tiled blue background, larger custom font, matching thin portrait ring and level-up sound.

##### Bug Fixes and Optimization

* Added Gwen to Special Thanks.
* Added a Debug reset button to restore tuning defaults, including saved portrait adjustments, without clearing recorded data.
* Fixed live Druid form controls ignoring adjustments. Each appearance now keeps its own tuning, separate from humanoid settings.
* Druid portrait defaults are reapplied once to replace older adjustments. Changes made afterward remain saved.
* Matched live Druid portrait loading to the debug previews and stopped repeated mask-camera setup during refreshes.
* Druid portrait presets now use the player's current display ID instead of relying on a reused portrait model. Added `/glu debugportrait info` to inspect the selected appearance and settings.
* Added the default Retail Night Elf and Tauren form mappings and corrected circular mask sizing for different screen aspect ratios.
* Added 3D portrait presets for default Night Elf, Tauren and Skyborne Cat and Bear forms, plus all Tree forms. Other forms and barber-shop appearances use zeroed positions and rotation. Leaving form restores normal portrait settings.
* Added Druid form previews to `/glu debugportrait`, so they can be checked without a Druid character.
* Druid form previews now include default Night Elf, Skyborne and Tauren variants, using Forever's current form displays and clearing the previous model before loading.
* Fixed Druid preview controls showing normal portrait values. Each preview starts with its form's preset and can be adjusted without changing saved portrait settings.
* Clearing character times now works for the character selected in Level History, including logged-out characters.
* Level History now labels times by the level reached, so the final level is included.
* Fixed guild records disappearing when selecting another character in Level History. Each character now shows records from their own saved guild.
* Fixed updated custom theme text sizes not applying to an already selected theme, including Blue Atlas's larger level label.
* Fixed shared records losing their holder's class colour when later records arrived after the class information.
* Fixed Forever character names losing their surnames or showing a dash between first and last names.
* Simplified history level labels and made History mode debug-only. Account-wide best-time comparisons are now always enabled, removing the extra toggle.
* Fixed custom theme font choices carrying over to Modern. Each theme now remembers its own font, and the font menu shows the font's name.
* Guild sharing sends only the records that need updating, retries temporarily blocked messages and spreads out replies during busy logins.
* Characters in the same guild now share their saved guild records locally. Leaving a guild clears that character's access without removing records used by your other guilded characters.
* Saved record removals stop older caches from restoring a deleted record once its removal is verified. Newly relayed removals require officer confirmation.
* Added translations for the guild controls and deletion prompts.
* Cleaned up pet tracking and removed duplicate saved observations and prices while keeping each pet's skill records.
* Tidied popup layout, ability scrolling and report-window code. Pet lookups no longer create or prune saved data, and report copying keeps its existing clearing behavior.
* Improved theme error messages and added an asset checker and updated guide for theme authors.

## 1.6.7

##### Bug Fixes and Optimization

* Limited scrollbar handle size to prevent inconsistent dragging when only a few abilities overflow.
* Fixed some skills ignoring the "ignore rank upgrades" rule, some may still persist.
* Pet trainer data now updates silently, without catalogue-change alerts. Hunter teaching ranks now stay learned when swapping pets, and each pet keeps its own skill list.
* Fixed stale trainer scans after opening Beast Training or talking to another NPC.
* Fixed ability scrolling and scrollbar jumps after changing the pet skill display.
* Fixed layout refreshes resetting the ability scroll position after changing skill options.
* Matched the width of stats and ability scrollbars while keeping larger mouse hitboxes.

## 1.6.6a

##### Bug Fixes and Optimization

* Fixed Replay keeping the previous level-up if the latest popup failed during setup.

## 1.6.6

##### Bug Fixes and Optimization

* Improved ability icon sizing and spacing to better fill the horizontal popup.
* Secondary stats now only show increases and scroll within the space used by primary stats, preventing the panel from becoming massive.
* Fixed missing icons when scrolling and improved scrollbar fading.
* Improved GLU's handling of Beast Training reports to hopefully stop false-positives.
* Fixed weapon skills appearing in trainer reports on non-English clients.
* Added more trainer details to reports to help investigate future issues.
* Removed GLU's built-in error handler and returned it to WoW's built-in one.
* Removed duplicate error messages from chat.

## 1.6.5

##### Bug Fixes and Optimization

* General optimization, minor fixes
* Improved Retail banner suppression
* Fixed the milestone background flash
* Corrected the training level for the first ranks of Great Stamina and Natural Armor
* Reduced extra work during popup animations and simplified spellbook caching.
* Sped up trainer ability lookups for `/glu test <level>`
* Shared tooltip price formatting between the popup and timeline
* Removed unused code and textures.

## 1.6.4a

* Forgot to add a toggle for Timeline Look Ahead, my bad.

## 1.6.4

##### New Features

* Added Turkish (Türkçe) support, including Turkish characters in the Fritz font. Thanks, Shadowhand!
* Added an optional level timeline with upcoming abilities and hover tooltips.
* Added a pin to keep the popup open.

##### Customization Options

* Added **Weather motes** for clear skies, rain, snow, sandstorms, and haze.
* Added a toggle to show only the latest spell rank.
* Added a toggle to hide the Abilities section of the popup.
* Added **Timeline Steps** to show two, three, or four levels at a time.
* Grouped the spell filters at the bottom of Trainer Data, above **Export Trainer Report**.

##### Bug Fixes and Optimization

* Reworked the locale system to make translations easier to contribute. Thanks, Shadowhand!
* Fixed French stat names and stale labels after switching languages.
* If something prevents GLU from seeing the stat totals, GLU will show the stats gained.
* Level times now show hours after 60 minutes. 
* The 3D portrait no longer lingers after the popup de-renders.
* Retail previews and the timeline share a spell unlock cache 
* /glu test <level>`replaces /glu milestone and /glumaxlevel, you can now add a number to the end of it to preview that level.

## 1.6.3

- Updated WoW Forever trainer prices
- Added Rogue Poised, both ranks of Shank, and the trainable Death Mark upgrades.
- Removed obsolete trainer entries for Frost Blast, Lava Burst, Binding Heal, Salvation, Mass Salvation, Blessing of Light, and Greater Blessing of Light.
- Improved trainer reporting for future use.
- the hidden gnome cannot be stopped

## 1.6.2

- Attempted another blank 3D portraits fix in WoW Forever
- Improved 2D fallback recovery when the model or camera fails.
- Tried again to fix Blizzard's level-up banner showing (This one is tricky, sorry.)
- Improved stat capture for rapid level-ups by checking the combined gains.
- Swapped the minimap shortcuts. People kept getting mixed up so it must have been confusing.
- Updated the WoW Forever Druid trainer catalogue for Ferocious Bite, Lacerate, Poised, and Primal Bite.
- Added regression checks to prevent the Hidden Gnome from returning.

## 1.6.1

- Added a workaround for a case where entering combat around a level-up could cause missing stat gains. (This was meant to be in 1.6 but I forgot it, sorry for the double update.)
-  The Hidden Gnome has been removed

## 1.6 - The Desperation Patch
(This patch wasn't quite ready yet but I really wanted to fix two major bugs brought to my attention, keep an eye out for custom themes in the near future!) 

##### New Features
- Added preliminary support for separately installed theme packs. This is a beta feature, not yet fully ready.
- Added **Use Theme Sounds** to control animation audio separately. This is a beta feature and has not been implemented for default themes.
- Added an optional **Class-coloured portrait background** under Texture Colours, shown only for 3D portraits. 

##### Bug Fixes and Optimization

- Attempted to fix missing primary stat gains in the level-up popup. GLU retries when reported gains are slow to appear and warns in chat if capture still fails.
- Attempted to fix blank 3D portraits by showing a 2D portrait or class icon while the model loads.
- Fixed the brief flash of Blizzard's level-up toast when **Hide Blizzard level-up toast** is enabled.
- Fixed Milestone Screenshots not firing and added a separate **Screenshot every level** toggle.
- Fixed language auto-detection loading an incomplete translation dictionary. 
- Fixed square glyphs in Cyrillic, Korean, Simplified Chinese, and Traditional Chinese. Please make sure Friz (default), Morpheus or Skurri are selected as your font if you use a non-latin character set.
- Added some missing translations in Cyrillic.

## 1.5.7

- Added Contributors to Cache Status
- Fixed Paladin spellbook cache

## 1.5.6
* Fixed ability scrollbar jump in Vertical mode.
* Stopped GLU notifying the user that riding skills are missing at the trainer.
* Preview controls are now fixed to the bottom of the options panel.
* Added an Ability Cost Size option.
* Right clicking on preview now lets you select how many skills to preview.

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

