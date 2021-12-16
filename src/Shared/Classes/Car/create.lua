local ServerStorage = game:GetService("ServerStorage")
while not _G.Loaded do task.wait() end

local WEIGHT_SCALING = 1/50
local DEBUG = _G.Config.CAR_DEBUG


local function weld(a: BasePart, b: BasePart, parent: Instance?)
	local w = Instance.new("WeldConstraint")
	w.Part0 = a
	w.Part1 = b
	w.Parent = parent or b
	return w
end


local function weldModel(model: Model, weldTo: BasePart)
	for _, desc in ipairs(model:GetDescendants()) do
		if desc:IsA("BasePart") then
			weld(weldTo, desc)
		end
	end
end


local function noCollision(a: BasePart, b: BasePart, parent: Instance?)
	local c = Instance.new("NoCollisionConstraint")
	c.Part0 = a
	c.Part1 = b
	c.Parent = parent or b
	return c
end


local function getMass(parent: Instance)
	local mass = 0

	if parent:IsA("BasePart") then
		mass += parent:GetMass()
	end

	for _, desc in ipairs(parent:GetDescendants()) do
		if desc:IsA("BasePart") then
			mass += (desc.Massless and desc:GetRootPart() ~= desc and 0) or desc:GetMass()
		end
	end

	return mass
end


local function getSeats(parent: Instance)
	local seats = {}
	for _, desc in ipairs(parent:GetDescendants()) do
		if desc:IsA("VehicleSeat") or desc:IsA("Seat") then
			table.insert(seats, {
				Seat = desc,
				Parts = {},
			})
		end
	end
	return seats
end

--[[
local function convertWheelMesh(wheel: BasePart)
	local mesh = SPHERE:Clone()
	mesh.Name = wheel.Name
	mesh.Size = wheel.Size
	mesh.CFrame = wheel.CFrame
	mesh.Material = wheel.Material
	mesh.BrickColor = wheel.BrickColor
	mesh.CustomPhysicalProperties = wheel.CustomPhysicalProperties
	mesh.Parent = wheel.Parent

	for _, child in ipairs(wheel:GetChildren()) do
		child.Parent = mesh
	end

	wheel:Destroy()
	return mesh
end]]


local function attachment(name: string, part: BasePart, pos: Vector3?, axis: Vector3?)
	local att = Instance.new("Attachment")
	att.Name = name

	if pos then
		att.Position = pos
	end

	if axis then
		att.Axis = axis
	end

	att.Parent = part
	return att
end


local function hinge(name: string, a: BasePart, b: BasePart, face: Enum.NormalId, parent: Instance?)

	local att0 = attachment(
		"[ATT]",
		a,
		Vector3.FromNormalId(face),
		Vector3.FromNormalId(face)
	)

	local att1 = att0:Clone()
	att1.Position = -Vector3.FromNormalId(face)
	att1.Parent = b

	local h = Instance.new("HingeConstraint")
	h.Name = name
	h.Attachment0 = att0
	h.Attachment1 = att1
	h.Parent = parent or b

	return h
end


local function alterPhysicalProps(part: BasePart, newProps: table)
	local currentProps = part.CustomPhysicalProperties or PhysicalProperties.new(part.Material)
	part.CustomPhysicalProperties = PhysicalProperties.new(
		newProps.Density        or currentProps.Density,
		newProps.Friction       or currentProps.Friction,
		newProps.Elasticy       or currentProps.Elasticity,
		newProps.FrictionWeight or currentProps.FrictionWeight,
		newProps.ElasticyWeight or currentProps.ElasticityWeight
	)
end


local function unAnchor(part: BasePart)
    if part:IsA("BasePart") then
        part.Anchored = false
    end

    for _, desc in ipairs(part:GetDescendants()) do
        if desc:IsA("BasePart") then
            desc.Anchored = false
        end
    end
end



