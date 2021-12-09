while not _G.Loaded do task.wait() end

local DS = game:GetService("Debris")
local PS = game:GetService("PhysicsService")

local Random = _G.Shared.Random
local Debug = require(script.Parent.Parent.Debug)

local IgnoreList = { workspace.Terrain:WaitForChild("Regions") }

local Shapes = game:GetService("ReplicatedStorage"):WaitForChild("Crystals")

local VacuumLock = require(script.Parent.Parent.VacuumLock)

local MIN_REQUIRED_LENGTH_FOR_SPLITTING = .025
local NUM_THETA_CHECKS = 6
local NUM_RHO_CHECKS = 3


--@class Crystal
local Crystal = {}
Crystal.Class = "Crystal"


---@param model Model
---@return Part
local function newPart(shape, model)
	local part = Shapes[shape]:Clone()

	part.Anchored = true

	part:SetAttribute("ResourcePart", true)
	part:SetAttribute("Owner", 0)
	part:SetAttribute("LastInteraction", 0)

	local modelValue = Instance.new("ObjectValue")
	modelValue.Name = "Model"
	modelValue.Value = model
	modelValue.Parent = part

	--PS:SetPartCollisionGroup(part, "Resource")

	return part
end

--===========================================================================================--
--======================================/ ParticeClass /======================================--


---@class CrystalParticle
local CrystalParticle = {}
local CrystalParticle_mt = { __index = CrystalParticle }


---@param type string
---@param props table
function CrystalParticle.new(type: string, props: table)
	local self = {}
	self.Type = type
	self.Props = props
	return setmetatable(self, CrystalParticle_mt)
end


---@return table
function CrystalParticle:newInstance()
	local particle = Instance.new(self.Type)
	for propName, propValue in pairs(self.Props) do
		particle[propName] = propValue
	end
	return particle
end

Crystal.Particle = CrystalParticle

--===========================================================================================--
--======================================/ Constructor /======================================--


--- Creates a new Crytal
---@param ParentModel Model
function Crystal.new(ParentModel : Model)
    local newCrystal = {}
    newCrystal.ParentModel = ParentModel

	newCrystal.Locked = false

	newCrystal.GrowCalls = 0
    newCrystal.FinishedGrowing = false
	newCrystal.Stage = "Growing"

	return newCrystal
end

--=========================================================================================--
--====================================/ Grow Clocking /====================================--


--- calls grow() if not finsihed growing yet
--- or calls age() if finished growing
---@param timePassed number
---@param acceratedGrowth boolean
function Crystal:growCheck(timePassed : number, acceratedGrowth : boolean)
	if self.VacuumLock.Locked then return end
	self.TimeToNextGrow -= timePassed
	if self.TimeToNextGrow <= 0 and not self.FinishedGrowing then
		self:grow()
		self.TimeToNextGrow = Random:nextRange(self.GrowInterval)
	elseif _G.Config.RESOURCES_CHECK_AGE then
		if self.FinishedGrowing and not acceratedGrowth then
			self:age(timePassed)
		end
	end

	if self.Debug then
		self.Debug:update()
	end
end

--=========================================================================================--
--====================================/ Seed Planting /====================================--


--- Return True if the crystal can be placed there
---@param cf CFrame
---@param otherCrystals table
function Crystal:canPlaceHere(cf : CFrame, otherCrystals : table) : boolean
	for _, tree in pairs(otherCrystals) do
		if tree.SeedCFrame then
			if (tree.SeedCFrame.Position - cf.Position).Magnitude < self.MinSpawnDistanceToOtherCrystals then
				return false
			end
		end
	end
	return true
end


--- Places the Crystal
---@param cf CFrame
function Crystal:place(cf : CFrame)
	self.OriginCFrame = cf
	self.MaxGrowCalls = Random:nextRange(self.MaxGrowCalls)

	self.Model = Instance.new("Model")
	self.Model.Name = self.Name
	self.Model:SetAttribute("Resource", true)
	self.Model.Parent = self.ParentModel

	self.VacuumLock = VacuumLock.new(self)

	self.Size = Random:nextRange(self.ClusterSize)
	self.TimeToNextGrow = Random:nextRange(self.GrowInterval)

	self.ShellPart = newPart(self.Shape, self.Model)
	self.ShellPart.Name = "CrystalShell"
	self.ShellPart.Transparency = self.ShellTransparency
	self.ShellPart.BrickColor = self.ShellColor
	self.ShellPart.Material = self.ShellMaterial
	self.ShellPart.Size = Vector3.new(1, 1, 1) * self.Size
	self.ShellPart.CFrame = self.OriginCFrame * CFrame.new(0, self.Size*(.5 + self.Offset), 0)
	self.ShellPart.Parent = self.Model

	self.InnerPart = newPart(self.Shape, self.Model)
	self.InnerPart.Name = "CrystalInner"
	self.InnerPart.Transparency = self.InnerTransparency
	self.InnerPart.BrickColor = self.InnerColor
	self.InnerPart.Material = self.InnerMaterial
	self.InnerPart.Size = Vector3.new(1, 1, 1) * (self.Size - self.ShellThickness)
	self.InnerPart.CFrame = self.ShellPart.CFrame
	self.InnerPart.Parent = self.Model

	if self.Light then
		local light = Instance.new("PointLight")
		for propName, propValue in pairs(self.Light) do
			light[propName] = propValue
		end
		light.Parent = self.InnerPart
	end

	if self.Effects then
		for name, effect in pairs(self.Effects) do
			effect:new().Parent = self.ShellPart
		end
	end

	self.Debug = Debug.new(self)
