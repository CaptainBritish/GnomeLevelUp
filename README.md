# GnomeLevelUp

**Development version: 1.5.6**

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

## Highlights in 1.5.2

- Adjustable primary/secondary stat timing within the existing popup duration.
- Middle-click replay of the last real level-up.
- Decorative effects skip ability icons outside the scrolling viewport.

## Highlights in 1.5

- Retail new-ability support, resource filtering and optional stat shortening.
- Shared stat columns, optional abbreviated names and independent text sizes.
- Optional secondary-stat pages at the selected percentage of the display duration (25–75%, default 50%).
- Recorded level times, new-best transitions and complete time-to-cap totals.
- Milestone/max-level celebrations and Classic Mode.
- Combined popups for rapid or combat-delayed multi-level gains.
- Shared, localized hover descriptions in both options menus and first-time setup.

See [CHANGELOG.md](CHANGELOG.md) for the release history.

## Setup and options

Open `/glu options` or click the minimap button for settings. Right-click the
button to preview a level-up; middle-click replays your last recorded level-up.
Use `/glu firsttime` to reopen setup, or `/glu controlleroptions` for the
controller menu.

Settings are grouped into tabs, with hover descriptions for every option:

- **Appearance and Colours:** themes, portraits, backgrounds, fonts, popup size
  and duration. Backgrounds support Tile, Fill (preserves proportions and crops)
  and Stretch. Hues are remembered for each background, frame and portrait ring;
  **Reset Theme Hues** restores the selected items.
- **Mode:** layout, stat formatting, secondary stats and client-specific options.
- **Animation:** decorative effects and **Classic Mode**, which keeps basic
  transitions while disabling decorative animations.
- **Sound:** the level-up sound and supported volume controls.
- **Profile:** saved settings and language selection.

## Stats, layouts and abilities

Choose horizontal or vertical layout. **Equal-width stat text** aligns values
into columns, and **Abbreviate stat names** uses shorter labels. Enable
**Show secondary stats** to replace the primary stats partway through the popup;
its timing control adjusts the split without extending the display duration.

Retail shows new abilities without automatic rank upgrades. **Relevant stats
only** filters primary stats for your specialization, and **Shorten stat totals**
shortens large totals while keeping gain counters exact. Mana is hidden for
classes that do not use it.

Forever includes trainer abilities, optional Hunter pet training, Warlock
grimoires and learning costs. Its secondary stats follow Forever's rules;
Retail shows Crit. Strike, Haste, Mastery and Versatility.

## Timing and celebrations

**Show time played this level** displays Time to Level and celebrates new best
level times. At max level, GLU shows total time to the cap only when it has
recorded every level interval; otherwise it shows the normal level time.
Previews and replays leave these records unchanged. The **Level History** tab
shows recorded times and personal bests across your characters, with an optional
account-wide comparison for new level times. Characters with recorded times appear after you
log into them; Retail and Forever records stay separate. Reset this character's
times there or use `/glu resettimers`.

Milestone celebrations can run every 5, 10 or 20 levels. Max level has its own
toggle. Horizontal and vertical layouts remember separate popup positions. Rapid or
combat-delayed level gains combine into one popup. Right-click or use the X to
close early; **Classic Mode** retains simple opening and closing transitions.

## Portraits and sound

Choose a class icon, player portrait, animated 3D portrait or no portrait.
3D portraits may use more memory. New or replaced texture files may require a
client restart.

**Level Up (default)** leaves Blizzard's level-up sound unchanged and adds no
replacement ding. `/glu test` also plays Blizzard's ding when it is unmuted.
Other choices include bundled and supported SharedMedia sounds.
For a custom sound, place an `.ogg` file in `GnomeLevelUp/Sounds/`, select
**Custom Sound** and enter its path, such as
`Interface/AddOns/GnomeLevelUp/Sounds/yourfile.ogg`. Volume uses game settings
when per-sound control is unavailable.

## Profiles and languages

Profiles save automatically and support creation, selection, rename/delete and
import/export. **Save per Character** gives each character its own profile
selection. Appearance resets and profile changes preserve level-time history
and trainer reports.

Choose a language in Profile, then reload the UI. GLU supports English, French,
Spanish (Spain/Latin America), German, Italian, Brazilian Portuguese, Russian,
Korean and Simplified/Traditional Chinese. **Auto Detect** follows the client;
spell names and native tooltips remain in the client's language.

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
| `/glu memory` | Print current addon memory usage in KB/MB |
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
| `/glu debug [on\|off]` | Enable/disable debug controls and commands; no argument toggles the setting; off by default | No |
| `/glu test [1-30]` | Preview the normal level-up screen with the chosen ability count; default three | No |
| `/glu milestone [level] [1-30]` | Preview a milestone: level first (a multiple of the selected milestone interval, up to 1000), ability count second (default three); no arguments uses the current/next milestone | No |
| `/glu maxlevel [1-30]` | Preview the max-level celebration and recorded time-to-cap (normal level time if history is incomplete), with the chosen ability count; default three | Yes |
| `/glu testlevels <from> <to> [1-30]` | Preview a combined gain of at least two levels (for example `20 23`), optionally choosing the ability count; leaves real histories untouched | Yes |
| `/glu debugskills` | Preview an expanded skill list; Forever includes pet-training examples and Retail shows new abilities | No |
| `/glu debugstats <old> <new>` | Set exact Strength old/new totals; randomize other stats from 1 up to each entered limit, keeping new at least old; whole numbers from 0–9007199254740991, new at least old | Yes |
| `/glu debugtime <new\|slower\|best>` | Preview a level time with no previous best, a faster old time (without an extra comparison line), or a new best; uses sample times, shows the timing section and leaves real history untouched | Yes |
| `/glu debugstats reset` | Restore ordinary preview totals and open a preview | Yes |
| `/glu dumptraining` | Print cached trainer skills and learned state | Yes |
| `/glu testtrainer` | Print the current unlearned trainer/ability list | Yes |
| `/glu dumpskills` | Print Skills-tab, equipped and trainable weapon diagnostics | Yes |
| `/glu perf on` or `/glu performance on` | Start performance profiling for this session; independent of debug mode | No |
| `/glu perf off` or `/glu performance off` | Stop profiling and retain the recorded counters | No |
| `/glu perf` or `/glu performance` | Print recorded performance counters and an off-state hint when stopped | No |
| `/glu perf reset` or `/glu performance reset` | Clear performance counters | No |
| `/glu bgtest <filename>` | Override settings/setup watermark artwork using a filename from `Textures/`, without a path; `.tga` is optional | No |
| `/glu bgtest clear` | Restore the seasonal watermark selection | No |

Watermark examples: `/glu bgtest options-watermark`,
`/glu bgtest options-watermark-h`, `/glu bgtest options-watermark-wv`, and
`/glu bgtest options-watermark-forever`.

## Performance diagnostics

Profiling measures GLU callback CPU time, not FPS or full 3D/GPU rendering
cost. It is off after every UI reload and independent of debug mode. For a
repeatable manual check:

```text
/glu perf on
/glu perf reset
/glu test 3
```

Wait for the popup to close, then run `/glu perf`. Use `/glu perf off` to stop
recording without clearing the results. `/glu perf reset` clears counters and
does not start or stop profiling. Repeat after resetting counters
with `/glu milestone 80 9` or `/glu maxlevel 30` (these two preview commands
still require `/glu debug on`). Keep portrait/layout/effect settings
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
