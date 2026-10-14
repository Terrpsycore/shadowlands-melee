local Ids = require("data.ids")
local Abilities = require("lib.abilities")
local Selection = require("scenario.common.mechanics.selection")
local Storage = require("lib.storage.storage")
local Spawn = require("spawn")
local Dummy = require("utils.dummy")

local function trim(msg)
    return (string.gsub(msg, "^%s*(.-)%s*$", "%1"))
end

local function say(player, text)
    DisplayTextToPlayer(player, 0, 0, text)
end

local function withSelectedUnit(player, fn)
    local unit = Selection.getUnit()
    if not unit then
        say(player, "Debug: no unit selected.")
        return
    end
    fn(unit)
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
    say(player, 'Debug: spawned pack "' .. packName .. '".')
end

local function resetCooldowns(player, unit)
    local index = 0
    while true do
        local abil = BlzGetUnitAbilityByIndex(unit, index)
        if not abil then
            break
        end
        local abilId = BlzGetAbilityId(abil)
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
        say(player, 'Debug: unknown unit slug "' .. slug .. '".')
        return
    end
    CreateUnit(GetOwningPlayer(anchor), FourCC(unitId), GetUnitX(anchor), GetUnitY(anchor), GetUnitFacing(anchor))
    say(player, 'Debug: spawned "' .. slug .. '".')
end

local function setUnitOwnerIndex(player, unit, ownerIndex)
    if ownerIndex < 0 or ownerIndex >= bj_MAX_PLAYER_SLOTS then
        say(player, "Debug: owner index must be 0-" .. (bj_MAX_PLAYER_SLOTS - 1) .. ".")
        return
    end
    SetUnitOwner(unit, Player(ownerIndex), true)
    say(player, "Debug: owner set to player " .. ownerIndex .. ".")
end

local function resolveAbilityId(token)
    local slugId = Ids.abilities[token]
    if slugId then
        return FourCC(slugId)
    end
    if #token == 4 then
        return FourCC(token)
    end
    return nil
end

local function setDummyDefault(player, mode)
    if mode == 1 then
        Dummy.setDefault(FourCC(Ids.units.dummy))
        say(player, "Debug: dummy default = dummy (visible).")
    else
        Dummy.setDefault(FourCC(Ids.units.dummyHidden))
        say(player, "Debug: dummy default = dummyHidden.")
    end
end

local function applyDummyTargetOrder(player, ownerIndex, target, skillToken, order)
    if ownerIndex < 0 or ownerIndex >= bj_MAX_PLAYER_SLOTS then
        say(player, "Debug: owner index must be 0-" .. (bj_MAX_PLAYER_SLOTS - 1) .. ".")
        return
    end
    local abilityId = resolveAbilityId(skillToken)
    if not abilityId then
        say(player, 'Debug: unknown ability "' .. skillToken .. '" (slug or 4-char rawcode).')
        return
    end
    Dummy.applyDummyOrder(Player(ownerIndex), target, abilityId, order)
    say(player, 'Debug: cast "' .. order .. '" (owner ' .. ownerIndex .. ").")
end

---@param player player
---@param cmd table
---@param msg string
---@return boolean handled
local function runCommand(player, cmd, msg)
    local captures
    if cmd.exact then
        if msg ~= cmd.exact then
            return false
        end
        captures = {}
    else
        local cap = { string.match(msg, cmd.pattern) }
        if cap[1] == nil then
            return false
        end
        captures = cap
    end

    if cmd.needsUnit then
        withSelectedUnit(player, function(unit)
            cmd.run(player, unit, table.unpack(captures))
        end)
    else
        cmd.run(player, table.unpack(captures))
    end
    return true
end

local commands = {
    { exact = "game clean", run = gameClean },
    { pattern = "^game spawn (%S+)$", run = gameSpawn },
    { exact = "cd", needsUnit = true, run = resetCooldowns },
    {
        pattern = "^level (%d+)$",
        needsUnit = true,
        run = function(player, unit, levelStr)
            local level = tonumber(levelStr)
            if not level or level < 1 or level > 10 then
                say(player, "Debug: level must be 1-10.")
                return
            end
            setHeroLevel(player, unit, level)
        end,
    },
    {
        pattern = "^hp (%d+%.?%d*)$",
        needsUnit = true,
        run = function(player, unit, valueStr)
            setUnitHp(player, unit, tonumber(valueStr))
        end,
    },
    {
        pattern = "^mp (%d+%.?%d*)$",
        needsUnit = true,
        run = function(player, unit, valueStr)
            setUnitMp(player, unit, tonumber(valueStr))
        end,
    },
    {
        pattern = "^maxHp (%d+%.?%d*)$",
        needsUnit = true,
        run = function(player, unit, valueStr)
            setUnitMaxHp(player, unit, tonumber(valueStr))
        end,
    },
    {
        pattern = "^maxMp (%d+%.?%d*)$",
        needsUnit = true,
        run = function(player, unit, valueStr)
            setUnitMaxMp(player, unit, tonumber(valueStr))
        end,
    },
    { exact = "root", needsUnit = true, run = rootUnit },
    { exact = "unroot", needsUnit = true, run = unrootUnit },
    { exact = "remove", needsUnit = true, run = removeSelectedUnit },
    {
        pattern = "^spawn (%S+)$",
        needsUnit = true,
        run = function(player, unit, slug)
            spawnUnitSlug(player, unit, slug)
        end,
    },
    {
        pattern = "^dummy ([01])$",
        run = function(player, modeStr)
            setDummyDefault(player, tonumber(modeStr))
        end,
    },
    {
        pattern = "^cast (%d+) (%S+) (%S*)$",
        needsUnit = true,
        run = function(player, unit, ownerStr, skillToken, modeStr)
            local abilityId = resolveAbilityId(skillToken)
            if not abilityId then
                say(player, 'Debug: unknown ability "' .. skillToken .. '" (slug or 4-char rawcode).')
                return
            end
            local mode = modeStr ~= "" and modeStr or nil
            local ok, orderOrErr = pcall(Abilities.orderId, abilityId, mode)
            if not ok then
                say(player, "Debug: " .. tostring(orderOrErr))
                return
            end
            applyDummyTargetOrder(player, tonumber(ownerStr), unit, skillToken, orderOrErr)
        end,
    },
    {
        pattern = "^owner (%d+)$",
        needsUnit = true,
        run = function(player, unit, ownerStr)
            setUnitOwnerIndex(player, unit, tonumber(ownerStr))
        end,
    },
}

local function onChat()
    local player = GetTriggerPlayer()
    local msg = trim(GetEventPlayerChatString())
    for _, cmd in ipairs(commands) do
        if runCommand(player, cmd, msg) then
            return
        end
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
