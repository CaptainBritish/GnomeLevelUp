# GnomeLevelUp

**Development version: 1.4.5**

A fancy, CRPG-inspired level-up screen for World of Warcraft. It shows your stat
gains and the trainer skills you haven't learned yet, with themes, custom sounds
and a separate controller menu.

Credit where it's due: the idea was inspired by **CoolLevelUp** by
Forge_User_42492943. None of its code or assets are used here.

Shoutouts to Shadowhand for helping test and fixing my broken-ass code for hiding
the default level-up toast, and to the 54 Sky Elf warriors created and killed to
help test this addon.

## Installation

1. Copy `GnomeLevelUp` into the current client's `Interface/AddOns` folder.
2. Enable it in the AddOns list, then restart the client or use `/reload`.
3. Open `/glu options` to set it up, or `/glu test` to preview a level-up.

WoW: Forever is the main target. Retail support is included but has had less
testing; the separate controller options menu is available only on Forever.

## What's new in 1.4.0

- A built-in catalogue of 1,414 trainer skills across all nine Forever classes.
  You don't need to visit a trainer to populate the level-up screen.
- Language selection, applied after **Reload UI**.
- Options that wrap long labels and fit smaller panels.
- Trainer-change reports to help keep the catalogue up to date.

See [CHANGELOG.md](CHANGELOG.md) for the full release history.

## Options

Use `/glu options`, the minimap button, or **Options > AddOns > GnomeLevelUp**.
The settings include themes, separate frame/background/portrait-ring choices,
fonts, sounds, animation, compact layout and trainer filters. Modern is the
default theme, with Player Portrait and no portrait ring. Time to Level and
right-click closing are enabled by default.
Non-Modern themes default to a 0px content inset inside Modern-sized frames. The close button stays on the
outer frame, and portrait artwork may overlap the border.
Existing saved preferences are preserved. Selecting Modern clears its ring.
Blizzard handles level-up chat; GLU does not replace or suppress that message.

On first run, the setup panel welcomes you to GnomeLevelUp and offers Language, Theme, Compact Layout, Horizontal layout,
Time to Level, a combined pet-skills switch, Enable Animations, Background Animations, controller
glyphs, unlearned weapon skills, learning costs, Right-click to Close, Ignore
Mouseover Delay and Use Class Colours. The setup pet switch controls both Hunter skills and Warlock training/grimoires;
the full menus retain separate controls. Disabling Enable Animations uses
Reduced Motion (simultaneous fades) while preserving individual effect choices. It uses the controller menu's theme and
navigation, and also accepts mouse input and mouse-wheel navigation. Both menus
use larger option rows, compact tabs, a scrollbar and the active Options
watermark at 36% opacity (normal Options remains 40%). Up/Down moves through
rows, Left/Right adjusts, Enter selects, Tab/Shift+Tab changes tabs (or focuses setup controls), and Escape
closes. A focused text-entry field retains its keyboard input. Selecting None for glyphs
hides controller hints; setup never displays a Tabs hint. Language changes update the setup
labels immediately; other already-built menus update after Reload UI. Finish
setup saves the choices through its separate footer button.
The welcome heading and footer text/glyphs are centered, with space reserved
between the options and Finish Setup. Finish Setup uses one font size in every
button state. The footer group is centered using its visible content widths.
The scrollbar runs along the full menu edge, with a clear track and a compact
thumb; native track clicks and dragging scroll the options. Dragging is
continuous, retaining fractional positions on release. Rows highlight on hover
without moving keyboard focus. The wheel scrolls the viewport directly,
including while hovering an option. Close/Escape also retains them. Setup appears once
per account and can be reopened with `/glu firsttime`. If login is in combat,
it waits until combat ends.

In controller mode, `/glu options` opens the controller menu. This menu is still
in beta. If something goes wrong, include the client version, active theme and
controller style in your report. The controller menu omits Debug; Clear Trainer
Cache and Reset All Options are in Profile. Normal Options retains Debug.

