--- Shared path helpers for icon preview (standalone, no asset_catalogs coupling).

local M = {}

local function trim(s)
    return (s:match("^%s*(.-)%s*$"))
end

function M.readDotEnv(repoRoot)
    local values = {}
    local path = repoRoot .. "/tools/icon_preview/.env"
    local f = io.open(path, "r")
    if not f then
        return values
    end
    for raw in f:lines() do
        local line = trim(raw)
        if line ~= "" and not line:match("^#") then
            local key, value = line:match("^([^=]+)=(.*)$")
            if key then
                key = trim(key)
                value = trim(value):gsub('^["\'](.-)["\']$', "%1")
                values[key] = value
            end
        end
    end
    f:close()
    return values
end

function M.resolveAssetsRoot(raw, repoRoot)
    local dotenv = repoRoot and M.readDotEnv(repoRoot) or {}
    raw = raw or os.getenv("WC3_ASSETS") or dotenv.WC3_ASSETS or "../wc3-assets"
    raw = raw:gsub("/", "\\")
    if raw:match("^%a:") then
        return raw
    end
    local p = io.popen('for %I in ("' .. raw .. '") do @echo %~fI')
    if p then
        local abs = p:read("*l")
        p:close()
        if abs and abs ~= "" then
            return abs:gsub("/", "\\")
        end
    end
    return raw
end

function M.normalizeSlashes(path)
    return path:gsub("/", "\\")
end

function M.normalizePathKey(path)
    return M.normalizeSlashes(path):lower()
end

function M.titleCase(s)
    return s:sub(1, 1):upper() .. s:sub(2)
end

function M.camelCase(s)
    s = s:gsub("[^%w]", "")
    if s == "" then
        return "unnamed"
    end
    return s:sub(1, 1):lower() .. s:sub(2)
end

function M.iconPathToKey(path)
    if type(path) ~= "string" or path == "" then
        return nil
    end
    path = M.normalizeSlashes(path)
    local name = path:match("[^\\]+$")
    if not name or name == "" then
        return nil
    end
    name = name:gsub("%.blp$", "")
    if name:sub(1, 6) == "PASBTN" then
        return "pas" .. M.titleCase(name:sub(7))
    end
    if name:sub(1, 3) == "BTN" then
        return M.camelCase(name:sub(4))
    end
    return M.camelCase(name)
end

function M.iconFileToEditorPath(subfolder, filename)
    local base = filename:gsub("%.dds$", ""):gsub("%.blp$", "")
    local lower = base:lower()

    if lower:sub(1, 6) == "pasbtn" then
        return ("ReplaceableTextures\\%s\\PASBTN%s.blp"):format(subfolder, M.titleCase(base:sub(7)))
    end
    if lower:sub(1, 3) == "btn" then
        return ("ReplaceableTextures\\%s\\BTN%s.blp"):format(subfolder, M.titleCase(base:sub(4)))
    end

    return ("ReplaceableTextures\\%s\\%s.blp"):format(subfolder, base)
end

function M.pickField(fields, name)
    if fields[name] and fields[name] ~= "" then
        return fields[name]
    end
    local sd = name .. ":sd"
    if fields[sd] and fields[sd] ~= "" then
        return fields[sd]
    end
    local hd = name .. ":hd"
    if fields[hd] and fields[hd] ~= "" then
        return fields[hd]
    end
    return nil
end

function M.parseIniSections(path)
    local f, err = io.open(path, "r")
    if not f then
        return nil, err
    end

    local sections = {}
    local currentId = nil
    for raw in f:lines() do
        local line = raw:match("^%s*(.-)%s*$")
        if line ~= "" and not line:match("^//") then
            local id = line:match("^%[(.+)%]$")
            if id then
                currentId = id
                sections[currentId] = sections[currentId] or {}
            elseif currentId then
                local key, value = line:match("^([^=]+)=(.*)$")
                if key then
                    key = key:match("^%s*(.-)%s*$")
                    sections[currentId][key] = value
                end
            end
        end
    end
    f:close()
    return sections
end

function M.collectAbilityParentIcons(assetsRoot)
    local path = assetsRoot .. "\\units\\abilityskin.txt"
    local sections, err = M.parseIniSections(path)
    if not sections then
        return {}, err
    end

    local out = {}
    for parentId, fields in pairs(sections) do
        local art = M.pickField(fields, "Art")
        if art then
            out[parentId] = M.normalizeSlashes(art)
        end
    end
    return out
