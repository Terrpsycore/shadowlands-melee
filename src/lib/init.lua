-- require('lib.native')
-- require('lib.base')
-- require('lib.oop')

require("lib.community.DebugUtils")
require("lib.community.IngameConsole")
IngameConsole.createTriggers()

seterrorhandler(function(msg)
    Debug.original.print("ERROR: " .. tostring(msg))
    Debug.original.print(Debug.traceback())
end)

require("lib.community.TotalInitialization")

require("lib.community.Timed")
require("lib.community.LinkedList")
require("lib.community.Influa")
require("lib.community.DamageEngine")

Debug.original.print("imports ready")
