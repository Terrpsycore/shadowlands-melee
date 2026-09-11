local lastSelectedUnit = nil

local function onSelect()
    lastSelectedUnit = GetTriggerUnit()
end

local function getUnit()
    return lastSelectedUnit
end

return {
    getUnit = getUnit,
    triggers = {
        {
            trigger = "EVENT_PLAYER_UNIT_SELECTED",
            action = onSelect,
        },
    },
}
