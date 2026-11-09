# GnomeLevelUp example theme pack

Install `GnomeLevelUp_ThemeExample` next to `GnomeLevelUp` in `Interface/AddOns`.
Enable both addons with GnomeLevelUp 1.6 or later and restart WoW. Select
**Moonstone (Example)** or **Emberstone (Example)** under **Appearance → Theme**.
The controller menu and first-time setup use the same theme list.
GLU automatically uses the selected theme’s level-up cue if you’ve kept the
default sound. If you’ve picked another sound, you can keep it or choose
**Theme sound** in the **Sound** menu. **Use Theme Sounds** controls the theme’s
other cues separately and is on by default. You can also select any registered
sound individually as your level-up sound.

## Make your own pack

1. Copy this example and give its folder and `.toc` file the same unique name.
2. Keep `## Dependencies: GnomeLevelUp` in the `.toc` so WoW loads GLU first. Set your own title, version and supported interface numbers.
3. Copy a matching pair of subfolders from `Textures/` and `Sounds/`. Edit `Textures/<theme>/Theme.lua` for the theme ID, display name, artwork, and layout. Edit `Sounds/<theme>/SoundList.lua` for that theme’s audio. Use the same theme ID in both config files.
4. List both config files in the `.toc` before `Register.lua`. Repeat for as many themes as you want in the same addon. Keep the addon folder name and each theme ID stable after publishing so updates keep players’ selections.
5. Test both layouts with `/glu test`. Use `/glu maxlevel` with debug enabled to test the fireworks. ZIP the whole addon folder and upload it as its own CurseForge project. List GnomeLevelUp as a required dependency there as well.

You may reuse, modify and redistribute the example code and textures.

## Theme API v1

`GnomeLevelUpThemeAPI.RegisterTheme(addonName, id, definition)` returns the
registered key on success or `nil, reason` on failure. Call it once per theme.
The addon name comes from `...` at the top of your Lua file. The name and ID use
letters, digits, underscores or hyphens. IDs are case-insensitive within each addon.
The combined saved key may be up to 80 bytes including the `GLUTheme:` prefix and separator.

| Field | Value |
| --- | --- |
| `label` | The visible name, up to 80 bytes. Your addon can supply a localized label. |
| `opacity` | Overall opacity from 0 to 1. Defaults to 0.95. |
| `sounds` | Optional table of sound cues. Each cue accepts a LibSharedMedia `media` name or a WoW `soundKit` ID. The example’s `Register.lua` builds this table from each `SoundList.lua`. |
| `frame` | An existing frame key such as `"WOOD_PANEL"`, or a table with `topLeft`, `top`, and `left` texture paths. `cornerSize`, `edgeSize`, and `edgeMaskInset` default to 48, 16, and 5. GLU reuses the supplied textures for the other pieces unless you supply their paths. Optional `cornerSizes`, `transforms`, and `hue` are shown in `Theme.lua`. |
| `background` | An existing background key such as `"SCRATCHED_STONE"`, or a table with `texture` and `style` (`"tile"`, `"fill"`, or `"stretch"`). Tile is the default. Fill requires the source `width` and `height` to preserve the image proportions. The optional `hue` and `opacity` apply to the background alone. |
| `portraitRing` | Optional. An existing ring key such as `"STEEL"`, or a table with a `texture` and optional `scale`, `offsetX`, `offsetY`, `hue`, and `glintRadius`. Omit it for the standard solid ring. |

Paths are relative to the companion addon folder and use `.tga` or `.blp` files.
Custom assets also appear in GLU’s individual Frame, Background and Portrait ring
lists. If a selected pack is unavailable, GLU falls back to Modern for the frame
and background and to the solid ring for any missing ring artwork. It retains
the saved selection, so the pack can resume when enabled again.

## Sound cues

| Key | When it plays |
| --- | --- |
| `levelUp` | As the level-up popup opens. GLU uses Blizzard’s default when the theme leaves this slot empty. |
| `portraitImpact` | When the portrait impact ring fires. |
| `starburst` | When the portrait starburst fires. |
| `statGlint` | When sparks appear at the end of a stat counter during a milestone or max-level celebration. |
| `idleMotes` | Repeats while portrait or background motes are visible. Set `loopSeconds` to the length of the clip. |
| `fireworks` | Once per background burst and once when the max-level edge fireworks begin. |
| `fadeIn` | At the start of the opening transition. |
| `fadeOut` | At the start of the closing transition. |

Omit a cue to leave it unset. `volume = 0` mutes a cue. WoW sound kits support a
per-cue `volume` from 0 to 1 on clients that expose the override. For `.ogg` or
`.mp3` assets, set the desired loudness when exporting the audio file. Classic
Mode keeps the level-up and fade cues and skips decorative animation cues.