return function(model: Model, tune: table)

	local hinges = Instance.new("Folder")
	hinges.Name = "Hinges"
	hinges.Parent = model

	local centerF = Vector3.new()
	local centerR = Vector3.new()
	local countF = 0
	local countR = 0

	local fDistX = tune.FWsBoneLength * math.cos(math.rad(tune.FWsBoneAngle))
	local fDistY = tune.FWsBoneLength * math.sin(math.rad(tune.FWsBoneAngle))
	local rDistX = tune.RWsBoneLength * math.cos(math.rad(tune.RWsBoneAngle))
	local rDistY = tune.RWsBoneLength * math.sin(math.rad(tune.RWsBoneAngle))

	local fSLX = tune.FSusLength * math.cos(math.rad(tune.FSusAngle))
	local fSLY = tune.FSusLength * math.sin(math.rad(tune.FSusAngle))
	local rSLX = tune.RSusLength * math.cos(math.rad(tune.RSusAngle))
	local rSLY = tune.RSusLength * math.sin(math.rad(tune.RSusAngle))

	-- Get driveseat
	local driveSeat
	for _=1, 3 do
		driveSeat = model:FindFirstChildWhichIsA("VehicleSeat")

		if driveSeat then
			break
		end
		task.wait()
	end
	assert(driveSeat~=nil, ("Car %s has no VehicleSeat!"):format(model:GetFullName()))

	-- Create sounds
	local engineSound = Instance.new("Sound")
	engineSound.Name = "EngineSound"
	engineSound.Volume = tune.SoundVolume
	engineSound.Looped = true
	engineSound.SoundId = tune.SoundId

	for _, effect in ipairs(tune.SoundEffects) do
		local suc, err = pcall(function()
			local inst = Instance.new(effect.Type)
			for propName, propVal in pairs(effect.Properties) do
				inst[propName] = propVal
			end
			inst.Parent = engineSound
		end)

		if not suc then
			warn(("Error creating sound effect %s, %s")
				:format(effect.Type, err))
		end
	end

	engineSound.Parent = driveSeat

	--Remove Existing Mass
	for _, desc in ipairs(model:GetDescendants()) do
		if desc:IsA("BasePart") then
			--[[alterPhysicalProps(desc, {
				Density = 0
			})]]
			desc.Massless = true

			if desc.CanCollide then
				--Fix collisions
				for _, part in ipairs(desc:GetTouchingParts()) do
					if part.CanCollide then
						noCollision(part, desc)
					end
				end
			end
		end
	end

	for _, wheel in ipairs(model.Wheels:GetChildren()) do
		--fix wheel mesh
		--wheel = convertWheelMesh(wheel)
		wheel.Massless = false

		local name = wheel.Name
		local isFrontWheel = name == "FL" or name == "FR" or name == "F"
		local isRearWheel = name == "RL" or name == "RR" or name == "R"


		if isFrontWheel then
			centerF = centerF + wheel.Position
			countF 	= countF  + 1
		elseif isRearWheel then
			centerR = centerR + wheel.Position
			countR 	= countR  + 1
		end

		--Store Axle-Anchored/Suspension-Anchored Part Orientation
		local wheelParts = {}

		if name == "FL" or name == "RL" then
			wheel.CFrame = ((driveSeat.CFrame - driveSeat.Position) * CFrame.Angles(0,  math.pi/2, 0)) + wheel.Position
		elseif name == "FR" or name == "RR" then
			wheel.CFrame = ((driveSeat.CFrame - driveSeat.Position) * CFrame.Angles(0, -math.pi/2, 0)) + wheel.Position
		end

		for _, v in ipairs{ wheel:FindFirstChild("Parts"), wheel:FindFirstChild("Fixed") } do
			for _, desc in ipairs(v:GetDescendants()) do
				if desc:IsA("BasePart") then
					table.insert(wheelParts, { Part = desc,
						CFrame = wheel.CFrame:toObjectSpace(desc.CFrame) })
				end
			end
		end

		-- Apply Wheel Density
		if isFrontWheel then
			if wheel:IsA("BasePart") then
				alterPhysicalProps(wheel, {
					Density = tune.FWDensity
				})
			end
		elseif isRearWheel then
			if wheel:IsA("BasePart") then
				alterPhysicalProps(wheel, {
					Density = tune.RWDensity
				})
			end
		end

		-- Align Wheel
		if name == "FL" or name == "FR" then
			if name == "FL" then
				wheel.CFrame = wheel.CFrame * CFrame.Angles(-math.rad(tune.FCamber), 0, 0)
											* CFrame.Angles(0, 0,  math.rad(tune.FToe))
			else
				wheel.CFrame = wheel.CFrame * CFrame.Angles(-math.rad(tune.FCamber), 0, 0)
											* CFrame.Angles(0, 0, -math.rad(tune.FToe))
			end
		elseif name == "RL" or name == "RR" then
			if name == "RL" then
				wheel.CFrame = wheel.CFrame * CFrame.Angles(-math.rad(tune.RCamber), 0, 0)
											* CFrame.Angles(0, 0,  math.rad(tune.RToe))
			else
				wheel.CFrame = wheel.CFrame * CFrame.Angles(-math.rad(tune.RCamber), 0, 0)
											* CFrame.Angles(0, 0, -math.rad(tune.RToe))
			end
		end

		--Re-orient Axle-Anchored/Suspension-Anchored Parts
		for _, a in pairs(wheelParts) do
			a.Part.CFrame = wheel.CFrame:toWorldSpace(a.CFrame)
		end


