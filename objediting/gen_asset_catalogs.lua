--- Generate asset catalogs from wc3-assets dump.
--- Usage: lua objediting/gen_asset_catalogs.lua
--- Env: WC3_ASSETS=D:/Workspace/game/wc3/wc3-assets

package.path = table.concat({
    package.path,
    "src/?.lua",
    "src/?/init.lua",
}, ";")

local function resolveAssetsRoot(raw)
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

local ASSETS_ROOT = resolveAssetsRoot(os.getenv("WC3_ASSETS") or "../wc3-assets")
local OUT_DIR = "src/lib/community/types/assets/generated"
local METADATA_DIR = ASSETS_ROOT .. "\\units"

local UNITFUNC_FILES = {
    "campaignunitfunc.txt",
    "humanunitfunc.txt",
    "orcunitfunc.txt",
    "undeadunitfunc.txt",
    "nightelfunitfunc.txt",
    "neutralunitfunc.txt",
}

local MODEL_SCAN_DIRS = {
    ASSETS_ROOT .. "\\units",
    ASSETS_ROOT .. "\\buildings",
}

local ICON_SCAN_DIRS = {
    { dir = ASSETS_ROOT .. "\\ReplaceableTextures\\CommandButtons", subfolder = "CommandButtons" },
    { dir = ASSETS_ROOT .. "\\ReplaceableTextures\\PassiveButtons", subfolder = "PassiveButtons" },
}

local function countKeys(t)
    local n = 0
    for _ in pairs(t) do
        n = n + 1
    end
    return n
end

local function assetsAvailable()
    local f = io.open(METADATA_DIR .. "\\unitskin.txt", "r")
    if f then
        f:close()
        return true
    end
    return false
end

local function ensureDir(path)
    path = path:gsub("/", "\\")
    os.execute('if not exist "' .. path .. '" mkdir "' .. path .. '"')
end

