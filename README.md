# GnomeLevelUp

**Version 2.0 · WoW Forever and Retail**

A CRPG-inspired level-up screen showing stat gains, available abilities and
level times, with customizable themes, sounds and controller support.

## Get started

1. Put `GnomeLevelUp` in your client's `Interface/AddOns` folder and enable it.
2. Restart the client or use `/reload`, then follow the first-time setup.
3. Open `/glu options` to adjust it, or `/glu test` for a preview.

The minimap button opens settings with a left-click, replays your last recorded
level-up with a right-click, and previews a level-up with a middle-click.

## Features

- **Flexible layouts:** horizontal, vertical and compact layouts, with separate
  saved positions for horizontal and vertical popups.
- **Stats and abilities:** stat gains, optional secondary stats, ability tooltips
  and an upcoming-ability timeline. Forever includes trainer skills, learning
  costs and pet training; Retail uses its own spell unlocks and stat rules.
- **Appearance:** themes, colours, fonts, backgrounds and 2D or 3D portraits.
  Druids use 2D portraits while transformed by default; this can be switched off.
- **Effects and sound:** weather effects, milestone and max-level celebrations,
  optional screenshots and custom sounds. Classic Mode keeps simple transitions
  and turns off decorative effects.
- **Level records:** personal bests across your characters and guild records in
  their own class-coloured column. Previews and replays do not change your times.
- **Profiles and languages:** saved profiles with import/export, optional
  per-character profile selection and a language selector under Profile.

Click the pin beside the close button to keep a popup open. On a Forever
controller, use Y on Xbox, Triangle on PlayStation or X on Nintendo. Waiting
until combat ends is enabled by default.

## Guild records

Guild sharing is on by default. GLU syncs once on login and compares records
again when you level up. Characters in the same guild also share their saved
records locally. Leaving a guild removes that character's access to its records.
Guild leaders and ranks allowed to edit officer notes can delete shared records
with confirmation.

## Hunter pet skills

On Forever, **Show Hunter pet abilities** includes pet-trainer skills.
**Show saved Beast Training skills** is a separate experimental option, off by
default, for unlearned skills in the current pet's saved Beast Training list.

Open Beast Training to refresh the list. GLU remembers it across pet swaps and
level-ups and hides learned skills, but saved availability can become outdated
and newly available skills may be missing. Each pet has its own saved list.

## Custom themes

Theme packs are separate addons. Install a pack beside GLU, enable both, restart
the client and select it under **Appearance → Theme**. Packs can include frames,
backgrounds, portrait rings, dividers, fonts and sounds.

Download the [example theme pack on CurseForge](https://www.curseforge.com/wow/addons/gnomelevelup-custom-theme-example-ffix-and-fire/preview)
for **Blue Atlas** and **FE Path of Radiance**, or use it as a starting point
for your own theme. See the quick-start README in
`Examples/GnomeLevelUp_ThemeExample` in the source repository. Examples are not
included in the main GLU download.

## Useful commands

| Command | Action |
| --- | --- |
| `/glu` | Show command help |
| `/glu options` | Open settings |
| `/glu test [level]` | Preview a level-up; a specified level includes its milestone or max-level effects when applicable |
| `/glu test count <1-30>` | Preview a chosen number of sample abilities |
| `/glu test 60 personal` / `/glu test 60 guild` / `/glu test 60 both` | Preview new full-run records with debug enabled; use your client's max level |
| `/glu test 60 both level` / `/glu test 60 both all` | Preview final-level records, or records for both the final level and the full run |
| `/glu firsttime` | Reopen first-time setup |
| `/glu controlleroptions` | Open controller settings outside combat |
| `/glu trainerreport` | Open trainer-report export |
| `/glu debugreport` | Open recorded addon errors for support |
| `/glu debug on` | Enable debug options, previews and diagnostics |

Use **Level History** to review times or clear the selected character's records.
The **Debug** tab includes a reset button for debug tuning.

## Help and reports

If something looks wrong, include your client, GLU version and a screenshot
when reporting it on GitHub or CurseForge. For missing or incorrect trainer
skills, use `/glu trainerreport`. Reports are never submitted automatically.
Pet-trainer updates are recorded silently.

New artwork, sounds or fonts may require a client restart. Client restrictions
can prevent GLU from reading some values, particularly during combat.

Translations are in `Locales/`; `Locales/Template.lua` is included in the addon
for contributors.
See [CHANGELOG.md](CHANGELOG.md) for release notes.

## Credits

Inspired by **CoolLevelUp** by Forge_User_42492943; none of its code or assets
are used here. Thanks to Shadowhand for help with testing, localization and hiding Blizzard's
level-up banner, everyone in Special Thanks, and the 54 Sky Elf warriors who
gave their lives to testing.

I'm still learning Lua and have used AI for implementation help and debugging.
Most artwork comes from WoW or existing assets, no AI generation was used for any art.