--[[Chassis Assembly]]
		-- Steering
		local arm = Instance.new("Part")
		arm.Name                        = "#ARM"
		arm.Anchored                    = true
		arm.CanCollide                  = false
		arm.Size                        = Vector3.new(tune.AxleSize, tune.AxleSize, tune.AxleSize)
		arm.CFrame                      = wheel.CFrame * CFrame.new(tune.StAxisOffset)
		arm.CustomPhysicalProperties    = PhysicalProperties.new(tune.AxleDensity, 0, 0, 100, 100)
		arm.Transparency                = DEBUG and 0.75 or 1
		arm.TopSurface					= Enum.SurfaceType.Smooth
		arm.BottomSurface				= Enum.SurfaceType.Smooth
		arm.BrickColor                  = BrickColor.new("Really red")
		arm.Parent                      = wheel

		-- Create Wheel Spindle
		local base = arm:Clone()
		base.Name       = "#BASE"
		base.CFrame     = base.CFrame * CFrame.new(0, tune.AxleSize, 0)
		base.BrickColor = BrickColor.new("Lime green")
		base.Parent     = wheel

		-- Create Steering Anchor
		local axle = arm:Clone()
		axle.Name       = "#AXLE"
		axle.CFrame     = axle.CFrame * CFrame.new(0, 0, wheel.Size.Z/2 + axle.Size.Z/2)
		axle.BrickColor = BrickColor.new("Deep blue")
		axle.Parent     = wheel

		--[[
		if name == "F" or name == "R" then
			local axle2 = arm:Clone()
			axle2.Name = "Axle"
			axle2.CFrame = CFrame.new(wheel.Position + wheel.CFrame.UpVector * ((wheel.Size.X/2) + (axle.Size.X/2)), wheel.Position)
				* CFrame.Angles(0, math.pi, 0)
			axle2.Parent = wheel
			weld(arm, axle2)
		end]]

		-- Create Suspension
		local sa = arm:Clone()
		sa.Name = "#SA"
		sa.BrickColor = BrickColor.new("Neon orange")
		sa.Parent = wheel
		if isFrontWheel then
			local aOff = tune.FAnchorOffset
			sa.CFrame = wheel.CFrame * CFrame.new(-tune.AxleSize/2, -fDistY, fDistX) * CFrame.new(aOff.X, aOff.Y, -aOff.Z)
		elseif isRearWheel then
			local aOff = tune.RAnchorOffset
			sa.CFrame = wheel.CFrame * CFrame.new(-tune.AxleSize/2, -rDistY, rDistX) * CFrame.new(aOff.X, aOff.Y, -aOff.Z)
		end

		local sb = sa:Clone()
		sb.Name     	= "#SB"
		sb.CFrame   	= sa.CFrame * CFrame.new(tune.AxleSize, 0, 0)
		sb.Parent   	= wheel

		local gyro = Instance.new("BodyGyro")
		gyro.Name       = "Stabilizer"
		gyro.MaxTorque  = Vector3.new(0, 1, 0)
		gyro.P          = 0
		gyro.Parent 	= sb

		local sp = Instance.new("SpringConstraint")
		sp.Name             = "Spring"
		sp.LimitsEnabled    = true
		sp.Visible          = tune.SusVisible
		sp.Radius           = tune.SusRadius
		sp.Thickness        = tune.SusThickness
		sp.Color            = tune.SusColor
		sp.Coils            = tune.SusCoilCount
		sp.Parent           = wheel

		if isFrontWheel then
			sp.Attachment0 = attachment("#SATT", sa,
				Vector3.new( tune.AxleSize/2, -fDistY + fSLY, -fDistX - fSLX))
			sp.Attachment1 = attachment("#SATT", sb,
				Vector3.new(-tune.AxleSize/2, -fDistY, -fDistX))
		elseif isRearWheel then
			sp.Attachment0 = attachment("#SATT", sa,
				Vector3.new( tune.AxleSize/2, -rDistY + rSLY, -rDistX - rSLX))
			sp.Attachment1 = attachment("#SATT", sb,
				Vector3.new(-tune.AxleSize/2, -rDistY, -rDistX))
		end

		if isFrontWheel then
			gyro.D          = tune.FAntiRoll
			sp.Damping      = tune.FSusDamping
			sp.Stiffness    = tune.FSusStiffness
			sp.FreeLength   = tune.FSusLength + tune.FPreCompress
			sp.MaxLength    = tune.FSusLength + tune.FExtensionLim
			sp.MinLength    = tune.FSusLength - tune.FCompressLim
		elseif isRearWheel then
			gyro.D          = tune.RAntiRoll
			sp.Damping      = tune.RSusDamping
			sp.Stiffness    = tune.RSusStiffness
			sp.FreeLength   = tune.RSusLength + tune.RPreCompress
			sp.MaxLength    = tune.RSusLength + tune.RExtensionLim
			sp.MinLength    = tune.RSusLength - tune.RCompressLim
		end

		--Weld Miscelaneous Parts
		if wheel:FindFirstChild("SuspensionFixed") then
			weldModel(wheel.SuspensionFixed, driveSeat)
		end
		if wheel:FindFirstChild("WheelFixed") then
			weldModel(wheel.WheelFixed, axle)
		end
		if wheel:FindFirstChild("Fixed") then
			weldModel(wheel.Fixed, arm)
		end

		--Weld Wheel Parts
		if wheel:FindFirstChild("Parts") then
			weldModel(wheel.Parts, wheel)
		end

		--Weld Assembly
		weld(arm, axle)
		weld(driveSeat, sa)
		weld(sb, base)
		hinge("Suspension", sa, sb, Enum.NormalId.Right ,  hinges)
		hinge("Axle", axle, wheel,  Enum.NormalId.Front ,  hinges)
		hinge("Base", base, arm,    Enum.NormalId.Bottom, hinges)

		if isFrontWheel then
			local steer = Instance.new("BodyGyro")
			steer.Name		= "#STEER"
			steer.P			= tune.SteerP
			steer.D			= tune.SteerD
			steer.MaxTorque = Vector3.new(0, tune.SteerMaxTorque, 0)
			steer.CFrame	= wheel.CFrame
			steer.Parent 	= arm
		elseif isRearWheel then
			--Lock Rear Steering Axle
			weld(base, axle)
		end

		--Add Stabilization Gyro
		local gyro = Instance.new("BodyGyro")
		gyro.Name 		= "#STABILIZER"
		gyro.MaxTorque 	= Vector3.new(1, 0, 1)
		gyro.D 			= isFrontWheel and tune.FGyroDamp or
				 		  isRearWheel  and tune.RGyroDamp or 0
		gyro.Parent 	= wheel

		if tune.Config == "AWD"
			or (isFrontWheel and tune.Config == "FWD")
			or (isRearWheel  and tune.Config == "RWD")
		then
			--Add Rotational BodyMover
			local AV=Instance.new("BodyAngularVelocity")
			AV.Name				= "#AV"
			AV.angularvelocity 	= Vector3.new(0, 0, 0)
			AV.maxTorque 		= Vector3.new(tune.AngularTorque, 0, tune.AngularTorque)
			AV.P 				= tune.AngularP
			AV.Parent 			= wheel
		end
	end

