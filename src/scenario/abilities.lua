local Ids = require("data.ids")
local buffTypes = require("data.buffTypes")

return {
    buffs = {
        stun = buffTypes.stun,
        root = buffTypes.root,
    },
    abilities = {
        require("scenario.common.death"),
        require("scenario.common.selection"),
        -- require("scenario.common.order"),
        --
        require("scenario.factions.kyrian.abilities.animaBarrage"),
        require("scenario.factions.kyrian.abilities.bastionSpear"),
        require("scenario.factions.kyrian.abilities.cannibalize"),
        require("scenario.factions.kyrian.abilities.dedication"),
        require("scenario.factions.kyrian.abilities.deepMeditation"),
        require("scenario.factions.kyrian.abilities.defenceProtocol"),
        require("scenario.factions.kyrian.abilities.formation"),
        require("scenario.factions.kyrian.abilities.judgingGaze"),
        require("scenario.factions.kyrian.abilities.lastStand"),
        require("scenario.factions.kyrian.abilities.huntedAnimal"),
        require("scenario.factions.kyrian.abilities.memoryPeer"),
        require("scenario.factions.kyrian.abilities.oneMoreChance"),
        require("scenario.factions.kyrian.abilities.overcharge"),
        require("scenario.factions.kyrian.abilities.pulseback"),
        require("scenario.factions.kyrian.abilities.reusables"),
        require("scenario.factions.kyrian.abilities.scan"),
        require("scenario.factions.kyrian.abilities.soulbind"),
        require("scenario.factions.kyrian.abilities.spiritLink"),
        require("scenario.factions.kyrian.abilities.pride"),
        require("scenario.factions.necrolord.abilities.animateDead"),
        require("scenario.factions.necrolord.abilities.combatExpertise"),
        require("scenario.factions.necrolord.abilities.vanish"),
    },
}
