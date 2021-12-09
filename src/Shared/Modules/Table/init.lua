local Table = setmetatable({}, { __index = table })
Table.enumerate =  require(script:WaitForChild("enumerate"))
Table.zip =        require(script:WaitForChild("zip"))
Table.contains =   require(script:WaitForChild('contains'))


--- Removes the last value of a table and then returns it.
---@param t table
---@return table
Table.pop = function(t: table)
    local lastIndex = #t
    local value = t[lastIndex]
    table.remove(t, lastIndex)
    return value
end


--- Returns an Array of the keys of the given table.
---@param t table
---@return table
Table.keys = function(t: table)
    local keys = {}
    for k in pairs(t) do
        table.insert(keys, k)
    end
    return keys
end


--- Returns an Array of the values of the given table.
---@param t table
---@return table
Table.values = function(t: table)
    local values = {}
    for _, v in pairs(t) do
        table.insert(values, v)
    end
    return values
end

--- Combines multiple tables into one.
---@vararg table
---@return table
Table.combine = function(...: {any: table})
    local out = {}
    for _, t in ipairs(...) do
        if typeof(t) == "table" then
            for k, v in pairs(t) do
                if typeof(k) == "string" then
                    out[k] = v
                else
                    table.insert(out, v)
                end
            end
        end
    end
    return out
end


--- Gets the __index table 'Inheritence'
---@param t table
Table.super = function(t: table)
    return (getmetatable(t) or {}).__index
end


--- Table size 'n' filled with the given value. If the given value is a function
--- then than that function gets called for each index and the return value gets stored.
---@param n number
---@param value any
---@return table
Table.create = function(n: number, value: any)
    if typeof(value) == "function" then
        local t = {}
        for i=1, n do
            t[i] = value(i)
        end
        return t
    else
        return table.create(n, value)
    end
end

return Table