--[[Vehicle Weight]]
	--Determine Current Mass
	local mass = getMass(model)

	--Apply Vehicle Weight
	if mass < tune.Weight * WEIGHT_SCALING then
		--Calculate Weight Distribution

		centerF = centerF/countF
		centerR = centerR/countR
		local center = centerR:Lerp(centerF, tune.WeightDist)

		--Create Weight Brick
		local weightB = Instance.new("Part", model.Body)
		weightB.Name 						= "#WEIGHT"
		weightB.Anchored 					= true
		weightB.CanCollide 					= false
		weightB.Transparency 				= DEBUG and 0.75 or 1
		weightB.BrickColor					= BrickColor.new("Royal purple")
		weightB.Size 						= tune.WeightBSize
		weightB.CustomPhysicalProperties 	= PhysicalProperties.new(
			(tune.Weight * WEIGHT_SCALING - mass) / (weightB.Size.X * weightB.Size.Y * weightB.Size.Z), 0, 0, 0, 0
		)
		weightB.CFrame						= (driveSeat.CFrame - driveSeat.Position + center)
												* CFrame.new(0, tune.CGHeight, 0)
	else
		warn(("Mass too high for Car: %s.\
		Target Mass:  %d\
		Current Mass: %d")
			:format(model.Name, math.ceil(tune.Weight * WEIGHT_SCALING * 100) / 100, math.ceil(mass * 100) / 100))
	end

	local flipG = Instance.new("BodyGyro")
	flipG.Name 		= "#FLIP"
	flipG.D 		= 0
	flipG.MaxTorque = Vector3.new(0, 0, 0)
	flipG.P 		= 0
	flipG.Parent = driveSeat

