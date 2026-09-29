local A = require("data.abilityPresets")

return {
    -- Main
    castleReserves = A.channelNoTarget({ -- triggered summon unit
        name = "Castle Reserves",
        levels = 3,
    }),
    -- Muckpool
    muckpoolCargo = A.inventory({
        name = "Inventory (Muckpool)",
    }),
    muckpoolDissolve = A.sacrificePit({ -- UI effect when pool ready to full-heal any dredger
        -- make instant with trigger
        -- spend mana up to full HP (if mana sufficient) & add item
        -- or add mana basing on current HP (mana least < injured health)
        name = "Dissolve",
    }),
    muckpoolDredge = A.channelNoTarget({ -- item ability - spawn dredger
        name = "Dredge",
    }),
    -- Coffin
    peacefulRestCargo = A.cargoHold({
        name = "Peaceful Rest",
    }),
    peacefulRest = A.battlestationsChaos({ -- somehow add different unit types (use levels gdoc says)
        name = "Peaceful Rest",
    }),
    peacefulRestEnd = A.standDown({
        name = "Peaceful Rest",
    }),
    -- Focusing Mirror
    focusedLight = A.channelTarget({
        name = "Focus Light",
    }),
    -- == Dummy
    peacefulRestHeal = A.rejuvenation({
        name = "Peaceful Rest",
        buffs = { "peacefulRest" },
    }),
    focusedLightUI = A.innerFire({
        name = "Focused Light (UI)",
        buffs = { "focusedLight" },
    }),
    focusedLightBash = A.bash({
        name = "Blinding Light",
        -- apply ?100% chance
    }),
}
