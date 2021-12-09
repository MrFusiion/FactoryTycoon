while not _G.Loaded do task.wait() end

local PS = game:GetService("PhysicsService")

--local bf_GetVacuumInfo = game.ServerScriptService.EquipmentHandler.GetVacuumInfo
--local be_AddResource = game.ServerScriptService.EquipmentHandler.AddResource


--@class VacuumLock
local VacuumLock = {}
local VacuumLock_mt = { __index = VacuumLock }


--- Gets the color according to the resource color
---@param resource table
local function getColor(resource: table)
    return resource.BarkColor or resource.InnerColor or resource.OreColor
end


--- Creates a new VacuumLock
---@param resource table
function VacuumLock.new(resource: table)
    local newVacuumLock = {}

    newVacuumLock.Resource = resource
    newVacuumLock.Model = resource.Model

    newVacuumLock.Locked = false

    newVacuumLock.Part = Instance.new("Part")
    newVacuumLock.Part.Name = "VacuumLock"
    newVacuumLock.Part.Transparency = 1
    newVacuumLock.Part.CanCollide = false
    newVacuumLock.Part.Anchored = true
    newVacuumLock.Part.Size = Vector3.new(1, 1, 1) * .01
    newVacuumLock.Part.Parent = newVacuumLock.Model

    newVacuumLock.Lock = Instance.new("Attachment")
	newVacuumLock.Lock.Name = "Lock"
	newVacuumLock.Lock.Parent = newVacuumLock.Part

    newVacuumLock.CurrentLock = nil

    local lockEvent = Instance.new("RemoteEvent")
    lockEvent.Name = "LockEvent"
    lockEvent.Parent = newVacuumLock.Model

    lockEvent.OnServerEvent:Connect(function(player)
        newVacuumLock.Part.Position = resource.OriginCFrame.Position + Vector3.new(0, 3, 0) * .5
        local tool = player.Character and player.Character:FindFirstChildWhichIsA("Tool")
        if tool then
            newVacuumLock:lock(player, tool)
        end
    end)

    local unlockEvent = Instance.new("RemoteEvent")
    unlockEvent.Name = "UnlockEvent"
    unlockEvent.Parent = newVacuumLock.Model

    unlockEvent.OnServerEvent:Connect(function(player)
        newVacuumLock:unlock(player)
    end)

	game.Close:Connect(function()
		newVacuumLock:unlock()
	end)

    return setmetatable(newVacuumLock, VacuumLock_mt)
end


--- Locks a vacuum to a Resource
---@param player Player
---@param tool Tool
function VacuumLock:lock(player: Player, tool: Tool)
    if not self.CurrentLock then
        --local handle = tool:FindFirstChild("Handle")--to be sure no error's happen, find the handle the safe way
        local beam = tool:FindFirstChildWhichIsA("Beam")

        if beam then
            task.spawn(function()
                local maxHealt = self.Resource.Hardness * self.Resource:getVolume()
                local health = maxHealt
                while self.Locked do
                    local stats --= bf_GetVacuumInfo:Invoke(player)
                    if stats then
                        --re_TargetDetails:FireClient(player, self.Resource.OriginCFrame.Position, self.Resource.Name,
                        --self.Resource.TextColor, math.max(0, health), maxHealt)
                        task.wait(stats.speed)
                        health -= stats.damage

                        if health <= 0 then
                            --print(string.format("%s Harvested %s with %s", player.Name, resource.Name, tool.Name))
                            --be_AddResource:Fire(player, self.Resource.Name, 5)
                            self.Resource:kill()
                            self:unlock(player)
                        end
                    end
                end
            end)

            local conn = beam:GetPropertyChangedSignal("Attachment1"):Connect(function()
                _G.print("Disconnect", self.Resource.Name)
                self:unlock(player)
            end)

            self.Locked = true
            beam.Attachment1 = self.Lock
            self.CurrentLock = { tool = tool, connections = { conn } }
        end
    end
end


--- Unlocks a vacuum to a Resource
---@param player Player
function VacuumLock:unlock(player)
    if self.CurrentLock then
        --local handle = self.CurrentLock.tool:FindFirstChild("Handle")--to be sure no error's happen, find the handle the safe way
        local beam = self.CurrentLock.tool:FindFirstChildWhichIsA("Beam")

        --re_TargetDetails:FireClient(player)

        for _, conn in ipairs(self.CurrentLock.connections) do
            conn:Disconnect()
        end
        self.Locked = false
        self.CurrentLock = nil

        if beam then
            if beam.Attachment1 == self.Lock then
                beam.Attachment1 = nil
            end
        end
    end
end


return VacuumLock