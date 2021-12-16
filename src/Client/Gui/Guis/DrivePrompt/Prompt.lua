local ProxPS = game:GetService("ProximityPromptService")
local UIS = game:GetService("UserInputService")

local player = game:GetService("Players").LocalPlayer

local function getIcon(seat: Seat)
    if seat:IsA("VehicleSeat") then
        return "rbxassetid://8265624779"
    end
    return "rbxassetid://8265626102"
end


local DrivePrompt = {}

function DrivePrompt:init(gui: BillboardGui)
    self.Prompt = gui
    self.Gui = gui.Parent

    gui.Parent = nil

    ProxPS.PromptShown:Connect(function(prompt, inputType)
        if prompt.Name == "DrivePrompt" then
            local promptUI = self:create(prompt, inputType)
            if promptUI then


                prompt.PromptHidden:Wait()
                promptUI:Destroy()
            end
        end
    end)
end

function DrivePrompt:create(prompt: ProximityPrompt, inputType: Enum.ProximityPromptInputType)
    local seat = prompt:FindFirstAncestorWhichIsA("Seat") or prompt:FindFirstAncestorWhichIsA("VehicleSeat")

    if seat then
        local promptUI = self.Prompt:Clone()
        promptUI.Adornee = prompt.Parent

        promptUI.Icon.Image = getIcon(seat)
        promptUI.Key.Label.Text = UIS:GetStringForKeyCode(prompt.KeyboardKeyCode)

        promptUI.Enabled = prompt.Enabled

        local humConn
        local hum = player.Character and player.Character:WaitForChild("Humanoid")
        if hum then
            humConn = hum:GetPropertyChangedSignal("SeatPart"):Connect(function()
                promptUI.Enabled = hum.SeatPart == nil
            end)
            promptUI.Enabled = hum.SeatPart == nil
        end

        prompt.Destroying:Connect(function()
            if humConn then
                humConn:Disconnect()
            end
        end)

        promptUI.Parent = self.Gui

        return promptUI
    else
        warn(("No seat found, No prompt was created!"))
    end
end

return DrivePrompt