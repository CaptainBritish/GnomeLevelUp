# Working on GnomeLevelUp

The current development version is 1.5; the last public release is 1.3.8. WoW Forever is the primary test client. Retail compatibility needs separate in-game testing.

## Code map

- `Core.lua`: defaults, saved settings, themes and addon events.
- `UI.lua`: level-up display and ability rows.
- `TextureCompat.lua`: shared texture assignment, atlas lookup and controller glyph fallbacks.
- `Options.lua`, `OptionsLayout.lua`: Blizzard settings panel and text layout.
- `ControllerOptions.lua`: controller menu, navigation and preview.
- `Locals.lua`: UI translations and locale selection.
- `Data/ForeverCatalog.lua` and class data files: bundled trainer skills and metadata lookup.
- `TrainerReport.lua`: trainer differences, report export and report window.
- `Tools/`: development checks; excluded from release packaging by `.pkgmeta`.

## Comments and translations

Use comments to explain client quirks, constraints and decisions that the code cannot make obvious. Keep conversation history and instructions out of runtime comments. Describe current behavior in the README and record release changes in the changelog.

Every new user-facing string must be added to all ten non-English dictionaries. English source strings are the lookup keys. Do not translate saved-variable keys, API names, slash commands, spell IDs or asset paths. See `LOCALIZATION.md` for locale status and review guidance.

## Trainer data

The bundled catalogue is the normal source of trainer skills. Trainer visits provide a fallback for detecting new spell IDs or changed required levels. Prices can vary with discounts, and an absent service does not prove that a spell was removed.

Reports are stored in SavedVariables when the player reloads or logs out. The export window can also provide report-only JSON. Profession capture remains experimental and off by default; its slash command remains available, but there is no profession checkbox in the options panel.

The catalogue validator currently reports 22 family/rank collisions for review and 72 explicit external spell references. Do not rewrite these records merely to silence warnings: check the actual spell relationship first.

## Local checks

Run these from the addon directory with Python 3 and `liblua5.4` installed:

```sh
python3 Tools/verify_localization.py
python3 Tools/verify_forever_training.py
python3 Tools/verify_refresh.py
python3 Tools/validate_forever_catalog.py
python3 Tools/verify_catalogue_validation.py
python3 Tools/verify_trainer_reports.py
python3 Tools/verify_lazy_options.py
python3 Tools/verify_controller_layout.py
python3 Tools/verify_texture_compat.py
python3 Tools/verify_ui_load_order.py
python3 Tools/verify_wow_api_runner.py
python3 Tools/verify_native_level_chat.py
python3 Tools/verify_hunter_report_update.py
python3 Tools/verify_shaman_report_update.py
python3 Tools/verify_mage_report_update.py
python3 Tools/verify_paladin_report_update.py
python3 Tools/verify_visual_effects.py
```

These checks exercise mocked APIs. They cannot confirm client rendering, controller focus or actual trainer responses. In game, check language changes after `/reload`, mouse and controller options, narrow panels, trainer reports after saving, and the level-up preview. Check sound behavior on the target client before changing its mute logic.

Package source archives with the `GnomeLevelUp/` folder at the root. Exclude Python bytecode and temporary files. Keep development tools in source archives; release packaging excludes them through `.pkgmeta`.

## Compatibility maintenance

Call required addon functions directly once their TOC dependencies have loaded.
Retain checks for client APIs, optional libraries and the controller module, which
returns early on Retail. Keep texture fallback rules in `TextureCompat.lua`;
callers own sizing, visibility, text fallback and theme transforms.

The 19 October 2026 refactor log and rollback files are under `Tools/`.

## WoW API diagnostics

Run the API-aware check as part of development validation:

```sh
# First run: install checksum-verified LuaLS and Ketho definitions in a user cache.
python3 Tools/check_wow_api.py --setup

# Later runs reuse those exact dependencies; missing tools fail explicitly.
python3 Tools/check_wow_api.py

# Show the unsuppressed warning outcome (currently returns exit code 1).
python3 Tools/check_wow_api.py --strict
```

