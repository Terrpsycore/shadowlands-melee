
    _G.__HOT_RELOAD__ = true
    _G.__HOT_RELOAD_FILES__ = _G.__HOT_RELOAD_FILES__ or {}

    local function normalizePath(path)
        return path:gsub('[./\\]+', '/')
    end

    function package.setFileSource(filename, source)
        filename = normalizePath(filename)
        _FILES[filename] = source
        _G.__HOT_RELOAD_FILES__[filename] = source
        _LOADED_FILES[filename] = nil
    end

    function package.invalidateModule(moduleName)
        _LOADED_MODULES[moduleName] = nil
    end

    function package.invalidateByFilePrefix(prefix)
        prefix = normalizePath(prefix)
        for filename in pairs(_LOADED_FILES) do
            local norm = normalizePath(filename)
            if norm:sub(1, #prefix) == prefix then
                _LOADED_FILES[filename] = nil
            end
        end
        for moduleName in pairs(_LOADED_MODULES) do
            local filename = resolvefile(moduleName)
            if filename then
                filename = normalizePath(filename)
                if filename:sub(1, #prefix) == prefix then
                    _LOADED_MODULES[moduleName] = nil
                end
            end
        end
        local dotPrefix = prefix:gsub('/', '.')
        if prefix:sub(-1) == '/' then
            dotPrefix = prefix:sub(1, -2):gsub('/', '.')
        end
        for moduleName in pairs(_LOADED_MODULES) do
            if moduleName == dotPrefix or moduleName:sub(1, #dotPrefix + 1) == dotPrefix .. '.' then
                _LOADED_MODULES[moduleName] = nil
            end
        end
    end

    _G.__HOT_RELOAD_API__ = {
        setFileSource = package.setFileSource,
        invalidateModule = package.invalidateModule,
        invalidateByFilePrefix = package.invalidateByFilePrefix,
    }
