--[[
]]

local Ids = require("data.ids")
local AbilityConfig = require("lib.ability.config")
local Dummy = require("utils.dummy")
local Unit = require("utils.unit")

local CONFIG = AbilityConfig.compile({
    refs = {
        abilities = {},
        units = {},
    },
    balance = {},
})

-- local memory = {} -- TODO: save/load -- process 1.33/1.5 WS stacks per hit

return {
    triggers = {},
    config = CONFIG,
}
