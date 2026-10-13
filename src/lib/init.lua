require("vendor.ext.DebugUtils")

require("vendor.ext.IngameConsole")
IngameConsole.createTriggers()

require("lib.early_error_handler").install()

-- require("vendor.ext.TotalInitialization")

require("vendor.ext.Timed")
require("vendor.ext.LinkedList")
require("vendor.ext.Influa")
require("vendor.ext.DamageEngine")

Debug.original.print("imports ready")

require("lib.triggers.init")