**Show Hunter pet abilities** is enabled by default. Pet-training skills appear
only at their unlock level, regardless of the current-level filter or summoned
pet. The control is disabled on other classes and on Retail. Weapon skills are
optional and off by default; Warlock Grimoires have their own section.

If a custom theme has missing textures, try **Reset Appearance** or select the
theme again.

## Profiles and colours

**Profile**, above Cache Status in Options, contains profile selection, creation, rename/delete,
import/export and Language. Changes save automatically. **Save per Character**
starts with a copy of your current options and remembers that character's
selected profile; turning it off returns to the account selection. Characters
choosing the same named profile share its settings. Trainer reports, scan data
and level history stay separate from profiles.

Enter a unique name and choose **Create profile** to copy the current options.
Names allow up to 80 Unicode characters. To rename the selected profile, enter
a new name and choose **Rename profile**. **Delete profile** asks for confirmation
and returns to Default. Default cannot be renamed or deleted.
**Import / export** opens a separate window with a scrolling string field.
Choose **Export profile** to select a sharing string for Ctrl+C, or paste a string
and choose **Import profile** to create a new profile. The optional import-name
field is separate from the profile-creation name. Existing strings with the old
default-font marker are accepted. Language changes need **Reload UI** to update
all static menu labels. The controller Profile tab offers selection and language
controls, with a link to the same sharing window for text entry.

With **Use class colors** enabled, colour pickers begin at the class colour and
remain editable. Turning the option off restores your previous custom palette.
Turning it back on starts from the original class colours, clearing earlier
class-colour adjustments. Edits remain through ordinary refreshes and reloads
while the option stays enabled. Reset Appearance and Reset to Defaults also
clear these edits.

## Level-up effects

`/glu test` previews all seven supported stat rows: Strength, Stamina, Intellect,
Agility, Spirit, Health and Mana as the resource example. The same full fixture
is used by the options preview and `/glu debugskills`. Live level-ups still show
only increased stats appropriate to the client. Unused pooled rows release their
counter data and hide their entire text layer, preventing leftover gains beside
Time to Level after switching between popups with different row counts.

Animation has nine effect toggles, enabled by default in both options menus:
**Portrait pulse and starburst**, **Highlight new abilities**, **Emphasize stat
gains**, **Portrait sparks**, **New ability sparkles**, **Background embers**,
and **Frame edge glow**.

The entrance runs from top to bottom: background, portrait/ring and level text,
Stats Gained heading, stat block, Abilities heading, ability icons, then weapon
training. Time-to-level appears after the stats; Abilities and Grimoires enter
together. Hidden optional sections add no wait. Prices, scrollbars, dividers
and text glows follow their section. Animation speed scales the entrance;
Reduced Motion fades every section in together over 0.25 seconds (scaled by
Animation speed), with all decorative animated elements hidden. The display-duration timer
starts once the entrance finishes, preserving reading time at slower speeds.

**Portrait and ring settle** and **Reveal dividers** are
also available in Animation. Portrait and ring start 10% larger, stay enlarged
through the first 35% of their fade, then settle together to normal size before
the pulse. The text below stays fixed. **Emphasize stat gains** also controls
stat counting; its extra compact-mode width is retained. Stat values begin at their old amount
and signed gains at zero, counting to their final values as each row starts
sliding/fading in. The one-second count eases out and continues after the row
lands. During counting the shared stat text opacity smoothly rises from 72% to
100%, combined with the entrance fade. No permanent darkening remains on the
labels or old values, so completed counts match normal stat text brightness.
The normal stat highlight starts after
all counts finish. Labels and old values stay fixed; reserved digit widths
prevent text shifting as numbers change.
Divider textures open from the centre over 0.60 seconds at visible opacity,
without moving sections. These timings follow Animation speed; the full display
duration starts after the last count and divider reveal finish.
Reduced Motion shows final values and static artwork, with only the common
fade-in; it suppresses pulse/starburst, particles, sparkles and highlights.

