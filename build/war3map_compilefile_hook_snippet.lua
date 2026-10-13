    local function compilefileRaw(filename, mode, env, level)
        local code = _FILES[filename]
        if not code then
            error(string.format('cannot open %s: No such file or directory', filename), (level or 1) + 1)
        end
        return preload(code, '@' .. filename, mode, env or _G)
    end

    local function compilefile(filename, mode, env, level)
        local hook = rawget(_G, "__MAP_COMPILEFILE_HOOK__")
        if type(hook) == "function" then
            return hook(filename, mode, env, level, compilefileRaw)
        end
        return compilefileRaw(filename, mode, env, level)
    end
