local DS = game:GetService("Debris")
local PS = game:GetService("PhysicsService")

while not _G.Loaded do task.wait() end

local Random = _G.Shared.Random
local debug = require(script.Parent.Parent.Debug)

local conecheckIgnoreList = { workspace.Terrain:WaitForChild("Regions") }

local vacuumLock = require(script.Parent.Parent.VacuumLock)

local NUM_THETA_CHECKS = 6
local NUM_RHO_CHECKS = 3
local MIN_REQUIRED_LENGTH_FOR_SPLITTING = .025


--@class Tree
local Tree = {}
Tree.Class = "Tree"
Tree.LeafClass = require(script.Leaves) --Default LeafClass fallback


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
--======================================/ Constructor /======================================--

--- Creates a new Tree
---@param parentModel Model
---@param branchParentTree table
function Tree.new(parentModel : Model, branchParentTree : table)
    local newTree = {}

	newTree.IsABranch = not not branchParentTree
	newTree.BranchParentTree = branchParentTree
    newTree.ParentModel = parentModel

	newTree.Sections = {}
	newTree.Locked = false
	newTree.Branches = {}

	newTree.GrowCalls = 0
	newTree.FinishedGrowing = false
	newTree.Stage = "Growing"

    return newTree
end
--=========================================================================================--
--====================================/ Grow Clocking /====================================--

--- calls grow() if not finsihed growing yet
--- or calls age() if finished growing
---@param timePassed number
---@param acceratedGrowth boolean
function Tree:growCheck(timePassed : number, acceratedGrowth : boolean)
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

--- Places the Tree
---@param cf CFrame
---@param distUp number
function Tree:place(cf : CFrame, distUp : number)
	self.Model = Instance.new("Model")

	if not self.IsABranch then
		cf *= CFrame.Angles(0, math.rad(Random:nextRange(self.TrunkAngleTheta)), math.rad(Random:nextRange(self.TrunkAnglePhi)))
		self.VacuumLock = vacuumLock.new(self)
	end

	self.OriginCFrame = cf
	self.MaxGrowCalls = Random:nextRange(self.MaxGrowCalls)

	self.Model.Name = self.Name
	self.Model.Parent = self.ParentModel

	self.LeafModel = Instance.new("Model")
	self.LeafModel.Name = "Leaves"
	self.LeafModel.Parent = self.Model

	self:newSection(cf, "Seed", distUp)
	self.TimeToNextGrow = Random:nextRange(self.GrowInterval)

	if not self.BranchParentTree then
		self.Onwer = Instance.new("ObjectValue", self.Model)
		self.Onwer.Name = "Owner"
		local lastInteractionV = Instance.new("IntValue", self.Onwer)
		lastInteractionV.Name = "LastInteraction"

		--TODO Tree owner ship mannager script
	else
		self.Onwer = self.BranchParentTree.Onwer
	end

	self.Debug = debug.new(self)
end

--===================================================================================--
--====================================/ Cleanup /====================================--


--- Destroys the Tree
function Tree:destroy()
	self.Model:Destroy()
end


--- Does a age check and kills the the Tree if its time
---@param timePassed number
function Tree:age(timePassed : number)
	if self.Stage == "Growing" then
		self.Stage = "Grown"
	end

	if self.Stage == "Grown" or self.Stage == "Leaves Fallen" then
		self.TimeUntilDeath -= timePassed
	else
		self.TimeUntilDeath -= timePassed
	end

	if self.Stage == "Grown" then
		if self.TimeUntilDeath < self.LeafDropTime then
			self.Stage = "Leaves Fallen"
			self:dropLeaves()
		end
	elseif self.Stage == "Leaves Fallen" then
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
function Tree:grow(timePassed : number)
	if self.FinishedGrowing then return end

	self.GrowCalls += 1

	local foundGrowingSection = false
	local existingSections = #self.Sections
	for ID = 1, existingSections do
		local section = self.Sections[ID]
		if section and section.IsGrowing then
			foundGrowingSection = true

			local stopForBranches = self.MaxGrowCalls - self.GrowCalls < self.NewBranchCutoff and self.BranchClasses
			if section.IsExtremety and not stopForBranches and self:coneCheck(section) then
				local lengthGrow = Random:nextRange(self.LengthGrow)

				section.Length += lengthGrow
				section.DistanceToBend -= lengthGrow
				section.DistanceToSplit -= lengthGrow
				section.DistanceToBranch -= lengthGrow

				if section.DistanceToSplit <= 0 and section.Length > MIN_REQUIRED_LENGTH_FOR_SPLITTING then
					self.Sections[ID].IsExtremety = false
					self:split(section, "Split", section.Length, self.NumSplits, self.SplitAngle, self.SplitUnitYComponentConstraints, self.AllowableAngleBetweenSplits)
				elseif section.DistanceToBend <= 0 and section.Length > MIN_REQUIRED_LENGTH_FOR_SPLITTING then
					self.Sections[ID].IsExtremety = false
					self:split(section, "Bend", section.Length, { min=1, max=1 }, self.BendAngle, self.BendUnitYComponentConstraints, { min=0, max=180 })
				elseif section.DistanceToBranch <= 0 and self.BranchClasses then
					section.DistanceToBranch = Random:nextRange(self.DistanceBetweenBranching)--BACK
					self:split(section, "Branch", section.Length, self.NumBranches, self.BranchAngle, self.BranchUnitYComponentConstraints, self.AllowableAngleBetweenBranches)
				end
			end

			section.Thickness += Random:nextRange(self.ThicknessGrow)
			section.Part.Size = Vector3.new(section.Thickness, section.Length, section.Thickness)
			section.Part.CFrame = section.StartCFrame * CFrame.new(0, section.Length * .5, 0)

			self:updateLeaves(section)
		end
	end

	if self.GrowCalls > self.MaxGrowCalls or not foundGrowingSection then
		self.FinishedGrowing = true
		self.FinalVolume = self:getVolume()
		self.TimeUntilDeath = self.FinalVolume * self.LifetimePerVolume + Random:nextInt(120, 360)
		self.Stage = "Grown"
	end

	for i, branch in pairs(self.Branches) do
		branch.branch:grow(timePassed)
		if not branch.branch.Model.Parent then
			self.Branches[i] = nil
		end
	end
