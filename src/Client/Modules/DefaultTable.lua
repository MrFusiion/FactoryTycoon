local DefaultTable = {}
local DefaultTable_mt = { __index = DefaultTable }

function DefaultTable.new(values: table)
    local self = {}

    self.Values = {}
    for k, v in pairs(values) do
        self.Values[k] = v
    end

    return setmetatable(self, DefaultTable_mt)
end

function DefaultTable:validate(t: table)
    local newT = {}
    for k, v in pairs(t) do
        newT[k] = v
    end
    for k, v in pairs(self.Values) do
        if newT[k] == nil then
            newT[k] = v
        end
    end
    return newT
end

return DefaultTable