-- Fluent Bit Lua script to add checksum to log records
-- This script calculates a checksum of the log record content

local callCount = 0

function log(msg)
    local timestamp = os.date("%Y/%m/%d %H:%M:%S")
    print("[" .. timestamp .. "] [ script] " .. msg)
end

function add_checksum(tag, timestamp, record)
    if (callCount % 50000 == 0) then
      log("Processed " .. callCount .. " records")
    end
    callCount = callCount + 1

    -- Convert the record to a deterministic string representation
    local record_string = ""

    -- Sort keys for consistent ordering
    local keys = {}
    for k, v in pairs(record) do
        table.insert(keys, k)
    end
    table.sort(keys)

    -- Build string representation
    for _, key in ipairs(keys) do
        record_string = record_string .. key .. "=" .. tostring(record[key]) .. "|"
    end

    -- Add timestamp to the string for uniqueness
    record_string = record_string .. "ts=" .. tostring(timestamp)

    -- Calculate checksum (simplified version since Lua doesn't have built-in CRC32)
    local checksum = 0
    for i = 1, string.len(record_string) do
        checksum = (checksum * 31 + string.byte(record_string, i)) % 0xFFFFFFFF
    end

    -- Format as hexadecimal string
    record["record_checksum"] = string.format("%08x", checksum)

    -- Return modified record
    return 1, timestamp, record
end
