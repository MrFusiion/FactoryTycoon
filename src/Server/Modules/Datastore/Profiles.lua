local Players = game:GetService("Players")
local Table = _G.Shared.Table

return function (Datastore)
    Datastore.addProfile("Data.Cash", {
        DefaultValue = _G.Config.DFLT_CASH,
        BackupValue = _G.Config.DFLT_CASH,

        serialize = function(_, data)
            return ("$ %d"):format(data)
        end,

        deserialize = function(self, data)
            local suc, val = pcall(function()
                return tonumber(data:match("%d+"))
            end)

            if suc then
                return val
            else
                return self:getDefaultValue()
            end
        end
    })


    Datastore.addProfile("Data.Land", {
        DefaultValue = _G.Config.DFLT_LAND,
        BackupValue = _G.Config.DFLT_LAND,

        serialize = function(_, data)
            return table.concat(data)
        end,

        deserialize = function(_, data)
            local t = {}
            for i=1, #data do
                table.insert(t, tonumber(data:sub(i, i)))
            end
            return t
        end
    })


    Datastore.addProfile("Data.Slots", {
        DefaultValue = Table.create(4, function()
            return {}
        end),
        BackupValue = Table.create(4, function()
            return {}
        end)
    })
end