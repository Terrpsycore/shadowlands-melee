local ItemIds = require("vendor.assets.ItemIds")
local UnitArt = require("vendor.assets.generated.UnitArt")

local function resolveIcon(row)
    if row.art and row.art.icon then
        return row.art.icon:gsub("/", "\\")
    end

    local art = UnitArt[row.parent]
    if not art or not art.icon then
        error("no icon for unit parent '" .. row.parent .. "' in vendor.assets.generated.UnitArt")
    end
    return art.icon
end

local function build()
    local units = require("data.units")
    local db = {}

    local slugs = {}
    for slug in pairs(units) do
        slugs[#slugs + 1] = slug
    end
    table.sort(slugs)

    for _, unitSlug in ipairs(slugs) do
        local row = units[unitSlug]
        if row.class == "unit" or row.class == "dummy" then
            local itemSlug = unitSlug .. "Grabbed"
            local unitName = row.name or unitSlug
            db[itemSlug] = {
                parent = ItemIds.ringProtection1,
                name = unitName .. " (Grabbed)",
                art = {
                    icon = resolveIcon(row),
                },
                unit = true,
                apply = function(i)
                    i:setAbilities("")
                end,
            }
        end
    end

    return db
end

return {
    build = build,
}
