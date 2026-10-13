    local function compilefile(filename, mode, env, level)
        filename = filename:gsub('[./\\]+', '/')
        local code
        local overlay = _G.__HOT_RELOAD_FILES__
        if overlay then
            code = overlay[filename]
        end
        if not code then
            code = _FILES[filename]
        end
        if not code then
            error(string.format('cannot open %s: No such file or directory', filename), (level or 1) + 1)
        end
        return preload(code, '@' .. filename, mode, env or _G)
    end
