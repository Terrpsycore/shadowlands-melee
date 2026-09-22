--- Usage: lua tools/gen/validate_scenario.lua (or via tools/bake.lua)
--- Bake-time validation: scenario Ids/triggers, data ability buffs, unit abilities.

local root = dofile("tools/_path.lua").setup()

-- ids.lua may refresh the file after data.abilities already required an older copy
package.loaded["data.generated.ids"] = nil
local generated = dofile(root .. "/src/data/generated/ids.lua")
local registry = require("scenario.generated.abilities_registry")

local ID_DOMAINS = { abilities = true, buffs = true, units = true, items = true, upgrades = true }

local function readFile(path)
    local f, err = io.open(path, "r")
    if not f then
        error(path .. ": " .. tostring(err))
    end
    local src = f:read("*a")
    f:close()
    return src
end

local function loadTriggerEvents()
    local src = readFile(root .. "/src/lib/triggers/callbacks.lua")
    local events = {}
    local inBlock = false
    for line in src:gmatch("[^\r\n]+") do
        if not inBlock then
            if line:find("T%.methods%s*=%s*{") then
                inBlock = true
            end
        else
            if line:find("^}") then
                break
            end
            local event = line:match("^%s*([%w_]+)%s*=")
            if event then
                events[event] = true
            end
        end
    end
    if not next(events) then
        error("validate scenario: could not parse T.methods from callbacks.lua")
    end
    return events
end

local triggerEvents = loadTriggerEvents()

local function modulePath(mod)
    return root .. "/src/" .. mod:gsub("%.", "/") .. ".lua"
end

local function validateModule(mod)
    local path = modulePath(mod)
    local src = readFile(path)

    for domain, slug in src:gmatch("Ids%.(%w+)%.(%w+)") do
        if ID_DOMAINS[domain] then
            if not generated[domain] or generated[domain][slug] == nil then
                error(string.format("%s: Ids.%s.%s unknown slug", mod, domain, slug))
            end
        end
    end

    for event in src:gmatch('trigger%s*=%s*"([^"]+)"') do
        if not triggerEvents[event] then
            error(string.format('%s: unknown trigger event %q', mod, event))
        end
    end
end

for _, mod in ipairs(registry) do
    validateModule(mod)
end

local AbilityIds = require("vendor.assets.AbilityIds")
local AbilityBaseIds = require("data.abilityBaseIds")

local function assertAbilitySlug(slug, context)
    if generated.abilities[slug] or AbilityIds[slug] or AbilityBaseIds[slug] then
        return
    end
    error(string.format("%s: unknown ability %q", context, slug))
end

local function assertBuffSlug(slug, context)
    if generated.buffs[slug] then
        return
    end
    error(string.format("%s: unknown buff %q", context, slug))
end

local function validateUnitAbilities(slug, row)
    for _, abilitySlug in ipairs(row.abilities or {}) do
        assertAbilitySlug(abilitySlug, "units." .. slug .. ".abilities")
    end
    for _, abilitySlug in ipairs(row.heroAbilities or {}) do
        assertAbilitySlug(abilitySlug, "units." .. slug .. ".heroAbilities")
    end
end

local function validateAbilityBuffs(slug, row)
    for _, buffSlug in ipairs(row.buffs or {}) do
        assertBuffSlug(buffSlug, "abilities." .. slug .. ".buffs")
    end
end

local units = require("data.units")
local abilities = require("data.abilities")

local unitCount = 0
for unitSlug, row in pairs(units) do
    unitCount = unitCount + 1
    validateUnitAbilities(unitSlug, row)
end

local abilityCount = 0
for abilitySlug, row in pairs(abilities) do
    abilityCount = abilityCount + 1
    validateAbilityBuffs(abilitySlug, row)
end

print(("Validated %d scenario modules, %d units, %d abilities"):format(
    #registry,
    unitCount,
    abilityCount
))
