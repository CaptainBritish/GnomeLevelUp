# Localization and native-speaker review

Language changes take effect after **Reload UI**. The saved selection is applied
at `ADDON_LOADED`, before the options controls are constructed on first opening; popup headings
created during file loading are refreshed at the same point. This supports
clients that load SavedVariables after executing addon files.

## Language availability

All language options are enabled. To hide a language in a custom build, edit
`ENABLED_LOCALES` near the top of `Locals.lua`, then reload the UI:

```lua
    deDE = true,  -- Deutsch
    itIT = false, -- Italiano
```

Set a flag to `true` to make that locale available to auto-detection and the language dropdown. Set it to `false` to hide it and use English instead. A saved manual selection of a disabled language falls back to English; its saved code is retained so enabling that language again restores the selection after reload. English is always available as the fallback. English (UK) uses the English (US) catalogue.

| Locale | Language | Default |
| --- | --- | --- |
| enUS / enGB | English | Enabled; fallback |
| frFR | French | Enabled |
| esES | Spanish (Spain) | Enabled |
| esMX | Spanish (Latin America) | Enabled |
| deDE | German | Enabled |
| itIT | Italian | Enabled |
| ptBR | Portuguese (Brazil) | Enabled |
| ruRU | Russian | Enabled |
| koKR | Korean | Enabled |
| zhCN | Chinese (Simplified) | Enabled |
| zhTW | Chinese (Traditional) | Enabled |

All ten non-English locale dictionaries contain all 270 canonical source keys. Spanish shares one vocabulary table with regional overrides, while the esES/esMX switches remain independent. All languages are available regardless of review status. The translation tables received contextual and glossary review; machine-translated wording still benefits from native-speaker feedback.

## English key cleanup

- One `On` and one `Off` key serve menus, minimap status and slash-command setting status.
- `Compact Layout`, `Lock Location`, `Preview Level-Up`, `Reset Appearance` and other equivalent settings use the same English source in both menus.
- Trainer-cost, new-skill, pet, profession, sound, text-shadow and debug labels no longer have separate short and long synonyms for the same setting.
- One `%s (recommended for gamepad)` format replaces duplicated gamepad variants.
- Hue and rotation controls share nine position labels and two format strings.
- The trainer-save notification is one complete format string; it no longer joins translated singular/plural sentence fragments.
- Proper font names, media titles, internal setting keys, slash commands, spell IDs and asset paths are not translated. Native language names in the dropdown are deliberately stable.

The original cleanup reduced 228 keys to 194; the startup announcement and trainer-report messages brought the catalogue to 203; retiring six Classic chat keys leaves 197; the highlighted report-option hint adds one, followed by seven visual-effect/control labels; removing the level-number control left 204; combining the two portrait effect labels left 203; the four extra effects bring the count to 207; twelve debug particle fields brought it to 219; portrait/ring settle, stat gain counting and divider reveal brought it to 222; merging counting into emphasis removes one unused label, leaving 221; the Animated Elements colour label brings it to 222; the three effect opacity labels bring it to 225; Copy and its shortcut hint bring it to 227, including newly covered faction/NPC/theme names and the default-font label. Different concepts that happen to have the same translated value keep separate keys.

## Terminology review

Reviewed 15 October 2026. Core WoW terms were compared with localized Blizzard guides/class descriptions and localized Wowhead database entries. Addon-specific settings are contextual wording, not official Blizzard interface labels.

| Locale | Abilities | Weapon skills | Hunter pet / warlock pet |
| --- | --- | --- | --- |
| frFR | techniques | compétences d’armes | familier / familier |
| esES / esMX | facultades | habilidades con armas | mascota / mascota |
| deDE | Fähigkeiten | Waffenfertigkeiten | Begleiter / Begleiter |
| itIT | abilità | competenze nelle armi | famiglio / famiglio |
| ptBR | habilidades | perícias com armas | ajudante / ajudante |
| ruRU | способности | навыки владения оружием | питомец / питомец |
| koKR | 기술 | 무기 숙련 | 야수 / 소환수 |
| zhCN | 技能 | 武器技能 | 宠物 / 恶魔 |
| zhTW | 技能 | 武器技能 | 寵物 / 惡魔 |

Examples of second-pass corrections include the official NPC names **Sangrelorde Mandokir** (Portuguese) and **Signore del Sangue Mandokir** (Italian), Korean on/off state labels, avoiding a gender-dependent Italian stat-gain sentence, explicit new-skill versus higher-rank wording, and retaining the distinction between pet abilities and weapon proficiencies. Regional Spanish substitutions apply to whole words so `comandos` is not corrupted when changing `mando` to `control`.

