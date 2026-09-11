local Ids = require("data.ids")
local T = require("tests.support.runner").suite("spiritLink")

local spiritLink = require("scenario.factions.kyrian.abilities.spiritLink")

local config = spiritLink.config

local function applySpiritLinkBuff(case, target)
    local carrier = case:createUnit(Ids.units.loyalty)
    IssueTargetOrder(carrier, "spiritlink", target)
    return carrier
end

T:test("Damage reduced when spirit link buff present", function(case)
    local target = case:createUnit(Ids.units.aspirant)
    local attacker = case:createUnit(Ids.units.aspirant, Player(PLAYER_NEUTRAL_AGGRESSIVE))

    applySpiritLinkBuff(case, target)

    return case:delay(1, function()
        assert(UnitHasBuffBJ(target, config.refs.buffs.main), "spirit link buff not applied")

        SetUnitState(target, UNIT_STATE_LIFE, 100)
        Damage.apply(attacker, target, 20, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_UNIVERSAL)

        return case:delay(0.2, function()
            local life = GetUnitState(target, UNIT_STATE_LIFE)
            assert(life == 86, "expected 14 damage after reduction, got " .. (100 - life))
        end)
    end)
end)

T:test("Damage floored at minDamage", function(case)
    local target = case:createUnit(Ids.units.aspirant)
    local attacker = case:createUnit(Ids.units.aspirant, Player(PLAYER_NEUTRAL_AGGRESSIVE))

    applySpiritLinkBuff(case, target)

    return case:delay(1, function()
        assert(UnitHasBuffBJ(target, config.refs.buffs.main), "spirit link buff not applied")

        SetUnitState(target, UNIT_STATE_LIFE, 100)
        Damage.apply(attacker, target, 5, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_UNIVERSAL)

        return case:delay(0.2, function()
            local life = GetUnitState(target, UNIT_STATE_LIFE)
            assert(life == 97, "expected minDamage=3, got " .. (100 - life))
        end)
    end)
end)

T:test("No reduction without buff", function(case)
    local target = case:createUnit(Ids.units.aspirant)
    local attacker = case:createUnit(Ids.units.aspirant, Player(PLAYER_NEUTRAL_AGGRESSIVE))

    SetUnitState(target, UNIT_STATE_LIFE, 100)
    Damage.apply(attacker, target, 20, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_UNIVERSAL)

    return case:delay(0.2, function()
        local life = GetUnitState(target, UNIT_STATE_LIFE)
        assert(life == 80, "expected full 20 damage without buff, got " .. (100 - life))
    end)
end)
