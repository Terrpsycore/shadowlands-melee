local A = require("data.abilityPresets")
local Ids = require("data.ids")
local Icons = require("vendor.assets.generated.Icons")
local Orders = require("data.generated.Orders")

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
        order = Orders.shadowstrike,
    }),
    soulforgeForgeGauntlets = A.channelNoTarget({
        name = "Forge Gauntlets",
        button = { 1, 0 },
        hotkey = "W",
        order = Orders.innerfire,
    }),
    soulforgeForgeSpikedArmor = A.channelNoTarget({
        name = "Forge Spiked Armor",
        button = { 2, 0 },
        hotkey = "E",
        order = Orders.thunderclap,
    }),
    -- Cage
    mawswornCageInventory = A.inventory({
        name = "Inventory (Mawsworn Cage)",
        apply = A.inventory.apply(function(a, level)
            a:setItemCapacity(level, 1)
        end),
    }),
    -- == Dummy
    mawswornCageTransmute = A.transmute({
        name = "Transmute",
        apply = A.transmute.apply(function(a, level)
            --
        end),
    }),
}