The portrait and ring share an isolated artwork layer, hidden during setup and
until their fade begins. They reach full opacity 0.025 seconds before the pulse.
The original-size pulse expands to 1.4 times its starting size, then starts
the portrait starburst immediately. New abilities have a class-coloured
border and a stronger Animated Elements glow; rank upgrades use a quieter border.
Stat names and old values retain their full selected colour; new values and
signed gains use the gain colour.
Ability highlights start half a second after the final fade-in. Each nonzero
stat gain flashes white once as its count finishes. The regular top-to-bottom
stat wave starts 1.5 seconds after the last stat finishes counting and
waits three seconds after each wave before repeating the same overlapping flashes. New abilities highlight one at a time,
1.25 seconds apart by default, sharing one order across player and pet icons.
An ability repeats no sooner than five seconds later; the round grows for long
lists or longer debug sparkle bursts, keeping bursts from overlapping. Stat waves
reuse the count-completion offsets: each row flashes for 0.40 seconds, overlapping
the next row as the wave moves downward. The highlight is white
at up to 80% opacity, independent of Class Colours and Animated Elements. Text stays fixed; the sweeping bar and its
clipping layers have been removed.
Hover an icon to see its classification.
**Slide direction: None** keeps the stat fade-in without sideways movement.
Each stat row fades its text and glow through one shared frame. Its slide
updates the existing anchor, avoiding repeated anchor resets during the fade.

Portrait motes start halfway through the starburst entrance and continue for as
long as the popup is visible. Defaults are five portrait motes and five contained
starburst motes, replenishing faded slots with fresh randomized paths. The
contained group travels sideways/downward within the panel. Speed falls to zero
as each mote fades. Requires Player Portrait mode and the portrait pulse/starburst
animation. Two
corner sparkles twinkle with each new-ability highlight. New-ability
glows and sparkle bursts share the wider per-icon schedule; positions near random corners
change between cycles and stay fixed while each sparkle is visible. Rank upgrades stay
quiet. Twenty faint embers rise behind the content, and frame edges begin a
roughly 33%-opacity pulse during frame fade-in on custom themes. **Modern**
disables Frame edge glow while retaining its saved toggle. Each effect has its own toggle
and is hidden by Reduced Motion. Textures are pooled and share the existing animation driver.

All mote base sizes are 10% larger, with an additional random ±10% size variation
chosen per lifetime. Background motes use Animated Elements colour and peak at 36% opacity.
Sizes stay steady during each mote's life rather than flickering each frame.
Bottom ember base sizes are another 15% larger. Twenty embers rise with gentle
random sideways drift. Each lifetime starts at a randomized 50–100% of the previous
travel speed, then slows gradually to 70% of that starting speed at the top. Motion is upward/left/right only; there is no downward drift.
Paths and speeds renew when an ember fades out, with no visible repositioning.

**Portrait: None** hides the portrait, its ring/frame, pulse, starburst and portrait
motes, and removes the empty header space. Both options menus offer this choice.

Enable **Enable debug commands** to reveal twelve numeric tuning fields in the
normal options panel: count, size (%) and opacity (%) for portrait motes,
starburst motes, background embers and ability sparkles. Enter or leaving a field
applies it live; Escape discards the pending edit. Counts range from 0–30 for
each portrait group, 0–200 embers and 0–8 burst sparkles plus one ambient twinkle per new ability. Size is
25–400% of the current base size (defaults: 200%, 100%, 150%, 200%); opacity is 0–100%, applied
to the existing fade envelope (defaults: 65%, 65%, 30%, 90%). Count zero hides
that group. Invalid input restores the stored value; out-of-range values are
clamped. Fields are hidden outside debug mode, but saved tuning still applies.
Tuning survives theme changes and resets with **Reset to Defaults**.
This update applies the requested 5 portrait motes / 200% size, 5 starburst motes
and 20 embers at 150% size once to existing profiles; later debug edits survive reloads. Texture
pools grow only on setting changes and reuse slots when counts are lowered.

