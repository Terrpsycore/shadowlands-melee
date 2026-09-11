local Ids = require("data.ids")
local T = require("tests.support.runner").suite("animaBarrage")

local animaBarrage = require("scenario.factions.kyrian.abilities.animaBarrage")
local MechStorage = require("scenario.storage.mech")

local config = animaBarrage.config

local function setupColossus(case, active)
    local colossus = case:createUnit(Ids.units.colossus)
    if active then
        MechStorage:set(colossus, "active", true)
        UnitAddAbility(colossus, config.refs.abilities.main)
    else
        MechStorage:drop(colossus)
    end
    return colossus
end

T:test("Spends mana when active and air enemy nearby", function(case)
    local colossus = setupColossus(case, true)
    local flying = case:createUnit(Ids.units.ascendedWarriorFlying, Player(PLAYER_NEUTRAL_AGGRESSIVE))
    local ground = case:createUnit(Ids.units.aspirant, Player(PLAYER_NEUTRAL_AGGRESSIVE))

    local cx, cy = GetUnitX(colossus), GetUnitY(colossus)
    SetUnitPosition(flying, cx + 100, cy + 100)
    SetUnitPosition(ground, cx + 50, cy)

    local manaBefore = GetUnitState(colossus, UNIT_STATE_MANA)
    IssueTargetOrder(colossus, "attack", ground)

    return case:delay(2, function()
        local manaAfter = GetUnitState(colossus, UNIT_STATE_MANA)
        assert(
            manaAfter <= manaBefore - config.balance.manacost + 0.01,
            "mana not spent with active toggle and nearby air unit"
        )
    end)
end)

T:test("No mana spend when toggle off", function(case)
    local colossus = setupColossus(case, false)
    local flying = case:createUnit(Ids.units.ascendedWarriorFlying, Player(PLAYER_NEUTRAL_AGGRESSIVE))
    local ground = case:createUnit(Ids.units.aspirant, Player(PLAYER_NEUTRAL_AGGRESSIVE))

    local cx, cy = GetUnitX(colossus), GetUnitY(colossus)
    SetUnitPosition(flying, cx + 100, cy + 100)
    SetUnitPosition(ground, cx + 50, cy)

    local manaBefore = GetUnitState(colossus, UNIT_STATE_MANA)
    IssueTargetOrder(colossus, "attack", ground)

    return case:delay(2, function()
        assert(
            GetUnitState(colossus, UNIT_STATE_MANA) == manaBefore,
            "mana spent while toggle off"
        )
    end)
end)

T:test("No mana spend when mana below cost", function(case)
    local colossus = setupColossus(case, true)
    SetUnitState(colossus, UNIT_STATE_MANA, config.balance.manacost - 1)

    local flying = case:createUnit(Ids.units.ascendedWarriorFlying, Player(PLAYER_NEUTRAL_AGGRESSIVE))
    local ground = case:createUnit(Ids.units.aspirant, Player(PLAYER_NEUTRAL_AGGRESSIVE))

    local cx, cy = GetUnitX(colossus), GetUnitY(colossus)
    SetUnitPosition(flying, cx + 100, cy + 100)
    SetUnitPosition(ground, cx + 50, cy)

    IssueTargetOrder(colossus, "attack", ground)

    return case:delay(2, function()
        assert(
            GetUnitState(colossus, UNIT_STATE_MANA) <= config.balance.manacost,
            "mana spent without enough resources"
        )
    end)
end)
