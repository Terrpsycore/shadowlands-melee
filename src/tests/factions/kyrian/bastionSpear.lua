local Ids = require("data.ids")
local T = require("tests.support.runner").suite("bastionSpear")

local bastionSpear = require("scenario.factions.kyrian.abilities.bastionSpear")

local config = bastionSpear.config

T:test("Point cast debuffs enemy in radius", function(case)
    local warrior = case:createUnit(Ids.units.ascendedWarrior)
    local enemy = case:createUnit(Ids.units.aspirant, Player(PLAYER_NEUTRAL_AGGRESSIVE))

    local ex, ey = GetUnitX(enemy), GetUnitY(enemy)
    IssuePointOrder(warrior, "bastionspear", ex, ey)

    return case:delay(1, function()
        assert(
            UnitHasBuffBJ(enemy, config.refs.buffs.bonusDamage),
            "enemy missing bastion spear bonus damage debuff"
        )
    end)
end)

T:test("Bonus damage consumed on hit", function(case)
    local warrior = case:createUnit(Ids.units.ascendedWarrior)
    local enemy = case:createUnit(Ids.units.aspirant, Player(PLAYER_NEUTRAL_AGGRESSIVE))

    case:applyDummyOrder(GetOwningPlayer(warrior), enemy, config.refs.abilities.bonusDamage, "slow")

    return case:delay(0.5, function()
        assert(UnitHasBuffBJ(enemy, config.refs.buffs.bonusDamage), "setup debuff missing")

        SetUnitState(enemy, UNIT_STATE_LIFE, 200)
        Damage.apply(warrior, enemy, 10, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_UNIVERSAL)

        return case:delay(0.2, function()
            local life = GetUnitState(enemy, UNIT_STATE_LIFE)
            assert(life == 165, "expected bonus damage applied, got life=" .. life)
            assert(not UnitHasBuffBJ(enemy, config.refs.buffs.bonusDamage), "debuff not consumed")
        end)
    end)
end)
