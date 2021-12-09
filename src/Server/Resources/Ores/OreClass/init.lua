local DS = game:GetService("Debris")
local PS = game:GetService("PhysicsService")

while not _G.Loaded do task.wait() end

local Random = _G.Shared.Random
local Debug = require(script.Parent.Parent.Debug)

local VacuumLock = require(script.Parent.Parent.VacuumLock)

local MIN_REQUIRED_LENGTH_FOR_SPLITTING = .025

---@class Ore
local Ore = {}
Ore.Class = "Ore"


---@param model Model
---@return Part
local function newPart(model: Model)
	local part = Instance.new("Part")

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


---@class OreParticle
local OreParticle = {}
local OreParticle_mt = { __index = OreParticle }


---@param type string
---@param props table
function OreParticle.new(type: string, props: table)
	local self = {}
	self.Type = type
	self.Props = props
	return setmetatable(self, OreParticle_mt)
end


---@return table
function OreParticle:newInstance()
	local particle = Instance.new(self.Type)
	for propName, propValue in pairs(self.Props) do
		particle[propName] = propValue
	end
	return particle
end

Ore.Particle = OreParticle

--===========================================================================================--
--======================================/ Constructor /======================================--


--- Creates a new Ore
---@param ParentModel Model
function Ore.new(ParentModel : Model)
    local newOre = {}
    newOre.ParentModel = ParentModel

	newOre.Sections = {}
	newOre.Locked = false

	newOre.GrowCalls = 0
    newOre.FinishedGrowing = false
	newOre.Stage = "Growing"

	return newOre
end

--=========================================================================================--
--====================================/ Grow Clocking /====================================--


--- calls grow() if not finsihed growing yet
--- or calls age() if finished growing
---@param timePassed number
---@param acceratedGrowth boolean
function Ore:growCheck(timePassed : number, acceratedGrowth : boolean)
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


--- Places the Ore
---@param cf CFrame
function Ore:place(cf : CFrame)
	self.OriginCFrame = cf
	self.MaxGrowCalls = Random:nextRange(self.MaxGrowCalls)

	self.Model = Instance.new("Model")
	self.Model.Name = self.Name
	self.Model:SetAttribute("Resource", true)
	self.Model.Parent = self.ParentModel

	self.VacuumLock = VacuumLock.new(self)

	self.TimeToNextGrow = Random:nextRange(self.GrowInterval)

	for _=1, Random:nextRangeInt(self.SectionCount) do
		self:newSection(self.OriginCFrame)
	end

	self.Debug = Debug.new(self)
end

--===================================================================================--
--====================================/ Cleanup /====================================--


--- Destroys the Ore
function Ore:destroy()
	self.Model:Destroy()
end


--- Does a age check and kills the the Ore if its time
---@param timePassed number
function Ore:age(timePassed : number)
	if self.Stage == "Growing" then
		self.Stage = "Grown"
	end

	if self.Stage == "Grown" then
		self.TimeUntilDeath -= timePassed
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
function Ore:grow(timePassed : number)
    if self.FinishedGrowing then return end

    self.GrowCalls += 1

	for _, section in pairs(self.Sections) do
		for _, part in ipairs(section.Parts) do
			section.Size = section.Size + Vector3.new(
				Random:nextRange(self.SizeGrow),
				Random:nextRange(self.SizeGrow),
				Random:nextRange(self.SizeGrow)
			)

			part.Size = section.Size
			part.CFrame = section.StartCFrame * CFrame.new(0, section.Size.Y*.5, 0) * section.Angle * CFrame.new(section.Size * section.Offset)
		end
	end

    if self.GrowCalls > self.MaxGrowCalls then
		self.FinishedGrowing = true
		self.FinalVolume = self:getVolume()
		self.TimeUntilDeath = self.FinalVolume * self.LifetimePerVolume + Random:nextInt(120, 360)
		self.Stage = "Grown"
	end
end


--- Gets the volume of all sections and sub Trees
---@return number
function Ore:getVolume()
	local volume = 0
	for _, section in pairs(self.Sections) do
		volume += section.Size.X * section.Size.Y * section.Size.Z
	end
	return volume
end

--============================================================================================--
--====================================/ Segment Creation /====================================--


--- Creates a new Section
---@param cf CFrame
function Ore:newSection(cf : CFrame)
	local section = {}

	local phi = Random:nextRange(self.SectionPhi)
	local theta = Random:nextRange(self.SectionTheta)

	section.ID = #self.Sections + 1
	section.Parts = {newPart(self.Model)}
	section.Angle = CFrame.Angles(0, theta, phi) * CFrame.Angles(0, -theta, 0)
	section.StartCFrame = cf

	for _, part in ipairs(section.Parts) do
		part.Name = "Section"

		if self.Effects then
			for _, effect in pairs(self.Effects) do
				effect:new().Parent = section.Part
			end
		end

		if typeof(self.OreColor) == "function" then
			self:OreColor(part)
		else
			part.BrickColor = self.OreColor
		end

		if typeof(self.OreMaterial) == "function" then
			self:OreMaterial(part)
		else
			part.Material = self.OreMaterial
		end

		section.Offset = Vector3.new(
			Random:nextRange(self.SectionOffset),
			0,
			Random:nextRange(self.SectionOffset)
		)

		section.Size = Vector3.new(
			Random:nextRange(self.SectionSize),
			Random:nextRange(self.SectionSize),
			Random:nextRange(self.SectionSize)
		)


		part.Size = section.Size
		part.CFrame = section.StartCFrame * CFrame.new(0, section.Size.Y*.5, 0) * section.Angle * CFrame.new(section.Size * section.Offset)
		part.Parent = self.Model

		part:SetAttribute("ID", section.ID)
	end

	self.Sections[#self.Sections + 1] = section
end


--- Kills the Ore. after 15 sec Ore:Destroy()
function Ore:kill()
	task.spawn(function()
		self.FinishedGrowing = true
		self.TimeUntilDeath = 0
		self.FinalVolume = self:getVolume()
		self.Stage = "Broken Up"

		for _, section in pairs(self.Sections) do
			for _, part in ipairs(section.Parts) do
				for _, effect in pairs(part:GetChildren()) do
					effect:Destroy()
				end
				part.Material = "SmoothPlastic"
				part.BrickColor = BrickColor.new("Black")
				part.Anchored = false

				DS:AddItem(part, 15)
			end
		end

		task.wait(10)

		for _, section in pairs(self.Sections) do
			for _, part in ipairs(section.Parts) do
				part.CanCollide = false
			end
		end

		task.wait(5)

		self:destroy()
	end)
end


-- TODO: implement harvesting
function Ore:harvest(sectionId: number, x: number, y: number, radius: number)

end

return Ore