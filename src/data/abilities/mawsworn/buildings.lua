local A = require("data.abilityPresets")
local Ids = require("data.ids")

return {
    -- Main
    suppressingAura = A.slowAura({
        name = "Suppressing Aura",
        levels = 3,
        buffs = { "suppressingAura" },
    }),
    -- Soulforge
    soulforgeInventory = A.inventory({
        name = "Inventory (Mawsworn Cage)",
        apply = A.inventory.apply(function(a, level)
            a:setItemCapacity(level, 6)
        end),
    }),
    soulforgeCraft = A.spellBook({
        name = "Inventory (Mawsworn Cage)",
        apply = A.spellBook.apply(function(a, level)
            a:setSpellList(
                level,
                table.concat({
                    Ids.abilities.soulforgeForgeCloak,
                    Ids.abilities.soulforgeForgeGauntlets,
                    Ids.abilities.soulforgeForgeSpikedArmor,
                }, ",")
            )
        end),
        hotkey = "C",
    }),
    soulforgeForgeCloak = A.channelNoTarget({
        name = "Forge Cloak",
        button = { 0, 0 },
        hotkey = "Q",
        apply = A.spellBook.apply(function(a, level)
            a:setBaseOrderID(level, "shadowstrike")
            a:setOrderStringUseTurnOn("shadowstrike")
            a:setOrderStringActivate("shadowstrike")
        end),
    }),
    soulforgeForgeGauntlets = A.channelNoTarget({
        name = "Forge Gauntlets",
        button = { 1, 0 },
        hotkey = "W",
        apply = A.spellBook.apply(function(a, level)
            a:setBaseOrderID(level, "innerfire")
            a:setOrderStringUseTurnOn("innerfire")
            a:setOrderStringActivate("innerfire")
        end),
    }),
    soulforgeForgeSpikedArmor = A.channelNoTarget({
        name = "Forge Spiked Armor",
        button = { 2, 0 },
        hotkey = "E",
        apply = A.spellBook.apply(function(a, level)
            a:setBaseOrderID(level, "thunderclap")
            a:setOrderStringUseTurnOn("thunderclap")
            a:setOrderStringActivate("thunderclap")
        end),
    }),
    -- Cage
    mawswornCageInventory = A.inventory({
        name = "Inventory (Mawsworn Cage)",
        apply = A.inventory.apply(function(a, level)
            a:setItemCapacity(level, 1)
        end),
    }),
    -- Maw Chain
    relink = A.channelTarget({
        name = "Re-link",
    }),
    -- == Dummy
    mawswornCageTransmute = A.transmute({
        name = "Transmute",
        apply = A.transmute.apply(function(a, level)
            --
        end),
    }),
}