end


--- Gets the volume of all sections and sub Trees
---@return number
function Tree:getVolume()
	local volume = 0
	local existingSections = #self.Sections
	for ID = 1, existingSections do
		local section = self.Sections[ID]
		if section and section.Part then
			volume += section.Part.Size.X * section.Part.Size.Y * section.Part.Size.Z
		end
	end

	for i, branch in pairs(self.Branches) do
		volume += branch.branch:getVolume()
	end

	return volume
end


--- Does a does n raycast in the form of a cone
---@param sectionOrCFrame table | CFrame
---@return boolean
function Tree:coneCheck(sectionOrCFrame : {table | CFrame})
	local ignoreList = { self.LeafModel, self.Model }

	for _, ignoreItem in ipairs(conecheckIgnoreList) do
		table.insert(ignoreList, ignoreItem)
	end

	for _, player in pairs(game.Players:GetPlayers()) do
		table.insert(ignoreList, player.Character)
	end

	if typeof(sectionOrCFrame) == "table" and self.Sections[sectionOrCFrame.ParentId] then
		table.insert(ignoreList, self.Sections[sectionOrCFrame.ParentId].Part)
		for _, childId in pairs(self.Sections[sectionOrCFrame.ParentId].ChildrenSections) do
			table.insert(ignoreList, self.Sections[childId].Part)
		end
	end

	local checkCFrame = typeof(sectionOrCFrame) == "CFrame" and sectionOrCFrame or sectionOrCFrame.StartCFrame * CFrame.new(0, sectionOrCFrame.Length, 0)
	for rho=math.rad(self.SpaceCheckCone.angle)/NUM_RHO_CHECKS, math.rad(self.SpaceCheckCone.angle), math.rad(self.SpaceCheckCone.angle)/NUM_RHO_CHECKS do
		for theta=math.pi*2/NUM_THETA_CHECKS, math.pi*2, math.pi*2/NUM_THETA_CHECKS do
			local unit=(checkCFrame * CFrame.Angles(0, theta, rho) * CFrame.Angles(math.pi/2,0,0) * CFrame.new(0, 1, 0)).LookVector

			local rayParams = RaycastParams.new()
			rayParams.FilterDescendantsInstances = ignoreList
			rayParams.FilterType = Enum.RaycastFilterType.Blacklist

			if workspace:Raycast(checkCFrame.Position, unit * self.SpaceCheckCone.dist, rayParams) then
				if typeof(sectionOrCFrame) == "table" then
					sectionOrCFrame.IsGrowing = false
					if sectionOrCFrame.ID == 1 then
						self:destroy()
					end
					return false
				end
			end
		end
	end
	return true
end

--=========================================================================================--
--======================================/ Splitting /======================================--


