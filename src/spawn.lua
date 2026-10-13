local Ids = require("data.ids")
local Units = require("data.units")
local Triggers = require("lib.triggers.callbacks")
local Dummy = require("utils.dummy")
local Unit = require("utils.unit")

local DeathStorage = require("scenario.storage.death")

local x, y, f = 219.4, -90.4, 293.630
local p0, p1 = Player(0), Player(1)

local skip = {
    aspirantMelee = true,
    memorySpirit = true,
    warBanner = true,
    opressiveBanner = true,
}

local function shouldSpawn(slug, row)
    if row.class == "building" then
        return false
    end
    if skip[slug] then
        return false
    end
    if slug:find("Flying") then
        return false
    end
    if slug:find("^ascended") then
        return false
    end
    return true
end

local function spawnSlug(player, slug, row)
    local id = Ids.units[slug]
    if not id then
        return
    end

    local unit = CreateUnit(player, FourCC(id), x, y, f)
    -- Triggers.fireEvent("CREATE", { target = unit })

    if row.heroAbilities then
        -- SetHeroLevel(unit, 10, false)
    end
    if slug == "phalynx" then
        require("scenario.storage.phalynx"):add(unit)
    end
end

local CORPSE_CLUSTER_RADIUS = 56

local kyrianCorpses = { "aspirant", "larion", "purity", "wisdom", "loyalty" }
local necrolordCorpses = { "animateWarrior", "gladiator", "scavenger", "necromancer", "bonestorm" }

local function finishFakeDeath(unit, px, py)
    Timed.call(0.1, function()
        for _, corpse in ipairs(Unit.getCorpsesInRadius({ x = px, y = py }, 48)) do
            local info = DeathStorage:bind(corpse)
            if info and info.unit == unit then
                -- UnitSuspendDecay(corpse, true)
                -- DeathStorage:set(corpse, "reviveAfter", 0)
                return
            end
        end
    end)
end

local function spawnCorpseCluster(player, slugs, centerX, centerY)
    local count = #slugs
    for i, slug in ipairs(slugs) do
        local id = Ids.units[slug]
        if id then
            local angle = (i - 1) * (360 / count)
            local rad = math.rad(angle)
            local px = centerX + CORPSE_CLUSTER_RADIUS * math.cos(rad)
            local py = centerY + CORPSE_CLUSTER_RADIUS * math.sin(rad)
            local unit = CreateUnit(player, FourCC(id), px, py, GetRandomReal(0, 360))
            Damage.apply(unit, unit, 99999, false, false, ATTACK_TYPE_CHAOS, DAMAGE_TYPE_ENHANCED)
            -- finishFakeDeath(unit, px, py)
        end
    end
end

local function spawnFaction(faction)
    local slugs = {}
    for slug, row in pairs(Units) do
        if row.faction == faction and shouldSpawn(slug, row) then
            slugs[#slugs + 1] = slug
        end
    end
    table.sort(slugs)

    for _, slug in ipairs(slugs) do
        spawnSlug(p0, slug, Units[slug])
    end
end

local packs = {
    kyrian = function()
        spawnFaction("kyrian")
    end,
    necrolord = function()
        spawnFaction("necrolord")
    end,
    fae = function()
        spawnFaction("fae")
    end,
    venthyr = function()
        spawnFaction("venthyr")
    end,
    mawsworn = function()
        CreateUnit(p0, FourCC(Ids.units.mawswornCage), x - 50, y - 50, f)
        CreateUnit(p0, FourCC(Ids.units.mawswornMechBarracks), x + 200, y + 200, f)
        CreateItem(FourCC(Ids.items.soulkeeper0), x, y)
        spawnFaction("mawsworn")
    end,
    corpses = function()
        spawnCorpseCluster(p1, kyrianCorpses, x - 180, y)
        spawnCorpseCluster(p1, necrolordCorpses, x + 180, y)
    end,
    enemies = function()
        CreateUnit(p1, FourCC(Ids.units.aspirant), -1000.4, y, f)
        CreateUnit(p1, FourCC(Ids.units.aspirant), -1000.4, y, f)
        CreateUnit(p1, FourCC(Ids.units.shade), -1000.4, y, f)

        local i = CreateUnit(p1, FourCC(Ids.units.dummyInvis), -1000.4, y, f)
        IssueImmediateOrder(i, "windwalk")
        IssueImmediateOrder(i, "hold")

        local e = CreateUnit(p1, FourCC(Ids.units.aspirant), x, y, f)
        BlzSetUnitMaxHP(e, 1)

        local g = CreateUnit(p0, FourCC(Ids.units.footman), x, y, f)
        SetUnitState(g, UNIT_STATE_LIFE, 1)
        local g = CreateUnit(p0, FourCC(Ids.units.footman), x, y, f)
        SetUnitState(g, UNIT_STATE_LIFE, 1)
        local g = CreateUnit(p0, FourCC(Ids.units.footman), x, y, f)
        SetUnitState(g, UNIT_STATE_LIFE, 1)

        CreateItemLoc(FourCC(Ids.items.dummyHeroItem), Location(200, -100))

        local footman = CreateUnit(p1, FourCC(Ids.units.footman), -1500.4, y + 1000, f)
        BlzSetUnitMaxMana(footman, 300)

        local t = CreateUnit(p1, FourCC(Ids.units.dummyTank), x, y + 1500, f)
        -- Dummy.applyDummyOrder(p0, t, FourCC(Ids.abilities.exhaustionDebuff), "acidbomb")
        CreateUnit(p1, FourCC(Ids.units.priest), x, y + 1500, f)
        CreateUnit(p1, FourCC(Ids.units.priest), x, y + 1500, f)
        -- CreateUnit(p1, FourCC(Ids.units.priest), x, y + 1500, f)
        local p = CreateUnit(p1, FourCC(Ids.units.priest), x, y + 1500, f)
        SetUnitState(p, UNIT_STATE_MAX_MANA, 1)
        BlzSetUnitMaxMana(p, 0)
    end,
}

local function run(names)
    Debug.original.print("Hello warcraft-vscode !")

    for _, name in ipairs(names) do
        local pack = packs[name]
        if not pack then
            error("unknown spawn pack: " .. tostring(name))
        end
        pack()
    end

    Debug.original.print("IngameConsole:", IngameConsole ~= nil)

    SetPlayerState(p0, PLAYER_STATE_RESOURCE_GOLD, 100000)
    SetPlayerState(p0, PLAYER_STATE_RESOURCE_LUMBER, 100000)
    SetPlayerState(p0, PLAYER_STATE_RESOURCE_FOOD_CAP, 70)
end

return {
    run = run,
}
