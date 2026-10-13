    local function mapPreloadSource(filename)
        if type(filename) ~= "string" or filename == "" then
            return nil
        end
        filename = filename:gsub("\\", "/"):gsub("^@", "")
        local code = _FILES[filename]
        if code then
            return code
        end

        local bestName
        for name, content in pairs(_FILES) do
            if name == filename or (#filename <= #name and name:sub(-#filename) == filename) then
                if not bestName or #name > #bestName then
                    bestName = name
                    code = content
                end
            end
        end
        if code then
            return code
        end

        local base = filename:match("([^/]+%.lua)$")
        if not base then
            return nil
        end
        bestName = nil
        for name, content in pairs(_FILES) do
            if name:sub(-#base) == base then
                if not bestName or #name > #bestName then
                    bestName = name
                    code = content
                end
            end
        end
        return code
    end

    package.source = mapPreloadSource
    _G.__MAP_PRELOAD_SOURCE__ = mapPreloadSource
