-- TODO: dispell test
local Ids = require("data.ids")
local T = require("tests.support.runner")

local defenceProtocol = require("scenario.factions.kyrian.abilities.defenceProtocol")
local MechStorage = require("scenario.storage.mech")

local config = defenceProtocol.config

local function enableToggle(praetor)
    IssueImmediateOrder(praetor, "immolation")
end

T:test("Buff is applied, cooldown starts", function(case)
    local praetor = case:createUnit(Ids.units.praetor)
    local target = case:createUnit(Ids.units.aspirant)
    local attacker = case:createUnit(Ids.units.aspirant, Player(PLAYER_NEUTRAL_AGGRESSIVE))

    enableToggle(praetor)
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

    enableToggle(praetor)
    IssueTargetOrder(attacker, "attack", target)

    return case:delay(2, function()
        assert(UnitHasBuffBJ(praetor, config.buffId), "praetor doesn't receive buff")
    end)
end)

T:test("Buff not applied when toggle off", function(case)
    local praetor = case:createUnit(Ids.units.praetor)
    local target = case:createUnit(Ids.units.aspirant)
    local attacker = case:createUnit(Ids.units.aspirant, Player(PLAYER_NEUTRAL_AGGRESSIVE))

    IssueTargetOrder(attacker, "attack", target)

    return case:delay(2, function()
        assert(not UnitHasBuffBJ(praetor, config.buffId), "buff applied without toggle")
    end)
end)

T:test("Buff not applied to wrong target type", function(case)
    local praetor = case:createUnit(Ids.units.praetor)
    local target = case:createUnit(Ids.units.praetor)
    local attacker = case:createUnit(Ids.units.aspirant, Player(PLAYER_NEUTRAL_AGGRESSIVE))

    enableToggle(praetor)
    IssueTargetOrder(attacker, "attack", target)

    return case:delay(2, function()
        assert(not UnitHasBuffBJ(praetor, config.buffId), "wrong triggering unit")
    end)
end)

T:test("Cooldown affects", function(case)
    local praetor = case:createUnit(Ids.units.praetor)
    local target = case:createUnit(Ids.units.aspirant)
    local attacker = case:createUnit(Ids.units.aspirant, Player(PLAYER_NEUTRAL_AGGRESSIVE))

    enableToggle(praetor)
    BlzStartUnitAbilityCooldown(praetor, config.abilityId, config.cooldown)
    IssueTargetOrder(attacker, "attack", target)

    return case:delay(2, function()
        assert(not UnitHasBuffBJ(praetor, config.buffId), "ability works when on cooldown")
    end)
end)

T:test("Passive skipped when mana below cost", function(case)
    local praetor = case:createUnit(Ids.units.praetor)
    local target = case:createUnit(Ids.units.aspirant)
    local attacker = case:createUnit(Ids.units.aspirant, Player(PLAYER_NEUTRAL_AGGRESSIVE))

    enableToggle(praetor)
    SetUnitState(praetor, UNIT_STATE_MANA, config.manacost - 1)
    IssueTargetOrder(attacker, "attack", target)

    return case:delay(2, function()
        assert(not UnitHasBuffBJ(praetor, config.buffId), "buff applied without enough mana")
        assert(MechStorage:get(praetor, "active"), "toggle turned off when passive skipped")
    end)
end)

T:test("Passive spends mana", function(case)
    local praetor = case:createUnit(Ids.units.praetor)
    local target = case:createUnit(Ids.units.aspirant)
    local attacker = case:createUnit(Ids.units.aspirant, Player(PLAYER_NEUTRAL_AGGRESSIVE))
    local manaBefore = GetUnitState(praetor, UNIT_STATE_MANA)

    enableToggle(praetor)
    IssueTargetOrder(attacker, "attack", target)

    return case:delay(2, function()
        assert(UnitHasBuffBJ(praetor, config.buffId), "praetor doesn't receive buff")
        assert(
            GetUnitState(praetor, UNIT_STATE_MANA) <= manaBefore - config.manacost + 0.01,
            "mana not spent on passive trigger"
        )
    end)
end)

T:test("Toggle not enabled without enough mana", function(case)
    local praetor = case:createUnit(Ids.units.praetor)

    SetUnitState(praetor, UNIT_STATE_MANA, config.manacost - 1)
    enableToggle(praetor)

    return case:delay(0.5, function()
        assert(not MechStorage:get(praetor, "active"), "toggle enabled without enough mana")
    end)
end)
