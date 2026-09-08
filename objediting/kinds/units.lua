local Ids = require("data.generated.ids")

local reserved = {
    parent = true,
    class = true,
    apply = true,
}

local fields = {
    name = function(u, value)
        u:setName(value)
    end,
    abilities = function(u, slugs)
        local parts = {}
        for _, slug in ipairs(slugs) do
            local id = Ids.abilities[slug]
            if not id then
                error("unknown ability '" .. slug .. "'")
            end
            parts[#parts + 1] = id
        end
        u:setNormalAbilities(table.concat(parts, ","))
    end,
    heroAbilities = function(u, slugs)
        local parts = {}
        for _, slug in ipairs(slugs) do
            local id = Ids.abilities[slug]
            if not id then
                error("unknown ability '" .. slug .. "'")
            end
            parts[#parts + 1] = id
        end
        u:setHeroAbilities(table.concat(parts, ","))
    end,
}

local function applyFields(u, data, slug)
    for key, value in pairs(data) do
        if not reserved[key] then
            local handler = fields[key]
            if not handler then
                error("unknown unit field '" .. key .. "' on " .. slug)
            end
            handler(u, value)
        end
    end
end

local classMapping = {
    unit = UnitDefinition,
    hero = HeroDefinition,
    building = BuildingDefinition,
}

return {
    resolve = function()
        return {
            new = function(id, parent, class)
                local Definition = classMapping[class] or UnitDefinition
                return Definition:new(id, parent)
            end,
        }
    end,
    defaults = function(u)
        -- u:setNormalAbilities("")
    end,
    applyFields = applyFields,
}
