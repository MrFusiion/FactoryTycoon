while not _G.Loaded do task.wait() end

local Property = require(game:GetService("ReplicatedStorage")
    :WaitForChild("Classes")
    :WaitForChild("Property")
)

local myProperty
_G.Remotes:onEvent("Property.PropertySet", function(prop)
    myProperty = Property.recreate(prop)
    myProperty:buildMode(true)
end)