end

function M.collectUnitParentIcons(assetsRoot)
    local path = assetsRoot .. "\\units\\unitskin.txt"
    local sections, err = M.parseIniSections(path)
    if not sections then
        return {}, err
    end

    local out = {}
    for parentId, fields in pairs(sections) do
        local art = M.pickField(fields, "Art")
        if art then
            out[parentId] = M.normalizeSlashes(art)
        end
    end
    return out
end

function M.resolveUnitPortrait(row, unitParentIcons, icons, pathToKey)
    local iconPath, iconKey, iconExpr, iconSource = nil, nil, nil, "missing"

    if row.art and type(row.art.icon) == "string" and row.art.icon ~= "" then
        local normalized = M.normalizeSlashes(row.art.icon)
        iconKey = M.resolveIconKey(normalized, pathToKey) or M.iconPathToKey(normalized)
        if iconKey and icons[iconKey] then
            iconPath = icons[iconKey]
        else
            iconPath = normalized
        end
        iconExpr = M.pathToIconsExpr(iconPath or normalized, pathToKey)
        iconSource = "explicit"
    elseif row.parent and unitParentIcons[row.parent] then
        iconPath = unitParentIcons[row.parent]
        iconKey = M.resolveIconKey(iconPath, pathToKey)
        iconExpr = M.pathToIconsExpr(iconPath, pathToKey)
        iconSource = "parent"
    end

    if iconPath and not iconKey then
        iconKey = M.iconPathToKey(iconPath)
    end

    if iconPath and iconSource == "missing" then
        iconSource = "path"
    end

    return iconPath, iconKey, iconExpr, iconSource
end

local ICON_SCAN_DIRS = {
    { dir = "ReplaceableTextures\\CommandButtons", subfolder = "CommandButtons" },
    { dir = "ReplaceableTextures\\PassiveButtons", subfolder = "PassiveButtons" },
}

function M.scanIconsFromDisk(assetsRoot)
    local icons = {}

    for _, entry in ipairs(ICON_SCAN_DIRS) do
        local fullDir = assetsRoot .. "\\" .. entry.dir
        local cmd = ('dir /b "%s\\*.dds" "%s\\*.blp" 2>nul'):format(fullDir, fullDir)
        local p = io.popen(cmd)
        if p then
            for filename in p:lines() do
                local editorPath = M.iconFileToEditorPath(entry.subfolder, filename)
                local key = M.iconPathToKey(editorPath)
                if key and not icons[key] then
                    icons[key] = editorPath
                end
            end
            p:close()
        end
    end

    return icons
end

function M.loadIconsCatalog()
    local icons = {}
    local pathToKey = {}

    local ok, catalog = pcall(require, "vendor.assets.generated.Icons")
    if ok and type(catalog) == "table" then
        for key, path in pairs(catalog) do
            if type(path) == "string" and path ~= "" then
                icons[key] = M.normalizeSlashes(path)
                pathToKey[M.normalizePathKey(path)] = key
            end
        end
    end

    return icons, pathToKey
end

function M.mergeIcons(primary, secondary)
    local merged = {}
    for k, v in pairs(secondary) do
        merged[k] = v
    end
    for k, v in pairs(primary) do
        merged[k] = v
    end
    return merged
end

function M.iconFolder(path)
    path = M.normalizeSlashes(path):lower()
    if path:find("\\passivebuttons\\", 1, true) then
        return "PassiveButtons"
    end
    return "CommandButtons"
end

function M.buildIconRegistry(assetsRoot)
    local catalogIcons, catalogPathToKey = M.loadIconsCatalog()
    local diskIcons = M.scanIconsFromDisk(assetsRoot)

    local icons = {}
    local pathToKey = {}

    for key, path in pairs(catalogIcons) do
        icons[key] = path
        pathToKey[M.normalizePathKey(path)] = key
    end

    for key, path in pairs(diskIcons) do
        local norm = M.normalizePathKey(path)
        if not pathToKey[norm] then
            icons[key] = path
            pathToKey[norm] = key
        end
    end

    return icons, pathToKey
end

function M.resolveIconKey(path, pathToKey)
    if type(path) ~= "string" or path == "" then
        return nil
    end
    return pathToKey[M.normalizePathKey(path)]
end

function M.pathToIconsExpr(path, pathToKey)
    local key = M.resolveIconKey(path, pathToKey)
    if key then
        return "Icons." .. key
    end
    return nil
end

return M
