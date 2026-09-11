return {
    resolve = function()
        return {
            new = function(id, parent)
                return ItemDefinition:new(id, parent)
            end,
        }
    end,
    defaults = function() end,
}
