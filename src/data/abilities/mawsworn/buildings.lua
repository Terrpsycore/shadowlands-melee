local A = require("data.abilityPresets")

return {
    -- Main
    suppressingAura = A.slowAura({
        name = "Suppressing Aura",
        levels = 3,
        buffs = { "suppressingAura" },
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
