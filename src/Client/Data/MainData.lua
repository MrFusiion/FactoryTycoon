return function(Data)
    local player = game:GetService("Players").LocalPlayer

    local cashV = player:WaitForChild("Cash")
    local cashDV = Data:newValue("Cash", cashV.Value)

    cashV:GetPropertyChangedSignal("Value"):Connect(function()
        cashDV:set(cashV.Value)
    end)

    local slotV = player:WaitForChild("Slot")
    local slotDV = Data:newValue("Slot", slotV.Value)
    slotV:GetPropertyChangedSignal("Value"):Connect(function()
        slotDV:set(slotV.Value)
    end)
end