New-ability icons are 42px (5% larger); rank upgrades remain 40px. Compact Layout
reserves room for five larger icons. With Emphasize Stat Gains enabled, compact
mode uses an extra 40px of text space and a slightly smaller 19px stat font
with emphasis/counting enabled, reducing the frame by 20px. It reduces the font
further only when needed to fit the longest complete row. Labels, numbers, suffixes and glows use
the same fitted size. Regular mode keeps the normal 20px stat font and expands
the text area/frame beyond its usual width when needed. Counter boxes include
extra padding to prevent ellipsis at the final digits or closing parenthesis.
The full counting range is measured before animation; the font and frame stay
fixed while values count. Changing back to regular restores the normal font.

In **Player Portrait** mode, the starburst sits behind the portrait and follows
its position and size. It uses **Animated Elements** colour, independently of
**Portrait Border** and **Portrait Ring Hue**. When the pulse finishes, it grows from a small star
to full size and gives two short settling blinks. Its base opacity is 50%,
with a subtle shimmer and one rotation every two minutes. Class-icon mode hides
the starburst.
**Reduced motion** keeps static colours and gain emphasis while disabling the
new movement, pulses and shimmer.

`/glu test` and **Preview Level-Up** always include one new-ability example and
one rank-up example (Gnomeregan Smash, spell 432423), even without trainer data. The same examples appear in
`/glu debugskills` alongside the larger preview list.

## Languages

Choose a language at the bottom of **Mode**, then click **Reload UI**. **Auto Detect** follows the game
client. English is the fallback when a translation is missing or unavailable.

All language options are enabled: English, French, Spanish (Spain and Latin
America), German, Italian, Brazilian Portuguese, Russian, Korean, Simplified
Chinese and Traditional Chinese. Native-speaker feedback is welcome; see
[LOCALIZATION.md](LOCALIZATION.md) for translation and review notes.

Spell names, stat names and game tooltips follow the client's language. The
default font follows the client too; custom fonts need the appropriate glyphs
for the language you select.

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

| Command | Action |
| --- | --- |
| `/glu options` or `/glu config` | Open settings |
| `/glu firsttime` | Reopen GLU First Time Setup |
| `/glu controlleroptions` | Open the controller menu outside controller mode |
| `/glu test` | Preview the level-up screen |
| `/glu sound` | Toggle GLU's level-up sound |
| `/glu duration <seconds>` | Set display time; default is 7 seconds |
| `/glu mode <retail\|forever\|auto>` | Choose a client data path |
| `/glu combat` | Toggle waiting for combat to end; enabled by default |
| `/glu trainerreport` | Open trainer-report export and save instructions |
| `/glu trainerreport clear` | Clear saved change reports |
| `/glu cleartraining` | Clear scanned data; keeps bundled skills and reports |
| `/glu scan` | Toggle legacy trainer capture; bundled-class capture requires debug mode |
| `/glu scanprof` | Toggle profession capture; experimental and off by default |
| `/glu debug [on\|off]` | Toggle debug commands; off by default |
| `/glu dumptraining` | Print cached skills and learned state; requires debug mode |
| `/glu testtrainer` | Print unlearned trainer skills; requires debug mode |
| `/glu dumpskills` | Print weapon-skill diagnostics |
| `/glu perf` or `/glu perf reset` | Show or clear debug performance counters |

## Custom sounds

Put an `.ogg` file in `GnomeLevelUp/Sounds/`, then either:

- Select **Custom Sound** in options and enter its path.
- Add an entry to `Sounds/SoundList.lua`, using an existing entry as a template.
- Set the path directly:

```lua
/run GnomeLevelUpDB.customSoundFile = "Interface/AddOns/GnomeLevelUp/Sounds/yourfile.ogg"
```

LibSharedMedia sounds registered by other addons are also available.

## Known limitations

- Retail has less test coverage than Forever. Blizzard API and protected-value
  changes can require compatibility fixes.
- Trainer monitoring can only compare services the client exposes during a
  visit. It doesn't detect removed skills or check every trainer remotely.
