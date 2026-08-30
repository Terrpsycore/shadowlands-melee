local Storage = require("lib.storage.instance")
local htApi = require("lib.storage.ht")

local makeUnitSet = require("lib.storage.unitSet")
local makeUnitFields = require("lib.storage.unitFields")
local makeRecord = require("lib.storage.record")

function Storage.unitSet(name)
    return makeUnitSet(name)
end

function Storage.unitFields(name, schema)
    return makeUnitFields(name, schema)
end

function Storage.record(name, schema)
    return makeRecord(name, schema)
end

Storage.ht = htApi.ht
Storage.GLOBAL = htApi.GLOBAL

return Storage
