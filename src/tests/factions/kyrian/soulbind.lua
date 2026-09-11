-- TODO:
-- - forbid 2 bonds on same target
-- - forbid 2 bonds from same caster
local Ids = require("data.ids")
local T = require("tests.support.runner").suite("soulbind")

local Soulbind = require("scenario.factions.kyrian.abilities.soulbind")
local Store = require("scenario.storage.soulbind")

local cfg = Soulbind.config
local BUFF = FourCC(Ids.buffs.soulbind)
local TICKS_PER_LEVEL = cfg.balance.secondsForLevel / cfg.balance.tickSeconds
local OUT_OF_RANGE_OFFSET = cfg.balance.radius + 500

local function hasBuff(unit)
    return UnitHasBuffBJ(unit, BUFF)
end

local function pair(case, offsetX)
    local u1 = case:createUnit(Ids.units.aspirant)
    local u2 = case:createUnit(Ids.units.aspirant)
    if offsetX then
        local x, y = GetUnitX(u2), GetUnitY(u2)
        SetUnitPosition(u2, x + offsetX, y)
    end
    return u1, u2
end

local function bond(u1, u2)
    local id = Store:alloc()
    assert(Store:create(id, { unit_a = u1, unit_b = u2 }), "create failed")
    return id
end

local function tick(id, n)
    for _ = 1, n do
        Soulbind.tickBond(id)
    end
end

T:test("Bond starts at level 1", function(case)
    local u1, u2 = pair(case)
    local id = bond(u1, u2)
    local b = assert(Store:read(id), "bond missing")

    assert(b.level == 1 and b.progress == 0 and not b.active, "bond starts at level 1")
    assert(Store:find(u1) == id, "unit lookup works")
end)

T:test("Progress advances to level 2", function(case)
    local u1, u2 = pair(case)
    local id = bond(u1, u2)

    local halfTicks = math.ceil(TICKS_PER_LEVEL / 2)
    tick(id, halfTicks)
    local mid = assert(Store:read(id), "bond missing")
    assert(mid.level == 1 and mid.progress > 0 and mid.progress < 1, "partial progress mid level")

    tick(id, TICKS_PER_LEVEL - halfTicks)
    local lvl2 = assert(Store:read(id), "bond missing")
    assert(lvl2.level == 2 and lvl2.progress == 0, "level 2 after full cycle")
end)

T:test("Progress capped at max level", function(case)
    local u1, u2 = pair(case)
    local id = bond(u1, u2)

    tick(id, TICKS_PER_LEVEL * 3)
    local capped = assert(Store:read(id), "bond missing")
    assert(capped.level == 3 and capped.progress == 0, "stays at max level")
end)

T:test("Out of range stops progress", function(case)
    local u1, u2 = pair(case, OUT_OF_RANGE_OFFSET)
    local id = bond(u1, u2)

    Soulbind.tickBond(id)
    local b = assert(Store:read(id), "bond missing")

    assert(not b.active and b.level == 1 and b.progress == 0, "no progress when out of range")
end)

T:test("Buff applied at level 3 and removed on range break", function(case)
    local u1, u2 = pair(case)
    local id = bond(u1, u2)

    tick(id, TICKS_PER_LEVEL * 2)

    return case:delay(0.5, function()
        assert(hasBuff(u1) and hasBuff(u2), "buff applied at level 3")

        SetUnitPosition(u2, GetUnitX(u2) + OUT_OF_RANGE_OFFSET, GetUnitY(u2))
        Soulbind.tickBond(id)
        assert(not hasBuff(u1) and not hasBuff(u2), "buff removed on range break")

        SetUnitPosition(u2, GetUnitX(u1) + 32, GetUnitY(u1))
        Soulbind.tickBond(id)

        return case:delay(0.5, function()
            assert(hasBuff(u1) and hasBuff(u2), "buff restored in range")
        end)
    end)
end)
