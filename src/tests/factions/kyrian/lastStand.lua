local Ids = require("data.ids")
local T = require("tests.support.runner").suite("lastStand")

local lastStand = require("scenario.factions.kyrian.abilities.lastStand")

local config = lastStand.config

T:test("Channel start adds aura ability", function(case)
    local caster = case:createUnit(Ids.units.watcher)

    IssueImmediateOrder(caster, "laststand")

    return case:delay(0.5, function()
        assert(
            GetUnitAbilityLevel(caster, config.refs.abilities.aura) > 0,
            "last stand aura not added on channel start"
        )
    end)
end)

T:test("Damage clamped to leave 1 HP", function(case)
    local target = case:createUnit(Ids.units.aspirant)
    case:applyDummyOrder(Player(0), target, config.refs.abilities.aura, "slow")

    return case:delay(0.5, function()
        assert(UnitHasBuffBJ(target, config.refs.buffs.main), "last stand buff not applied")

        local info = { target = target, damage = 50 }
        SetUnitState(target, UNIT_STATE_LIFE, 10)
        lastStand.debug.onDamage(info)
        assert(info.damage == 9, "expected damage clamped to 9, got " .. info.damage)
    end)
end)
