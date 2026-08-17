return {
    resolve = function()
        return {
            new = function(id, parent)
                return UnitDefinition:new(id, parent)
            end,
        }
    end,
    defaults = function(u)
        -- u:setNormalAbilities("")
    end,
}
