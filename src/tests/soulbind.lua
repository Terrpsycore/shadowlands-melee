-- Test ideas:
-- -
local Ids = require("data.generated.ids")
local Store = require("scenario.store.soulbind")
local Soulbind = require("scenario.factions.kyrian.abilities.soulbind")

local X, Y = -200, -200
local cfg = Soulbind.config
local TICKS_PER_LEVEL = cfg.secondsForLevel / cfg.tickSeconds -- 60

local function say(ok, name)
    Debug.original.print((ok and "OK: " or "ERROR: ") .. name)
end

local function pair()
    local u1 = CreateUnit(Player(0), FourCC(Ids.units.aspirant), X, Y, 270)
    local u2 = CreateUnit(Player(0), FourCC(Ids.units.aspirant), X + 32, Y, 270)
    return u1, u2
end

local function bond(u1, u2)
    local id = Store.allocBondId()
    assert(Store.create(id, u1, u2), "create failed")
    return id
end

local function cleanup(id, u1, u2)
    Store.destroy(id)
    RemoveUnit(u1)
    RemoveUnit(u2)
end

-- === storage ===
Timed.call(0, function()
    Store.init()
    local u1, u2 = pair()
    local id = bond(u1, u2)
    local b = Store.get(id)

    say(b.level == 1 and b.progress == 0 and not b.active, "bond starts at level 1")
    say(Store.getBondIdByUnit(u1) == id, "unit lookup works")

    cleanup(id, u1, u2)
end)

-- === progress cycle (мгновенно, без ожидания 60 сек) ===
Timed.call(0, function()
    Store.init()
    local u1, u2 = pair()
    local id = bond(u1, u2)

    for _ = 1, 30 do
        Soulbind.tickBond(id)
    end
    local mid = Store.get(id)
    say(mid.level == 1 and math.abs(mid.progress - 0.5) < 0.001, "half level after 30 ticks")

    for _ = 1, 30 do
        Soulbind.tickBond(id)
    end
    local lvl2 = Store.get(id)
    say(lvl2.level == 2 and lvl2.progress == 0, "level 2 after full cycle")

    for _ = 1, TICKS_PER_LEVEL do
        Soulbind.tickBond(id)
    end
    local lvl3 = Store.get(id)
    say(lvl3.level == 3, "level 3 after second cycle")

    for _ = 1, TICKS_PER_LEVEL do
        Soulbind.tickBond(id)
    end
    local capped = Store.get(id)
    say(capped.level == 3 and capped.progress == 0, "stays at max level")

    cleanup(id, u1, u2)
end)

-- === out of range: прогресс не растёт ===
Timed.call(0, function()
    Store.init()
    local u1, u2 = pair()
    local id = bond(u1, u2)

    SetUnitPosition(u2, X + 2000, Y)
    Soulbind.tickBond(id)
    local b = Store.get(id)

    say(not b.active and b.level == 1 and b.progress == 0, "no progress when out of range")

    cleanup(id, u1, u2)
end)

-- === smoke: реальное время ~3 сек (опционально) ===
Timed.call(0, function()
    Store.init()
    local saved = cfg.secondsForLevel
    cfg.secondsForLevel = 3 -- 3 тика = 1 уровень

    local u1, u2 = pair()
    local id = bond(u1, u2)
    local n = 0

    Timed.echo(1, 3, function()
        Soulbind.tickBond(id)
        n = n + 1
        return n >= 3
    end, function()
        say(Store.get(id).level == 2, "level up in ~3 seconds (smoke)")
        cfg.secondsForLevel = saved
        cleanup(id, u1, u2)
    end)
end)
