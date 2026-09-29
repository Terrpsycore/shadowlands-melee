local A = require("data.abilityPresets")

return {
    -- Main
    necropoliManaShield = A.seaWitchManaShield({
        name = "Anima Barrier",
    }),
    -- Transport Conductor
    conductorManaRegenAura = A.brillianceAura({ -- mb use triggered mana regen instead of native ability
        name = "Necropoli Mana Regeneration",
        levels = 2,
        -- apply target player/allied mechanical ancient
    }),
    conductorManaRegenAuraAmplify = A.immolationToggle({
        name = "Regeneration Amplify",
    }),
    -- Body Banks
    bodyBanksInventory = A.inventory({
        name = "Inventory (Body Banks)",
    }),
    scavengerHire = A.sacrificePit({
        name = "Hire Scavenger",
    }),
    -- Maldracite Battery
    chargeTower = A.channelTarget({ -- freeze mana
        name = "Charge Tower",
    }),
    -- Tower
    chargedBash = A.bash({
        name = "Charged Missiles",
        -- apply 100% chance ?50
    }),
    -- == Dummy
    chargeTowerUI = A.innerFire({
        name = "Charge Tower",
        buffs = { "chargeTower" },
    }),
}
