# GnomeLevelUp

**Development version: 1.5**

A fancy, CRPG-inspired level-up screen for World of Warcraft. It shows your stat
gains and the trainer skills you haven't learned yet, with themes, custom sounds
and a separate controller menu.

Credit where it's due: the idea was inspired by **CoolLevelUp** by
Forge_User_42492943. None of its code or assets are used here.

Shoutouts to Shadowhand for helping test and fixing my broken-ass code for hiding
the default level-up toast, and to the 54 Sky Elf warriors created and killed to
help test this addon.

## Installation

1. Put `GnomeLevelUp` in your client's `Interface/AddOns` folder.
2. Enable the addon, then restart the client or use `/reload`.
3. Open `/glu options` to configure it, or `/glu test` for a preview.

WoW: Forever and Retail use separate ability/stat rules. Automatic controller
routing is supported on Forever; `/glu controlleroptions` can open the controller
menu manually in either flavour, outside combat. `/glu mode` shows the resolved
flavour; use `/glu mode retail`, `/glu mode forever` or `/glu mode auto` to change it.

## Highlights in 1.5

- Retail new-ability support, resource filtering and optional stat shortening.
- Shared stat columns, optional abbreviated names and independent text sizes.
- Optional secondary-stat pages halfway through the popup.
- Recorded level times, new-best transitions and complete time-to-cap totals.
- Milestone/max-level celebrations and Classic Mode.
- Combined popups for rapid or combat-delayed multi-level gains.
- Shared, localized hover descriptions in both options menus and first-time setup.

See [CHANGELOG.md](CHANGELOG.md) for the release history.

## Setup and options

Open settings with `/glu options`, the minimap button or the game's AddOns
settings. Right-click the minimap button to preview a level-up.
`/glu firsttime` reopens first-time setup. Setup supports the mouse,
keyboard and controller navigation; completing it saves your choices. If login
or setup is blocked by combat/loading, it waits until the client permits it.

Fresh settings use Modern, horizontal layout, a player portrait, class colours,
equal-width stats, Time to Level and right-click closing. Horizontal layout
also enables Compact Layout. Abbreviated names, secondary stats, Retail stat
shortening and Retail relevant-stat filtering default to off. Existing saved
choices are preserved. Controller glyphs default to None without a detected
controller, or Xbox with one; saved manual glyph choices remain intact.

Setup includes Language, Classic Mode, theme, orientation, portrait, timing,
secondary stats, compact layout and closing/mouseover preferences. Forever adds
pet training/cost options; Retail adds its stat filters. Every controller entry
has hover help, reused by matching normal-menu controls. Portrait help includes
the red 3D-memory warning.

Appearance contains Popup Scale, Display Duration, font and independent Stat,
Heading and Time to Level sizes (50–200%). Mode contains shared stat columns,
abbreviations, secondary stats and client-specific filters. Animation contains
Classic Mode and decorative effect switches. Language and profile management
are in Profile; change Language there and reload the UI. Setup updates its
language immediately. English is the fallback for unavailable translations.

Normal and controller Options build their controls only when opened. Setup and
controller windows can be dragged. Modern menu backgrounds have a soft gradient;
textured themes retain their artwork. Right-click closes these windows only
when no option row is hovered. Up/Down moves selection, Left/Right adjusts,
Enter selects, Tab/Shift+Tab changes tabs, and Escape closes. Focused text fields
retain their normal keyboard input. Normal Options includes Debug; the
controller menu does not. Its Profile page includes Clear Trainer Cache and
Reset All Options.

## Stats, layouts and abilities

Live primary rows show increased stats. Mana is hidden for classes that do not
use it; Retail also hides fixed non-Mana resources. Retail omits Spirit and
excludes automatic ability-rank upgrades. Its empty ability section is removed.
Forever uses the bundled 1,414-entry class-trainer catalogue, optional weapon
training, and separate Hunter/Warlock pet rules. Scanned data does not replace
the bundled class list. Trainer scanning/reporting and pet/cost controls are
hidden on Retail. The experimental next-ability preview has been removed.

**Relevant stats only** applies to Retail. It keeps Health, Mana when used,
Stamina and the active specialization's primary stat. **Shorten stat totals**
is also Retail-only: horizontal totals shorten from 10,000 and vertical totals
from 100,000. Million-scale values can show `1M 360k`. Gain counters remain exact.

**Equal-width stat text** aligns whole groups—label, old total, arrow, new total
and gain—into shared columns. It does not spread individual letters. With
**Abbreviate stat names**, primary labels become `STR`, `STA`, `INT`, `AGI`,
`SPI`, `HP`, `MP` in equal-width mode. Secondary abbreviations are `Crit`,
`Mast`, `Haste`, `Versa`, with equal widths on or off. The full English critical
label is **Crit. Strike**. Longer rows shrink to fit instead of crossing borders.

