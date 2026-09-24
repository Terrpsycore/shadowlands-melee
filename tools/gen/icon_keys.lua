--- Shared icon key naming rules (custom scan + icon preview).

local M = {}

local function titleCase(s)
    return s:sub(1, 1):upper() .. s:sub(2)
end

local function camelCase(s)
    s = s:gsub("[^%w]", "")
    if s == "" then
        return "unnamed"
    end
    return s:sub(1, 1):lower() .. s:sub(2)
end

function M.parentFolder(rel)
    rel = rel:gsub("\\", "/")
    local parent = rel:match("^(.+)/[^/]+$")
    if not parent then
        return nil
    end
    return (parent:match("([^/]+)$") or parent):lower()
end

--- Disabled icon variants: DIS prefix (DISATC…, DISPAS…) or ATCdisbtn… — not suffix DIS.
function M.isDisStem(stem)
    if type(stem) ~= "string" or stem == "" then
        return false
    end
    local lower = stem:lower()
    if #stem >= 3 and stem:sub(1, 3):upper() == "DIS" then
        return true
    end
    if lower:match("^atcdisbtn") then
        return true
    end
    return false
end

function M.disBaseStem(stem)
    if stem:sub(1, 3):upper() == "DIS" then
        stem = stem:sub(4)
    end
    if stem:lower():match("^atcdisbtn") then
        return "ATCbtn" .. stem:sub(10)
    end
    return stem
end

local function stemFromPath(path)
    if type(path) ~= "string" or path == "" then
        return nil
    end
    local stem = path:match("[^\\/]+$") or path
    return stem:gsub("%.[^%.]+$", "")
end

function M.isDisIcon(_key, iconPath)
    local stem = stemFromPath(iconPath)
    if not stem then
        return false
    end
    return M.isDisStem(stem)
end

function M.resolveCategory(rel)
    rel = rel:gsub("\\", "/"):lower()
    if rel:find("autocast", 1, true) then
        return "AutocastButtons"
    end
    if rel:find("passive", 1, true) then
        return "PassiveButtons"
    end
    if rel:find("commandbuttonsdisabled", 1, true) then
        return "CommandButtonsDisabled"
    end
    if rel:find("commandbuttons", 1, true) then
        return "CommandButtons"
    end
    return "Custom"
end

function M.displayKey(key)
    if key:sub(1, 8) == "autocast" and #key > 8 then
        local rest = key:sub(9)
        return rest:sub(1, 1):lower() .. rest:sub(2)
    end
    if key:sub(1, 3) == "pas" and #key > 3 and key:sub(4, 4):match("%u") then
        local rest = key:sub(4)
        return rest:sub(1, 1):lower() .. rest:sub(2)
    end
    return key
end

--- Base key from filename (WC3 BTN/PASBTN/ATCbtn conventions + camelCase fallback).
function M.fileNameToKey(stem)
    local lower = stem:lower()
    if lower:sub(1, 6) == "atcbtn" then
        return camelCase(stem:sub(7))
    end
    if lower:sub(1, 6) == "pasbtn" then
        return "pas" .. titleCase(camelCase(stem:sub(7)))
    end
    if lower:sub(1, 3) == "btn" then
        return camelCase(stem:sub(4))
    end
    return camelCase(stem)
end

--- Primary key for a disabled companion (folder of the DIS file is misleading).
function M.companionTargetKey(baseStem)
    local lower = baseStem:lower()
    if lower:sub(1, 3) == "atc" then
        return M.iconKey("ReplaceableTextures/AutocastButtons/_", baseStem)
    end
    if lower:sub(1, 6) == "pasbtn" then
        return M.iconKey("ReplaceableTextures/PassiveButtons/_", baseStem)
    end
    if lower:sub(1, 3) == "btn" then
        return M.iconKey("ReplaceableTextures/CommandButtons/_", baseStem)
    end
    return M.fileNameToKey(baseStem)
end

--- Category-aware key: folder prefix avoids BTN vs autocast/passive collisions.
function M.iconKey(rel, stem)
    local base = M.fileNameToKey(stem)
    local folder = M.parentFolder(rel)

    if folder == "autocast" or folder == "autocastbuttons" then
        return "autocast" .. titleCase(base)
    end
    if folder == "passivebuttons" then
        if base:sub(1, 3) == "pas" then
            return base
        end
        return "pas" .. titleCase(base)
    end
    if folder == "commandbuttons" or folder == "commandbuttonsdisabled" then
        return base
    end

    return base
end

return M
