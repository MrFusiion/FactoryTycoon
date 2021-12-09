local function getKeys(t)
    local keys = {}
    for k in pairs(t) do
        table.insert(keys, k)
    end
    return keys
end

return function(t)
    local index = 0
    local keys = getKeys(t)
    return function()
        index += 1
        if index <= #keys then
            return index, keys[index], t[keys[index]]
        end
    end
end

--[[
    local function enumerate(f: ()->(any), i: number?)
    i = i - 1 or 0
    return function()
        i += 1
        local vals = {f()}
        if #vals > 0 then
            return i, table.unpack(vals)
        end
    end
end
]]