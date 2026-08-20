-- require('lib.native')
-- require('lib.base')
-- require('lib.oop')

require("lib.community.DebugUtils")
require("lib.community.IngameConsole")
IngameConsole.createTriggers()

require("lib.community.TotalInitialization")

require("lib.community.Hook")
require("lib.community.Timed")
require("lib.community.DamageEngine")

Debug.original.print("imports ready")