- Catalogue prices are base prices, before reputation discounts. Quest rewards
  aren't part of the trainer list.
- Prerequisite spells and skill requirements are stored as metadata. Ranks may
  appear before you've bought earlier ranks; race, faction and talent
  restrictions are filtered.
- Weapon availability uses a separate built-in list that may need patch updates.
- Warlock Grimoires are shown at their unlock level.

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


Hunter pet training is hidden before level 10. Pet skills recorded below level
10 are first displayed at level 10; later pet ranks appear at their normal unlock
levels without accumulating on later popups. This also respects **Show Hunter
pet abilities**. Raw trainer levels and trainer-change reports remain unchanged.


**Colors > Animated Elements** controls pulse/starburst, motes, embers, edge glow,
ability glows/sparkles together. Stat highlights stay white. **Use class colors**
overrides it; switching that off restores the selected custom colour. Static
portrait/icon borders retain their existing colour controls.

Finished entrances stop writing section geometry/alpha. Stat colour updates
reuse row geometry, compact font fitting is cached until its inputs change, and
animation loops reuse effect-pool lists. These optimizations preserve animation
cadence and particle counts; native performance still needs in-client profiling.

Glow and sparkle pools skip quiet intervals using deadlines on the existing
animation clock. Stat highlights clear once between bursts and skip idle row
scans. Visible effects still update every rendered frame; no extra timers are
created. Live option changes and new popups invalidate the cached deadlines.


New ability sparkles also twinkle sporadically between flash bursts; a flash
adds the configured corner sparkles. Ambient and burst sparkles share the
existing size/opacity controls and Animated Elements colour, including Class
Colours. Rank upgrades and Reduced Motion show neither sparkle layer.

With debug mode enabled, numeric fields under Debug control **Starburst opacity
(%)**, **Portrait pulse opacity (%)** and **Frame edge glow opacity (%)**.
Defaults are 50%, 71.5% and 33% respectively. Enter
0–100; decimal values are accepted. Pulse opacity changes apply on its next play.


New-ability glow pulses last 0.60 seconds, keeping the existing stagger between
icons and the five-second minimum round. Ambient sparkle gaps are randomized
between 0.30 and 1.20 seconds; each twinkle still fades over 0.42 seconds.


Stat waves preserve the initial completion pass's overlap and Animation speed.
Each wave finishes before a three-second pause, then the next wave begins.


Shaman class-coloured elements use **#6381FF** for readability.


In the trainer report window, **Copy** selects the JSON for **Ctrl+C** (Command+C
also works). After that shortcut, the visible field clears; saved observations
remain available when you reopen the report. WoW restricts direct clipboard
writes, so clicking Copy alone does not erase the field or claim a clipboard copy.

Background Animations in first-time setup switches decorative 1.4.0 effects
off together: portrait pulse/starburst/settle, motes, embers, edge glow, ability
glow/sparkles, stat highlights and divider reveals. Text movement, stat counting
and entrance/exit fades remain. Individual effect choices are kept, so enabling
the master switch restores them. This differs from Reduced Motion.


### Horizontal popup layout

Enable **Horizontal layout** in Appearance, the controller Mode page or first-time
setup. It works independently of **Compact Layout**. The larger player portrait
sits at the centre-left with a stronger pulse, stats and Time to Level occupy
the next column, then Abilities and a separate Warlock Grimoires column when
present. Portrait None keeps only the level in the left column.

In both Horizontal sizes, abilities fill four down before using a second and
third column. Up to 12 fit before a vertical scrollbar appears at 13. Training
columns use their actual content width, with a 28-unit gap between Abilities
and Grimoires. The vertical popup keeps its prior ability layout. Column widths
account for the display and popup scale; long stat values fit their column.

Horizontal defaults to **90% (0.9)** scale and a top-centre position, 80 UI units
below the top. Horizontal and vertical positions/scales are saved independently;
the Popup scale control edits the active layout. Orientation and both layouts'
positions/scales travel in profiles. Theme changes preserve the horizontal
position/scale; Reset All Options restores defaults. Portrait effects follow the
portrait. Reduced Motion and Background Animations retain their behavior.

