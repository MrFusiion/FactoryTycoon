local hidden = false
local tools = {}
local hiddenConnection

local Backpack = {}
Backpack.Player = game:GetService("Players").LocalPlayer
Backpack.Folder = Backpack.Player:WaitForChild("Backpack")

Backpack.Temp = Instance.new("Folder")
Backpack.Temp.Name = "BackpackHidden"
Backpack.Temp.Parent = Backpack.Player


function Backpack:hide()
    if not hidden then
        if not game:IsLoaded() then
            game.Loaded:Wait()
        end

        hiddenConnection = self.Folder.ChildAdded:Connect(function(child)
            task.wait()
            child.Parent = self.Temp
            table.insert(tools, child)
        end)

        for _, tool in ipairs(self.Folder:GetChildren()) do
            tool.Parent = self.Temp
            table.insert(tools, tool)
        end

        hidden = true
    end
end


function Backpack:show()
    if hidden then
        hiddenConnection:Disconnect()

        for _, tool in ipairs(tools) do
            tool.Parent = self.Folder
        end
        tools = {}

        hidden = false
    end
end


return Backpack