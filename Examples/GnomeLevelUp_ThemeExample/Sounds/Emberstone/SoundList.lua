local _, pack = ...

-- Keep the theme ID in sync with the matching file in Textures.
-- Remove a row for a silent cue. Set volume = 0 to mute any row.
-- Files use their exported loudness. For an in-game sound kit,
-- replace name and file with soundKit = 12345, volume = 0.5.
pack.soundSets = pack.soundSets or {}
pack.soundSets.emberstone = {
    folder = "Emberstone",
    cues = {
        levelUp = { name = "Emberstone - Level Up", file = "LevelUp.ogg" },
        portraitImpact = { name = "Emberstone - Portrait Impact", file = "PortraitImpact.ogg" },
        starburst = { name = "Emberstone - Starburst", file = "Starburst.ogg" },
        statGlint = { name = "Emberstone - Stat Glint", file = "StatGlint.ogg" },
        idleMotes = { name = "Emberstone - Idle Motes", file = "IdleMotes.ogg", loopSeconds = 2 },
        fireworks = { name = "Emberstone - Firework", file = "Firework.ogg" },
        fadeIn = { name = "Emberstone - Fade In", file = "FadeIn.ogg" },
        fadeOut = { name = "Emberstone - Fade Out", file = "FadeOut.ogg" },
    },
}