Modern defaults to **80% opacity** on fresh settings or when selected again.
Its original soft backdrop has a masked edge, shaded stat rows and accent bars
that extend to 94% of the frame width. Bars update with Animated Elements colour
changes immediately and reveal from the centre with Reveal dividers. Reduced
Motion and Background Animations also apply to these reveals. The backdrop
expands outward in sync with the bars. Custom themes
retain their artwork.

First-time setup opens shortly after login/world loading has settled and retries
when combat ends if necessary. **Finish Setup** saves completion. Closing it
without finishing allows it to return next login; `/glu firsttime` always opens
it manually. Older builds recorded only an attempted opening, so users with
that old marker will receive setup once more until they finish it.


`/glu debugskills` shows 15 abilities and 15 grimoires, exercising the full
four-down, three-across grids and overflow. Horizontal Abilities reserves three
columns: one populated column is centred, and two are centred as a pair. Icons
retain their base sizes as lists grow. All twelve grid positions fit before
scrolling; the shared scrollbar sits halfway between Abilities and Grimoires
and moves both lists, stopping each at its own end. Mouse wheel works over
either list. Without Grimoires, the bar sits beside Abilities.

Horizontal enlarges the player portrait and ring together by about 14% over
the earlier Horizontal base, keeps their configured relative size and reserves enough height
for four full skill rows, the portrait and stats/Time to Level, with additional
bottom clearance. The 350 displayed UI-unit limit remains; whole-panel fitting
is used for extreme scale/display settings. Weapon training is hidden and its
option disabled in Horizontal; the saved preference returns in Vertical.
Horizontal defaults to top centre (80 UI units below the top), while dragged
positions remain independent for each layout. Missing or legacy vertical-default
horizontal positions use that top-centre fallback immediately when switching.

Vertical centres incomplete ability rows and removes the unused bottom
extension, balancing top/bottom content padding. Modern's vertical backdrop
still extends 12% further down while preserving its top edge.

The 3D portrait uses model-depth occlusion adapted from Animated Default
Portraits 1.1.3 by dvd (see THIRD_PARTY_NOTICES.md). Two almost-invisible built-in
gears models occlude the player model outside their circular holes. Their
15-degree relative rotation improves the polygonal circle outline. The black
backing remains confined to its circular texture; there is no opaque square
cover. Mask creation is lazy, shared with the existing portrait lifecycle, and
adds no addon dependency or global portrait hooks. This relies on client model
rendering behavior and needs an in-game visual check on Forever.

Horizontal ring geometry defaults to 1.15× scale and a +1 Y offset. The ring
scale/offset controls edit the active layout; vertical ring geometry is retained.
Horizontal ring settings are also included in profiles and full reset.

Choose **Player 3D portrait** in the Portrait dropdown for a live player model
inside the existing ring. It shares the portrait fade, settle, horizontal size
and effects. Reduced Motion or disabled Background Animations pauses its idle
movement. The model is created only when selected and reused thereafter. The
small controller/setup header preview remains a flat player portrait.

With Debug enabled, numeric fields control the 3D model rotation (degrees),
depth, horizontal/vertical position and scale (%). Edits apply immediately and
are stored in profiles. Selecting Horizontal layout enables Compact Layout;
Compact stays locked on while Horizontal is enabled; it becomes selectable
again in Vertical.

In Horizontal mode, Time to Level sits directly below stats with a 2-unit gap;
the separators between/under those blocks are hidden and their height removed.
Vertical mode keeps both separators and its existing spacing.

With Debug enabled, **3D mask size (%)** adjusts the circular model-depth
opening independently of the model and ring size. Range: 25–300; 100 aligns
with the black backing circle. Changes apply immediately after Enter or leaving
the field. The setting is saved in profiles and resets to 100 with full reset.

