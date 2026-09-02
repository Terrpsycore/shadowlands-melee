local Ids = require("data.ids")

return {
    buffs = {
        stun = { Ids.buffs.stunned, Ids.buffs.stunnedPause, Ids.buffs.deepMeditationStun },
        root = {},
    },
    abilities = {
        require("scenario.common.selection"),
        --
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
        require("scenario.factions.kyrian.abilities.soulbind"),
        require("scenario.factions.kyrian.abilities.spiritLink"),
        require("scenario.factions.kyrian.abilities.pride"),
    },
}