--- does a split. Types: "Seed", "Split", "Bend", "Branch"
---@param parentBranch table
---@param type string
---@param distUp number
---@param numSplits number
---@param splitAngle table
---@param unitYComponentConstraints table
---@param allowableAngleBetweenSplits table
function Tree:split(parentBranch : table, type : string, distUp : number, numSplits : table, splitAngle : table, unitYComponentConstraints : table, allowableAngleBetweenSplits : table)
	local diff1 = self.MaxGrowCalls - self.GrowCalls
	local diff2 = self.BranchParentTree and self.BranchParentTree.MaxGrowCalls - self.BranchParentTree.GrowCalls or self.NewBranchCutoff
	if diff1 < self.NewBranchCutoff or diff2 < self.NewBranchCutoff then
		return
	end

	numSplits = Random:nextRangeInt(numSplits)

	local splitDistBounds = { min=math.sqrt(2 - 2 * math.cos(math.rad(allowableAngleBetweenSplits.min))), max=math.sqrt(2 - 2 * math.cos(math.rad(allowableAngleBetweenSplits.max))) }--Values between 0 and 2

	local newCFrames = {}
	for _=1, self.NumNewSegmentAttempts do
		local splitSuccess = true
		for _=#newCFrames + 1, numSplits do
			local newTheta = Random:nextRange({ min=0, max=math.pi*2 })
			local newPhi = math.rad(Random:nextRange(splitAngle))
			local angle = CFrame.Angles(0, newTheta, newPhi) * CFrame.Angles(0, -newTheta, 0)
			local resultCFrame = parentBranch.StartCFrame * CFrame.new(0, parentBranch.Length, 0) * angle

			local unit = (resultCFrame * CFrame.Angles(math.pi*.5, 0, 0)).LookVector --Check that section attempts do not violate Y unit vector bounds and do cone check
			if unit.Y > unitYComponentConstraints.max or unit.Y < unitYComponentConstraints.min or not self:coneCheck(resultCFrame) then
				--print("Y violation")
				splitSuccess = false
				break
			end

			local success = true
			for _, cf in ipairs(newCFrames) do--Check that section attempts do not violate bounds for allowable angle between splits
				local dist = ((resultCFrame * CFrame.new(0, 1, 0)).Position - (cf.netCFrame * CFrame.new(0, 1, 0)).Position).Magnitude
				if dist < splitDistBounds.min or dist > splitDistBounds.max then
					newCFrames = {}--Throw out new branch, clean out list and start over
					--print("D violation", "min: ", splitDistBounds.min, "max: ", splitDistBounds.max, "dist: ", dist)
					success = false
					break
				end
			end

			if not success then
				splitSuccess = false
				break
			end

			table.insert(newCFrames, {netCFrame=resultCFrame, angle=angle})
		end

		if splitSuccess then
			break
		end
	end

	local success = #newCFrames > 0 --Success does not necessarily mean the amount of desired branches was reached
	if success then
		for _, cf in ipairs(newCFrames) do
			self:newSection(cf.netCFrame, type, distUp, parentBranch.ID, cf.angle)
		end
		if type ~= "Branch" then
			self:destroyLeaves(parentBranch)
		end
	elseif not success and type ~= "Branch" then
		parentBranch.IsGrowing = false
		--print("No SplitSuccess")
	end
end

--============================================================================================--
--====================================/ Segment Creation /====================================--