Horizontal centres the stat rows and Time to Level together between the header
divider and lower accent, retaining the usual section gap above Time to Level.
The Stats Gained heading stays at the top of its column. Vertical training
headings use full column width, CENTER horizontal and MIDDLE vertical alignment.

**3D viewport size (%)**, also Debug-only, controls the rectangular model frame;
range 25–300, default 100. The depth-mask opening remains tied to the backing
circle as the viewport grows. Start both mask and viewport at 100% for testing,
then report any adjustments needed. The model itself still has separate scale,
rotation and position fields. Model-mask calibration refreshes for viewport,
portrait, ring, settle and effective-scale changes. Mask models are paused and
remain children of the portrait, so hiding the popup hides their rendering.


### Race and sex calibration

The 3D portrait automatically uses the 18 tested male/female presets for Human,
Dwarf, Night Elf, Gnome, Orc, Undead, Tauren, Troll and Skyborne from the supplied
worksheet, including rotation. Draenei and Blood Elf have no Forever preset.
The original workbook is in Tools/Portrait-Race-Sex-Tuning.xlsx.
Unknown races or sex values use the existing configurable model defaults.

Debug model fields show the effective preset values. Editing one stores an
absolute override for that race/sex in this character's SavedVariables, separate
from shared/imported appearance profiles. Reset All Options clears this
character's overrides and restores the shipped presets. Existing profile model
fields remain available as the fallback for races without a preset; they do not
override calibrated races. Character race/sex is refreshed on portrait/model
refresh, with mask geometry using the same effective calibration as the model.


### Milestone celebrations

Real level-ups at positive multiples of ten use stronger effects for that popup:
twice the configured particle counts (within the existing per-effect caps),
25% larger/brighter particles, more frequent ambient ability sparkles, a larger
starburst/pulse and brighter edge glow. Zero counts and disabled effects remain
off. Reduced Motion and Background Animations keep their existing behavior.
The next nine levels use the ordinary settings; saved tuning is never modified.
Pools are reused after the first larger celebration.

Use `/glu milestone` to preview the nearest milestone at or above your current
level, or `/glu milestone 30` to choose a multiple of ten (10–1000). `/glu test`
and `/glu debugskills` remain normal previews even on a milestone-level character.


Milestone popups use the original portrait pulse with two thin expanding shockwaves, a repeating
clipped-glyph gleam across the level text, brighter decelerating bursts on every
stat with alternating left/right origins after the last stat count, and paired light trails moving from divider centres toward
their ends after each section lands. These use the Animated Elements colour;
the text gleam lightens that colour for readability. The portrait pulse follows
Portrait Animation and require a player portrait; divider trails follow Reveal
Dividers; the completion burst requires Emphasize Stat Gains and improved stats.
All four follow Background Animations and Reduced Motion. The pulse, fireworks
and trails play once per popup; the gleam repeats every 3 seconds. They share the existing visible-only driver, with lazily allocated reusable
textures. `/glu milestone` previews all enabled milestone effects.


Animation settings include **Milestone Animations**, enabled by default in both
normal and controller menus, saved in profiles and restored by Reset All Options.
Turning it off disables all milestone boosts/accents and restores normal level
text. Milestone level text is 43% larger and uses no added bold weight, retaining custom fonts and non-Latin coverage.
The larger static text remains available with Reduced Motion. Horizontal
milestone starbursts are 20% smaller than the earlier milestone version;
vertical and ordinary starbursts retain their sizes. Stat bursts emit up to
16 particles per visible row, with increased brightness/size. Stat fireworks
play one row at a time with alternating origins, roughly twice the original
travel distance and a fixed random opacity multiplier of 0.9–1.1 per particle.
Their non-overlapping windows shorten when necessary to fit the popup duration.
The brighter text gleam repeats start-to-start every 3 seconds, and Modern
top/bottom bars use the same centre-out trails as the section dividers.


