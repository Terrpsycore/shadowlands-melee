-- Toggle Ability
-- use storage
-- check GetIssuedOrderId for toggle on off

local Ids = require("data.ids")
local Dummy = require("utils.dummy")
local Type = require("utils.type")
local Unit = require("utils.unit")
local dump = require("utils.logger")

local CONFIG = {
    radius = 600,
    cooldown = 5,

    buffId = FourCC(Ids.buffs.defenceProtocol),

    abilityId = FourCC(Ids.abilities.defenceProtocol),
    dummyAbilityId = FourCC(Ids.abilities.defenceProtocolBuff),
    requiredUpgradeId = nil,
}

local function applyDefenceProtocolBuff(unit)
    Dummy.applyDummyOrder(GetOwningPlayer(unit), unit, CONFIG.dummyAbilityId, "bloodlust")
end

local function activateDefenceProtocol(event, unit)
    if IsUnitAlly(event.target, GetOwningPlayer(event.source)) then
        return
    end
    if not Unit.isOffCooldown(unit, CONFIG.abilityId) then
        return
    end
    BlzStartUnitAbilityCooldown(unit, CONFIG.abilityId, CONFIG.cooldown)
    applyDefenceProtocolBuff(unit)
end

-- @
local function onDamageEvent(info)
    -- dump("defenceProtocol onDamageEvent fire")
    local nearbyPraetors = Unit.getAllyUnitsOfTypeInRadius(info.target, FourCC(Ids.units.praetor), CONFIG.radius)
    -- dump("nearbyPraetors " .. #nearbyPraetors)
    for _, unit in ipairs(nearbyPraetors) do
        activateDefenceProtocol(info, unit)
    end
end

return {
    triggers = {
        -- damage event
        DAMAGE = {
            action = onDamageEvent,
            target = {
                type = { Ids.units.steward, Ids.units.aspirant },
            },
        },
    },
    config = CONFIG,
}
