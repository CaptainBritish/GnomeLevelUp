# Changelog

## 1.3 - 07/10/2026



##### New Features

* Added optional Classic-style level-up text in chat with configurable colour.
* Added Forever Warlock grimoire tracking from the demon-trainer catalog.
* Added optional filtering of grimoires by the currently active pet.
* Added the embedded LibSharedMedia-3.0 library for shared font and sound registration.



##### Customization Options

* Added new Black Metal, Wood Panel, Alliance, and Horde background themes
* Implemented early support for robust theming.
* Added optional horizontal scrolling for overflowing ability and grimoire rows.
* Added a compact popup layout option.
* Added customizable popup background color.
* Added a reskinnable, recolourable divider texture.
* Added optional class colors 
* Added a Reset Appearance button 
* Added Ignore Mouseover Delay mode support.
* Added Allow click-through mode support





##### Optimization

* Reduced repeated UI colour updates and background layout work.
* Combined repeated stat-change events into a single delayed snapshot refresh.
* Cached spellbook snapshots and refresh them when spells or skills change
* Combined stat and ability animations into one update loop.
* Added trainer cache status information to the options panel.
* Reorganized the options panel
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
* Added hardcoded Forever weapon skills
* Improved Blizzard's level-up popup suppression and anchoring.

