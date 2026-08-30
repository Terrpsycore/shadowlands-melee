local Ids = require("data.ids")

return {
    buffs = {
        stun = { Ids.buffs.stunned, Ids.buffs.stunnedPause },
        root = {},
    },
    abilities = {
        require("scenario.factions.kyrian.abilities.cannibalize"),
        require("scenario.factions.kyrian.abilities.defenceProtocol"),
        require("scenario.factions.kyrian.abilities.formation"),
        require("scenario.factions.kyrian.abilities.soulbind"),
        require("scenario.factions.kyrian.abilities.pride"),
    },
}