The portrait pulse uses the original circle-frame artwork and .65s timing,
with two thin milestone shockwaves. The experimental thick-ring artwork is no
longer used by the runtime (retained for rollback). The brighter, wider level gleam repeats every 3 seconds after its first
pass. Firework slots are .50s / speed (shortened further if the popup needs it),
and their derived base opacity is 10% higher, preserving per-particle variation.
Horizontal portrait motes start beyond the ring edge and drift 70% farther;
vertical and contained starburst motes retain their existing paths.

Default font explicitly selects Fonts/FRIZQT__.TTF and clears customFontPath.
It does not use STANDARD_TEXT_FONT, which skins or clients can replace.
Invalid/empty font paths also fall back to Friz for existing and new stat text.
First-time setup lists Horizontal layout in slot 5, after Time to Level.


### Grimoire space and entrance

In Horizontal layout, a visible Grimoire section reserves the same three-column,
four-down grid as Abilities. A single populated column is centred in that space;
two populated columns are centred as a pair. Overflow keeps the shared scrollbar
and fixed icon sizes. Modern's dark horizontal backdrop extends another 24px on
each side while Grimoires are visible, including during its expanding reveal;
that extra coverage is removed when the section disappears. Custom artwork and
vertical backdrop dimensions remain unchanged.

Abilities and Grimoires now share their header fade start and icon entrance
start in both layouts. Each list retains its own per-icon stagger. Later sections
and popup duration wait for whichever list finishes later.


Milestone gleam brightness is slightly reduced while preserving its 3s repeat.
Fireworks explicitly render above both the content and background frame levels,
so an opaque backdrop cannot cover them. For lists longer than nine skills,
ability highlights and sparkles become eligible after the first nine entrances
finish (plus the existing .5s delay), instead of waiting for every skill. Later
icons still wait for their own entrance; each effect keeps its existing stagger.
This applies to both the Abilities and Grimoire lists; ordinary shorter lists
retain their previous completion gate.

Horizontal headers sit 4px higher and excess vertical padding is reduced,
trimming about 10 layout pixels in standard Compact/Regular popups without
shrinking icons or fonts. The stats/Time-to-Level block still stays together
and centres in the available space; content-fit safeguards remain active.

Milestone portrait glows expand 10% further and gain 10% opacity (capped at full
opacity). Stat fireworks visit rows in a shuffled order, alternating randomized
left/right origins across the text width, with varied size and taller spread.
Ability wheel scrolling works over icons and the scrollbar, and layout refreshes
retain the current offset. The 2D player portrait is 5% smaller inside its ring.
First-time setup includes Portrait in slot 4, before Time to Level and Horizontal.

Firework size and opacity can be tuned with numeric fields in Debug. Defaults
are 80% size and 70% opacity. Compact horizontal mode
has its own 2px default section padding; Section padding edits the active layout value.
Overflow lists with more than nine skills skip entrances for off-screen icons.
Switching orientation refreshes the 3D portrait camera and its mask together.
Female Troll defaults use horizontal position 0.18 and rotation -15 degrees.

Textured themes never enlarge the popup beyond the equivalent Modern layout.
Their contents scale down together when needed to preserve the 5px inset.

Debug includes **Frame inset (px)**, a numeric field from 0 to 100 (default 0).
It adjusts non-Modern content clearance without increasing the outer frame.

Horizontal popups calculate equal whitespace at each end from the portrait/level
column and the final training column, including an external scrollbar.

Debug numeric fields include small +/- buttons alongside narrower text boxes.
3D depth/position steps by 0.01, rotation by 1 degree, and percentages/counts/inset
by 1. Female Gnome defaults are depth -0.05, horizontal 0.10, vertical -0.03 and
rotation -20 degrees.

Updated 15 race/sex 3D portrait calibrations from in-game tuning on 22 October.
The detailed values and rollback instructions are in Tools/REFACTOR_LOG_2026-10-19.md.

Seven additional effects can be compared individually under Animation: portrait
ring glint, new-ability reveal shine, milestone anticipation, stat impact sparks,
background depth, closing animation, and milestone color transition. All default
on and respect Reduced Motion and Background Animations. Test ordinary effects
with `/glu test` and milestone effects with `/glu milestone 30`.
