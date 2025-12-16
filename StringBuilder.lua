-- A single-threaded StringBuilder implementation
local StringBuilder = {}

local NEWLINE = "\n"

local buffer = {}

StringBuilder.clear = function()
    table.clear(buffer)
end

StringBuilder.append = function(text)
    table.insert(buffer, text)
end

StringBuilder.toString = function()
    return table.concat(buffer, NEWLINE)
end

return StringBuilder