# Working on GnomeLevelUp

Read the addon version and load order from `GnomeLevelUp.toc`. Retail and Forever
share the renderer but use different ability and stat rules. Test both paths;
headless checks cannot confirm native rendering, sound or controller input.

## Source map

| Area | Files |
| --- | --- |
| Defaults, shared settings/display rules, migrations and commands | `Core.lua` |
| Profiles and sharing window | `Profiles.lua`, `ProfileTransfer.lua` |
| Live level events, /played cache and pending popups | `LevelUp.lua` |
| Recorded intervals, best times, account history and its Options page | `LevelHistory.lua` |
| Last real level-up snapshot and replay | `LevelReplay.lua` |
| Stats, resource filtering and number formatting | `Stats.lua` |
| Popup lifecycle, animation clock and frame layout | `UI.lua` |
| Text measurement, section anchors and effect updates | `UIStatText.lua`, `UIPopupLayout.lua`, `UIEffects.lua`, `UIRender.lua` |
| Theme definitions, texture compatibility and textured frames | `ThemeList.lua`, `TextureCompat.lua`, `ThemeRenderer.lua` |
| Mouse Options, tabs and responsive controls | `Options.lua`, `OptionsTabs.lua`, `OptionsLayout.lua` |
| Controller menu and first-time setup | `ControllerOptions.lua` |
| Shared option descriptions and translations | `OptionHelp.lua`, `Locals.lua`, `Locales/*.lua` |
| Spellbook, trainer data and pet training | `SpellBookCompat.lua`, `TrainerScan.lua`, `WarlockPet.lua`, `Data/` |
| Trainer reports | `TrainerReport.lua` |
| Native notification suppression and minimap shortcuts | `HideBlizzardLevelUp.lua`, `MinimapButton.lua` |

## Editing conventions

Use comments for the reason behind a workaround, a client limitation or an
important data boundary. Avoid restating the next line or leaving conversational
history in runtime files. Name longer-lived locals by their purpose. Extract a
function when a caller needs to distinguish separate jobs, rather than creating
wrappers around individual API calls.

Keep saved-variable keys, translation keys and public `ns` functions stable.
Call required addon functions directly after their TOC dependencies load. Keep
feature checks for client APIs and optional libraries. Do not remove a migration
just because its old setting no longer appears in Options.

Every new player-facing string needs a translation in every non-English language file. Do not
translate API names, commands, IDs or asset paths. See [LOCALIZATION.md](LOCALIZATION.md).

## State boundaries

- `Core.lua` owns defaults, shared setting setters and client/display policies.
  Shared mouse and controller settings use `OPTION_SETTINGS`; `Profiles.lua` applies
  validated snapshots without replacing the live `ns.db` table.
- `LevelHistory.lua` owns saved level intervals, best times and account history.
  `LevelUp.lua` owns the live stat baseline, pending level-up batch and /played
  cache. Its reset command asks history to clear records, then resets the cache.
- `UI.lua` owns preview lifetime and its closing timer. Menus request suspension;
  they do not change the timer or stat-page state. Effect helpers read the popup
  clock through their context and update their own pooled textures.
- `LevelReplay.lua` owns the saved last-level-up snapshot. Profiles and test
  previews do not replace real history or replay records.

Keep saved-data writes in their owning module. Use returned history views for
rendering; do not edit stored records from menus or event callbacks.

## Automated checks

Run from the addon directory with Python 3:

```text
python -X utf8 Tools/run_checks.py
python -X utf8 Tools/run_checks.py verify_screenshot_test.py verify_max_background_fade.py
python Tools/check_wow_api.py
```

The first command runs the main regression set. Pass individual `verify_*.py`
filenames for focused work; the remaining checks are under `Tools/`. Linux uses
`liblua5.4.so.0`. On Windows, the runner finds the VS Code Lua extension, or accepts
`--luals "C:/path/to/lua-language-server.exe"`.

For the API check, run `python Tools/check_wow_api.py --setup` once to install
checksum-verified dependencies. `--cache PATH` selects their location. Use `--output PATH` to choose the report
directory. Versions and hashes are pinned in
`Tools/wow-api-lock.json`.

The API check fails on errors or new warnings. Four existing warnings have
specific explanations in `Tools/wow-api-baseline.json`; do not regenerate that
baseline to hide new findings. `--strict` also fails on reviewed warnings.
Results go to `Tools/Diagnostics/` by default.

## In-game checks

After `/reload`, check the affected controls with the mouse and controller.
For popup changes, compare normal, milestone and max-level previews in both
layouts, Modern and a textured theme, and Classic Mode. Check long stat strings,
secondary-page switching, early close and automatic close. Test new text in a
longer translation and a narrow Options window.

Use `/glu perf on`, `/glu perf reset`, run the preview, then `/glu perf` for
callback timings. Keep portrait, effects and location consistent when comparing
runs. Warm up first. `/glu memory` samples allocations; a manual collection with
the popup closed distinguishes retained data from pending garbage. GLU does not
force collection automatically.

Never automate WoW input. Rendering, audio, controller focus and actual trainer
responses require manual confirmation on the target client.

## Data and packaging

The bundled Forever catalogue is the primary trainer list. Trainer visits can
report changed IDs or required levels; discounts and missing services are not
proof that the catalogue changed. Keep uncertain records for review rather than
rewriting them merely to silence a warning.

Release packages use `GnomeLevelUp/` as their root. `.pkgmeta` excludes development
tools and contributor/localization notes. The temporary screenshot command stays
in `Tools/ScreenshotTest.lua`; its loader and renderer overrides have
`@do-not-package@` markers. Keep those markers intact while the tool is in use.

Historical decisions and rollback instructions remain under `Tools/`. Preserve
all rollback backups, including the six explicitly retained by the user. The
readability snapshots are `Tools/Rollback/2026-11-02-readability/` and
`Tools/Rollback/2026-11-02-rules-state/`.

## Readability work status

All nine original suggestions are complete. The second pass consolidated display
rules and setting callbacks, moved timing persistence into history, and made
preview lifetime private to the renderer. The saved schema, public entry points
and temporary screenshot tool remain compatible.
