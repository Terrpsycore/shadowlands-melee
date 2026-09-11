local Ids = require("data.ids")
local T = require("tests.support.runner").suite("deepMeditation")

local deepMeditation = require("scenario.factions.kyrian.abilities.deepMeditation")
local Storage = require("scenario.storage.deepMeditation")

local config = deepMeditation.config

T:test("Cast on non-full mana target starts tracking", function(case)
    local caster = case:createUnit(Ids.units.wisdom)
    local target = case:createUnit(Ids.units.aspirant)
    SetUnitState(target, UNIT_STATE_MANA, 0)

    IssueTargetOrder(caster, "deepmeditation", target)

    return case:delay(1.5, function()
        assert(UnitHasBuffBJ(target, config.refs.buffs.main), "deep meditation buff not applied")
        assert(Storage:has(target), "target not tracked in storage")
        assert(Storage:get(target, "damageReceived") == 0, "damage counter not initialized")
    end)
end)

T:test("Skipped on full mana target", function(case)
    local caster = case:createUnit(Ids.units.wisdom)
    local target = case:createUnit(Ids.units.aspirant)
    SetUnitState(target, UNIT_STATE_MANA, GetUnitState(target, UNIT_STATE_MAX_MANA))

    IssueTargetOrder(caster, "deepmeditation", target)

    return case:delay(1.5, function()
        assert(not Storage:has(target), "full mana target should not be tracked")
    end)
end)

T:test("Excessive damage removes effects", function(case)
    local target = case:createUnit(Ids.units.aspirant)
    Storage:set(target, "damageReceived", 0)

    case:applyDummyOrder(Player(0), target, config.refs.abilities.stunDummy, "thunderbolt")

    return case:delay(1, function()
        assert(Storage:has(target), "setup tracking missing")

        local attacker = case:createUnit(Ids.units.aspirant, Player(PLAYER_NEUTRAL_AGGRESSIVE))
        Damage.apply(attacker, target, config.balance.damageThreshold + 1, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_UNIVERSAL)

        return case:delay(0.2, function()
            assert(not Storage:has(target), "storage not cleared after damage threshold")
            assert(not UnitHasBuffBJ(target, config.refs.buffs.main), "buff not removed after damage threshold")
        end)
    end)
end)