--- Creates a new Section
---@param cf CFrame
---@param type string
---@param distUp number
---@param parentId number
---@param angle CFrame
function Tree:newSection(cf : CFrame, type : string, distUp : number, parentId : number, angle : CFrame)
	local parentSection = self.Sections[parentId]

	if type == "Branch" then
		local branch = Random:choice(self.BranchClasses)
		local newTree = require(branch.class)

		newTree = newTree.new(self.Model, self)
		newTree.SkipTrunkYield = branch.skipTrunkYield

		newTree:place(cf)

		table.insert(self.Branches, { branch=newTree, parentId=parentId })
		return
	end

	local section = {}
	section.Part = newPart(self.Model)
	section.Part.Name = type

	if typeof(self.BarkColor) == "function" then
		self:BarkColor(section.Part)
	else
		section.Part.BrickColor = self.BarkColor
	end

	if typeof(self.BarkMaterial) == "function" then
		self:BarkMaterial(section.Part)
	else
		section.Part.Material = self.BarkMaterial
	end

	--section.InnerWoods = {}

	if parentSection then --Came from another branch
		if type == "Bend" then
			section.Thickness = parentSection.Thickness - Random:nextRange(self.BendThicknessReduce)
		elseif type == "Split" then
			section.Thickness = parentSection.Thickness - Random:nextRange(self.SplitThicknessReduce)
		end
		section.AncestryLength = parentSection.Length + parentSection.AncestryLength
	elseif type == "Seed" then
		section.Thickness = Random:nextRange(self.SeedThickness)
		section.AncestryLength = 0
	end
	section.Length = .2

	section.StartCFrame = cf
	section.Part.Size = Vector3.new(section.Thickness, section.Length, section.Thickness)
	section.Part.CFrame = section.StartCFrame * CFrame.new(0, section.Length*.5, 0)
	section.Part.Parent = self.Model

	section.LeafBunch = self:newLeafBunch(section)

	section.IsExtremety = true
	section.IsGrowing = true

	if type == "Seed" then
		if self.SkipTrunkYield then
			section.DistanceToBend = Random:nextRange(self.DistanceBetweenBends)
			section.DistanceToSplit = Random:nextRange(self.DistanceBetweenSplits)
			section.DistanceToBranch = Random:nextRange(self.DistanceBetweenBranching)
		else
			section.DistanceToBend = Random:nextRange(self.TrunkDistanceUntilBending)
			section.DistanceToSplit = Random:nextRange(self.TrunkDistanceUntilSpliting)
			section.DistanceToBranch = Random:nextRange(self.TrunkDistanceUntilBranching)
		end
	elseif parentSection then
		if type == "Bend" then
			section.DistanceToBend = Random:nextRange(self.DistanceBetweenBends)
			section.DistanceToSplit = parentSection.DistanceToSplit
		elseif type == "Split" then
			section.DistanceToBend = parentSection.DistanceToBend
			section.DistanceToSplit = Random:nextRange(self.DistanceBetweenSplits)
		end
		section.DistanceToBranch = parentSection.DistanceToBranch
	end

	section.ID = #self.Sections + 1
	section.ParentId = parentId

	if parentSection then
		table.insert(self.Sections[parentId].ChildrenSections, section.ID)
	end
	section.ChildrenSections = {}

	self.Sections[#self.Sections + 1] = section
end

--=============================================================================================--
--======================================/ Leaf Creation /======================================--


--- Create a new LeafBunch
---@param section table
function Tree:newLeafBunch(section: table)
	local numLeaves = Random:nextRangeInt(self.NumLeafParts)

	local leaves = {}
	for i=1, numLeaves do --All the parts that make up a leaf bunch
		local newLeaf = self.LeafClass.new()

		newLeaf.LeafSizeFactor = Vector3.new(
			Random:nextRange(self.LeafSizeFactor.X),
			Random:nextRange(self.LeafSizeFactor.Y),
			Random:nextRange(self.LeafSizeFactor.Z)
    	)

    	newLeaf.LeafAngle = CFrame.Angles(0, math.pi*.5, 0)--Orient correctly
                        * CFrame.Angles(0, math.rad(Random:nextRange(self.LeafAngle.Y)), 0)--Spin
                        * CFrame.Angles(math.rad(Random:nextRange(self.LeafAngle.X)), 0, math.rad(Random:nextRange(self.LeafAngle.Z)))--Tilt

		newLeaf:init(self)

		leaves[i] = newLeaf
	end

	self:updateLeaves(section, leaves)

	return leaves
end


--- Updates the leaves
---@param section table
---@param leavesIn table | nil
function Tree:updateLeaves(section: table, leavesIn: {table | nil})
	local leaves = leavesIn or section.LeafBunch
	for _, leaf in pairs(leaves) do
		leaf:update(section)
	end
end


--- Destroys the leaves
---@param section table
function Tree:destroyLeaves(section: table)
	local leaves = section.LeafBunch
	for _, leaf in pairs(leaves or {}) do
		leaf:destroy()
	end
	self.Sections[section.ID].LeafBunch = {}
end


--- Drops the leaves
function Tree:dropLeaves()
	for ID = 1, #self.Sections do
		local section = self.Sections[ID]
		for _, part in ipairs(self.LeafModel:GetDescendants()) do
			if part:IsA("BasePart") then
				part.Anchored = false
				part.CanCollide = false
			end
		end
	end
end


--- Kills the Tree: foreach Branch:kill() and after 15 sec Tree:Destroy()
function Tree:kill()
	task.spawn(function()
		if self.Stage == "Growing" or self.Stage == "Grown" then
			self:dropLeaves()
		end

		self.FinishedGrowing = true
		self.TimeUntilDeath = 0
		self.FinalVolume = self:getVolume()
		self.Stage = "Broken Up"

		for _, branch in pairs(self.Branches) do
			if branch then
				branch.branch:kill()
			end
		end

		for ID = 1, #self.Sections do
			local section = self.Sections[ID]
			if section and section.Part then
				section.Part.Material = "SmoothPlastic"
				section.Part.BrickColor = BrickColor.new("Black")
				section.Part.Anchored = false
			end
		end

		task.wait(10)

		for ID = 1, #self.Sections do
			local section = self.Sections[ID]
			if section and section.Part then
				section.Part.CanCollide = false
			end
		end

		task.wait(5)

		self:destroy()
	end)
end


return Tree