end

--===================================================================================--
--====================================/ Cleanup /====================================--


--- Destroys the Ore
function Crystal:destroy()
	self.Model:Destroy()
end


--- Does a age check and kills the the Crystal if its time
---@param timePassed number
function Crystal:age(timePassed : number)
	if self.Stage == "Growing" then
		self.Stage = "Grown"
	end

	if self.Stage == "Grown" then
		self.TimeUntilDeath -= timePassed
		self.FinalVolume = self:getVolume()
	else
		self.TimeUntilDeath -= timePassed
	end

	if self.Stage == "Grown" then
		if self.TimeUntilDeath <= 0 then
			self.Stage = "Broken Up"
			self.TimeUntilDeath = 0
			self:kill()
        end
	elseif self.Stage == "Broken Up" then
		if self.TimeUntilDeath < -10 then
			self.Stage = "Dead"

		end
	end
end

--===========================================================================================--
--====================================/ Segment Growing /====================================--


--- Grows the current sections
---@param timePassed number
function Crystal:grow(timePassed : number)
    if self.FinishedGrowing then return end

    self.GrowCalls += 1

	if self:coneCheck(self.OriginCFrame * CFrame.new(0, self.Size, 0)) then
		local lengthGrow = Random:nextRange(self.SizeGrow)
		self.Size += lengthGrow
	end

	self.ShellPart.Size = Vector3.new(1, 1, 1) * self.Size
	self.ShellPart.CFrame = self.OriginCFrame * CFrame.new(0, self.Size*(.5 + self.Offset), 0)
	self.InnerPart.Size = Vector3.new(1, 1, 1) * (self.Size - self.ShellThickness)
	self.InnerPart.CFrame = self.ShellPart.CFrame

    if self.GrowCalls > self.MaxGrowCalls then
		self.FinishedGrowing = true
		self.FinalVolume = self:getVolume()
		self.TimeUntilDeath = self.FinalVolume * self.LifetimePerVolume + Random:nextInt(120, 360)
		self.Stage = "Grown"
	end
end


--- Gets the volume of all sections and sub Trees
---@return number
function Crystal:getVolume()
	return self.Size^3
end


--- Does a does n raycast in the form of a cone
---@param cf CFrame
---@return boolean
function Crystal:coneCheck(cf : CFrame)
	local ignoreList = { self.Model }

	for _, ignoreItem in ipairs(IgnoreList) do
		table.insert(ignoreList, ignoreItem)
	end

	for _, player in pairs(game.Players:GetPlayers()) do
		table.insert(ignoreList, player.Character)
	end

	local checkCFrame = cf
	for rho=math.rad(self.SpaceCheckCone.angle)/NUM_RHO_CHECKS, math.rad(self.SpaceCheckCone.angle), math.rad(self.SpaceCheckCone.angle)/NUM_RHO_CHECKS do
		for theta=math.pi*2/NUM_THETA_CHECKS, math.pi*2, math.pi*2/NUM_THETA_CHECKS do
			local unit=(checkCFrame * CFrame.Angles(0, theta, rho) * CFrame.Angles(math.pi/2,0,0) * CFrame.new(0, 1, 0)).LookVector

			local rayParams = RaycastParams.new()
			rayParams.FilterDescendantsInstances = ignoreList
			rayParams.FilterType = Enum.RaycastFilterType.Blacklist

			if workspace:Raycast(checkCFrame.Position, unit * self.SpaceCheckCone.dist, rayParams) then
				self.FinishedGrowing = true
				self.FinalVolume = self:getVolume()
				self.TimeUntilDeath = self.FinalVolume * self.LifetimePerVolume
				return false
			end
		end
	end
	return true
end


--- Kills the Crystal. after 15 sec Crystal:Destroy()
function Crystal:kill()
	spawn(function()
		self.FinishedGrowing = true
		self.TimeUntilDeath = 0
		self.FinalVolume = self:getVolume()
		self.Stage = "Broken Up"

		self.InnerPart:Destroy()
		for _, effect in ipairs(self.ShellPart:GetChildren()) do
			effect:Destroy()
		end

		self.ShellPart.Material = "SmoothPlastic"
		self.ShellPart.BrickColor = BrickColor.new("Black")
		self.ShellPart.Transparency = 0
		self.ShellPart.Anchored = false

		wait(10)

		self.ShellPart.CanCollide = false

		wait(5)

		self:destroy()
	end)
end


return Crystal