The runner needs Python 3.9+ and supports the pinned Linux/macOS x64/arm64 and
Windows x64 packages. Installation needs access to GitHub and codeload.github.com.
Use `--cache PATH` to choose a dependency cache and `--output PATH` to choose
where reports are written. The default output is `Tools/Diagnostics/`.

`Tools/wow-api-lock.json` pins LuaLS 3.19.2 and Ketho 0.22.3 plus archive hashes.
The Ketho version matches the uploaded VSCode settings. The user's LuaLS version
and user-wide editor settings were not supplied, so exact editor parity is not
claimed. The command uses Ketho Core definitions, WoW Lua 5.1, disabled stock
Lua builtins, and the uploaded recognized-global and weak-union settings from
`Tools/wow-api-config.json`. It does not run VSCode's extension-host callbacks
that automatically modify diagnostic settings. No broad warning category is
disabled to obtain a clean result.

Embedded libraries are loaded for their declarations; their own diagnostics are
excluded. Development fixtures and rollback copies are excluded. These files
remain covered by their existing checks where applicable.

The initial result is zero errors and four reviewed warnings. Each is recorded
with its reason in `Tools/wow-api-baseline.json`: the guarded legacy GetSpellInfo
lookup, initialization of the Forever cache through EnsureSavedStore, and two
optional trainer-tooltip ID fields absent from Ketho's declared type. The last
two still require live Forever verification. Existing mocked coverage does not
prove the real-client tooltip shape.

The normal command exits 0 only when no new diagnostics or errors appear. It
prints the reviewed warning count and preserves all findings in JSON/Markdown;
strict mode exits 1 on any warning. The comparison uses file, diagnostic code,
message, source text and occurrence count, so line-number shifts do not create
noise and duplicate/new findings still fail. Exit 2 indicates setup or checker
failure. Review baseline edits manually; never regenerate them merely to silence
a failing run. If a reviewed warning disappears, remove its baseline entry after
reviewing the reason.

Read `Tools/Diagnostics/api-check-results.md` and the corresponding JSON for the
latest static findings. Continue the live WoW tests described above.


The visual-effects check runs the real `/glu test` entry point against headless
widgets. It covers new/rank samples without trainer data, rank metadata in all
ability sources, pooled icon reuse, individual toggles, appearance reset,
Reduced Motion, portrait colour/layer/opacity and hidden-frame cleanup.
It does not render Blizzard textures or prove in-game appearance. In the client,
compare `/glu test` with each Animation effect off/on, both portrait modes,
custom themes, compact layout and Reduced Motion.


Scale animations use `SetScaleFrom`/`SetScaleTo`; the visual-effects mock exposes
only the documented Scale setters instead of accepting arbitrary `Set*` names.
Keep the explicit `Scale` type on the portrait-pulse animation so LuaLS checks
its calls against Ketho's Scale definitions rather than the generic return
from `CreateAnimation`.


Stat rows now move a shared parent frame each render tick instead of animating
text/glow regions independently. The visual regression samples their movement
and checks that they remain at the final position through later effects. It
also checks delayed starburst growth, both settling brightness dips, 40% base
opacity, the half-second post-fade shimmer delay and three-second repeats, stronger class tints
independent of the global colour setting, and the Gnomeregan Smash preview.
The level text has no added scale or starburst effect and no reveal toggle.
Reduced Motion skips the growth/blink/repeating-shimmer sequence.


The seven effect controls are in Animation in both menus. The regression selects
None through the normal dropdown and controller choice, checks no horizontal
stat motion with fading preserved (including switching off a running slide),
and samples three consecutive repeating ability/stat shimmer cycles. The repeat
interval is three real seconds and is independent of Animation speed.


Compact sizing checks cover the emphasized-stat width increase, longer localized
labels and large values, unchanged normal width, live toggles, synchronized text
and glow widths, 42px new versus 40px rank-up icons, pooled reuse, pet rows,
trainer costs, five-icon compact scrolling and layout refreshes that do not
replay entrance animations. Measurements in the widget mock ignore colour codes
and account for inline texture placeholders instead of counting formatting as
visible text.


