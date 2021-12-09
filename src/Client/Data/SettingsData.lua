local Theme = _G.Client.Theme
local Platform = _G.Client.Platform

local player = game:GetService("Players").LocalPlayer

return function(Data)
    local platformDV = Data:newValue("Platform", Platform:getPlatform())

    local inputTypeDV = Data:newValue("InputType", Platform:getInputType())
    Platform.InputTypeChanged:Connect(function(inputType)
        inputTypeDV:set(inputType)
    end)

    --local themeV = player:WaitForChild("Theme")
    local themeDV = Data:newValue("Theme", Theme.new("Dark"))
    --[[themeV:GetPropertyChangedSignal("Value"):Connect(function()
        Theme:setTheme(themeV.Value)
    end)]]
end