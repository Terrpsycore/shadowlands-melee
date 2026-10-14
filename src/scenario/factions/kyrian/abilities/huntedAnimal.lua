local Ids = require("data.ids")
local AbilityConfig = require("lib.ability.config")
local Dummy = require("utils.dummy")
local Type = require("utils.type")
local Unit = require("utils.unit")

local CONFIG = AbilityConfig.compile({
    refs = {
        abilities = {
            main = Ids.abilities.huntedAnimal,
            buff = Ids.abilities.huntedAnimalBuff,
        },
        buffs = {
            main = Ids.buffs.huntedAnimal,
        },
        units = {
            carrier = Ids.units.larion,
        },
    },
})

local function activateAbility(unit)
    Dummy.applyDummyOrder(GetOwningPlayer(unit), unit, CONFIG.refs.abilities.buff, "bloodlust")
end

local function onFullDisable(info)
    local unit = info.target
    if Unit.isOffCooldown(unit, CONFIG.refs.abilities.main) then
        activateAbility(unit)
    end
end

return {
    triggers = {
        {
            trigger = "STUN",
            filter = { target = CONFIG.refs.units.carrier },
            action = onFullDisable,
        },
        {
            trigger = "ROOT",
            filter = { target = CONFIG.refs.units.carrier },
            action = onFullDisable,
        },
    },
    config = CONFIG,
}
