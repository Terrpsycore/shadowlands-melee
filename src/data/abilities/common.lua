local A = require("data.ability")

return {
    inventory = A.inventory({}),
    phase = A.windWalk({
        apply = A.windWalk.apply(function(a)
            a:setRequirements("")
            a:setManaCost(1, 0)
            a:setTransitionTime(1, -1)
            a:setBackstabDamage(1, 0)
        end),
    }),
    dummyEnsnare = A.ensnare({
        apply = A.ensnare.apply(function(a)
            a:setRequirements("")
        end),
    }),
    reincarnationCheck = A.defend({
        apply = A.defend.apply(function(a)
            a:setRequirements("")
        end),
    }),
}