Reference material:

- [Blizzard Classic guide: French](https://worldofwarcraft.blizzard.com/fr-fr/news/23090134/), [Spanish](https://worldofwarcraft.blizzard.com/es-es/news/23090134/), [German](https://worldofwarcraft.blizzard.com/de-de/news/23090134/), [Italian](https://news.blizzard.com/it-it/article/23090134/manuale-base-di-wow-classic-per-nuovi-giocatori), [Portuguese](https://worldofwarcraft.blizzard.com/pt-br/news/23090134/), [Russian](https://news.blizzard.com/ru-ru/article/23090134/putevoditel-po-wow-classic-dlya-novyh-igrokov).
- [Blizzard Korean Classic trainer guide](https://worldofwarcraft.blizzard.com/ko-kr/news/23149291/wow-classic-city-tour-stormwind), [Korean warlock class](https://worldofwarcraft.blizzard.com/ko-kr/game/classes/warlock).
- [Blizzard Simplified Chinese hunter class](https://worldofwarcraft.blizzard.com/zh-cn/game/classes/hunter), [Simplified Chinese patch notes: grimoires](https://wow.blizzard.cn/news/24271855/).
- [Blizzard Traditional Chinese hunter class](https://worldofwarcraft.blizzard.com/zh-tw/game/classes/hunter), [warlock class](https://worldofwarcraft.blizzard.com/zh-tw/game/classes/warlock), [profession trainers](https://worldofwarcraft.blizzard.com/zh-tw/news/23572862/).
- [Blizzard Portuguese Mandokir name](https://worldofwarcraft.blizzard.com/pt-br/news/24194658/), [Italian Mandokir name](https://worldofwarcraft.blizzard.com/it-it/news/10021220/), [German](https://worldofwarcraft.blizzard.com/de-de/news/23780549/), [Russian](https://worldofwarcraft.blizzard.com/ru-ru/news/23780549/), [Korean](https://worldofwarcraft.blizzard.com/ko-kr/news/23391283/), [Traditional Chinese](https://worldofwarcraft.blizzard.com/zh-tw/news/24115316/).
- [Wowhead Portuguese weapon skills](https://www.wowhead.com/pt/spell=76301/pericias-com-armas), [Russian weapon skills](https://www.wowhead.com/ru/spell=76290/), [German weapon skills](https://www.wowhead.com/de/skills/weapon-skills).

## Context to preserve when reviewing

- New-skills mode excludes higher ranks of abilities the character already knows.
- Mouseover-delay mode prevents hovering from extending the popup's display time.
- Click-through passes mouse input through the popup.
- Suspend Preview keeps the manual preview visible while options are open; it does not suspend real level-up notifications.
- Trainer scanning records offered abilities and learning costs, not the NPC itself.
- Master refers to the overall sound channel, not a trainer.
- Portrait ring and portrait border refer to different visual elements.

Keep `%s`, `%d`, `%02d` and other format arguments in their original order. Preserve `\n` between the two missing-trainer-data sentences. Test long labels in normal, compact and controller layouts.

The default popup font now follows the client's `STANDARD_TEXT_FONT` when available, preserving explicit custom-font choices. Use a font/client that supports the chosen script when reviewing Korean, Chinese or Cyrillic. Language selection changes addon labels only; game-provided spell/stat names and tooltips follow the game client. Existing technical debug output may still use English. Automated checks cannot establish font coverage, native fluency or in-game layout correctness.

## Standing project instruction: future strings

Every future new user-facing string must use the shared translation catalogue
and be added to **all ten non-English dictionaries**, including disabled locales.
Preserve the exact English source supplied by the user, command names and format
arguments. Do not rely on English fallback as completion of a new string.

Profile controls and sharing messages add 14 source keys. Language selection now
lives in Profile in both menus and is saved with the selected profile. Profile
names are user text and are not translated.

The separate profile-sharing window adds an optional-name label and distinct
invalid-string/settings messages (three more keys, 244 total).

Profile rename/delete controls add ten keys; first-run setup adds three (257
canonical keys). Every non-English dictionary includes them. Existing option
labels are reused in setup, including Language and class-specific pet skills.

Setup-only Show pet skills and Enable animations add two keys (259 total),
translated in all ten non-English dictionaries.

The centered setup welcome heading adds one translated key (260 total).

Background animations adds one setup key, translated in all ten dictionaries
(261 canonical keys).

Horizontal layout adds one label in every non-English dictionary (262 canonical keys).

Player 3D portrait is translated in all ten dictionaries (263 canonical keys).

Seven debug model/mask/viewport controls bring coverage to 270 canonical keys.
