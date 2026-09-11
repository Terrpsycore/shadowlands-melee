-- require('lib.native')
-- require('lib.base')
-- require('lib.oop')

require("vendor.ext.DebugUtils")
require("vendor.ext.IngameConsole")
IngameConsole.createTriggers()

seterrorhandler(function(msg)
    Debug.original.print("ERROR: " .. tostring(msg))
    Debug.original.print(Debug.traceback())
end)

require("vendor.ext.TotalInitialization")

require("vendor.ext.Timed")
require("vendor.ext.LinkedList")
require("vendor.ext.Influa")
require("vendor.ext.DamageEngine")

Debug.original.print("imports ready")

require("lib.triggers.init")