--[[Finalize Chassis]]

	--Weld Sections
	for _, section in ipairs(model:GetChildren()) do
		if section:IsA("Model") and section.Name ~= "Wheels" then
			weldModel(section, driveSeat)	-- Weld descendants
		elseif section:IsA("Seat") then
			weld(driveSeat, section)		-- Weld chair
			weldModel(section, driveSeat)	-- Weld descendants
		elseif section:IsA("VehicleSeat") and section ~= driveSeat then
			section:Destroy()
			warn(("More then 1 VehicleSeat found destroyed one!"))
		end
	end
	weldModel(driveSeat, driveSeat)

	--Unanchor
	unAnchor(model)

	--[[Remove Character Weight]]
	for _, seat in ipairs(getSeats(model)) do
		seat.Seat:SetAttribute("IsCarSeat", true)

		-- Prompt
		local prompt: ProximityPrompt = seat.Seat:FindFirstChildWhichIsA("ProximityPrompt", true)
		if prompt then
			prompt.Triggered:Connect(function(player: Player)
				if not seat.Seat.Occupant then
					local char = player.Character
					local hum = char and char:FindFirstChild("Humanoid")
					if hum and not hum.SeatPart then
						seat.Seat:Sit(hum)
					end
				end
			end)
		end

		seat.Seat.CanCollide = false
		seat.Seat.CanTouch = false

		-- Sit and Leave Handler
		seat.Seat:GetPropertyChangedSignal("Occupant"):Connect(function()
			local hum = seat.Seat.Occupant

			if prompt then
				prompt.Enabled = hum == nil
			end

			-- Player sitted
			if hum then
				seat.Parts = {}

				for _, desc in ipairs(hum.Parent:GetDescendants()) do
					if desc:IsA("BasePart") then
						--Store old props
						table.insert(seat.Parts, {
							Part = desc,
							PProps = desc.CustomPhysicalProperties,
							CanCollide = desc.CanCollide
						})

						desc.CanCollide = false
						alterPhysicalProps(desc, {
							Density = 0
						})
					end
				end

				-- Driver seat
				if seat.Seat:IsA("VehicleSeat") then
					local player = game.Players:GetPlayerFromCharacter(hum.Parent)
					if player then
						driveSeat:SetNetworkOwner(player)
					end
				end

				local seatWeld = seat.Seat:FindFirstChild("SeatWeld")
				if seatWeld and seatWeld:IsA("Weld") then
					seatWeld.C0 = tune.SeatCFOffset
									* CFrame.Angles(-math.pi/2, 0, 0)
									* tune.SeatCFAngle
				end

			-- Player left
			else
				for _, v in ipairs(seat.Parts) do
					if v.Part then
						v.Part.CustomPhysicalProperties = v.PProps
						v.Part.CanCollide = v.CanCollide
					end
				end
				seat.Parts = {}

				-- Driver seat
				if seat.Seat:IsA("VehicleSeat") then

					-- Remove Flip Force
					local flip = seat.Seat:FindFirstChild("#FLIP")
					if flip then
						flip.MaxTorque = Vector3.new()
					end

					-- Remove Wheel Force
					for _, wheel in ipairs(model.Wheels:GetChildren()) do
						local av = wheel:FindFirstChild("#AV")
						if av then
							if av.AngularVelocity.Magnitude > 0 then
								av.AngularVelocity = Vector3.new()
								av.MaxTorque = Vector3.new()
							end
						end
					end
				end
			end
		end)
	end

	return model
end