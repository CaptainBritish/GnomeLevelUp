local addonName, pack = ...
local api = GnomeLevelUpThemeAPI
if not api or api.version ~= 1 then return end

local media = LibStub and LibStub("LibSharedMedia-3.0", true)
local soundRoot = "Interface\\AddOns\\" .. addonName .. "\\Sounds\\"
for _, theme in ipairs(pack.themes or {}) do
    local soundSet = pack.soundSets and pack.soundSets[theme.id]
    if soundSet then
        local folder = soundRoot .. soundSet.folder .. "\\"
        theme.sounds = {}
        for cue, sound in pairs(soundSet.cues) do
            if media and sound.name and sound.file then
                media:Register("sound", sound.name, folder .. sound.file)
            end
            theme.sounds[cue] = {
                media = sound.name,
                soundKit = sound.soundKit,
                volume = sound.volume,
                loopSeconds = sound.loopSeconds,
            }
        end
    end
    local key, reason = api.RegisterTheme(addonName, theme.id, theme)
    if not key then print(addonName .. " - " .. theme.id .. " - " .. reason) end
end
