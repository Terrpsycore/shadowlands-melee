local Ids = require("data.generated.ids")
local shared = dofile("tools/oe/kinds/_shared.lua")

local reserved = {
    parent = true,
    class = true,
    apply = true,
}

local function resolveUnitIdList(slugs)
    local parts = {}
    for _, slug in ipairs(slugs) do
        local id = Ids.units[slug]
        if not id then
            error("unknown unit '" .. slug .. "'")
        end
        parts[#parts + 1] = id
    end
    return table.concat(parts, ",")
end

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
    structuresBuilt = function(u, slugs)
        u:setStructuresBuilt(resolveUnitIdList(slugs))
    end,
    unitsTrained = function(u, slugs)
        u:setUnitsTrained(resolveUnitIdList(slugs))
    end,
    revivesDeadHeros = function(u, flag)
        u:setRevivesDeadHeros(flag)
    end,
    classification = function(u, value)
        u:setUnitClassification(value)
    end,
    mana = function(u, value)
        shared.applySubfields(u, value, {
            max = function(u, v)
                u:setManaMaximum(v)
            end,
            initial = function(u, v)
                u:setManaInitialAmount(v)
            end,
        }, "mana")
    end,
    cost = function(u, value)
        shared.applySubfields(u, value, {
            gold = function(u, v)
                u:setGoldCost(v)
            end,
            lumber = function(u, v)
                u:setLumberCost(v)
            end,
            food = function(u, v)
                u:setFoodCost(v)
            end,
        }, "cost")
    end,
    attack1 = function(u, value)
        shared.applySubfields(u, value, {
            type = function(u, v)
                u:setAttack1AttackType(v)
            end,
            weapon = function(u, v)
                u:setAttack1WeaponType(v)
            end,
            range = function(u, v)
                u:setAttack1Range(v)
            end,
            cooldown = function(u, v)
                u:setAttack1CooldownTime(v)
            end,
            damageBase = function(u, v)
                u:setAttack1DamageBase(v)
            end,
            weaponSound = function(u, v)
                u:setAttack1WeaponSound(v)
            end,
            targetsAllowed = function(u, v)
                u:setAttack1TargetsAllowed(v)
            end,
        }, "attack1")
    end,
    art = function(u, value)
        shared.applySubfields(u, value, {
            model = function(u, v)
                u:setModelFile(shared.normalizePath(v))
            end,
            icon = function(u, v)
                u:setIconGameInterface(shared.normalizePath(v))
            end,
            scale = function(u, v)
                u:setScalingValue(v)
            end,
        }, "art")
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
