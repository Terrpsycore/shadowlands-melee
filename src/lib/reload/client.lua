local Engine = require("lib.reload.engine")
local Registry = require("lib.reload.registry")
local Contract = require("lib.reload.contract")
require("vendor.ext.FileIO")

local Client = {
    lastSeq = 0,
    nextInbound = 1,
    pollCancel = nil,
    disabled = false,
}

local function log(msg)
    Debug.original.print("|cff88ccff[reload]|r " .. tostring(msg))
end

local function normalizeFileKey(path)
    return path:gsub("\\", "/")
end

local function loadInboxFromRaw(raw)
    if not raw or raw == "" then
        return nil
    end
    local fn, err = load(raw, "@inbox.lua", "t", {})
    if not fn then
        return nil, err
    end
    local ok, inbox = pcall(fn)
    if not ok or type(inbox) ~= "table" then
        return nil, inbox
    end
    return inbox
end

local function peekInboxRaw()
    local path = Contract.inboxPath(Client.nextInbound)
    local raw = FileIO.Load(path)
    if not raw or raw == "" then
        return nil
    end
    return raw
end

local function consumeInbound()
    Client.nextInbound = Client.nextInbound + 1
end

local function applyReload(inbox)
    local Bootstrap = require("lib.triggers.bootstrap")
    local patches = inbox.patches or {}
    if #patches == 0 then
        return false, "empty patches"
    end

    local normalized = {}
    for _, patch in ipairs(patches) do
        normalized[#normalized + 1] = {
            file = normalizeFileKey(patch.file),
            source = patch.source,
        }
    end

    local ok, err = Registry.applyPatches(normalized)
    if not ok then
        return false, err
    end

    Engine.teardown()
    Bootstrap.reregister()
    return true
end

local function writeAck(seq)
    FileIO.Save(Contract.ackPath(), string.format('{"seq":%d,"ok":true}', seq))
end

local function resumeFromAck()
    local ackSeq = Contract.parseAckSeq(FileIO.Load(Contract.ackPath()))
    if ackSeq <= 0 then
        return
    end
    Client.lastSeq = ackSeq
    Client.nextInbound = ackSeq + 1
    log("resume ack seq=" .. tostring(ackSeq) .. " next inbox=" .. tostring(Client.nextInbound))
end

local function runFileioSelfTest()
    local pingPath = Contract.pingPath()
    local ok, err = pcall(function()
        FileIO.Save(pingPath, "ping")
        local back = FileIO.Load(pingPath)
        if back ~= "ping" then
            error("roundtrip got " .. tostring(back))
        end
    end)
    if ok then
        log("FileIO ok (fileioLoad in map)")
        resumeFromAck()
    else
        Client.disabled = true
        log("FileIO self-test failed: " .. tostring(err))
        log("poller off (fix fileioLoad in object data / Allow Local Files)")
    end
end

local function pollOnce()
    if Client.disabled then
        return
    end

    local raw = peekInboxRaw()
    if not raw then
        return
    end

    local inbox, err = loadInboxFromRaw(raw)
    if not inbox or not inbox.seq then
        log("inbox parse: " .. tostring(err or "expected return { seq, patches }"))
        consumeInbound()
        return
    end
    if inbox.seq <= Client.lastSeq then
        consumeInbound()
        return
    end

    local ok, applyErr = pcall(function()
        local applied, applyReason = applyReload(inbox)
        if not applied then
            error(tostring(applyReason or "applyReload failed"))
        end
    end)
    if ok then
        Client.lastSeq = inbox.seq
        writeAck(inbox.seq)
        consumeInbound()
        log("ok seq=" .. tostring(inbox.seq) .. " patches=" .. tostring(#(inbox.patches or {})))
    else
        log("error: " .. tostring(applyErr))
    end
end

function Client.start()
    if Client.pollCancel or Client.disabled then
        return
    end
    log("poller started (" .. Contract.inboxDir() .. "\\N.pld)")
    Timed.call(1, runFileioSelfTest)
    Client.pollCancel = Timed.echo(0.1, pollOnce)
end

function Client.stop()
    if Client.pollCancel then
        Client.pollCancel()
        Client.pollCancel = nil
    end
end

return Client
