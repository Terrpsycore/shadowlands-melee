local Ids = require("data.ids")

local A = require("data.ability")

return {
    combatExpertise = A.passiveGeneric({
        name = "Combat Expertise",
    }),
    combatExpertiseDamage = A.itemDamageBonus({
        levels = 5,
        apply = A.itemDamageBonus.apply(function(a)
            for level = 1, 5 do
                a:setAttackBonus(level, 1 * level)
            end
        end),
    }),
    animateDead = A.raiseDead({
        name = "Animate Dead",
    }),
    animateDeadResurrection = A.resurrection({
        apply = A.resurrection.apply(function(a)
            a:setNumberofCorpsesRaised(1, 1)
        end),
    }),
}
