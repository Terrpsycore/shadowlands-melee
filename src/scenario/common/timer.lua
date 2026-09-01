local myGameTimer = CreateTimer()

TimerStart(myGameTimer, 99999.0, false, nil)

function GetElapsedGameTime()
    return TimerGetElapsed(myGameTimer)
end

return GetElapsedGameTime
