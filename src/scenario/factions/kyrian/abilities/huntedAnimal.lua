local Ids = require("data.generated.ids")
local Dummy = require("utils.dummy")
local Type = require("utils.type")
local Unit = require("utils.unit")
local dump = require("utils.logger")

local CONFIG = {
    -- radius = 600,
    -- cooldown = 5,

    buffId = FourCC(Ids.buffs.huntedAnimal),

    abilityId = FourCC(Ids.abilities.huntedAnimal),
    dummyAbilityId = FourCC(Ids.abilities.huntedAnimalBuff),
    -- requiredUpgradeId = nil,
}

local function activateAbility(unit)
    Dummy.applyDummyOrder(GetOwningPlayer(unit), unit, CONFIG.dummyAbilityId, "bloodlust")
end

local function onFullDisable(unit)
    if Unit.isOffCooldown(unit, CONFIG.abilityId) then
        activateAbility(unit)
    end
end

return {
    triggers = {},
    config = CONFIG,
}
