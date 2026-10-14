--- Hot reload OS ↔ map contract. Sync constants with tools/reload_contract.py.
local Contract = {
    RELOAD_FOLDER = "shadowlands-melee-reload",
    INBOX_SUBDIR = "inbox",
    ACK_BASENAME = "ack.json",
    PING_BASENAME = "_ping.pld",
    INBOX_EXTENSION = ".pld",
}

local PATH_SEP = "\\"

function Contract.inboxDir()
    return Contract.RELOAD_FOLDER .. PATH_SEP .. Contract.INBOX_SUBDIR
end

function Contract.inboxPath(seq)
    return Contract.inboxDir() .. PATH_SEP .. tostring(seq) .. Contract.INBOX_EXTENSION
end

function Contract.ackPath()
    return Contract.RELOAD_FOLDER .. PATH_SEP .. Contract.ACK_BASENAME
end

function Contract.pingPath()
    return Contract.RELOAD_FOLDER .. PATH_SEP .. Contract.PING_BASENAME
end

---@param raw string|nil
---@return integer
function Contract.parseAckSeq(raw)
    if not raw or raw == "" then
        return 0
    end
    local seq = tonumber(raw:match('"seq"%s*:%s*(%d+)'))
    return seq or 0
end

return Contract
