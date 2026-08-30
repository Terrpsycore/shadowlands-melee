-- TODO: dispell test
local Ids = require("data.ids")
local Items = require("lib.items")
local T = require("tests.support.runner")

local defenceProtocol = require("scenario.factions.kyrian.abilities.defenceProtocol")

local config = defenceProtocol.config

T:test("Buff is applied, cooldown starts", function(case)
    local praetor = case:createUnit(Ids.units.praetor)
    local target = case:createUnit(Ids.units.aspirant)
    local attacker = case:createUnit(Ids.units.aspirant, Player(PLAYER_NEUTRAL_AGGRESSIVE))

    IssueTargetOrder(attacker, "attack", target)

    return case:delay(2, function()
        assert(UnitHasBuffBJ(praetor, config.buffId), "praetor doesn't receive buff")
        assert(BlzGetUnitAbilityCooldown(praetor, config.abilityId, 1) <= 0, "cooldown didn't start")
    end)
end)

T:test("Buff is applied", function(case)
    local praetor = case:createUnit(Ids.units.praetor)
    local target = case:createUnit(Ids.units.aspirant)
    local attacker = case:createUnit(Ids.units.aspirant, Player(PLAYER_NEUTRAL_AGGRESSIVE))

    IssueTargetOrder(attacker, "attack", target)

    return case:delay(2, function()
        assert(UnitHasBuffBJ(praetor, config.buffId), "praetor doesn't receive buff")
    end)
end)

T:test("Buff not applied", function(case)
    local unit = case:createUnit(Ids.units.praetor)
    local target = case:createUnit(Ids.units.praetor)
    local attacker = case:createUnit(Ids.units.aspirant, Player(PLAYER_NEUTRAL_AGGRESSIVE))

    IssueTargetOrder(attacker, "attack", target)

    return case:delay(2, function()
        assert(not UnitHasBuffBJ(unit, config.buffId), "wrong triggering unit")
    end)
end)

T:test("Cooldown affects", function(case)
    local unit = case:createUnit(Ids.units.aspirant)

    BlzStartUnitAbilityCooldown(unit, config.abilityId, config.cooldown)

    local target = case:createUnit(Ids.units.praetor)
    local attacker = case:createUnit(Ids.units.aspirant, Player(PLAYER_NEUTRAL_AGGRESSIVE))

    IssueTargetOrder(attacker, "attack", target)

    return case:delay(2, function()
        assert(not UnitHasBuffBJ(unit, config.buffId), "ability works when on cooldown")
    end)
end)
