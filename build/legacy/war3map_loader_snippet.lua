    local function mapPreloadSource(filename)
        filename = filename:gsub('\\', '/')
        local overlay = _G.__HOT_RELOAD_FILES__
        if overlay and overlay[filename] then
            return overlay[filename]
        end
        if _FILES[filename] then
            return _FILES[filename]
        end
        local alt = filename:gsub('^scenario/', '')
        if _FILES['scenario/' .. alt] then
            return _FILES['scenario/' .. alt]
        end
        return nil
    end

    _G.__MAP_PRELOAD_SOURCE__ = mapPreloadSource
