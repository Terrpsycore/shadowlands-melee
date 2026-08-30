-- TODO:
-- - forbid 2 bonds on same target
-- - forbid 2 bonds from same caster
-- Generated
local Ids = require("data.ids")
local Store = require("scenario.storage.soulbind")
local Storage = require("lib.storage.storage")
local Soulbind = require("scenario.factions.kyrian.abilities.soulbind")

local cfg = Soulbind.config
local BUFF = FourCC(Ids.buffs.soulbind)
local TICKS_PER_LEVEL = cfg.secondsForLevel / cfg.tickSeconds
local OUT_OF_RANGE_OFFSET = cfg.radius + 500

local function report(ok, name)
    DisplayTextToPlayer(GetLocalPlayer(), 0, 0, (ok and "OK: " or "ERROR: ") .. name)
end

local function hasBuff(unit)
    return UnitHasBuffBJ(unit, BUFF)
end

local function pair(x, y)
    local u1 = CreateUnit(Player(0), FourCC(Ids.units.aspirant), x, y, 270)
    local u2 = CreateUnit(Player(0), FourCC(Ids.units.aspirant), x + 32, y, 270)
    return u1, u2
end

local function bond(u1, u2)
    local id = Store:alloc()
    assert(Store:create(id, { unit_a = u1, unit_b = u2 }), "create failed")
    return id
end

local function cleanup(id, u1, u2)
    Store:destroy(id)
    RemoveUnit(u1)
    RemoveUnit(u2)
end

local function tick(id, n)
    for _ = 1, n do
        Soulbind.tickBond(id)
    end
end

Timed.call(0, function()
    Storage.initAll()
    local x, y = -200, -200
    local u1, u2 = pair(x, y)
    local id = bond(u1, u2)
    local b = Store:get(id)

    report(b.level == 1 and b.progress == 0 and not b.active, "bond starts at level 1")
    report(Store:getByUnit(u1) == id, "unit lookup works")

    cleanup(id, u1, u2)
end)

Timed.call(0, function()
    Storage.initAll()
    local x, y = -200, -400
    local u1, u2 = pair(x, y)
    local id = bond(u1, u2)

    local halfTicks = math.ceil(TICKS_PER_LEVEL / 2)
    tick(id, halfTicks)
    local mid = Store:get(id)
    report(mid.level == 1 and mid.progress > 0 and mid.progress < 1, "partial progress mid level")

    tick(id, TICKS_PER_LEVEL - halfTicks)
    local lvl2 = Store:get(id)
    report(lvl2.level == 2 and lvl2.progress == 0, "level 2 after full cycle")

    tick(id, TICKS_PER_LEVEL)
    report(Store:get(id).level == 3, "level 3 after second cycle")

    tick(id, TICKS_PER_LEVEL)
    local capped = Store:get(id)
    report(capped.level == 3 and capped.progress == 0, "stays at max level")

    cleanup(id, u1, u2)
end)

Timed.call(0, function()
    Storage.initAll()
    local x, y = -200, -600
    local u1, u2 = pair(x, y)
    local id = bond(u1, u2)

    SetUnitPosition(u2, x + OUT_OF_RANGE_OFFSET, y)
    Soulbind.tickBond(id)
    local b = Store:get(id)

    report(not b.active and b.level == 1 and b.progress == 0, "no progress when out of range")

    cleanup(id, u1, u2)
end)

Timed.call(0, function()
    Storage.initAll()
    local x, y = -400, -200
    local u1, u2 = pair(x, y)
    local id = bond(u1, u2)

    tick(id, TICKS_PER_LEVEL * 2)

    Timed.call(1, function()
        report(hasBuff(u1) and hasBuff(u2), "buff applied at level 3")

        SetUnitPosition(u2, x + OUT_OF_RANGE_OFFSET, y)
        Soulbind.tickBond(id)
        report(not hasBuff(u1) and not hasBuff(u2), "buff removed on range break")

        SetUnitPosition(u2, x + 32, y)
        Soulbind.tickBond(id)

        Timed.call(1, function()
            report(hasBuff(u1) and hasBuff(u2), "buff restored in range")

            SetUnitPosition(u2, x + OUT_OF_RANGE_OFFSET, y)
            Soulbind.tickBond(id)
            report(not hasBuff(u1) and not hasBuff(u2), "buff removed on 2nd range break")

            cleanup(id, u1, u2)
        end)
    end)
end)