local function readLines(path)
    local f, err = io.open(path, "r")
    if not f then
        return nil, err
    end
    local lines = {}
    for line in f:lines() do
        lines[#lines + 1] = line
    end
    f:close()
    return lines
end

local function escapeLuaString(s)
    if s:find("\n") or s:find("\\") then
        return "[[" .. s .. "]]"
    end
    return string.format("%q", s)
end

local function normalizeSlashes(p)
    return p:gsub("/", "\\")
end

local function normalizePathKey(path)
    return normalizeSlashes(path):lower()
end

local function withModelExtension(path)
    path = normalizeSlashes(path)
    if path:match("%.mdx?$") then
        return path
    end
    return path .. ".mdx"
end

local function isPortraitModel(path)
    return path:lower():find("_portrait", 1, true) ~= nil
end

local function isIdent(s)
    return type(s) == "string" and s:match("^[%a_][%w_]*$") ~= nil
end

local function camelCase(s)
    s = s:gsub("[^%w]", "")
    if s == "" then
        return "unnamed"
    end
    return s:sub(1, 1):lower() .. s:sub(2)
end

local function titleCase(s)
    return s:sub(1, 1):upper() .. s:sub(2)
end

--- Prefer plain field, then SD, then HD variant (Reforged skin metadata).
local function pickField(fields, name)
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

local function iconFileToEditorPath(subfolder, filename)
    local base = filename:gsub("%.dds$", ""):gsub("%.blp$", "")
    local lower = base:lower()

    if lower:sub(1, 6) == "pasbtn" then
        return ("ReplaceableTextures\\%s\\PASBTN%s.blp"):format(subfolder, titleCase(base:sub(7)))
    end
    if lower:sub(1, 3) == "btn" then
        return ("ReplaceableTextures\\%s\\BTN%s.blp"):format(subfolder, titleCase(base:sub(4)))
    end

    return ("ReplaceableTextures\\%s\\%s.blp"):format(subfolder, base)
end

local function iconPathToKey(path)
    if type(path) ~= "string" or path == "" then
        return nil
    end
    path = normalizeSlashes(path)
    local name = path:match("[^\\]+$")
    if not name or name == "" then
        return nil
    end
    name = name:gsub("%.blp$", "")
    if name:sub(1, 6) == "PASBTN" then
        return "pas" .. titleCase(name:sub(7))
    end
    if name:sub(1, 3) == "BTN" then
        return camelCase(name:sub(4))
    end
    return camelCase(name)
end

local function modelPathToKey(path)
    local withoutExt = path:gsub("\\[^\\]+$", ""):gsub("%.mdx?$", "")
    local leaf = path:match("[^\\]+$"):gsub("%.mdx?$", "")
    local parent = withoutExt:match("[^\\]+$") or leaf
    if leaf:lower() == parent:lower() then
        return camelCase(leaf)
    end
    return camelCase(parent .. leaf)
end

local function uniqueKey(base, used)
    if not used[base] then
        used[base] = 1
        return base
    end
    local i = 2
    while used[base .. i] do
        i = i + 1
    end
    local key = base .. i
    used[base] = (used[base] or 1) + 1
    used[key] = 1
    return key
end

local function newPathCatalog()
    return {
        byNorm = {},
        entries = {},
        usedKeys = {},
    }
end

local function catalogHasPath(catalog, path)
    return catalog.byNorm[normalizePathKey(path)] == true
end

local function catalogInsert(catalog, path, preferredKey, keyFn)
    path = normalizeSlashes(path)
    if path == "" then
        return
    end
    local norm = normalizePathKey(path)
    if catalog.byNorm[norm] then
        return
    end
    catalog.byNorm[norm] = true

    local keyBase = preferredKey or keyFn(path)
    if not keyBase then
        return
    end

    local key = keyBase
    if catalog.entries[key] and normalizePathKey(catalog.entries[key]) ~= norm then
        key = uniqueKey(keyBase, catalog.usedKeys)
    else
        catalog.usedKeys[key] = 1
    end
    catalog.entries[key] = path
end

local function catalogToTable(catalog)
    return catalog.entries
end

local function parseIniSections(path)
    local lines, err = readLines(path)
    if not lines then
        error("cannot read " .. path .. ": " .. tostring(err))
    end

    local sections = {}
    local currentId

    for _, raw in ipairs(lines) do
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

    return sections
end

local function mergeSections(into, from)
    for id, fields in pairs(from) do
        into[id] = into[id] or {}
        for k, v in pairs(fields) do
            into[id][k] = v
        end
    end
end

local function collectUnitSkin()
    return parseIniSections(METADATA_DIR .. "\\unitskin.txt")
end

local function collectUnitFunc()
    local merged = {}
    for _, name in ipairs(UNITFUNC_FILES) do
        local path = METADATA_DIR .. "\\" .. name
        local f = io.open(path, "r")
        if f then
            f:close()
            mergeSections(merged, parseIniSections(path))
        end
    end
    return merged
end

local function collectAbilitySkin()
    return parseIniSections(METADATA_DIR .. "\\abilityskin.txt")
end

local function fileExists(path)
    local f = io.open(path, "rb")
    if f then
        f:close()
        return true
    end
    return false
end

local function resolveModelOnDisk(editorPath)
    local rel = editorPath:lower()
    for _, root in ipairs(MODEL_SCAN_DIRS) do
        local directMdx = root .. "\\" .. rel:gsub("/", "\\")
        local directMdl = directMdx:gsub("%.mdx$", ".mdl")
        if fileExists(directMdx) then
            return editorPath
        end
        if fileExists(directMdl) then
            return editorPath:gsub("%.mdx$", ".mdl")
        end
    end
    return editorPath
end

local function toAssetRelative(absPath)
    absPath = normalizeSlashes(absPath)
    local root = ASSETS_ROOT:lower()
    if absPath:lower():sub(1, #root) == root then
        return absPath:sub(#ASSETS_ROOT + 2)
    end
    return absPath
end

local function collectMetadataModels(unitSkin)
    local catalog = newPathCatalog()
    for _, skin in pairs(unitSkin) do
        if skin.skinType == "unit" then
            local file = pickField(skin, "file")
            if file then
                local path = resolveModelOnDisk(withModelExtension(file))
                catalogInsert(catalog, path, modelPathToKey(path), modelPathToKey)
            end
        end
    end
    return catalog
end

local function collectMetadataIcons(unitSkin, abilitySkin)
    local catalog = newPathCatalog()
    for _, skin in pairs(unitSkin) do
        local art = pickField(skin, "Art")
        if art then
            local path = normalizeSlashes(art)
            catalogInsert(catalog, path, iconPathToKey(path), iconPathToKey)
        end
    end
    for _, skin in pairs(abilitySkin) do
        local art = pickField(skin, "Art")
        if art then
            local path = normalizeSlashes(art)
            catalogInsert(catalog, path, iconPathToKey(path), iconPathToKey)
        end
        local researchArt = pickField(skin, "Researchart")
        if researchArt then
            local path = normalizeSlashes(researchArt)
            catalogInsert(catalog, path, iconPathToKey(path), iconPathToKey)
        end
    end
    return catalog
end

local function scanModelsInto(catalog)
    for _, root in ipairs(MODEL_SCAN_DIRS) do
        local cmd = ('dir /s /b "%s\\*.mdx" "%s\\*.mdl"'):format(root, root)
        local p = io.popen(cmd)
        if p then
            for line in p:lines() do
                local rel = toAssetRelative(line)
                if not isPortraitModel(rel) then
                    catalogInsert(catalog, rel, nil, modelPathToKey)
                end
            end
            p:close()
        end
    end
end

local function scanIconsInto(catalog)
    for _, entry in ipairs(ICON_SCAN_DIRS) do
        local cmd = ('dir /b "%s\\*.dds" "%s\\*.blp"'):format(entry.dir, entry.dir)
        local p = io.popen(cmd)
        if p then
            for filename in p:lines() do
                local editorPath = iconFileToEditorPath(entry.subfolder, filename)
                if not catalogHasPath(catalog, editorPath) then
                    catalogInsert(catalog, editorPath, nil, iconPathToKey)
                end
            end
            p:close()
        end
    end
end

local function collectMissiles(unitFunc, abilitySkin)
    local missiles = {}
    local byNorm = {}

    local function add(path)
        path = normalizeSlashes(path)
        if path == "" then
            return
        end
        for rawPart in path:gmatch("[^,]+") do
            local part = rawPart:match("^%s*(.-)%s*$")
            if part ~= "" then
                local norm = normalizePathKey(part)
                if not byNorm[norm] then
                    byNorm[norm] = true
                    local leaf = part:match("([^\\]+)%.mdl?$") or part
                    missiles[camelCase(leaf)] = part
                end
            end
        end
    end

    for _, fields in pairs(unitFunc) do
        if fields.Missileart then
            add(fields.Missileart)
        end
    end

    for _, fields in pairs(abilitySkin) do
        if fields.Missileart then
            add(fields.Missileart)
        end
    end

    return missiles
end

local function buildUnitArt(unitSkin, unitFunc)
    local art = {}

    for unitId, skin in pairs(unitSkin) do
        if skin.skinType == "unit" then
            local file = pickField(skin, "file")
            if file then
                local func = unitFunc[unitId] or {}
                local model = resolveModelOnDisk(withModelExtension(file))
                local icon = pickField(skin, "Art")
                local row = {
                    model = model,
                    icon = icon and normalizeSlashes(icon) or nil,
                    scale = tonumber(skin.scale),
                    scaleProjectiles = skin.scaleBull == "1",
                }
                if func.Missileart then
                    row.attack1Missile = normalizeSlashes(func.Missileart:match("[^,]+"))
                end
                if func.Specialart then
                    row.specialArt = normalizeSlashes(func.Specialart)
                end
                art[unitId] = row
            end
        end
    end

    return art
end

local function buildUnitArtBySlug(unitArt)
    local UnitIds = require("lib.community.types.assets.UnitIds")
    local bySlug = {}

    for slug, rawId in pairs(UnitIds) do
        if type(rawId) == "string" and unitArt[rawId] then
            bySlug[slug] = unitArt[rawId]
        end
    end

    return bySlug
end

local function writeCatalog(name, className, entries)
    ensureDir(OUT_DIR)
    local out = assert(io.open(OUT_DIR .. "/" .. name .. ".lua", "w"))
    out:write("--- Autogenerated by objediting/gen_asset_catalogs.lua — do not edit\n")
    out:write("---@class " .. className .. "\n")
    out:write("local " .. name .. " = {\n")

    local keys = {}
    for k in pairs(entries) do
        keys[#keys + 1] = k
    end
    table.sort(keys)

    for _, k in ipairs(keys) do
        local key = isIdent(k) and k or ("[" .. escapeLuaString(k) .. "]")
        out:write("    " .. key .. " = " .. escapeLuaString(entries[k]) .. ",\n")
    end

    out:write("}\n\nreturn " .. name .. "\n")
    out:close()
end

local function writeUnitArt(name, entries)
    ensureDir(OUT_DIR)
    local out = assert(io.open(OUT_DIR .. "/" .. name .. ".lua", "w"))
    out:write("--- Autogenerated by objediting/gen_asset_catalogs.lua — do not edit\n\n")
    out:write("return {\n")

    local keys = {}
    for k in pairs(entries) do
        keys[#keys + 1] = k
    end
    table.sort(keys)

    for _, id in ipairs(keys) do
        local row = entries[id]
        local key = isIdent(id) and id or ("[" .. escapeLuaString(id) .. "]")
        out:write("    " .. key .. " = {\n")
        out:write("        model = " .. escapeLuaString(row.model) .. ",\n")
        if row.icon then
            out:write("        icon = " .. escapeLuaString(row.icon) .. ",\n")
        end
        if row.scale then
            out:write("        scale = " .. row.scale .. ",\n")
        end
        if row.scaleProjectiles ~= nil then
            out:write("        scaleProjectiles = " .. tostring(row.scaleProjectiles) .. ",\n")
        end
        if row.attack1Missile then
            out:write("        attack1Missile = " .. escapeLuaString(row.attack1Missile) .. ",\n")
        end
        if row.specialArt then
            out:write("        specialArt = " .. escapeLuaString(row.specialArt) .. ",\n")
        end
        out:write("    },\n")
    end

    out:write("}\n")
    out:close()
end

local function generate()
    local unitSkin = collectUnitSkin()
    local unitFunc = collectUnitFunc()
    local abilitySkin = collectAbilitySkin()

    local modelCatalog = collectMetadataModels(unitSkin)
    scanModelsInto(modelCatalog)

    local iconCatalog = collectMetadataIcons(unitSkin, abilitySkin)
    scanIconsInto(iconCatalog)

    local models = catalogToTable(modelCatalog)
    local icons = catalogToTable(iconCatalog)
    local missiles = collectMissiles(unitFunc, abilitySkin)
    local unitArt = buildUnitArt(unitSkin, unitFunc)
    local unitArtBySlug = buildUnitArtBySlug(unitArt)

    writeCatalog("Models", "Models", models)
    writeCatalog("Icons", "Icons", icons)
    writeCatalog("Missiles", "Missiles", missiles)
    writeUnitArt("UnitArt", unitArt)
    writeUnitArt("UnitArtBySlug", unitArtBySlug)

    print(("Generated asset catalogs in %s"):format(OUT_DIR))
    print(("  Models: %d"):format(countKeys(models)))
    print(("  Icons: %d"):format(countKeys(icons)))
    print(("  Missiles: %d"):format(countKeys(missiles)))
    print(("  UnitArt: %d"):format(countKeys(unitArt)))
    print(("  UnitArtBySlug: %d"):format(countKeys(unitArtBySlug)))
end

if not assetsAvailable() then
    print("skip gen_asset_catalogs: WC3_ASSETS not found at " .. ASSETS_ROOT)
    return
end

generate()
