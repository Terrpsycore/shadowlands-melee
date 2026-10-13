---Suppress DebugUtils nil-global __index during WSCode UI (EnableEditor, toggles, Show).
local nilGlobalHook = require("lib.nil_global_hook")

---@param callback function
local function wrapWithNilGlobalSuppressed(callback)
    return function(...)
        local packed = table.pack(...)
        return nilGlobalHook.withSuppressed(function()
            return callback(table.unpack(packed, 1, packed.n))
        end)
    end
end

if rawget(_G, "AsyncControl") and AsyncControl.Register then
    local register = AsyncControl.Register
    AsyncControl.Register = function(eventData)
        if type(eventData) == "table" and type(eventData.onPress) == "function" then
            eventData.onPress = wrapWithNilGlobalSuppressed(eventData.onPress)
        end
        return register(eventData)
    end
end

if rawget(_G, "WSCodeConfig") and WSCodeConfig.editor then
    local editor = WSCodeConfig.editor

    if type(editor.ON_ENABLE) == "function" then
        local onEnable = editor.ON_ENABLE
        editor.ON_ENABLE = function()
            nilGlobalHook.withSuppressed(onEnable)
        end
    end

    if type(editor.ON_DISABLE) == "function" then
        local onDisable = editor.ON_DISABLE
        editor.ON_DISABLE = function()
            nilGlobalHook.withSuppressed(onDisable)
        end
    end
end

if not rawget(_G, "WSCode") then
    return
end

local wscode = WSCode
local show = wscode.Show
local initialize = wscode.Initialize

wscode.Show = function(enable)
    nilGlobalHook.withSuppressed(function()
        show(enable)
    end)
end

wscode.Initialize = function()
    if wscode.IsEnabled() then
        return
    end
    nilGlobalHook.withSuppressed(initialize)
end