The stat sweep regression samples ordered row peaks and overlapping neighbours
over three cycles, verifies updates on consecutive 144 Hz ticks, and checks a
single visible row with hidden pooled rows. It preserves delayed startup, a
two-second sweep/one-second gap, unchanged ability timing, no row movement,
Reduced Motion and hidden-frame cleanup. Actual glow rendering still needs
`/glu test` in the client.


The latest stat regression checks top/bottom glyph samples, neighbouring-row
overlap, stationary base text, clipping windows and gain-only text alignment,
font changes, pooled allocation reuse and hidden rows. The renderer uses 32
pooled horizontal clipping slices shared by all rows, with a raised-cosine
alpha profile. It approximates a soft gradient using ~1.625px slices at the
default scale; live-client rendering is the final visual check.

Portrait checks cover the combined toggle in both menus, old-setting migration,
the 0.2s delay at normal/double speed, original 1.4x expansion, starburst beginning only on
pulse completion, cancellation, Reduced Motion and retained settling/40% opacity.


After a live report that the sliced sweep was invisible, its windows now use
ScrollFrames with top-left anchored, padded scroll children. Tests resolve
viewport position, child-local text position and vertical scroll together to
check stationary glyphs and in-range offsets, and assert the highlight frame
level is above the base rows. The widget mock cannot certify native clipping
or prove the renderer fault is fixed: confirm with `/glu test` in WoW.


Four extra texture effects share the visible-only driver: six portrait sparks,
eight embers, twelve edge-glow strips, and two corner sparkles per pooled icon.
They use built-in star4/WHITE8X8 textures. Regression checks independent menus,
class colours with global colour mode off, post-pulse ordering, main/pet new/rank
classification, repeat timing, one-shot completion, pooling, Reduced Motion and
hide/disable cleanup. Actual appearance still requires the WoW client.


Latest renderer correction replaces stat-sweep ScrollFrames with plain Frames
using SetClipsChildren and locally anchored counter-moving canvases. Tests reject
ScrollFrames and texture regions in this tree and resolve screen positions.
Native rendering still needs confirmation; neither mocks nor static API checks
prove glyph clipping looks correct.

Mote tests cover the half-starburst-entrance threshold, randomized per-popup
parameters, decreasing travel over equal time intervals, opacity approaching
zero, final hiding, and no motes without a visible starburst. Edge tests check a
root-parented 30%-alpha layer, visibility during initial fade-in and bounded
combined strip intensity. No UI strings or setting keys changed.


The second starburst-mote pool has six textures sharing Portrait sparks. Seeded
headings/origins stay in the lower half, and clamped endpoints keep the complete
rotated mote inside the panel without per-frame boundary stops. Tests sample
non-upward motion, normal and narrow/offset panel bounds, class tint, pooled
reuse and cleanup. The bottom pool is 40 (8x5), with its original eight duration
variants repeated across the larger pool. Sweep alpha samples must be exactly
70% of their prior profile (peak coefficient 0.455 rather than 0.65).


The user canceled the glyph-sweep experiment. Current production code uses the
original text/glow layers for whole-row highlights, one stat at a time. No
stat clipping windows, ScrollFrames, extra glyph copies or moving bars remain.
The regression checks exclusive ordered row peaks, 0.455 maximum gain blend,
delayed startup, three repeats, quiet gaps, single-row/hidden-row reuse and
hide/Reduced Motion cleanup. Earlier sweep-rendering notes above are historical.


Portrait motes now use one original and two contained slots, shared across the
whole portrait emitter. Expired invisible slots reroll their parameters and
restart at zero alpha; no textures are created. Regression runs a 15-second
preview past multiple lifetimes, checks a 2–3 active population and stable object
counts, fresh paths, disable/re-enable and Reduced Motion resume. Bottom motes
remain a separate pool of forty. Earlier one-shot count notes are historical.


Mote sizes use base*1.10*(0.90+random*0.20), selected per lifetime for portrait
slots and per rising cycle for background motes. Tests cover the resulting size
bounds, no size changes mid-cycle, cycle renewal, exact 21% background-opacity
peak, all forty background class tints with global colouring off, and retained
containment for larger motes. No new UI strings or settings are introduced.
