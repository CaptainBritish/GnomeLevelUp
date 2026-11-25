# Theme pack reference

[Back to the quick start](README.md)



`GnomeLevelUpThemeAPI.RegisterTheme(addonName, id, definition)` returns the
registered key on success or `nil, reason` on failure. Call it once per theme.
The addon name comes from `...` at the top of your Lua file. The name and ID use
letters, digits, underscores or hyphens. IDs are case-insensitive within each addon.
The combined saved key may be up to 80 bytes including the `GLUTheme:` prefix and separator.

|Field|Value|
|-|-|
|`label`|The visible name, up to 80 bytes. Your addon can supply a localized label.|
|`opacity`|Overall opacity from 0 to 1. Defaults to 0.95.|
|`soundsEnabled`|`true` or `false`. Set `false` for a theme without custom audio; GLU ignores its sound cues and uses the normal fallback. Omitted means `true` for compatibility with older packs. This does not change the player's sound settings.|
|`sounds`|Optional table of sound cues. Each cue accepts a LibSharedMedia `media` name or a WoW `soundKit` ID. The example’s `Register.lua` builds this table from each `SoundList.lua`.|
|`font`|Optional. A relative `.ttf` or `.otf` path, or a built-in font key: `FRIZQT`, `ARIALN`, `MORPHEUS` or `SKURRI`. Omit it for GLU's default font. Selecting the theme applies this font; players can then override it under Appearance → Font.|
|`fontName`|Optional display name for a bundled font, such as `"Final Fantasy IX"`. The Font menu uses this name; the registration remains unique to your addon.|
|`fontSizeOffset`|Optional adjustment in points, from -8 to 16, applied to popup text before the player's text scaling. Defaults to 0. Blue Atlas uses 2.|
|`fontSizes`|Optional table of exact base point sizes (6–72) for `stats`, `headings`, `level`, `time`, `abilityCosts`, `timeline`, and `body`. Each supplied size takes precedence over `fontSizeOffset` for that role.|
|`fontSizeOffsets`|Optional per-element adjustments (-8 to 16 points), added to inherited sizes. Blue Atlas uses `{ level = 5 }` to enlarge only its level label by another five points.|
|`divider`|Optional table with a `texture`, `height` (1–32 pixels, default 3), and optional RGB `hue`. Applies to the popup's section dividers. Omit it for the normal dividers. Blue Atlas uses a four-pixel silver bevel cut from its frame.|
|`frame`|An existing frame key such as `"WOOD\_PANEL"`, or a table with `topLeft`, `top`, and `left` texture paths. `cornerSize`, `edgeSize`, and `edgeMaskInset` default to 48, 16, and 5. Optional `backgroundInset` moves the fill inside rounded artwork; it defaults to 0 and accepts values up to `cornerSize`. GLU reuses the supplied textures for the other pieces unless you supply their paths. Optional `cornerSizes`, `transforms`, and `hue` are shown in `Theme.lua`.|
|`background`|An existing background key such as `"SCRATCHED\_STONE"`, or a table with `texture` and `style` (`"tile"`, `"fill"`, or `"stretch"`). Tile is the default. Fill requires the source `width` and `height` to preserve the image proportions. The optional `hue` and `opacity` apply to the background alone.|
|`portraitRing`|Optional. An existing ring key such as `"STEEL"`, or a table with a `texture` and optional `scale`, `offsetX`, `offsetY`, `hue`, and `glintRadius`. Omit it for the standard solid ring.|

Paths are relative to the companion addon folder and use `.tga` or `.blp` files.
Custom assets also appear in GLU’s individual Frame, Background and Portrait ring
lists. If a selected pack is unavailable, GLU falls back to Modern for the frame
and background and to the solid ring for any missing ring artwork. It retains
the saved selection, so the pack can resume when enabled again.

Registration errors identify the addon/theme key, the problem field and the
expected value, for example `background.width` or `sounds.idleMotes.loopSeconds`.
Fix the reported field and reload before trying again. A failed registration
does not add a partial theme to the menus.

## Fonts

FFIV Blue Atlas uses a bundled font, a silver nine-slice frame, a tiled blue
background and one custom level-up sound.
Its supplied 109×109 frame was cropped into four 32×32 corners, two 32×16
horizontal edges and two 16×32 vertical edges. All pieces are 32-bit TGA files
with their original alpha; the 128×128 background keeps the supplied pixels.
The fill has a 12-pixel inset to preserve the transparent rounded outer corners.

`Theme.lua` selects the supplied font:

```lua
font = "Fonts/FinalFantasyIXfontcopy.ttf",
fontName = "Final Fantasy IX",
fontSizeOffset = 2,
fontSizeOffsets = { level = 5 },
-- Optional exact sizes instead of the offset for individual roles:
-- fontSizes = { stats = 22, headings = 20, time = 16 },
-- Alternative built-in font example:
-- font = "ARIALN",
```

