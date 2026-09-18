--- Usage: lua tools/oe/main.lua

local path = dofile("tools/_path.lua")
path.setup()

-- wc3.exe saves via extension ObjectWriter (not src/vendor copy). "Crs" is 3 bytes;
-- without null padding the w3a stream misaligns and WE hangs on custom object data.
local function padFourCC(id)
    if #id >= 4 then
        return id:sub(1, 4)
    end
    return id .. string.rep("\0", 4 - #id)
end

if ObjectWriter and ObjectWriter.writeDefinition and not ObjectWriter._padFourCCPatched then
    local writeDefinition = ObjectWriter.writeDefinition

    function ObjectWriter:writeDefinition(def)
        local restore = {}
        for _, field in pairs(def.fields) do
            if #field.id < 4 then
                restore[field] = field.id
                field.id = padFourCC(field.id)
            end
        end

        local ok, err = pcall(writeDefinition, self, def)
        for field, id in pairs(restore) do
            field.id = id
        end
        if not ok then
            error(err, 0)
        end
    end

    ObjectWriter._padFourCCPatched = true
end

require("lib.objediting.inventory")

local Ids = require("data.generated.ids")
local create = dofile("tools/oe/create.lua")

create(require("data.buffs"), dofile("tools/oe/kinds/buffs.lua"), Ids.buffs)
create(require("data.abilities"), dofile("tools/oe/kinds/abilities.lua"), Ids.abilities)
create(require("data.units"), dofile("tools/oe/kinds/units.lua"), Ids.units)
create(require("data.items"), dofile("tools/oe/kinds/items.lua"), Ids.items)
