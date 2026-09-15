local Ids = require("data.ids")
local Units = require("data.units")
local Triggers = require("lib.triggers.callbacks")

local x, y, f = 219.4, -90.4, 293.630
local p0, p1 = Player(0), Player(1)

local skip = {
    aspirantMelee = true,
    memorySpirit = true,
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
    Triggers.fireEvent("CREATE", { target = unit })

    if row.heroAbilities then
        SetHeroLevel(unit, 10, false)
    end
    if slug == "phalynx" then
        require("scenario.storage.phalynx"):add(unit)
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
    enemies = function()
        CreateUnit(p1, FourCC(Ids.units.aspirant), -1000.4, y, f)
        CreateUnit(p1, FourCC(Ids.units.aspirant), -1000.4, y, f)
        CreateUnit(p1, FourCC(Ids.units.shade), -1000.4, y, f)

        local i = CreateUnit(p1, FourCC(Ids.units.dummyInvis), -1000.4, y, f)
        IssueImmediateOrder(i, "windwalk")
        IssueImmediateOrder(i, "hold")

        local e = CreateUnit(p1, FourCC(Ids.units.aspirant), x, y, f)
        BlzSetUnitMaxHP(e, 1)

        local g = CreateUnit(p0, FourCC(Ids.units.abomination), x, y, f)
        SetUnitState(g, UNIT_STATE_LIFE, 1)

        CreateItemLoc(FourCC(Ids.items.dummyHeroItem), Location(200, -100))
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
