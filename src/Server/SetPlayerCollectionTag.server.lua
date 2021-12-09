local CS = game:GetService("CollectionService")

local conns = {}

game:GetService("Players").PlayerAdded:Connect(function(player)
    local char = player.Character or player.CharacterAdded:Wait()
    CS:AddTag(char, "Player")

    conns[player] = player.CharacterAdded:Connect(function(char)
        CS:AddTag(char, "Player")
    end)
end)

game:GetService("Players").PlayerRemoving:Connect(function(player)
    local conn = conns[player]
    if conn then
        conns[player] = conn:Disconnect()
    end
end)