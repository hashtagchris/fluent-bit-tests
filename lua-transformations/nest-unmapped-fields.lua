-- Nest unmapped fields under a specified field in the log record
-- This is a lua script because the Nest filter plugin doesn't current support an exclude list

-- Return values
local DROP = -1
local UNCHANGED = 0
local RECORD_CHANGED = 2

-- Based on OTel semantic conventions for log record fields
-- https://opentelemetry.io/docs/specs/otel/logs/data-model/#log-and-event-record-definition
local nestUnder = "attributes"

local mappedFields = {
  ["foo"] = true,
  ["bar"] = true,
  [nestUnder] = true,  -- to avoid nesting under itself
}

function nest_unmapped_fields(tag, timestamp, record)
  if record[nestUnder] ~= nil and type(record[nestUnder]) ~= "table" then
    -- cannot nest under a non-table field
    print("Warning: cannot nest unmapped fields under '" .. nestUnder .. "' because it is not a table")
    return UNCHANGED, timestamp, record
  end

  local code = UNCHANGED

  if record[nestUnder] == nil then
    record[nestUnder] = {}
    code = RECORD_CHANGED
  end

  -- identify unmapped fields first, in case modifying the record affects iteration
  local unmappedFields = {}
  for key in next, record do
    if mappedFields[key] == nil then
      unmappedFields[#unmappedFields + 1] = key
    end
  end

  -- nest the unmapped fields
  for _, key in ipairs(unmappedFields) do
    record[nestUnder][key] = record[key]
    record[key] = nil
    code = RECORD_CHANGED
  end

  return code, timestamp, record
end
