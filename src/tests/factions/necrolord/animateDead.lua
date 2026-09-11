local Ids = require("data.ids")
local T = require("tests.support.runner").suite("animateDead")

local animateDead = require("scenario.factions.necrolord.abilities.animateDead")
local Callback = require("lib.triggers.callbacks")
local DeathStorage = require("scenario.storage.death")

local config = animateDead.config

local function setupCorpse(case, opts)
    opts = opts or {}
    local x, y = -50, -50
    local hidden = CreateUnit(Player(0), FourCC(Ids.units.aspirant), x, y, 270)
    SetUnitInvulnerable(hidden, true)
    ShowUnitHide(hidden)

    local corpse = CreateUnit(Player(0), FourCC(Ids.units.aspirant), x, y, 270)
    KillUnit(corpse)

    DeathStorage:set(corpse, "unit", hidden)
    DeathStorage:set(corpse, "isPeon", false)
    DeathStorage:set(corpse, "originalOwner", 0)
    DeathStorage:set(corpse, "reviveAfter", opts.reviveAfter or 0)

    case:addFlushCallback(function()
        if corpse and UnitAlive(corpse) then
            RemoveUnit(corpse)
        end
        if hidden and UnitAlive(hidden) then
            RemoveUnit(hidden)
        end
    end)

    return { caster = case:createUnit(Ids.units.necromancer), corpse = corpse, hidden = hidden }
end

T:test("Revives bound corpse and fires REVIVE", function(case)
    local setup = setupCorpse(case)
    local revived = false

    Callback.registerCallback("REVIVE", {
        trigger = "REVIVE",
        action = function(ctx)
            if ctx.source == setup.caster and ctx.target == setup.hidden then
                revived = true
            end
        end,
    })

    local ok = animateDead.debug.tryRevive(setup.caster, setup.corpse)
    assert(ok, "tryRevive should succeed")
    assert(revived, "REVIVE event not fired")
    assert(not DeathStorage:has(setup.corpse), "corpse storage not cleared")
    assert(not IsUnitHidden(setup.hidden), "revived unit still hidden")
    assert(GetUnitState(setup.hidden, UNIT_STATE_LIFE) > 0, "revived unit not at full life")
end)

T:test("reviveAfter blocks resurrection", function(case)
    local setup = setupCorpse(case, { reviveAfter = 2 })
    local manaBefore = GetUnitState(setup.caster, UNIT_STATE_MANA)

    local ok = animateDead.debug.tryRevive(setup.caster, setup.corpse)
    assert(not ok, "revive should be blocked while reviveAfter > 0")
    assert(DeathStorage:get(setup.corpse, "reviveAfter") == 1, "reviveAfter not decremented")
    assert(IsUnitHidden(setup.hidden), "unit revived prematurely")
    assert(GetUnitState(setup.caster, UNIT_STATE_MANA) == manaBefore - config.balance.manaCost, "mana not spent")
end)

T:test("Nil corpse restores mana", function(case)
    local caster = case:createUnit(Ids.units.necromancer)
    local manaBefore = GetUnitState(caster, UNIT_STATE_MANA)

    local ok = animateDead.debug.tryRevive(caster, nil)
    assert(not ok, "nil corpse should not revive")
    assert(GetUnitState(caster, UNIT_STATE_MANA) == manaBefore, "mana not restored for nil target")
end)
