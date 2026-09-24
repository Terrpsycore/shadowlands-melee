--- WC3 ReplaceableTextures editor paths (custom scan + asset catalogs).

local iconKeys = dofile("tools/gen/icon_keys.lua")

local M = {}

local EDITOR_SUBFOLDERS = {
    commandbuttons = "CommandButtons",
    passivebuttons = "PassiveButtons",
    commandbuttonsdisabled = "CommandButtonsDisabled",
    autocastbuttons = "AutocastButtons",
    autocast = "AutocastButtons",
}

local function titleCase(s)
    return s:sub(1, 1):upper() .. s:sub(2)
end

function M.isReplaceableTexturesRel(rel)
    rel = rel:gsub("\\", "/"):lower()
    return rel:match("^replaceabletextures/") ~= nil
end

function M.editorSubfolder(folderLower)
    if type(folderLower) ~= "string" or folderLower == "" then
        return nil
    end
    return EDITOR_SUBFOLDERS[folderLower:lower()]
end

function M.iconFileToEditorPath(subfolder, filename)
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

function M.relToEditorPath(rel, stem, ext)
    if not M.isReplaceableTexturesRel(rel) then
        return nil, "must be under ReplaceableTextures/"
    end

    local folderLower = iconKeys.parentFolder(rel)
    local subfolder = M.editorSubfolder(folderLower)
    if not subfolder then
        return nil, ("unknown ReplaceableTextures subfolder %q"):format(folderLower or "?")
    end

    return M.iconFileToEditorPath(subfolder, stem .. ext:lower())
end

return M
