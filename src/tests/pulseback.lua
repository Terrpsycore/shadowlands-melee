local Ids = require("data.ids")
local T = require("tests.support.runner")

local pulseback = require("scenario.factions.kyrian.abilities.pulseback")
local MechStorage = require("scenario.storage.mech")

local config = pulseback.config

local function setActive(unit, active)
    MechStorage:set(unit, "active", active)
end

T:test("Proc not triggered when toggle off", function(case)
    local goliath = case:createUnit(Ids.units.goliath)
    local attacker = case:createUnit(Ids.units.aspirant, Player(PLAYER_NEUTRAL_AGGRESSIVE))

    setActive(goliath, false)
    IssueTargetOrder(attacker, "attack", goliath)

    return case:delay(2, function()
        assert(BlzGetUnitAbilityCooldownRemaining(goliath, config.refs.abilities.main) <= 0, "proc triggered with toggle off")
    end)
end)

T:test("Proc skipped when mana below cost", function(case)
    local goliath = case:createUnit(Ids.units.goliath)
    local attacker = case:createUnit(Ids.units.aspirant, Player(PLAYER_NEUTRAL_AGGRESSIVE))

    setActive(goliath, true)
    SetUnitState(goliath, UNIT_STATE_MANA, config.balance.pulseManacost - 1)
    IssueTargetOrder(attacker, "attack", goliath)

    return case:delay(2, function()
        assert(BlzGetUnitAbilityCooldownRemaining(goliath, config.refs.abilities.main) <= 0, "proc triggered without enough mana")
        assert(MechStorage:get(goliath, "active") ~= false, "toggle turned off when proc skipped")
    end)
end)

T:test("Cooldown blocks proc", function(case)
    local goliath = case:createUnit(Ids.units.goliath)
    local attacker = case:createUnit(Ids.units.aspirant, Player(PLAYER_NEUTRAL_AGGRESSIVE))

    setActive(goliath, true)
    BlzStartUnitAbilityCooldown(goliath, config.refs.abilities.main, config.balance.cooldown)
    IssueTargetOrder(attacker, "attack", goliath)

    return case:delay(2, function()
        assert(BlzGetUnitAbilityCooldownRemaining(goliath, config.refs.abilities.main) > 0, "cooldown was reset")
    end)
end)

T:test("Ally attack does not proc", function(case)
    local goliath = case:createUnit(Ids.units.goliath)
    local ally = case:createUnit(Ids.units.aspirant)

    setActive(goliath, true)
    IssueTargetOrder(ally, "attack", goliath)

    return case:delay(2, function()
        assert(BlzGetUnitAbilityCooldownRemaining(goliath, config.refs.abilities.main) <= 0, "proc triggered by ally attack")
    end)
end)

T:test("Toggle off via unimmolation", function(case)
    local goliath = case:createUnit(Ids.units.goliath)

    setActive(goliath, true)
    IssueImmediateOrder(goliath, "unimmolation")

    return case:delay(1, function()
        assert(MechStorage:get(goliath, "active") == false, "toggle not disabled")
    end)
end)

T:test("Active by default allows proc attempt", function(case)
    local goliath = case:createUnit(Ids.units.goliath)
    local attacker = case:createUnit(Ids.units.aspirant, Player(PLAYER_NEUTRAL_AGGRESSIVE))
    local manaBefore = GetUnitState(goliath, UNIT_STATE_MANA)

    IssueTargetOrder(attacker, "attack", goliath)

    return case:delay(3, function()
        local cdRemaining = BlzGetUnitAbilityCooldownRemaining(goliath, config.refs.abilities.main)
        local manaAfter = GetUnitState(goliath, UNIT_STATE_MANA)
        assert(
            cdRemaining > 0 or manaAfter >= manaBefore - config.balance.pulseManacost + 0.01,
            "no proc attempt with default active state"
        )
    end)
end)
