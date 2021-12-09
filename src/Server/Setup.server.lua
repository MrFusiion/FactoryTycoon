local Spawns = workspace.Terrain.Spawns
local Replicate = workspace.ReplicatedStorage

--[[
    Cleanup Spawns
]]
do
    for _, spawn in ipairs(Spawns:GetChildren()) do
        spawn.Transparency = 1
        for _, child in ipairs(spawn:GetChildren()) do
            child:Destroy()
        end
    end
end

--[[
    ReplicatedStorage
]]
do
    Replicate.Floors:Destroy()
    for _, folder in ipairs(Replicate:GetChildren()) do
        folder.Parent = game:GetService('ReplicatedStorage')
    end
end