**Show secondary stats** defaults off. After the initial entrance, primary rows
begin their exit halfway through the configured display duration and secondary
rows use the same fade/slide entrance. The portrait, abilities and timing retain
their timeline. The taller page is reserved once, avoiding frame resizing.
Short display durations compress the swap so the second page can appear.

Retail secondary stats are Crit. Strike, Haste, Mastery and Versatility.
Forever instead uses combined crit/hit, haste, expertise, attack/spell/healing
power, armor, defense and avoidance, plus supported armor penetration and mana
regeneration. Hunters can show ranged attack power. Unavailable/protected
values are skipped. Percentages retain two decimals and can decrease.

Horizontal mode top-aligns stats and abilities 8px below their matching-size
headers. The ability viewport uses a 3×3 grid before scrolling. One ability is
raised around the middle of its column; two or more start at the top. Sections
with one to three abilities can grow icons by up to 50%, within existing space.
They do not enlarge the popup. Vertical player portraits/rings are 1.25× their
previous size, with the level label below the visible ring.

Textured vertical layouts reserve 24px more bottom clearance. Textured
horizontal max-level events add 8px below their existing content. Modern vertical
uses a fixed 20px fade tail and lower line 8px below the content budget; it no
longer extends downward by 12% of the frame height. Grimoire/cost viewports retain
their own space. Portraits, rings and layout positions retain independent
horizontal/vertical tuning where provided.

**Show Hunter pet abilities** is enabled by default for Hunters on Forever.
Training appears at its unlock level, with pre-level 10 records first shown at
10. Warlock grimoires have their own section and active-pet filter. Learning
costs are optional and use base catalogue prices before discounts. Horizontal
layout hides weapon training while retaining the saved vertical preference.

## Timing and celebrations

**Show time played this level** controls both Time to Level and new-best
celebrations. First records, slower levels and ties show only the ordinary time.
A new best transitions the previous time from green to red as it fades out,
slides the new time in, and shows **New Best Time!**. The extra row is reserved
only for that transition. Records are per character/flavour, outside profiles;
previews do not change them.

At max level, **Time to max level** appears only if GLU recorded every interval
from level 1 to the cap. Missing intervals fall back to normal time-to-level;
WoW's total played time is not substituted. Retail uses the client-reported cap,
Forever uses 60. `/glu resettimers` clears this character's GLU timing history.

Rapid or combat-delayed gains combine into one popup with `Level X - Y`, total
stat increases and consolidated abilities from the gained range. Known combined
time is labelled for the number of levels; missing intervals are never invented.
Crossing a milestone celebrates once. A normal preview on a capped character
remains normal; `/glu maxlevel` explicitly previews the finale.

Milestone Animations add accents at ten-level milestones. Max Level Celebration
adds varied class-coloured curved fireworks, denser/faster background motes,
post-starburst sparks and randomly placed electrical ring spikes. Only the
background mote layer receives the max-level opacity boost. Portrait shine
repeats on milestone/max-level popups. The max-level background fades from the
class colour to black. Optional milestone screenshots run after a real entrance;
previews do not take them.

**Classic Mode** disables decorative animations, including milestone/max-level
flair, pulse/starburst and ring effects, while preserving staged text fades and
slides, Modern opening/closing and textured fades. Saved effect choices return
when Classic Mode is disabled. 3D portrait idle animation still runs in Classic
Mode; disabling Background Animations pauses it.

All closing stages start together. Automatic closing is slower than the earlier
release; right-click/X remains fast. Closing immediately becomes click-through,
so hovering cannot revive a nearly hidden popup. **Suspend Preview** pauses the
preview timeout only while Options is visibly open. It does not pause previews
launched outside Options or ordinary level-ups.

## Portraits and artwork

Portrait choices include class icon, player portrait, live player 3D portrait
and None. None removes its portrait effects and header space. Selecting Modern
clears the decorative ring selection. Frame/background artwork choices are for
textured themes; their controls are unavailable in Modern.

The 3D portrait is created lazily. Its circular depth masking is adapted from
Animated Default Portraits by dvd, without an additional addon dependency.
Debug fields tune rotation, depth, position, scale, mask and viewport sizes.
Race/sex presets are separate from per-character calibration overrides; unknown
races use fallback settings. Gnome female defaults are rotation -6, depth -0.04,
horizontal 0.12 and vertical -0.07. Reset All Options clears this character's model
overrides. The calibration worksheet remains in development Tools.

