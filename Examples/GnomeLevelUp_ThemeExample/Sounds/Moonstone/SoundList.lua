local _, pack = ...

-- Keep the theme ID in sync with the matching file in Textures.
-- Remove a row for a silent cue. Set volume = 0 to mute any row.
-- Files use their exported loudness. For an in-game sound kit,
-- replace name and file with soundKit = 12345, volume = 0.5.
pack.soundSets = pack.soundSets or {}
pack.soundSets.moonstone = {
    folder = "Moonstone",
    cues = {
        levelUp = { name = "Moonstone - Level Up", file = "LevelUp.ogg" },
        portraitImpact = { name = "Moonstone - Portrait Impact", file = "PortraitImpact.ogg" },
        starburst = { name = "Moonstone - Starburst", file = "Starburst.ogg" },
        statGlint = { name = "Moonstone - Stat Glint", file = "StatGlint.ogg" },
        idleMotes = { name = "Moonstone - Idle Motes", file = "IdleMotes.ogg", loopSeconds = 2 },
        fireworks = { name = "Moonstone - Firework", file = "Firework.ogg" },
        fadeIn = { name = "Moonstone - Fade In", file = "FadeIn.ogg" },
        fadeOut = { name = "Moonstone - Fade Out", file = "FadeOut.ogg" },
    },
}
