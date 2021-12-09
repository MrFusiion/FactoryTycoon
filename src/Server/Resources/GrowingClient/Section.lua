---@diagnostic disable: count-down-loop
while not _G.Loaded do task.wait() end

local Random = _G.Shared.Random

local section = {}
section.__index = section

local function createDebugRegion(min, max)
    local reg = Region3.new(min, max)
    local PS = game:GetService("PhysicsService")
    local part = Instance.new("Part")
    part.Name = "Debug"
    part.Transparency = .5
    part.BrickColor = BrickColor.Red()
    part.Material = "SmoothPlastic"
    part.CanCollide = false
    part.CanTouch = false
    part.Anchored = true
    part.CFrame = reg.CFrame
    part.Size = reg.Size
    PS:SetPartCollisionGroup(part, "Region")
    part.Parent = workspace
end

function section.new(max, classes, parts)
    local self = setmetatable({}, section)
    self.Max = max
    self.Resources = {}
    self.Classes = Random.toWeightedList(classes)

    self.LastPlant = 0
	self.ThisTick = nil
	self.LastTick = nil

    self.FloorSymbol = ("REGIONPART_%s"):format(tostring(self):gsub("table: ", ""))

    self.Parts = parts
    self.RegionBounds = {min = Vector3.new(1, 1, 1) * math.huge, max = Vector3.new(1, 1, 1) *  -math.huge}

	for _, part in pairs(parts) do
		if part:IsA("BasePart") then
			for x = -1, 1, 2 do
				for y = -1, 1, 2 do
					for z = -1, 1, 2 do
						local point = (part.CFrame * CFrame.new(Vector3.new(x * part.Size.X * .5, y * part.Size.Y * .5, z * part.Size.Z * .5))).Position
						self.RegionBounds.max = Vector3.new(
                            math.max(self.RegionBounds.max.X, point.X),
							math.max(self.RegionBounds.max.Y, point.Y),
						    math.max(self.RegionBounds.max.Z, point.Z)
                        )

                        self.RegionBounds.min = Vector3.new(
                            math.min(self.RegionBounds.min.X, point.X),
							math.min(self.RegionBounds.min.Y, point.Y),
						    math.min(self.RegionBounds.min.Z, point.Z)
                        )

                        part:SetAttribute(self.FloorSymbol, true)
					end
				end
			end
		end
	end
    --self.DebugPart = createDebugRegion(self.RegionBounds.min, self.RegionBounds.max)

    return self
end

function section:timeToPlant(spawnRate, growSpeed, superSpeed)
    return #self.Resources < self.Max and ((tick() - self.LastPlant) * growSpeed > spawnRate or superSpeed)
end

function section:newResource(parent)
    return Random:choice(self.Classes).new(parent)
end

function section:plantResouce(resource, cf)
    self.LastPlant = tick()
    resource:place(cf)
    table.insert(self.Resources, resource)
end

function section:updateResources(growSpeed, superSpeed)
    self.LastTick = self.ThisTick or tick() - .1
    self.ThisTick = tick()
    local timeDiff = self.ThisTick - self.LastTick

    local removeResource
    for i, resource in ipairs(self.Resources) do
        local suc, err = pcall(function()
            resource:growCheck(timeDiff  * growSpeed, superSpeed)
        end)

        if not suc then
            warn(err)
            resource:destroy()
        end

        if removeResource == nil and not resource.Model.Parent then
            removeResource = i
        end
    end

    if removeResource ~= nil then
        table.remove(self.Resources, removeResource)
        removeResource = nil
    end
    wait(1)
end

return section