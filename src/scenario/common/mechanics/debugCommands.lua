local Ids = require("data.ids")
local Selection = require("scenario.common.mechanics.selection")
local Storage = require("lib.storage.storage")
local Spawn = require("spawn")

local function trim(msg)
    return (string.gsub(msg, "^%s*(.-)%s*$", "%1"))
end

local function say(player, text)
    DisplayTextToPlayer(player, 0, 0, text)
end

local function collectAllUnits()
    local list = {}
    local g = CreateGroup()
    for i = 0, bj_MAX_PLAYER_SLOTS - 1 do
        GroupEnumUnitsOfPlayer(g, Player(i), nil)
    end
    ForGroup(g, function()
        table.insert(list, GetEnumUnit())
    end)
    DestroyGroup(g)
    return list
end

local function gameClean(player)
    local units = collectAllUnits()
    for _, unit in ipairs(units) do
        RemoveUnit(unit)
    end
    Storage.initAll()
    say(player, "Debug: map units removed.")
end

local function gameSpawn(player, packName)
    local ok, err = pcall(function()
        Spawn.run({ packName })
    end)
    if not ok then
        say(player, "Debug: spawn failed — " .. tostring(err))
        return
    end
    say(player, "Debug: spawned pack \"" .. packName .. "\".")
end

local function resetCooldowns(player, unit)
    local index = 0
    while true do
        local abilId = BlzGetUnitAbilityByIndex(unit, index)
        if not abilId or abilId == 0 then
            break
        end
        BlzEndUnitAbilityCooldown(unit, abilId)
        index = index + 1
    end
    say(player, "Debug: ability cooldowns reset.")
end

local function setHeroLevel(player, unit, level)
    if not IsUnitType(unit, UNIT_TYPE_HERO) then
        say(player, "Debug: selected unit is not a hero.")
        return
    end
    SetHeroLevel(unit, level, false)
    say(player, "Debug: hero level set to " .. level .. ".")
end

local function setUnitHp(player, unit, value)
    local max = GetUnitState(unit, UNIT_STATE_MAX_LIFE)
    value = math.max(0, math.min(max, value))
    SetUnitState(unit, UNIT_STATE_LIFE, value)
    say(player, "Debug: HP set to " .. value .. ".")
end

local function setUnitMp(player, unit, value)
    local max = GetUnitState(unit, UNIT_STATE_MAX_MANA)
    value = math.max(0, math.min(max, value))
    SetUnitState(unit, UNIT_STATE_MANA, value)
    say(player, "Debug: MP set to " .. value .. ".")
end

local function setUnitMaxHp(player, unit, value)
    value = math.max(0, value)
    BlzSetUnitMaxHP(unit, value)
    local life = GetUnitState(unit, UNIT_STATE_LIFE)
    if life > value then
        SetUnitState(unit, UNIT_STATE_LIFE, value)
    end
    say(player, "Debug: max HP set to " .. value .. ".")
end

local function setUnitMaxMp(player, unit, value)
    value = math.max(0, value)
    BlzSetUnitMaxMana(unit, value)
    local mana = GetUnitState(unit, UNIT_STATE_MANA)
    if mana > value then
        SetUnitState(unit, UNIT_STATE_MANA, value)
    end
    say(player, "Debug: max MP set to " .. value .. ".")
end

local function rootUnit(player, unit)
    SetUnitPropWindow(unit, 0)
    say(player, "Debug: prop window set to 0 (root).")
end

local function unrootUnit(player, unit)
    SetUnitPropWindow(unit, GetUnitDefaultPropWindow(unit))
    say(player, "Debug: prop window restored to default.")
end

local function removeSelectedUnit(player, unit)
    RemoveUnit(unit)
    say(player, "Debug: unit removed.")
end

local function spawnUnitSlug(player, anchor, slug)
    local unitId = Ids.units[slug]
    if not unitId then
        say(player, "Debug: unknown unit slug \"" .. slug .. "\".")
        return
    end
    CreateUnit(
        GetOwningPlayer(anchor),
        FourCC(unitId),
        GetUnitX(anchor),
        GetUnitY(anchor),
        GetUnitFacing(anchor)
    )
    say(player, "Debug: spawned \"" .. slug .. "\".")
