--[[
    Luashine FileIO (stable-style) — Save/Load via PreloadGenEnd + Preloader.
    https://www.hiveworkshop.com/threads/stable-lua-fileio.360424/
    LOAD ability: data slug fileioLoad (lib.abilities).
]]
do
    local Abilities = require("lib.abilities")

    local RAW_PREFIX = "]]i([["
    local RAW_SUFFIX = "]]" .. ")--[["
    local RAW_SIZE = 255 - #RAW_PREFIX - #RAW_SUFFIX
    local LOAD_ABILITY = Abilities.fourcc("fileioLoad")
    local LOAD_EMPTY_KEY = "!@#$, empty data"

    local currentName ---@type string?

    local function open(filename)
        currentName = filename
        PreloadGenClear()
        Preload('")\nendfunction\n//!beginusercode\nlocal p={} local i=function(s) table.insert(p,s) end--[[')
    end

    local function writeRaw(s)
        local i = 1
        local size = #s
        while i <= size do
            local pos = math.min(i + RAW_SIZE - 1, size)
            while pos > i and (s:sub(pos, pos) == "]" or (s:sub(pos + 1, pos + 1) == "]")) do
                pos = pos - 1
            end
            Preload(RAW_PREFIX .. s:sub(i, pos) .. RAW_SUFFIX)
            i = pos + 1
        end
    end

    local function close()
        if not currentName then
            return
        end
        Preload(
            "]]BlzSetAbilityTooltip("
                .. LOAD_ABILITY
                .. ', table.concat(p), 0)\n//!endusercode\nfunction a takes nothing returns nothing\n//'
        )
        PreloadGenEnd(currentName)
        currentName = nil
    end

    ---@param filename string
    ---@param data string
    local function savefile(filename, data)
        open(filename)
        writeRaw(data)
        close()
    end

    ---@param filename string
    ---@return string?
    local function loadfile(filename)
        local previous = BlzGetAbilityTooltip(LOAD_ABILITY, 0)
        BlzSetAbilityTooltip(LOAD_ABILITY, LOAD_EMPTY_KEY, 0)
        Preloader(filename)
        local loaded = BlzGetAbilityTooltip(LOAD_ABILITY, 0)
        BlzSetAbilityTooltip(LOAD_ABILITY, previous or "", 0)
        Preloader("")
        if loaded == nil or loaded == "" or loaded == LOAD_EMPTY_KEY then
            return nil
        end
        return loaded:gsub("!]", "]"):gsub("!\\", "\\")
    end

    FileIO = {
        Save = savefile,
        Load = loadfile,
        enabled = true,
    }
end

return FileIO
