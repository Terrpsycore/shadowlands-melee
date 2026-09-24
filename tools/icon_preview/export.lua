--- Export icon catalog and unit command cards to tools/icon_preview/.cache/
--- Usage:
---   lua tools/icon_preview/export.lua           # icons.json + units.json
---   lua tools/icon_preview/export.lua --icons   # icons.json only
---   lua tools/icon_preview/export.lua --units   # units.json only

local pathMod = dofile("tools/_path.lua")
local root = pathMod.setup()
local assets = dofile("tools/icon_preview/assets.lua")
local common = dofile("tools/icon_preview/export_common.lua")

local OUT_DIR = root .. "/tools/icon_preview/.cache"
local ICONS_PATH = OUT_DIR .. "/icons.json"
local UNITS_PATH = OUT_DIR .. "/units.json"

local ASSETS_ROOT = assets.resolveAssetsRoot(nil, root)
local mode = common.parseMode(arg)

local function loadSlugOrder(modulePath)
    local path = common.sourceFilePath(root, modulePath)
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

local function buildIconList(icons, pathToKey, customKeys, customIndex)
    local list = {}
    for key, iconPath in pairs(icons) do
        if assets.isDisIcon(key, iconPath) then
            goto continue
        end

        local isCustom = customKeys[key] == true
        local customRow = isCustom and customIndex[key] or nil
        local folder
        if isCustom and customRow and customRow.category then
            folder = customRow.category
        elseif isCustom then
            folder = "Custom"
        else
            folder = assets.iconFolder(iconPath)
        end

        local row = {
            key = key,
            path = iconPath,
            folder = folder,
            displayKey = (customRow and customRow.displayKey) or assets.displayKey(key),
            source = isCustom and "custom" or "vanilla",
            iconExpr = assets.pathToIconsExpr(iconPath, pathToKey) or ("Icons." .. key),
        }
        if isCustom and customRow then
            row.file = customRow.file
        end
        list[#list + 1] = row

        ::continue::
    end
    table.sort(list, function(a, b)
        return a.key < b.key
    end)
    return list
end

local function buildAbilityEntry(slug, row, icons, pathToKey, parentIcons)
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
    return {
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

local function collectReferencedAbilitySlugs(Units)
    local slugs = {}
    local seen = {}

    local function add(slug)
        if slug and not seen[slug] then
            seen[slug] = true
            slugs[#slugs + 1] = slug
        end
    end

    for _, row in pairs(Units) do
        if row.abilities then
            for _, abilitySlug in ipairs(row.abilities) do
                add(abilitySlug)
            end
        end
        if row.heroAbilities then
            for _, abilitySlug in ipairs(row.heroAbilities) do
                add(abilitySlug)
            end
        end
    end

    return slugs
end

local function buildAbilityIndex(Abilities, icons, pathToKey, parentIcons, onlySlugs)
    local index = {}

    if onlySlugs then
        for _, slug in ipairs(onlySlugs) do
            local row = Abilities[slug]
            if row then
                index[slug] = buildAbilityEntry(slug, row, icons, pathToKey, parentIcons)
            end
        end
        return index
    end

    for slug, row in pairs(Abilities) do
        index[slug] = buildAbilityEntry(slug, row, icons, pathToKey, parentIcons)
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

local DEFAULT_UNIT_ORDERS = {
    { order = "move", name = "Move", x = 0, y = 0, iconKey = "move" },
    { order = "stop", name = "Stop", x = 1, y = 0, iconKey = "stop" },
    { order = "holdPosition", name = "Hold Position", x = 2, y = 0, iconKey = "holdPosition" },
    { order = "attack", name = "Attack", x = 3, y = 0, iconKey = "attack" },
    { order = "patrol", name = "Patrol", x = 0, y = 1, iconKey = "patrol" },
}

local DEFAULT_HERO_ORDERS = {
    { order = "selectSkill", name = "Learn Skill", x = 3, y = 1, iconKey = "skillz" },
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

local function buildCommandCard(row, unitClass, abilityIndex, slug, warnings)
    local slots = {}
    local occupied = {}

    if unitClass ~= "building" then
        for _, order in ipairs(DEFAULT_UNIT_ORDERS) do
            occupied[slotKey(order.x, order.y)] = true
            slots[#slots + 1] = {
                kind = "order",
                order = order.order,
                name = order.name,
                x = order.x,
                y = order.y,
                iconKey = order.iconKey,
                iconExpr = "Icons." .. order.iconKey,
            }
        end
    end

    if unitClass == "hero" then
        for _, order in ipairs(DEFAULT_HERO_ORDERS) do
            occupied[slotKey(order.x, order.y)] = true
            slots[#slots + 1] = {
                kind = "order",
                order = order.order,
                name = order.name,
                x = order.x,
                y = order.y,
                iconKey = order.iconKey,
                iconExpr = "Icons." .. order.iconKey,
            }
        end
    end

    local slugs = {}
    if row.abilities then
        for _, abilitySlug in ipairs(row.abilities) do
            slugs[#slugs + 1] = abilitySlug
        end
    end
    if row.heroAbilities then
        for _, abilitySlug in ipairs(row.heroAbilities) do
            slugs[#slugs + 1] = abilitySlug
        end
    end

    for _, abilitySlug in ipairs(slugs) do
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
                kind = "ability",
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

    if #slots == 0 then
        return {}
    end

    return { { kind = "command", slots = slots } }
end

local function buildUnitCard(slug, row, abilityIndex, unitParentIcons, icons, pathToKey, warnings)
    local iconPath, iconKey, iconExpr, iconSource = assets.resolveUnitPortrait(
        row,
        unitParentIcons,
        icons,
        pathToKey
    )

    return {
        slug = slug,
        name = row.name or slug,
        faction = row.faction,
        class = row.class,
        parent = row.parent,
        iconPath = iconPath,
        iconKey = iconKey,
        iconExpr = iconExpr,
        iconSource = iconSource,
        groups = buildCommandCard(row, row.class, abilityIndex, slug, warnings),
    }
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

local function assertAssetsRoot()
    local metadataPath = ASSETS_ROOT .. "\\units\\abilityskin.txt"
    local metadata = io.open(metadataPath, "r")
    if not metadata then
        error("WC3_ASSETS not found or incomplete (missing abilityskin.txt): " .. ASSETS_ROOT)
    end
    metadata:close()
end

local function loadIconRegistry()
    assertAssetsRoot()
    return assets.buildIconRegistry(ASSETS_ROOT)
end

local function loadIconLookupFromIconsJson()
    local file = io.open(ICONS_PATH, "r")
    if not file then
        return nil
    end

    local content = file:read("*a")
    file:close()

    local icons = {}
    local pathToKey = {}
    for key, path in content:gmatch('"key"%s*:%s*"([^"]+)"[^}]*"path"%s*:%s*"([^"]+)"') do
        path = path:gsub("\\\\", "\\")
        icons[key] = path
        pathToKey[assets.normalizePathKey(path)] = key
    end

    if next(icons) == nil then
        return nil
    end

    return icons, pathToKey
end

local function loadIconLookupForUnits()
    assertAssetsRoot()

    local icons, pathToKey = loadIconLookupFromIconsJson()
    if icons then
        return icons, pathToKey
    end

    return assets.buildIconRegistry(ASSETS_ROOT, nil, { includeDiskScan = false })
end

local function exportIcons()
    local icons, pathToKey, customKeys, customIndex = loadIconRegistry()
    local customRoot = assets.resolveCustomRoot(root)
    local iconList = buildIconList(icons, pathToKey, customKeys, customIndex)
    local generatedAt = common.utcTimestamp()

    common.ensureDir(OUT_DIR)
    common.writeJson(ICONS_PATH, {
        generatedAt = generatedAt,
        assetsRoot = ASSETS_ROOT,
        customRoot = customRoot,
        icons = iconList,
    })
    common.writeStamp(ICONS_PATH, generatedAt)

    print(("icon preview icons: %s"):format(ICONS_PATH))
    print(("  icons: %d"):format(#iconList))
end

local function exportUnits()
    local icons, pathToKey = loadIconLookupForUnits()

    local parentIcons, parentErr = assets.collectAbilityParentIcons(ASSETS_ROOT)
    if parentErr then
        error("failed to read abilityskin.txt: " .. tostring(parentErr))
    end

    local unitParentIcons, unitParentErr = assets.collectUnitParentIcons(ASSETS_ROOT)
    if unitParentErr then
        error("failed to read unitskin.txt: " .. tostring(unitParentErr))
    end

    local Abilities, Units = loadData()
    local referencedSlugs = collectReferencedAbilitySlugs(Units)
    local abilityIndex = buildAbilityIndex(Abilities, icons, pathToKey, parentIcons, referencedSlugs)
    local unitCards, warnings = buildUnitCards(Units, abilityIndex, unitParentIcons, icons, pathToKey)
    local generatedAt = common.utcTimestamp()

    common.ensureDir(OUT_DIR)
    common.writeJson(UNITS_PATH, {
        generatedAt = generatedAt,
        units = unitCards,
        warnings = warnings,
    })
    common.writeStamp(UNITS_PATH, generatedAt)

    print(("icon preview units: %s"):format(UNITS_PATH))
    print(("  abilities (resolved): %d"):format(#referencedSlugs))
    print(("  units: %d"):format(#unitCards))
    print(("  warnings: %d"):format(#warnings))
end

if mode == "icons" then
    exportIcons()
elseif mode == "units" then
    exportUnits()
else
    exportIcons()
    exportUnits()
end