To replace it, put your font in the addon's `Fonts/` folder and update the path.
Fonts do not need entries in the `.toc`.
Each theme remembers the player's font choice independently, including Modern.
The silver portrait ring uses a 256×256 TGA with a transparent centre and outside.

Custom fonts are also registered with LibSharedMedia for the Font menu. Built-in
fonts retain GLU's locale handling. A bundled font needs its own glyphs for every
language you intend to support; check accented letters, Cyrillic and other
scripts in game. If the selected pack is disabled, its bundled font falls back
to GLU's default without erasing the saved path.

## Test in game

1. Select the theme and run `/glu test` for a normal preview and `/glu test count 30` for scrolling.
2. Run `/glu test <milestone level>` using your configured milestone interval. Use `/glu test 60` for Forever's maximum-level celebration; on Retail, use that client's current level cap. Milestone and maximum-level effects are included automatically; there are no separate `/glu milestone` or `/glu maxlevel` commands.
3. Check horizontal and vertical layouts, compact mode, long stat names and prices, portrait modes and the timeline. Check the controller menu and first-time setup too.
4. Check normal and Classic Mode animations, reduced motion and the appearance of transparent edges. Listen for overlapping or excessively loud cues.
5. Try the theme's default font, then choose another font and confirm it remains selected during previews and reloads. Test any languages the pack supports.
6. Test automatic theme audio, an explicitly chosen level-up sound, and Use Theme Sounds turned off. An artwork-only theme with `soundsEnabled = false` should use normal fallback audio.
7. Save a profile, reload, then disable and re-enable the pack. Missing artwork should fall back safely and return when the pack is enabled again.

## Sound cues

The included theme uses `Sounds/BlueAtlasFFIX/FFIXTheme.ogg` for level-up audio.
Its `SoundList.lua` is loaded before `Register.lua`:

```lua
local \_, pack = ...
pack.soundSets = pack.soundSets or {}
pack.soundSets.blue\_atlas\_ffix = {
    folder = "BlueAtlasFFIX",
    cues = {
        levelUp = { name = "FFIV Blue Atlas - Level Up", file = "FFIXTheme.ogg" },
    },
}
```

Add any other cues to that table if your theme needs them. Set
`soundsEnabled = false` in `Theme.lua` to disable all theme audio.

|Key|When it plays|
|-|-|
|`levelUp`|As the level-up popup opens. GLU uses Blizzard’s default when the theme leaves this slot empty.|
|`portraitImpact`|When the portrait impact ring fires.|
|`starburst`|When the portrait starburst fires.|
|`statGlint`|When sparks appear at the end of a stat counter during a milestone or max-level celebration.|
|`idleMotes`|Repeats while portrait or background motes are visible. Set `loopSeconds` to the length of the clip.|
|`fireworks`|Once per background burst and once when the max-level edge fireworks begin.|
|`fadeIn`|At the start of the opening transition.|
|`fadeOut`|At the start of the closing transition.|

Omit a cue to leave it unset. `volume = 0` mutes a cue. WoW sound kits support a
per-cue `volume` from 0 to 1 on clients that expose the override. For `.ogg` or
`.mp3` assets, set the desired loudness when exporting the audio file. Classic
Mode keeps the level-up and fade cues and skips decorative animation cues.

### Individual popup text sizes

Use these keys in `fontSizes` for exact point sizes or `fontSizeOffsets` for adjustments. Unspecified elements inherit their parent role. Player text scaling is applied afterward. An exact size overrides offsets on that element and its parents; more specific child offsets still apply.

|Elements|Parent role|
|-|-|
|`statLabel`, `statOld`, `statArrow`, `statNew`, `statDelta`|`stats`|
|`statsHeader`, `abilitiesHeader`, `petAbilitiesHeader`|`headings`|
|`secondaryStatsHeader`|`statsHeader`|
|`recordLabel`, `recordPrefix`, `recordOld`, `recordNew`|`time`|
|`petAbilityCosts`|`abilityCosts`|
|`timelineLevel`, `timelineUnlock`|`timeline`|
|`title`, `weaponSkills`, `noAbilities`, `closeButton`, `pinGlyph`|`body`|

`level`, `time`, `abilityCosts`, `stats`, `headings`, `timeline` and `body` remain available as general roles. `level` controls the portrait's Level X text. Controller atlas artwork is unaffected by text sizes; `pinGlyph` and `closeButton` size their text fallbacks.

```lua
fontSizes = {
    statsHeader = 20, secondaryStatsHeader = 19,
    statLabel = 22, statOld = 20, statArrow = 18, statNew = 22, statDelta = 20,
    abilitiesHeader = 19, petAbilitiesHeader = 18, abilityCosts = 13, petAbilityCosts = 12,
    time = 16, recordLabel = 20, recordPrefix = 16, recordOld = 15, recordNew = 18,
    timelineLevel = 16, timelineUnlock = 13,
},
```