Custom textures must be compatible with the WoW client. New/replaced texture
files may require restarting the client, even when Lua changes need only
`/reload`. Reset Appearance or reselect the theme if artwork is missing.

## Sound

**Level Up (default)** leaves Blizzard's normal level-up sound unchanged. GLU
plays no replacement ding and disables its play/mute checkboxes while this
selection is active. Their saved choices return with a replacement sound.

Animation sounds default to silent. Debug retains per-animation sound-ID fields;
0 disables a cue. Closing/replacing popups stops GLU animation sounds, and
Classic Mode suppresses them. The experimental ticker clicks were removed.

Sound volume applies where the client supports per-sound volume, including
supported Retail sound-kit choices. Default audio, files/custom OGG and Forever
playback use game volume; the disabled slider says **Uses game volume**. GLU
does not change global volume settings. SharedMedia sounds/fonts registered by
other addons are available when supported.

For a custom sound, put an `.ogg` file in `GnomeLevelUp/Sounds/`, choose Custom
Sound and enter its addon-relative path, such as
`Interface/AddOns/GnomeLevelUp/Sounds/yourfile.ogg`. You can also add a named
entry to `Sounds/SoundList.lua` using an existing entry as a template.

## Profiles and languages

Profiles support selection, creation, rename/delete and import/export. Changes
save automatically. Save per Character keeps that character's profile selection
separate from the account selection; turning it off returns to the account
profile. Imported/reset settings do not overwrite trainer reports, learned
history or level-time records. Reset Appearance affects appearance settings;
Reset All Options restores the full options set and character model calibration.

Supported languages: English, French, Spanish (Spain/Latin America), German,
Italian, Brazilian Portuguese, Russian, Korean, Simplified/Traditional Chinese.
Auto Detect follows the client. Spell names and native game tooltips remain in
the client language; custom fonts need glyphs for the selected language. See
[LOCALIZATION.md](LOCALIZATION.md) for development translation notes.

## Trainer reports

Trainer visits check readable class spells for new IDs or changed required
levels. You can turn this off with **Check trainer lists for catalogue changes**
under Trainer Data. Discounted prices and hidden or missing services don't count
as changes, and reports don't modify the bundled list.

If a difference is found, chat shows an alert, a separate report-options line
with `/glu trainerreport` highlighted in yellow, and the report's save location.
Use `/glu trainerreport` or **Export trainer report** to open the report window.
Click **Reload UI**, or log out, to have WoW write the file:

```text
WTF/Account/<account>/SavedVariables/GnomeLevelUp.lua
```

The path starts inside the client folder you're playing from. Replace
`<account>` with your account directory. Send the saved file to me on GitHub or
Curseforge. It includes your GLU settings and cache; the same window also offers
report-only JSON that you can copy into `GnomeLevelUp-trainer-report.json`.

`/glu trainerreport clear` clears the reports. Reload or log out again to update
the file on disk. Nothing is submitted automatically.

## Commands

### Normal-use commands

Commands are case-insensitive. Arguments in brackets are optional. Trainer
capture/report commands mainly apply to Forever; Retail uses spellbook unlocks.

| Command | Action |
| --- | --- |
| `/glu` | Print command help |
| `/glu options` or `/glu config` | Open settings |
| `/glu firsttime` | Reopen GLU First Time Setup |
| `/glu controlleroptions` | Open the controller menu outside controller mode |
| `/glu sound` | Toggle GLU playback for replacement/custom sounds; Blizzard's default selection remains native |
| `/glu duration [seconds]` | Show the current duration, or set it to 1–60 seconds; default is 7 |
| `/glu mode [retail\|forever\|auto]` or `/glu flavor [retail\|forever\|auto]` | Show the current/resolved client mode, or choose a mode |
| `/glu combat` | Toggle waiting for combat to end; enabled by default |
| `/glu trainerreport` | Open trainer-report export and save instructions |
| `/glu trainerreport clear` | Clear saved change reports |
| `/glu resettimers` | Clear this character’s GLU-recorded level intervals and fastest times in both modes; keep other character data and refresh the current `/played` cache |
| `/glu cleartraining` | Clear scanned data; keeps bundled skills and reports |
| `/glu scan` | Toggle legacy trainer capture; bundled-class capture requires debug mode |
| `/glu scanprof` | Toggle profession capture; experimental and off by default |

### Debug and testing commands

Enable gated commands with `/glu debug on`. Preview and watermark tests do not
require debug mode. The stat-range override lasts until reset or UI reload; ordinary
settings changed by commands are saved as usual.

