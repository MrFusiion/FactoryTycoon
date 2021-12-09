local Loaded = false

local Property = require(game:GetService("ReplicatedStorage")
    :WaitForChild("Classes")
    :WaitForChild("Property")
)

--Create remote events for server -> client coms
_G.Remotes:newEvent("Property.PropertySet")

local properties = {}
local propertyLookup = {}

while not _G.Loaded do task.wait() end

local LoadSlot, UnloadSlot = _G.Packages:get("SlotHandler"):get("LoadSlot", "UnloadSlot")

LoadSlot:Connect(function(player)
    while not Loaded do task.wait() end
    for _, property in ipairs(properties) do
        if not property.Onwer then
            property:setOwner(player)
            propertyLookup[player] = property
            break
        end
    end
end)

UnloadSlot:Connect(function(player)
    while not Loaded do task.wait() end
    for _, property in ipairs(properties) do
        if not property.Onwer == player then
            property:reset()
            propertyLookup[player] = nil
        end
    end
end)

_G.Remotes:onEvent("Property.ExpandProperty", function(player, i)
    if propertyLookup[player] then
        propertyLookup[player]:enableFloor(i)
    end
end)

for i, model in ipairs(workspace.Terrain.Properties:GetChildren()) do
    model.Name = string.format("Property(%d)", i)
    table.insert(properties, Property.create(model, _G.Config.LAND_SIZE))
end

Loaded = true