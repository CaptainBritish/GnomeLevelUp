# GnomeLevelUp example themes

This pack includes **FFIV Blue Atlas** and **FE Path of Radiance**.
Install `GnomeLevelUp_ThemeExample` beside `GnomeLevelUp` in `Interface/AddOns`,
enable both addons, then choose a theme under **Appearance → Theme**.
Requires GnomeLevelUp 2.0 or later.

## Make your own theme

1. **Copy the pack.** Rename its folder and `.toc` file to the same name,
   such as `MyThemePack` and `MyThemePack.toc`.
2. **Pick an example.** Keep the example you want to build on. Remove the
   other example's `Theme.lua` and `SoundList.lua` entries from the `.toc`.
   Keep `Register.lua` last and keep `## Dependencies: GnomeLevelUp`.
3. **Name your theme.** Open the remaining `Theme.lua` and change `id` and
   `label`. Use a simple ID such as `my_theme` and a readable label such as
   `My Theme`. Update the title in the `.toc` too.
4. **Replace the artwork.** Use the existing files as size and layout
   templates: four corners, four edges, a background, portrait ring and divider.
   Save textures as `.tga` or `.blp`. Keep their filenames, or update the paths
   in `Theme.lua`. For a tiled background, keep `style = "tile"` and set its
   `width` and `height` to the image's actual dimensions.
5. **Choose fonts and sound.** Replace the font in `Fonts/` and update `font`
   and `fontName`, or remove those lines to use GLU's default. For custom sound,
   replace the audio and edit `SoundList.lua`; its theme ID must match your new
   `id`. Without custom sound, set `soundsEnabled = false` and remove the
   `SoundList.lua` entry from the `.toc`.
6. **Try it.** Install your pack beside GLU, restart WoW and select your theme.
   Run `/glu test` and `/glu test count 30`. Check both layouts, the portrait,
   timeline, font and sound.

Leave `Register.lua` as it is. Once you share the pack, keep its folder name
and theme ID unchanged so updates preserve players' selections.

To share it, ZIP your addon folder and list **GnomeLevelUp** as a required
dependency on CurseForge. Only include assets you have permission to distribute.

## Need more control?

See the [reference](REFERENCE.md) for individual text sizes, frame settings,
sound cues and the optional asset checker.
