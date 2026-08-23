local AbilityIds = require("lib.community.types.assets.AbilityIds")
local Ids = require("data.generated.ids")

local reserved = {
    parent = true,
    apply = true,
}

local fields = {
    name = function(a, value)
        a:setName(value)
    end,
    autocastRange = function(a, value)
        a:setAutocastRange(1, value)
    end,
    options = function(a, value)
        a:setOptions(1, value)
    end,
    buttonNormalX = function(a, value)
        a:setButtonPositionNormalX(value)
    end,
    buttonNormalY = function(a, value)
        a:setButtonPositionNormalY(value)
    end,
    levels = function(a, value)
        a:setLevels(value)
    end,
    buffs = function(a, slugs, data)
        local parts = {}
        for _, slug in ipairs(slugs) do
            local id = Ids.buffs[slug]
            if not id then
                error("unknown buff '" .. slug .. "'")
            end
            parts[#parts + 1] = id
        end
        local levels = data.levels or 1
        for level = 1, levels do
            a:setBuffs(level, table.concat(parts, ","))
        end
    end,
}

local function applyFields(a, data, slug)
    for key, value in pairs(data) do
        if not reserved[key] then
            local handler = fields[key]
            if not handler then
                error("unknown ability field '" .. key .. "' on " .. slug)
            end
            handler(a, value, data)
        end
    end
end

local fallback = {
    new = function(id, parent)
        return AbilityDefinition:new(id, parent)
    end,
}

local byParent = {
    [AbilityIds.inventory] = {
        new = function(id, parent)
            return AbilityInventory:new(id, parent)
        end,
        apply = function(a)
            a:setCanUseItems(1, false)
        end,
    },
    [AbilityIds.innerFire] = {
        new = function(id)
            return AbilityDefinitionInnerFire:new(id)
        end,
    },
    [AbilityIds.itemDamageBonus] = {
        new = function(id)
            return AbilityDefinitionAttackBonus:new(id)
        end,
    },
    [AbilityIds.evasion] = {
        new = function(id)
            return AbilityDefinitionEvasion:new(id)
        end,
    },
    [AbilityIds.exhume] = {
        new = function(id)
            return AbilityDefinitionExhume:new(id)
        end,
    },
    [AbilityIds.bloodlust] = {
        new = function(id)
            return AbilityDefinitionBloodlust:new(id)
        end,
    },
    [AbilityIds.channel] = {
        new = function(id)
            return AbilityDefinitionIllidanChannel:new(id)
        end,
    },
}

return {
    resolve = function(parent)
        return byParent[parent] or fallback
    end,
    defaults = function(a)
        a:setHeroAbility(false)
    end,
    applyFields = applyFields,
}
