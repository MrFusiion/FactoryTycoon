while not _G.Loaded do task.wait() end

local GuiManager = require(script.Parent.GuiManager)
local State = GuiManager.State

local player = game:GetService("Players").LocalPlayer

--<< Initial States >>
if _G.Config.LOADING_ENABLED then
    State:append("Loading")
end


--<< Connections >>
local slotV = player:WaitForChild("Slot")
slotV.Changed:Connect(function()
    if slotV.Value ~= -1 then
        State:append("Slot")
    else
        State:remove("Slot")
    end
end)

if slotV.Value ~= -1 then
    State:append("Slot")
end