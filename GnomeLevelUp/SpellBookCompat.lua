local ADDON_NAME, ns = ...

-- Keep spellbook differences in one place so the rest of the addon can use names and IDs.
function ns.IsSpellKnownAcrossClients(spellID)
    if not spellID then return false end
    if C_SpellBook and C_SpellBook.IsSpellKnown and Enum and Enum.SpellBookSpellBank then
        local ok, known = pcall(C_SpellBook.IsSpellKnown, spellID, Enum.SpellBookSpellBank.Player)
        if ok and not (type(issecretvalue) == "function" and issecretvalue(known)) and known == true then
            return true
        end
    end
    if type(IsPlayerSpell) == "function" then
        local ok, known = pcall(IsPlayerSpell, spellID)
        if ok and not (type(issecretvalue) == "function" and issecretvalue(known)) and known == true then
            return true
        end
    end
    return false
end

function ns.SnapshotSpellBook()
    local known = {}
    if not C_SpellBook or not C_SpellBook.GetNumSpellBookSkillLines then
        return known
    end

    for i = 1, C_SpellBook.GetNumSpellBookSkillLines() do
        local skillLineInfo = C_SpellBook.GetSpellBookSkillLineInfo(i)
        if skillLineInfo and not skillLineInfo.isGuild then
            local offset = skillLineInfo.itemIndexOffset or 0
            local count = skillLineInfo.numSpellBookItems or 0
            for j = offset + 1, offset + count do
                local itemInfo = C_SpellBook.GetSpellBookItemInfo(j, Enum.SpellBookSpellBank.Player)
                local isSpell = itemInfo and itemInfo.spellID
                if isSpell and Enum.SpellBookItemType then
                    isSpell = itemInfo.itemType == Enum.SpellBookItemType.Spell
                end
                if isSpell then
                    local name = itemInfo.name
                    if not name and C_Spell and C_Spell.GetSpellInfo then
                        local spellInfo = C_Spell.GetSpellInfo(itemInfo.spellID)
                        name = type(spellInfo) == "table" and spellInfo.name or spellInfo
                    end
                    if not name and GetSpellInfo then
                        name = GetSpellInfo(itemInfo.spellID)
                    end
                    known[itemInfo.spellID] = name
                end
            end
        end
    end
    return known
end
