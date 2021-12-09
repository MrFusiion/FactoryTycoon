---@class String
local _string = string
local string = setmetatable({}, { __index = _string })


---@param str string
---@param sep string | table
---@return function
function string.splitIter(str : string, sep : any) : any
    sep = sep or "%s"
    if type(sep) == "table" then
        sep = table.concat(sep)
    end
    return string.gmatch(str, "([^"..sep.."]+)")
end


---@param str string
---@param sep string | table
---@return table
function string.split(str : string, sep : any) : table
    local t={}
    for s in string.splitIter(str, sep) do
        table.insert(t, s)
    end
    return t
end


---@param str string
---@param sep string | table
function string.sepUpper(str : string, sep : any) : string
    sep = sep or " "
    local out = ""
    for s in string.gmatch(str, "(%u%l*)") do
        out = ("%s%s%s"):format(out, out ~= "" and sep or "", s)
    end
    return out
end


---@param str string
---@return function
function string.iter(str: string)
    local i = 1
    return function()
        local c = str:sub(i, i)
        if c ~= "" then
            i += 1
            return i-1, c
        end
    end
end

return string