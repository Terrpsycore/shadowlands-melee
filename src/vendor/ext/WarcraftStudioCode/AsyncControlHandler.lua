if Debug then
    Debug.beginFile("AsyncControlHandler")
end
---@version 1.0
if not AsyncControl then
    --[[
    =============================================================================================================================================================
                                                                    Async Control Handler
                                                                        by Antares
                                                                           v1.0

                                    Requires:
                                    AsyncControlHandler

    =============================================================================================================================================================
                                                                        C O N F I G
    =============================================================================================================================================================
    ]]

    local INTERVAL = 0.01

    --[[
    =============================================================================================================================================================
                                                                           A P I
    =============================================================================================================================================================

    AsyncControl.Register(eventData) -> event           Registers an asynchronous control from the provided data table. The data table can hold the following fields:

                                                        oskey? oskeytype
                                                        mouseButton? mousebuttontype
                                                        metakey? integer | integer[]
                                                        exactMetakey? boolean
                                                        onPress? function
                                                        onRelease? function
                                                        whilePressed? function
                                                        delay? number
                                                        interval? number

                                                        Either oskey or mouseButton must be set. Metakey controls which modifier keys (Shift, Ctrl, Alt, Win) must be
                                                        pressed for the event to activate. The integer value should be set to the sum of all metakeys that must be
                                                        pressed, for example METAKEY_SHIFT + METAKEY_CTRL. If metakey is a table, all metakey values in that table are
                                                        allowed. exactMetakey controls whether additional metakeys are allowed or if exactly that combination needs to
                                                        be pressed. onPress is called when the key or mouse button is first pressed, onRelease when it is released,
                                                        and whilePressed is periodically called while the key is pressed, either at the specified interval or at the
                                                        minimum interval set in the config. The delay parameter controls how long the key must be pressed for the
                                                        whilePressed event to first fire.

    AsyncControl.Remove(whichEvent)                     Disables an AsyncControl returned by AsyncControl.Register.

    =============================================================================================================================================================
    ]]

    local oskeyChecksOfMetakey = setmetatable({}, {
        __index = function(self, key)
            self[key] = {}
            return self[key]
        end,
    })
    local eventsOfKeyAndMetakey = setmetatable({}, {
        __index = function(self, key)
            self[key] = {}
            return self[key]
        end,
    })
    local mouseChecksOfMetakey = setmetatable({}, {
        __index = function(self, key)
            self[key] = {}
            return self[key]
        end,
    })
    local eventsOfMouseAndMetakey = setmetatable({}, {
        __index = function(self, key)
            self[key] = {}
            return self[key]
        end,
    })
    local activeEvents = {}

    local timeElapsed = 0

    local function MainLoop()
        MouseScreenX = BlzPixelToFrameX(BlzGetMouseScreenPosX())
        MouseScreenY = BlzPixelToFrameY(BlzGetMouseScreenPosY())

        local metakey = (BlzIsMetaKeyPressed(METAKEY_SHIFT) and METAKEY_SHIFT or 0)
            + (BlzIsMetaKeyPressed(METAKEY_CTRL) and METAKEY_CTRL or 0)
            + (BlzIsMetaKeyPressed(METAKEY_ALT) and METAKEY_ALT or 0)
            + (BlzIsMetaKeyPressed(METAKEY_WINKEYS) and METAKEY_WINKEYS or 0)

        local events, event

        timeElapsed = timeElapsed + INTERVAL

        for oskey, __ in next, oskeyChecksOfMetakey[metakey] do
            if BlzIsKeyPressed(oskey) then
                events = eventsOfKeyAndMetakey[metakey][oskey]
                for i = 1, #events do
                    event = events[i]
                    if not event.isActive then
                        event.isActive = true
                        event.timeOfPress = timeElapsed
                        event.lastPeriodic = timeElapsed
                        activeEvents[#activeEvents + 1] = event
                        if event.onPress then
                            event.onPress()
                        end
                    elseif
                        event.whilePressed
                        and (not event.delay or timeElapsed >= event.timeOfPress + event.delay)
                        and (
                            not event.interval and timeElapsed > event.lastPeriodic
                            or timeElapsed >= event.lastPeriodic + event.interval
                        )
                    then
                        event.whilePressed(timeElapsed - event.timeOfPress)
                        event.lastPeriodic = timeElapsed
                    end
                    event.lastCheck = timeElapsed
                end
            end
        end

        for mouseButton, __ in next, mouseChecksOfMetakey[metakey] do
            if BlzIsMouseButtonPressed(mouseButton) then
                events = eventsOfMouseAndMetakey[metakey][mouseButton]
                for i = 1, #events do
                    event = events[i]
                    if not event.isActive then
                        event.isActive = true
                        event.timeOfPress = timeElapsed
                        event.lastPeriodic = timeElapsed
                        activeEvents[#activeEvents + 1] = event
                        if event.onPress then
                            event.onPress()
                        end
                    elseif
                        event.whilePressed
                        and (not event.delay or timeElapsed >= event.timeOfPress + event.delay)
                        and (
                            not event.interval and timeElapsed > event.lastPeriodic
                            or timeElapsed >= event.lastPeriodic + event.interval
                        )
                    then
                        event.whilePressed(timeElapsed - event.timeOfPress)
                        event.lastPeriodic = timeElapsed
                    end
                    event.lastCheck = timeElapsed
                end
            end
        end

        for i = #activeEvents, 1, -1 do
            if activeEvents[i].lastCheck < timeElapsed then
                if activeEvents[i].onRelease then
                    activeEvents[i].onRelease(timeElapsed - activeEvents[i].timeOfPress)
                end
                activeEvents[i].isActive = false
                table.remove(activeEvents, i)
            end
        end
    end

    AsyncControl = {
        ---Registers an asynchronous control from the provided data table. The data table can hold the following fields:
        -- - oskey? oskeytype
        -- - mouseButton? mousebuttontype
        -- - metakey? integer | integer[]
        -- - exactMetakey? boolean
        -- - onPress? function
        -- - onRelease? function
        -- - whilePressed? function
        -- - delay? number
        -- - interval? number
        ---
        ---Either oskey or mouseButton must be set. Metakey controls which modifier keys (Shift, Ctrl, Alt, Win) must be pressed for the event to activate. The integer value should be set to the sum of all metakeys that must be pressed, for example METAKEY_SHIFT + METAKEY_CTRL. If metakey is a table, all metakey values in that table are allowed. exactMetakey controls whether additional metakeys are allowed or if exactly that combination needs to be pressed. onPress is called when the key or mouse button is first pressed, onRelease when it is released, and whilePressed is periodically called while the key is pressed, either at the specified interval or at the minimum interval set in the config. The delay parameter controls how long the key must be pressed for the whilePressed event to first fire.
        ---@param eventData table
        ---@return table
        Register = function(eventData)
            local self = {
                oskey = eventData.oskey,
                mouseButton = eventData.mouseButton,
                metakeys = {},
                onPress = type(eventData.onPress) == "string" and eventData[eventData.onPress] or eventData.onPress,
                onRelease = type(eventData.onRelease) == "string" and eventData[eventData.onRelease]
                    or eventData.onRelease,
                whilePressed = type(eventData.whilePressed) == "string" and eventData[eventData.whilePressed]
                    or eventData.whilePressed,
                delay = eventData.delay,
                interval = eventData.interval,
                isActive = false,
            }

            local eventTable, checkTable, button
            if eventData.oskey then
                eventTable = eventsOfKeyAndMetakey
                checkTable = oskeyChecksOfMetakey
                button = self.oskey
            elseif eventData.mouseButton then
                eventTable = eventsOfMouseAndMetakey
                checkTable = mouseChecksOfMetakey
                button = self.mouseButton
            else
                error("eventData is missing either oskey or mouseButton field.")
            end

            if type(eventData.metakey) == "number" then
                if eventData.exactMetakey or eventData.metakey == 0 then
                    checkTable[eventData.metakey][button] = true
                    eventTable[eventData.metakey][button] = eventTable[eventData.metakey][button] or {}
                    eventTable[eventData.metakey][button][#eventTable[eventData.metakey][button] + 1] = self
                    self.metakeys[1] = eventData.metakey
                else
                    for i = 0, 15 do
                        if i & eventData.metakey > 0 then
                            checkTable[i][button] = true
                            eventTable[i][button] = eventTable[i][button] or {}
                            eventTable[i][button][#eventTable[i][button] + 1] = self
                            self.metakeys[#self.metakeys + 1] = i
                        end
                    end
                end
            elseif type(eventData.metakey) == "table" then
                for i = 1, #eventData.metakey do
                    checkTable[eventData.metakey[i]][button] = true
                    eventTable[eventData.metakey[i]][button] = eventTable[eventData.metakey[i]][button] or {}
                    eventTable[eventData.metakey[i]][button][#eventTable[eventData.metakey[i]][button] + 1] = self
                    self.metakeys[#self.metakeys + 1] = eventData.metakey[i]
                end
            else
                for i = 0, 15 do
                    checkTable[i][button] = true
                    eventTable[i][button] = eventTable[i][button] or {}
                    eventTable[i][button][#eventTable[i][button] + 1] = self
                    self.metakeys[#self.metakeys + 1] = i
                end
            end

            return self
        end,

        ---@param whichEvent table
        Remove = function(whichEvent)
            local eventTable, checkTable
            local button
            if whichEvent.oskey then
                eventTable = eventsOfKeyAndMetakey
                checkTable = oskeyChecksOfMetakey
                button = whichEvent.oskey
            else
                eventTable = eventsOfMouseAndMetakey
                checkTable = mouseChecksOfMetakey
                button = whichEvent.mouseButton
            end

            local event
            for __, metakey in ipairs(whichEvent.metakeys) do
                for i = 1, #eventTable[metakey][button] do
                    event = eventTable[metakey][button][i]
                    if event == whichEvent then
                        table.remove(eventTable[metakey][button], i)
                        if #eventTable[metakey][button] == 0 then
                            checkTable[metakey][button] = nil
                        end
                        break
                    end
                end
            end

            if whichEvent.isActive then
                for j = 1, #activeEvents do
                    if activeEvents[j] == whichEvent then
                        table.remove(activeEvents, j)
                        return
                    end
                end
            end
        end,
    }

    local old = InitGlobals
    InitGlobals = function()
        old()
        TimerStart(CreateTimer(), INTERVAL, true, MainLoop)
    end
end
