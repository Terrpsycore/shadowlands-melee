local A = require("data.abilityPresets")

return {
    inventory = A.inventory({}),
    phase = A.windWalk({
        apply = A.windWalk.apply(function(a)
            a:setManaCost(1, 0)
            a:setTransitionTime(1, -1)
            a:setBackstabDamage(1, 0)
        end),
    }),
    dummyEnsnare = A.ensnare({}),
    reincarnationCheck = A.defend({}),
    trueSight = A.trueSight1({
        name = "",
    }),
}