| Command | Action | Requires debug mode? |
| --- | --- | --- |
| `/glu debug [on\|off]` | Enable/disable debug controls and diagnostics; no argument toggles the setting; off by default | No |
| `/glu test [1-30]` | Preview the normal level-up screen with the chosen ability count; default three | No |
| `/glu milestone [level] [1-30]` | Preview a milestone: level first (multiple of 10 from 10–1000), ability count second (default three); no arguments uses the current/next milestone | No |
| `/glu maxlevel [1-30]` | Preview the max-level celebration and recorded time-to-cap (normal level time if history is incomplete), with the chosen ability count; default three | Yes |
| `/glu testlevels <from> <to> [1-30]` | Preview a combined gain of at least two levels (for example `20 23`), optionally choosing the ability count; leaves real histories untouched | Yes |
| `/glu debugskills` | Preview an expanded skill list; Forever includes pet-training examples and Retail shows new abilities | No |
| `/glu debugstats <old> <new>` | Set exact Strength old/new totals; randomize other stats from 1 up to each entered limit, keeping new at least old; whole numbers from 0–9007199254740991, new at least old | Yes |
| `/glu debugtime <new\|slower\|best>` | Preview a level time with no previous best, a faster old time (without an extra comparison line), or a new best; uses sample times, shows the timing section and leaves real history untouched | Yes |
| `/glu debugstats reset` | Restore ordinary preview totals and open a preview | Yes |
| `/glu dumptraining` | Print cached trainer skills and learned state | Yes |
| `/glu testtrainer` | Print the current unlearned trainer/ability list | Yes |
| `/glu dumpskills` | Print Skills-tab, equipped and trainable weapon diagnostics | Yes |
| `/glu perf` or `/glu performance` | Print measured performance counters | Yes |
| `/glu perf reset` or `/glu performance reset` | Clear performance counters | No |
| `/glu bgtest <filename>` | Override settings/setup watermark artwork using a filename from `Textures/`, without a path; `.tga` is optional | No |
| `/glu bgtest clear` | Restore the seasonal watermark selection | No |

Watermark examples: `/glu bgtest options-watermark`,
`/glu bgtest options-watermark-h`, `/glu bgtest options-watermark-wv`, and
`/glu bgtest options-watermark-forever`.

## Performance diagnostics

Debug counters measure GLU callback CPU time, not FPS or full 3D/GPU rendering
cost. They are disabled outside debug mode. For a repeatable manual check:

```text
/glu debug on
/glu perf reset
/glu test 3
```

Wait for the popup to close, then run `/glu perf`. Repeat after resetting counters
with `/glu milestone 80 9` or `/glu maxlevel 30`. Keep portrait/layout/effect settings
and the game location consistent. Record whether 3D and secondary stats are on.
The first popup may include cold setup work; compare repeated warm runs too.

`popup_prepare` measures one-time popup preparation. `visual_effects_frame`,
`stat_animation_frame` and `closing_frame` measure their callbacks;
`ambient_particles_frame` and `max_celebration_frame` identify effect groups.
Detailed counters split section entrances, portrait effects, ring glints,
portrait shimmer/anticipation, ability glow/shine, stat highlights/impacts,
background depth particles and milestone accents. `stat_page_swap` measures the
one-time secondary-stat replacement. `peak@=2.50s` means that
counter's slowest sample began about 2.5 seconds into the popup; separate maxima
can come from different frames. Calls count measurements; average/max/last are
milliseconds. These groups can nest, so do not add their totals together.
Debug measurement has its own overhead; compare runs with the same counters.

## Limits and troubleshooting

- Protected/secret client values may be unavailable, especially in combat.
  GLU skips unreadable secondary values and can defer normal popups until combat ends.
- Trainer monitoring compares readable services during visits; it cannot detect
  every removal or inspect all trainers remotely. Prerequisite/skill metadata
  may list ranks before earlier ranks are purchased. Race/faction/talent rules
  are filtered. Quest rewards are not trainer catalogue entries.
- Catalogue and weapon lists may need updates as either client changes.
- Automated tests cover both flavours, but they cannot prove actual rendering,
  hardware input, native audio or 3D performance. Live Forever testing is limited.

Development documentation and tests remain in [CONTRIBUTING.md](CONTRIBUTING.md)
and `Tools/`. Tools and contributor/localization docs are excluded from release
packaging. The addon does not upload reports automatically.

## AI assistance

I'm still learning Lua. I've used AI for implementation help, debugging and
understanding parts of the addon, including spellbook caching. Not every
suggestion made it in; scanning broadly by name instead of using the documented
APIs was one that got thrown out.

The goal is to build a cool addon while learning how it works along the way.
The graphical assets aren't AI-generated; they're taken from WoW or kitbashed
from other assets.

Development notes, the source map and checks are in
[CONTRIBUTING.md](CONTRIBUTING.md).
