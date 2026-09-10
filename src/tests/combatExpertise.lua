local Ids = require("data.ids")
local T = require("tests.support.runner").suite("combatExpertise")

local combatExpertise = require("scenario.factions.necrolord.abilities.combatExpertise")

local config = combatExpertise.config
local OUT_OF_RANGE_OFFSET = config.balance.radius + 50

local function populate(case, deathCount, opts)
    opts = opts or {}
    local carrier = case:createUnit(Ids.units.animateWarrior)
    local victim = case:createUnit(Ids.units.aspirant, Player(PLAYER_NEUTRAL_AGGRESSIVE))

    if opts.outOfRange then
        local cx, cy = GetUnitX(carrier), GetUnitY(carrier)
        SetUnitPosition(victim, cx + OUT_OF_RANGE_OFFSET, cy)
    end

    for _ = 1, deathCount do
        combatExpertise.debug.onDeath(victim)
    end

    return { carrier = carrier, victim = victim }
end

local function testLevelCalc(case, deathCount, expectedLevel, opts)
    local populated = populate(case, deathCount, opts)
    local level = GetUnitAbilityLevel(populated.carrier, config.refs.abilities.damageBuff)
    assert(
        level == expectedLevel,
        "Invalid buffLevel value = " .. level .. ", expected = " .. expectedLevel
    )
end

T:test("No damage bonus by default", function(case)
    testLevelCalc(case, 0, 0)
end)

T:test("1 death no bonus yet", function(case)
    testLevelCalc(case, 1, 0)
end)

T:test("+1 level", function(case)
    testLevelCalc(case, 2, 1)
end)

T:test("+5 strict", function(case)
    testLevelCalc(case, 10, 5)
end)

T:test("+5 max", function(case)
    testLevelCalc(case, 12, 5)
end)

T:test("Out of range deaths ignored", function(case)
    testLevelCalc(case, 10, 0, { outOfRange = true })
end)

T:test("Progress reset on carrier death", function(case)
    local populated = populate(case, 4)
    combatExpertise.debug.onDeath(populated.carrier)
    for _ = 1, 2 do
        combatExpertise.debug.onDeath(populated.victim)
    end

    local level = GetUnitAbilityLevel(populated.carrier, config.refs.abilities.damageBuff)
    assert(level == 1, "Invalid buffLevel after carrier death reset = " .. level .. ", expected = 1")
end)
