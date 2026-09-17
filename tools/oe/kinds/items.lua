local shared = dofile("tools/oe/kinds/_shared.lua")

local reserved = {
    parent = true,
    apply = true,
    unit = true,
    unique = true,
    corpseOf = true,
}

local fields = {
    name = function(item, value)
        item:setName(value)
    end,
    art = function(item, value)
        shared.applySubfields(item, value, {
            icon = function(item, path)
                item:setInterfaceIcon(shared.normalizePath(path))
            end,
        }, "art")
    end,
    abilities = function(item, slugs)
        local parts = {}
        for _, slug in ipairs(slugs) do
            parts[#parts + 1] = shared.resolveAbilityId(slug)
        end
        item:setAbilities(table.concat(parts, ","))
    end,
}

local function applyFields(item, data, slug)
    for key, value in pairs(data) do
        if not reserved[key] then
            local handler = fields[key]
            if not handler then
                error("unknown item field '" .. key .. "' on " .. slug)
            end
            handler(item, value)
        end
    end
end

local function defaults(item, data)
    if not data.corpseOf then
        return
    end

    item:setAbilities("")
    item:setGoldCost(0)
    item:setLumberCost(0)
    item:setActivelyUsed(false)
    item:setPerishable(false)
    item:setCanBeDropped(true)
    --item:setCanBeSoldByMerchants(false)
    --item:setCanBeSoldToMerchants(false)
end

return {
    resolve = function()
        return {
            new = function(id, parent)
                return ItemDefinition:new(id, parent)
            end,
        }
    end,
    defaults = defaults,
    applyFields = applyFields,
}
