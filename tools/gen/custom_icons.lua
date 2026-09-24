--- Scan WC3_CUSTOM and merge custom icons into Icons.lua.

local pathMod = dofile("tools/_path.lua")
local REPO_ROOT = pathMod.setup()
local customPaths = dofile("tools/gen/custom_paths.lua")
local iconKeys = dofile("tools/gen/icon_keys.lua")
local iconPaths = dofile("tools/gen/icon_paths.lua")

local INDEX_OUT = "src/vendor/assets/generated/custom_icon_index.lua"

local IMAGE_EXTENSIONS = {
    [".blp"] = true,
    [".dds"] = true,
}

local function trim(s)
    return (s:match("^%s*(.-)%s*$"))
end

local function normalizeSlashes(path)
    return path:gsub("/", "\\")
end

local function isIdent(s)
    return type(s) == "string" and s:match("^[%a_][%w_]*$") ~= nil
end

local function escapeLuaString(s)
    if s:find("\n") or s:find("\\") then
        return "[[" .. s .. "]]"
    end
    return string.format("%q", s)
end

local function ensureDir(path)
    path = path:gsub("/", "\\")
    os.execute('if not exist "' .. path .. '" mkdir "' .. path .. '"')
end

local function toAssetRelative(absPath, root)
    absPath = normalizeSlashes(absPath)
    root = normalizeSlashes(root)
    if absPath:lower():sub(1, #root) == root:lower() then
        return absPath:sub(#root + 2):gsub("\\", "/")
    end
    return absPath:gsub("\\", "/")
end

local function customRootExists(root)
    local p = io.popen('if exist "' .. root:gsub("/", "\\") .. '\\*" (echo yes) else (echo no)')
    if not p then
        return false
    end
    local answer = trim(p:read("*l") or "")
    p:close()
    return answer == "yes"
end

local function makeEntry(rel, stem, ext, editorPath)
    return {
        rel = rel,
        stem = stem,
        ext = ext,
        editorPath = editorPath,
        folder = iconKeys.parentFolder(rel),
        category = iconKeys.resolveCategory(rel),
    }
end

local function scanCustomIcons(customRoot)
    customRoot = normalizeSlashes(customRoot)
    if not customRootExists(customRoot) then
        print("skip custom icons: WC3_CUSTOM not found at " .. customRoot)
        return {}, {}
    end

    local cmd = ('dir /s /b "%s\\*.blp" "%s\\*.dds" 2>nul'):format(customRoot, customRoot)
    local p = io.popen(cmd)

    local scanned = {}
    if p then
        for line in p:lines() do
            local absPath = normalizeSlashes(line)
            local rel = toAssetRelative(absPath, customRoot)
            local filename = absPath:match("[^\\]+$") or absPath
            local stem, ext = filename:match("^(.+)(%.[^%.]+)$")
            if stem and IMAGE_EXTENSIONS[ext:lower()] then
                local editorPath, err = iconPaths.relToEditorPath(rel, stem, ext)
                if editorPath then
                    scanned[#scanned + 1] = makeEntry(rel, stem, ext, editorPath)
                else
                    print(("warning: skip custom icon %s: %s"):format(rel, err))
                end
            end
        end
        p:close()
    end

    local companionsByKey = {}
    local primaries = {}

    for _, entry in ipairs(scanned) do
        if iconKeys.isDisStem(entry.stem) then
            local baseStem = iconKeys.disBaseStem(entry.stem)
            local baseKey = iconKeys.companionTargetKey(baseStem)
            companionsByKey[baseKey] = companionsByKey[baseKey] or {}
            companionsByKey[baseKey][#companionsByKey[baseKey] + 1] = entry
        else
            primaries[#primaries + 1] = entry
        end
    end

    local icons = {}
    local index = {}
    local paths = {}
    local keysByFile = {}

    for _, entry in ipairs(primaries) do
        local rel = entry.rel
        local key = iconKeys.iconKey(rel, entry.stem)
        if not isIdent(key) then
            error(("custom icon %s: key %q is not a valid Lua identifier"):format(rel, key))
        end

        if keysByFile[key] and keysByFile[key] ~= rel then
            error(
                ("custom icon key collision %s: %s and %s"):format(key, keysByFile[key], rel)
            )
        end
        keysByFile[key] = rel

        local editorPath = entry.editorPath
        local pathKey = editorPath:lower()
        if paths[pathKey] then
            error(
                ("custom icon duplicate editor path %s (%s and %s)"):format(
                    editorPath,
                    paths[pathKey],
                    rel
                )
            )
        end
        paths[pathKey] = rel

        local row = {
            path = editorPath,
            file = rel,
            category = entry.category,
            displayKey = iconKeys.displayKey(key),
            companions = {},
        }

        for _, companion in ipairs(companionsByKey[key] or {}) do
            row.companions[#row.companions + 1] = {
                path = companion.editorPath,
                file = companion.rel,
            }
        end
        if #row.companions == 0 then
            row.companions = nil
        end

        icons[key] = editorPath
        index[key] = row
    end

    for baseKey, companionEntries in pairs(companionsByKey) do
        if not index[baseKey] then
            for _, companion in ipairs(companionEntries) do
                print(
                    ("warning: DIS icon without primary Icons.%s: %s"):format(baseKey, companion.rel)
                )
            end
        end
    end

    return icons, index
end

local function writeIndex(index)
    ensureDir("src/vendor/assets/generated")
    local out = assert(io.open(INDEX_OUT, "w"))
    out:write("--- Autogenerated by tools/gen/custom_icons.lua — do not edit\n\n")
    out:write("return {\n")

    local keys = {}
    for k in pairs(index) do
        keys[#keys + 1] = k
    end
    table.sort(keys)

    for _, key in ipairs(keys) do
        local row = index[key]
        out:write(("    %s = {\n"):format(key))
        out:write("        path = " .. escapeLuaString(row.path) .. ",\n")
        out:write("        file = " .. escapeLuaString(row.file) .. ",\n")
        out:write("        category = " .. escapeLuaString(row.category) .. ",\n")
        out:write("        displayKey = " .. escapeLuaString(row.displayKey) .. ",\n")
        if row.companions then
            out:write("        companions = {\n")
            for _, companion in ipairs(row.companions) do
                out:write("            {\n")
                out:write("                path = " .. escapeLuaString(companion.path) .. ",\n")
                out:write("                file = " .. escapeLuaString(companion.file) .. ",\n")
                out:write("            },\n")
            end
            out:write("        },\n")
        end
        out:write("    },\n")
    end

    out:write("}\n")
    out:close()
end

local function mergeIntoVanilla(vanillaIcons, customIcons)
    local merged = {}
    for k, v in pairs(vanillaIcons or {}) do
        merged[k] = v
    end

    local accepted = {}
    local skipped = 0
    for key, path in pairs(customIcons) do
        if merged[key] then
            print(("skip custom icon: Icons.%s already in vanilla catalog"):format(key))
            skipped = skipped + 1
        else
            merged[key] = path
            accepted[key] = path
        end
    end
    if skipped > 0 then
        print(("custom icons: skipped %d (vanilla key exists)"):format(skipped))
    end
    return merged, accepted
end

local function filterIndex(index, accepted)
    local filtered = {}
    for key, row in pairs(index) do
        if accepted[key] then
            filtered[key] = row
        end
    end
    return filtered
end

return {
    INDEX_OUT = INDEX_OUT,
    resolveCustomRoot = function()
        return customPaths.resolveCustomRoot(REPO_ROOT)
    end,
    load = function()
        local customRoot = customPaths.resolveCustomRoot(REPO_ROOT)
        return scanCustomIcons(customRoot)
    end,
    writeIndex = writeIndex,
    filterIndex = filterIndex,
    mergeIntoVanilla = mergeIntoVanilla,
}
