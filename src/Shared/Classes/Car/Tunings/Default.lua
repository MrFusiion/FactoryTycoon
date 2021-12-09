local tune = {}
do

--[[Wheel Alignment]]
	--[Values are in degrees]
	tune.FCamber			= 0
	tune.RCamber			= 0
	tune.FToe				= 0
	tune.RToe				= 0

--[[Weight and CG]]
	tune.Weight				= 6000									-- Total weight (in pounds)
	tune.WeightBSize		= Vector3.new(							-- Size of weight brick (dimmensions in studs ; larger = more stable)
--[[Width ]] 5,
--[[Height]] 8,
--[[Length]] 17
	)
	tune.WeightDist			= 0.6									-- Weight distribution (0 - on rear wheels, 1 - on front wheels, can be <0 or >100)
	tune.CGHeight			= 0.8									-- Center of gravity height (studs relative to median of all wheels)

	tune.FWDensity			= 0.1									-- Front Wheel Density
	tune.RWDensity			= 0.1									-- Rear Wheel Density

	tune.AxleSize			= 2										-- Size of structural members (larger = more stable/carry more weight)
	tune.AxleDensity		= 0.1									-- Density of structural members

	tune.StAxisOffset		= Vector3.new(							-- Steer Axis Offset
		0,
		0,
		0
	)

--[[Engine]]
    tune.Config         	= "AWD"                                     --"FWD" , "RWD" , "AWD"

    tune.Speed              = 50
	tune.ReverseSpeed		= 40
	tune.Acceleration		= 20
	tune.BrakeForce 		= 200
    tune.AngularTorque      = 2e3
    tune.AngularP           = 1

--[[Susupension]]
	tune.SusEnabled			= true									-- works only in with PGSPhysicsSolverEnabled, defaults to false when PGS is disabled

	--[Aesthetics]
	tune.SusVisible			= false									-- Spring Visible
	tune.SusRadius			= 0.2									-- Suspension Coil Radius
	tune.SusThickness		= 0.1									-- Suspension Coil Thickness
	tune.SusColor			= BrickColor.new("Really black")		  -- Suspension Color [BrickColor]
	tune.SusCoilCount		= 6										-- Suspension Coil Count

	--[Front Suspension]
	tune.FWsBoneLength		= 5										-- Wishbone Length
	tune.FWsBoneAngle		= 0										-- Wishbone angle (degrees from horizontal)
	tune.FSusLength			= 1										-- Suspension length (in studs)
	tune.FSusAngle			= 90									-- Suspension Angle (degrees from horizontal)
	tune.FAnchorOffset		= {										-- Suspension anchor point offset (relative to center of wheel)
--[[+ forward]] X = 0,
--[[+ upward ]] Y = -0.3,
--[[+ outward]] Z = -0.4,
	}

	tune.FPreCompress		= 0.95									-- Pre-compression adds resting length force
	tune.FExtensionLim		= 1.1									-- Max Extension Travel (in studs)
	tune.FCompressLim		= 0.1									-- Max Compression Travel (in studs)
	tune.FSusDamping		= 300									-- Spring Dampening
	tune.FSusStiffness		= 8000									-- Spring Force
	tune.FAntiRoll			= 50									-- Anti-Roll (Gyro Dampening)

	--[Rear Suspension]
	tune.RWsBoneLength		= 5										-- Wishbone Length
	tune.RWsBoneAngle		= 0										-- Wishbone angle (degrees from horizontal)
	tune.RSusLength			= 1										-- Suspension length (in studs)
	tune.RSusAngle			= 90									-- Suspension Angle (degrees from horizontal)
	tune.RAnchorOffset		= {										-- Suspension anchor point offset (relative to center of wheel)
--[[+ forward]] X = 0,
--[[+ upward ]] Y = -0.3,
--[[+ outward]] Z = -0.4,
	}

	tune.RPreCompress		= 0.95									-- Pre-compression adds resting length force
	tune.RExtensionLim		= 1.1									-- Max Extension Travel (in studs)
	tune.RCompressLim		= 0.1									-- Max Compression Travel (in studs)
	tune.RSusDamping		= 300									-- Spring Dampening
	tune.RSusStiffness		= 8000									-- Spring Force
	tune.RAntiRoll			= 50									-- Anti-Roll (Gyro Dampening)

--[[Wheel Stabilizer Gyro]]
	tune.FGyroDamp		= 100										-- Front Wheel Non-Axial Dampening
	tune.RGyroDamp		= 100										-- Rear Wheel Non-Axial Dampening

	--[[Steering]]
	tune.Steer			= 45										-- Inner wheel steering angle (in degrees)
	tune.SteerSpeed		= 1.0										-- Steering increment per tick (in degrees)
	tune.ReturnSpeed	= 2.0										-- Steering increment per tick (in degrees)
	tune.SteerDecay		= 320										-- Speed of gradient cutoff (in SPS)
	tune.MinSteer		= 10										-- Minimum steering at max steer decay (in percent)

	--[Steer Gyro Tuning]
	tune.SteerD			= 1000										-- Steering Dampening
	tune.SteerMaxTorque	= 50000										-- Steering Force
	tune.SteerP			= 90000										-- Steering Aggressiveness

--[[Brakes]]
	tune.FBrakeForce	= 1900										-- Front brake force
	tune.RBrakeForce	= 2200										-- Rear brake force
	tune.PBrakeForce	= 5000										-- Handbrake force

--[[Seats]]
	tune.SeatCFOffset	= CFrame.new(0, 0, 0)						-- Player seatweld offset
	tune.SeatCFAngle	= CFrame.Angles(0, 0, 0)					-- Player seatweld angle

--[[Sound]]
	tune.SoundIdleSpeed = 0.5
	tune.SoundMaxSpeed	= 1.15
	tune.SoundVolume 	= 1
	tune.SoundId 		= "rbxassetid://5257534962"
	tune.SoundEffects	= {
		{
			Type = "EqualizerSoundEffect",
			Properties = {
				HighGain = -80,
				LowGain  =   3,
				MidGain  =   2,
			}
		}
	}

end
return tune