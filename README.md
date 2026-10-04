# AI Usage Disclaimer 
I am still new to LUA and used AI as a training tool and to help me debug and to suggest 
ways to build certain functions, AI was used to help me write and understand the functions 
that allow for spell book caching. A lot of Claude's suggestions were outright thrown out (
e.g.: Originally, it wanted me to scan for a lot of things by name rather than using documented API functions.)
I intentionally stuck to the free version of Claude to discourage myself from relying on it too much.

As it stands the addon is about 70/30 my code/AI code. My goal isn't to just throw out vibe coded slop,
just to get a cool addon out that was above my level of understanding at the start while learning along the way.

# GnomeLevelUp

A fancy level-up screen for World of Warcraft that shows the stats you
gained and the trainer skills you have not learned yet inspired by CRPGs.

Credit where it's due, This addon is inspired by the *idea* behind the old addon 
"CoolLevelUp" by Forge_User_42492943. None of CLU's code ort other assets have been used.

Shoutouts: Shadowhand for helping test and fixing my broken-ass code for hiding the default level-up toast

## Supported clients

- **Retail**  Currently untested but should work okay.
- **WoW: Forever** — the active target.


## Installation

1. Copy the `GnomeLevelUp` folder into your `Interface\AddOns` folder
   for the relevant client (e.g. `_retail_\Interface\AddOns\` or the
   Forever client's AddOns folder once it exists).
2. Restart or reload the client (`/reload`).
3. Make sure it's checked in the AddOns list at the character-select
   screen.
4. If you are updating from an earlier version, GnomeLevelUp will detect an
   older trainer-cache format and clear it for a fresh scan. Visit your class
   trainer once after the update. You can also reset it manually from the
   options menu or with `/glu cleartraining`.


## Usage

GLU will automatically display upon level-up, in order to display available skills
you must first visit the trainer for your class at least once to allow GLU to cache
the trainer data. Weapon proficiencies are loaded from the built-in Forever list,
so they do not require a weapon-trainer scan.


Slash commands (`/glu`):
- `/glu test` — preview the screen without leveling up.
- `/glu sound` — toggle the level-up sound on/off.
- `/glu duration <seconds>` — how long the screen stays up (default 7).
- `/glu mode <retail|forever|auto>` — select the client data path. Auto
  detection selects Forever or Retail from the project API.
- `/glu scan` — toggle auto-saving trainer data when you visit a trainer
  (on by default).
- `/glu scanprof` — also include profession trainers in that scan (off
  by default, this feature is currently in an early pass).
- `/glu cleartraining` — wipes all scanned trainer data (also a button in
  the settings page's "Trainer Data" section). 
- `/glu debug [on|off]` — enable or disable the debug commands. They are off
  by default.
- `/glu dumptraining` — print cached trainer skills and learned status while
  debug is enabled.
- `/glu testtrainer` — print the current unlearned skill list while debug is
  enabled.
- `/glu combat` — toggle waiting for combat to end before showing the
  screen (on by default). This is needed to prevent secret values from breaking 
  the level up screen, but this option is left in for prosperity.
- `/glu options` (or `/glu config`) — jumps to the settings page, which
  also lives under **Options > AddOns > GnomeLevelUp**. 

  Press the white **X** in the top-right corner to close the level-up screen.
  Reduced motion skips the entrance, icon, and fade animations.

Trainer options include displaying each skill's training cost and limiting the
list to skills that unlock at the current level. Both options are disabled by
default. Costs are read from the trainer scan and stored separately from the
profession-service check.

The settings also include an optional level-time line. When enabled, it uses
the client's played-time data to show how long the player spent on the level
that just ended.
The addon requests this silently at login or when the option is enabled, then
tracks elapsed time locally. It does not repeatedly print played time to chat.

On first boot, GnomeLevelUp prints a short setup reminder in chat. The
**Print instructions to chat** option controls that message and is enabled by
default; it is only shown once per character profile.


## Customizing the sound

By default it plays Blizzard's built-in level-up sound effect. To use
your own instead, drop an `.ogg` file in the addon folder (e.g. under a
`Sounds\` subfolder) and set it in-game:
```
/run GnomeLevelUpDB.customSoundFile = "Interface\\AddOns\\GnomeLevelUp\\Sounds\\yourfile.ogg"
```

## Known limitations

- Retail support is included but has not been tested as extensively as WoW: Forever.
- Trainer abilities are only known after visiting the relevant class trainer once.
- Forever weapon skills use a built-in list because they are not read from the trainer window; that list may need updates if Forever changes its class or weapon rules.
- Blizzard's popup layout and protected-value rules can change with client updates and may require compatibility fixes.
- English labels and spell names are currently the most reliable for matching cached trainer data.

## File overview

| File                        | Purpose                                     |
|-----------------------------|----------------------------------------------|
| `GnomeLevelUp.toc`          | Addon manifest / load order                  |
| `Core.lua`                  | Saved variables, event registration, slash commands |
| `SpellBookCompat.lua`       | Reads known spells from the modern spellbook API |
| `Stats.lua`                 | Stat snapshot/diff helpers                   |
| `Data/ClassTraining.lua`    | Trainer data (auto-scanned, or hand-filled)  |
| `Data/WeaponSkills.lua`     | Hardcoded Forever weapon proficiency list   |
| `CHANGELOG.md`              | Release history                              |
| `TrainerScan.lua`           | Scans the trainer window and saves new data  |
| `HideBlizzardLevelUp.lua`   | Suppresses Blizzard's own level-up toast while the panel is visible |
| `UI.lua`                    | The on-screen cinematic frame                |
| `Options.lua`               | The settings page                            |
| `LevelUp.lua`                | Wires it all together on `PLAYER_LEVEL_UP`   |