end

local function setUnitOwnerIndex(player, unit, ownerIndex)
    if ownerIndex < 0 or ownerIndex >= bj_MAX_PLAYER_SLOTS then
        say(player, "Debug: owner index must be 0-" .. (bj_MAX_PLAYER_SLOTS - 1) .. ".")
        return
    end
    SetUnitOwner(unit, Player(ownerIndex), true)
    say(player, "Debug: owner set to player " .. ownerIndex .. ".")
end

local function onChat()
    local player = GetTriggerPlayer()
    local msg = trim(GetEventPlayerChatString())

    if msg == "game clean" then
        gameClean(player)
        return
    end

    local packName = string.match(msg, "^game spawn (%S+)$")
    if packName then
        gameSpawn(player, packName)
        return
    end

    if msg == "cd reset" then
        local unit = Selection.getUnit()
        if not unit then
            say(player, "Debug: no unit selected.")
            return
        end
        resetCooldowns(player, unit)
        return
    end

    local levelStr = string.match(msg, "^level (%d+)$")
    if levelStr then
        local level = tonumber(levelStr)
        if not level or level < 1 or level > 10 then
            say(player, "Debug: level must be 1-10.")
            return
        end
        local unit = Selection.getUnit()
        if not unit then
            say(player, "Debug: no unit selected.")
            return
        end
        setHeroLevel(player, unit, level)
        return
    end

    local hpStr = string.match(msg, "^hp (%d+%.?%d*)$")
    if hpStr then
        local unit = Selection.getUnit()
        if not unit then
            say(player, "Debug: no unit selected.")
            return
        end
        setUnitHp(player, unit, tonumber(hpStr))
        return
    end

    local mpStr = string.match(msg, "^mp (%d+%.?%d*)$")
    if mpStr then
        local unit = Selection.getUnit()
        if not unit then
            say(player, "Debug: no unit selected.")
            return
        end
        setUnitMp(player, unit, tonumber(mpStr))
        return
    end

    local maxHpStr = string.match(msg, "^maxHp (%d+%.?%d*)$")
    if maxHpStr then
        local unit = Selection.getUnit()
        if not unit then
            say(player, "Debug: no unit selected.")
            return
        end
        setUnitMaxHp(player, unit, tonumber(maxHpStr))
        return
    end

    local maxMpStr = string.match(msg, "^maxMp (%d+%.?%d*)$")
    if maxMpStr then
        local unit = Selection.getUnit()
        if not unit then
            say(player, "Debug: no unit selected.")
            return
        end
        setUnitMaxMp(player, unit, tonumber(maxMpStr))
        return
    end

    if msg == "root" then
        local unit = Selection.getUnit()
        if not unit then
            say(player, "Debug: no unit selected.")
            return
        end
        rootUnit(player, unit)
        return
    end

    if msg == "unroot" then
        local unit = Selection.getUnit()
        if not unit then
            say(player, "Debug: no unit selected.")
            return
        end
        unrootUnit(player, unit)
        return
    end

    if msg == "remove" then
        local unit = Selection.getUnit()
        if not unit then
            say(player, "Debug: no unit selected.")
            return
        end
        removeSelectedUnit(player, unit)
        return
    end

    local unitSlug = string.match(msg, "^spawn (%S+)$")
    if unitSlug then
        local unit = Selection.getUnit()
        if not unit then
            say(player, "Debug: no unit selected.")
            return
        end
        spawnUnitSlug(player, unit, unitSlug)
        return
    end

    local ownerStr = string.match(msg, "^owner (%d+)$")
    if ownerStr then
        local unit = Selection.getUnit()
        if not unit then
            say(player, "Debug: no unit selected.")
            return
        end
        setUnitOwnerIndex(player, unit, tonumber(ownerStr))
    end
end

return {
    triggers = {
        {
            trigger = "EVENT_PLAYER_CHAT",
            action = onChat,
        },
    },
}
