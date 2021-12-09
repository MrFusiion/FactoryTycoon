while not _G.Loaded do task.wait() end

local Random = _G.Shared.Random
local WaitInterval = _G.Shared.WaitInterval

local growingClient = {}
growingClient.Section = require(script.Section)
growingClient.__index = growingClient

local MAX_FIND_SPOT_TRIES = _G.Config.RESOURCES_MAX_FIND_SPOT_TRIES
local RAY_HEIGHT = _G.Config.RESOURCES_RAY_HEIGHT

function growingClient.new(name, sections, topSpawnRate, customSpawnRateFunc)
    local self = setmetatable({}, growingClient)

    self.Name = name
    self.Sections = sections

    self.Initialized = false
    self.SuperSpeed = false
    self.GrowSpeed = 1
    self.TopSpawnRate = topSpawnRate
    self.customSpawnRateFunc = customSpawnRateFunc

    self.Model = Instance.new("Model", _G.Config.RESOURCES_REGION_PARENT)
    self.Model.Name = ("Region(%s)"):format(self.Name)

    return self
end

function growingClient:getSpawnRate(section)
    if self.CustomSpawnRateFunc then
        return self.TopSpawnRate * self.CustomSpawnRateFunc(#section.Resources / section.Max)
    else
        return self.TopSpawnRate * (#section.Resources / section.Max) ^ 0.5
    end
end

function growingClient:canPlaceHere(cf : CFrame) : boolean
    local function canPlace(cf, resources)
        for _, resource in ipairs(resources) do
            if resource.OriginCFrame then
                if (resource.OriginCFrame.Position - cf.Position).Magnitude < resource.MinSpawnDistanceToOther then
                    return false
                end
            end
        end
        return true
    end

    for _, section in ipairs(self.Sections) do
        if not canPlace(cf, section.Resources) then
            return false
        end
    end
    return true
end

function growingClient:findPlantSpot(section, resource)
    local ignoreStuff = {}
	for _, player in pairs(game.Players:GetPlayers()) do
		table.insert(ignoreStuff, player)
	end
    if section.DebugPart then
        table.insert(ignoreStuff, section.DebugPart)
    end

    local wait = WaitInterval.new(5)
    for _= 1, MAX_FIND_SPOT_TRIES do
		local randPoint = Vector3.new(
            Random:nextNumber(section.RegionBounds.min.X, section.RegionBounds.max.X),
            section.RegionBounds.max.Y + RAY_HEIGHT,
            Random:nextNumber(section.RegionBounds.min.Z, section.RegionBounds.max.Z)
        )

        local rayParams = RaycastParams.new()
        rayParams.FilterDescendantsInstances = ignoreStuff
        rayParams.FilterType = Enum.RaycastFilterType.Blacklist

		local result = workspace:Raycast(randPoint, Vector3.new(0, section.RegionBounds.min.Y - section.RegionBounds.max.Y - RAY_HEIGHT, 0), rayParams)

		if result and result.Instance:GetAttribute(section.FloorSymbol) then
            local point = CFrame.new(result.Position)
            if self:canPlaceHere(point) then
                return point
            end
        elseif result and (_G.Config.RESOURCES_BLACKLIST_NAMES[result.Instance.Name] or result.Instance.Transparency == 1 or not result.Instance.Anchored) then
            table.insert(ignoreStuff, result.Instance)
		end

        wait:checkWait()
	end
end

function growingClient:plantResource(section)
    if section:timeToPlant(self:getSpawnRate(section), self.GrowSpeed, self.SuperSpeed) then
        local newResource = section:newResource(self.Model)

        local wait = WaitInterval.new(5)
        local spot
        for _=1, 100 do
            spot = self:findPlantSpot(section, newResource)
            if spot then
                section:plantResouce(newResource, spot)
                break
            end

            wait:checkWait()
        end
    end
end

function growingClient:init()
    self.GrowSpeed = 100
    self.SuperSpeed = true
    task.spawn(function()
        while true do
            local allDone = true

            for _, section in ipairs(self.Sections) do
                if #section.Resources < section.Max then
                    allDone = false
                end
            end

            if allDone then
                task.wait(10)
                self.GrowSpeed = 1
                self.SuperSpeed = false
                self.Initialized = true
                break
            end

            task.wait(1)
        end
    end)
end

function growingClient:start()
    self.Running = true
    while self.Running do
        for _, section in ipairs(self.Sections) do
            task.spawn(function()
                self:plantResource(section)
                section:updateResources(self.GrowSpeed, self.SuperSpeed)
            end)
        end
        task.wait(1 / self.GrowSpeed)
    end
end

function growingClient:stop()
    self.Running = false
end

return growingClient