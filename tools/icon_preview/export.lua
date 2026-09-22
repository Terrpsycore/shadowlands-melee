--- Export icon catalog + unit command cards to tools/icon_preview/.cache/manifest.json
--- Usage: lua tools/icon_preview/export.lua

local pathMod = dofile("tools/_path.lua")
local root = pathMod.setup()
local assets = dofile("tools/icon_preview/assets.lua")

local OUT_DIR = root .. "/tools/icon_preview/.cache"
local MANIFEST_PATH = OUT_DIR .. "/manifest.json"

local ASSETS_ROOT = assets.resolveAssetsRoot(nil, root)

local function sourceFilePath(modulePath)
    return root .. "/src/" .. modulePath:gsub("%.", "/") .. ".lua"
end

local function loadSlugOrder(modulePath)
    local path = sourceFilePath(modulePath)
    local file = io.open(path, "r")
    if not file then
        return nil, ("unit source not found: %s"):format(path)
    end

    local slugs = {}
    for line in file:lines() do
        local slug = line:match("^%s*([_%w]+)%s*=%s*{")
        if slug then
            slugs[#slugs + 1] = slug
        end
    end
    file:close()
    return slugs
end

local function ensureDir(dir)
    dir = dir:gsub("/", "\\")
    os.execute('if not exist "' .. dir .. '" mkdir "' .. dir .. '"')
end

local function jsonEscape(value)
    return (value:gsub("\\", "\\\\"):gsub('"', '\\"'):gsub("\n", "\\n"):gsub("\r", "\\r"))
end

local function jsonString(value)
    return '"' .. jsonEscape(tostring(value)) .. '"'
end

local function jsonEncode(value, indent)
    indent = indent or 0
    local pad = string.rep("  ", indent)
    local padInner = string.rep("  ", indent + 1)
    local t = type(value)

    if t == "nil" then
        return "null"
    end
    if t == "boolean" or t == "number" then
        return tostring(value)
    end
    if t == "string" then
        return jsonString(value)
    end
    if t == "table" then
        local isArray = true
        local maxIndex = 0
        for k in pairs(value) do
            if type(k) ~= "number" then
                isArray = false
                break
            end
            if k > maxIndex then
                maxIndex = k
            end
        end
        if isArray and maxIndex == #value then
            local parts = {}
            for i = 1, #value do
                parts[#parts + 1] = padInner .. jsonEncode(value[i], indent + 1)
            end
            if #parts == 0 then
                return "[]"
            end
            return "[\n" .. table.concat(parts, ",\n") .. "\n" .. pad .. "]"
        end

        local keys = {}
        for k in pairs(value) do
            keys[#keys + 1] = k
        end
        table.sort(keys, function(a, b)
            return tostring(a) < tostring(b)
        end)

        local parts = {}
        for _, k in ipairs(keys) do
            parts[#parts + 1] = padInner .. jsonString(tostring(k)) .. ": " .. jsonEncode(value[k], indent + 1)
        end
        if #parts == 0 then
            return "{}"
        end
        return "{\n" .. table.concat(parts, ",\n") .. "\n" .. pad .. "}"
    end

    error("unsupported json type: " .. t)
end

local function resolveArtValue(value, icons, pathToKey)
    if type(value) ~= "string" or value == "" then
        return nil, nil, nil
    end
    local normalized = assets.normalizeSlashes(value)
    local key = assets.resolveIconKey(normalized, pathToKey)
    if key and icons[key] then
        return icons[key], key, assets.pathToIconsExpr(normalized, pathToKey)
    end
    return normalized, key, nil
end

local function defaultButton(row)
    if row.button then
        return row.button[1], row.button[2]
    end
    return 0, 2
end

local function loadData()
    local okAbilities, Abilities = pcall(require, "data.abilities")
    if not okAbilities then
        error("failed to load data.abilities (run bake first): " .. tostring(Abilities))
    end

    local okUnits, Units = pcall(require, "data.units")
    if not okUnits then
        error("failed to load data.units: " .. tostring(Units))
    end

    return Abilities, Units
end

local function buildIconList(icons, pathToKey)
    local list = {}
    for key, iconPath in pairs(icons) do
        list[#list + 1] = {
            key = key,
            path = iconPath,
            folder = assets.iconFolder(iconPath),
            iconExpr = assets.pathToIconsExpr(iconPath, pathToKey) or ("Icons." .. key),
        }
    end
    table.sort(list, function(a, b)
        return a.key < b.key
    end)
    return list
end

local function buildAbilityIndex(Abilities, icons, pathToKey, parentIcons)
    local index = {}

    for slug, row in pairs(Abilities) do
        local iconPath, iconKey, iconExpr, iconSource = nil, nil, nil, "missing"
        local iconOffPath, iconOffKey = nil, nil
        local iconResearchPath, iconResearchKey = nil, nil

        if row.art then
            iconPath, iconKey, iconExpr = resolveArtValue(row.art.icon, icons, pathToKey)
            if iconPath then
                iconSource = "explicit"
            end
            iconOffPath, iconOffKey = resolveArtValue(row.art.iconOff, icons, pathToKey)
            iconResearchPath, iconResearchKey = resolveArtValue(row.art.iconResearch, icons, pathToKey)
        end

        if not iconPath and row.parent and parentIcons[row.parent] then
            iconPath = parentIcons[row.parent]
            iconKey = assets.resolveIconKey(iconPath, pathToKey)
            iconExpr = assets.pathToIconsExpr(iconPath, pathToKey)
            iconSource = "parent"
        end

        local bx, by = defaultButton(row)
        index[slug] = {
            slug = slug,
            name = row.name or slug,
            parent = row.parent,
            class = row.class,
            button = { bx, by },
            iconPath = iconPath,
            iconKey = iconKey,
            iconExpr = iconExpr,
            iconSource = iconSource,
            iconOffPath = iconOffPath,
            iconOffKey = iconOffKey,
            iconResearchPath = iconResearchPath,
            iconResearchKey = iconResearchKey,
        }
    end

    return index
end

local function slotKey(x, y)
    return x .. "," .. y
end

local MAX_BUTTON_COL = 3

local PREVIEW_HIDDEN = {
    inventory = true,
}

local function hasDisplayIcon(ability)
    return ability.iconKey ~= nil and ability.iconSource ~= "missing"
end

local function allocateDisplaySlot(occupied, x, y)
    local dx = x
    while occupied[slotKey(dx, y)] and dx < MAX_BUTTON_COL do
        dx = dx + 1
    end
    occupied[slotKey(dx, y)] = true
    return dx, y, dx ~= x
end

local function buildAbilityGroups(row, abilityIndex, slug, warnings)
    local groups = {}
    if row.abilities and #row.abilities > 0 then
        groups[#groups + 1] = { kind = "unit", slugs = row.abilities }
    end
    if row.heroAbilities and #row.heroAbilities > 0 then
        groups[#groups + 1] = { kind = "hero", slugs = row.heroAbilities }
    end

    local builtGroups = {}

    for _, group in ipairs(groups) do
        local slots = {}
        local occupied = {}

        for _, abilitySlug in ipairs(group.slugs) do
            local ability = abilityIndex[abilitySlug]
            if not ability then
                warnings[#warnings + 1] = {
                    kind = "missingAbility",
                    unit = slug,
                    ability = abilitySlug,
                    message = ("unit '%s' references unknown ability '%s'"):format(slug, abilitySlug),
                }
            elseif not PREVIEW_HIDDEN[abilitySlug] and hasDisplayIcon(ability) then
                local declaredX, declaredY = ability.button[1], ability.button[2]
                local x, y, shifted = allocateDisplaySlot(occupied, declaredX, declaredY)

                slots[#slots + 1] = {
                    ability = abilitySlug,
                    name = ability.name,
                    declaredButton = { declaredX, declaredY },
                    x = x,
                    y = y,
                    shifted = shifted,
                    iconPath = ability.iconPath,
                    iconKey = ability.iconKey,
                    iconExpr = ability.iconExpr,
                    iconSource = ability.iconSource,
                }
            end
        end

        table.sort(slots, function(a, b)
            if a.y == b.y then
                return a.x < b.x
            end
            return a.y < b.y
        end)

        builtGroups[#builtGroups + 1] = {
            kind = group.kind,
            slots = slots,
        }
    end

    return builtGroups
end

local function buildUnitCard(slug, row, abilityIndex, unitParentIcons, icons, pathToKey, warnings)
    local iconPath, iconKey, iconExpr, iconSource = assets.resolveUnitPortrait(
        row,
        unitParentIcons,
        icons,
        pathToKey
    )

    local card = {
        slug = slug,
        name = row.name or slug,
        faction = row.faction,
        class = row.class,
        parent = row.parent,
        iconPath = iconPath,
        iconKey = iconKey,
        iconExpr = iconExpr,
        iconSource = iconSource,
        groups = buildAbilityGroups(row, abilityIndex, slug, warnings),
    }

    return card
end

local function buildUnitCards(Units, abilityIndex, unitParentIcons, icons, pathToKey)
    local cards = {}
    local warnings = {}
    local seen = {}
    local unitSources = require("data.units._sources")

    local function appendCard(slug, row)
        if not row.faction or seen[slug] then
            return
        end
        seen[slug] = true
        cards[#cards + 1] = buildUnitCard(
            slug,
            row,
            abilityIndex,
            unitParentIcons,
            icons,
            pathToKey,
            warnings
        )
    end

    for _, source in ipairs(unitSources) do
        local slugs, slugErr = loadSlugOrder(source.path)
        if not slugs then
            error(slugErr)
        end

        for _, slug in ipairs(slugs) do
            local row = Units[slug]
            if row then
                appendCard(slug, row)
            end
        end
    end

    for slug, row in pairs(Units) do
        appendCard(slug, row)
    end

    table.sort(warnings, function(a, b)
        return a.message < b.message
    end)

    return cards, warnings
end

local function main()
    local metadataPath = ASSETS_ROOT .. "\\units\\abilityskin.txt"
    local metadata = io.open(metadataPath, "r")
    if not metadata then
        error("WC3_ASSETS not found or incomplete (missing abilityskin.txt): " .. ASSETS_ROOT)
    end
    metadata:close()

    local icons, pathToKey = assets.buildIconRegistry(ASSETS_ROOT)

    local parentIcons, parentErr = assets.collectAbilityParentIcons(ASSETS_ROOT)
    if parentErr then
        error("failed to read abilityskin.txt: " .. tostring(parentErr))
    end

    local unitParentIcons, unitParentErr = assets.collectUnitParentIcons(ASSETS_ROOT)
    if unitParentErr then
        error("failed to read unitskin.txt: " .. tostring(unitParentErr))
    end

    local Abilities, Units = loadData()
    local abilityIndex = buildAbilityIndex(Abilities, icons, pathToKey, parentIcons)
    local iconList = buildIconList(icons, pathToKey)
    local unitCards, warnings = buildUnitCards(Units, abilityIndex, unitParentIcons, icons, pathToKey)

    local manifest = {
        generatedAt = os.date("!%Y-%m-%dT%H:%M:%SZ"),
        assetsRoot = ASSETS_ROOT,
        icons = iconList,
        abilities = abilityIndex,
        units = unitCards,
        warnings = warnings,
    }

    ensureDir(OUT_DIR)
    local out = assert(io.open(MANIFEST_PATH, "w"))
    out:write(jsonEncode(manifest))
    out:write("\n")
    out:close()

    print(("icon preview manifest: %s"):format(MANIFEST_PATH))
    print(("  icons: %d"):format(#iconList))
    print(("  abilities: %d"):format((function(t)
        local n = 0
        for _ in pairs(t) do
            n = n + 1
        end
        return n
    end)(abilityIndex)))
    print(("  units: %d"):format(#unitCards))
    print(("  warnings: %d"):format(#warnings))
end

main()
