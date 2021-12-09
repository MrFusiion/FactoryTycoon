local car = require(game:GetService("ReplicatedStorage")
    :WaitForChild("Classes")
    :WaitForChild("Car")
).new(script.CarRef.Value)

local throttle = 0
local steer = 0
local angle = 0
local speed = 0
local flipping = false
local flipWait = 0

local engineSound = car.Sounds.Engine
engineSound.PlaybackSpeed = car.Tune.SoundIdleSpeed
engineSound:Play()

local loop = game:GetService("RunService").Heartbeat:Connect(function(dt)

    -- Steer
    for _, wheel in ipairs(car.Front) do
        local name = wheel.Name

        --local sDecay = (1 - math.min(car.DriveSeat.AssemblyLinearVelocity.Magnitude / car.Tune.SteerDecay, 1 - car.Tune.MinSteer))
        --local angle = math.max(math.min(angle + steer * car.Tune.SteerSpeed))
        if steer == 0 then
            if angle > 0 then
                angle = math.max(angle - car.Tune.ReturnSpeed, 0)
            else
                angle = math.min(angle + car.Tune.ReturnSpeed, 0)
            end
        else
            angle = math.min(math.max(angle + steer * car.Tune.SteerSpeed,  -car.Tune.Steer), car.Tune.Steer)
        end

        --[[
        if name =="F" then
            wheel.Steer.CFrame = wheel.Base.CFrame * CFrame.Angles(0, -math.rad(angle), 0)
        elseif name =="FL" then
            wheel.Steer.CFrame = wheel.Base.CFrame * CFrame.Angles(0, -math.rad(angle), 0)
        elseif name =="FR" then
            wheel.Steer.CFrame = wheel.Base.CFrame * CFrame.Angles(0, -math.rad(angle), 0)
        end]]

        wheel.Steer.CFrame = wheel.Base.CFrame * CFrame.Angles(0, -math.rad(angle), 0)
    end

    -- Flip
    --Detect Orientation
	if flipping or (car.DriveSeat.CFrame * CFrame.Angles(math.pi/2, 0, 0)).LookVector.Y > 0.1 then
		flipWait = tick()
	else
        --Apply Flip
		if tick() - flipWait >= 1 then
			flipping = true

			local gyro = car.FlipG
			gyro.maxTorque = Vector3.new(10000, 0, 10000)
			gyro.P = 3000
			gyro.D = 500

			task.wait(1)
			gyro.maxTorque = Vector3.new(0, 0, 0)
			gyro.P = 0
			gyro.D = 0
			flipping = false
		end
	end

    -- Engine
    if throttle > 0 then
         -- Forward
        if speed < 0 then
            speed = math.min(speed + car.Tune.BrakeForce * dt, 0)
        else
            speed = math.min(speed + car.Tune.Acceleration * dt,  car.Tune.RPS * math.abs(throttle))
        end

    elseif throttle < 0 then
        -- Reverse
        if speed > 0 then
            speed = math.max(speed - car.Tune.BrakeForce * dt, 0)
        else
            speed = math.max(speed - car.Tune.Acceleration * dt, -car.Tune.ReverseRPS * math.abs(throttle))
        end

    else
        -- Deaccelerate
        if speed > 0 then
            speed = math.max(speed - car.Tune.Acceleration * 0.5 * dt, 0)
        else
            speed = math.min(speed + car.Tune.Acceleration * 0.5 * dt, 0)
        end

    end

    -- Sounds
    engineSound.PlaybackSpeed = (car.Tune.SoundIdleSpeed + (car.Tune.SoundMaxSpeed - car.Tune.SoundIdleSpeed) * (math.abs(speed) / car.Tune.RPS))

    -- Throttle
    for _, wheel in ipairs(car:getDriveWheels()) do
        local name = wheel.Name

        local ref = -wheel.Arm.CFrame.LookVector
        local sign = 1
        if name == "FL" or name == "RL" then
            sign = -1
        end

        wheel.AV.AngularVelocity = ref * speed * sign
    end
end)


local conns = {}
local function destroy()
    local forceStop = false

    loop:Disconnect()
    for _, conn in ipairs(conns) do
        conn:Disconnect()
    end

    for _, wheel in ipairs(car.Wheels) do
        steer = 0
        speed = 0
        if wheel.AV then
            wheel.AV.AngularVelocity = Vector3.new(0, 0, 0)
        end
        if wheel.Steer then
            wheel.Steer.CFrame = wheel.Base.CFrame
        end
    end

    local seatConn, runConn
    seatConn = car.DriveSeat:GetPropertyChangedSignal("Occupant"):Connect(function()
        if car.DriveSeat.Occupant  then
            forceStop = true
        end
    end)

    runConn = game:GetService("RunService").RenderStepped:Connect(function(dt)
        engineSound.PlaybackSpeed = engineSound.PlaybackSpeed - 0.35 * dt

        if forceStop or engineSound.PlaybackSpeed <= 0 then
            runConn:Disconnect()
            seatConn:Disconnect()
            script:Destroy()
        end
    end)
end

table.insert(conns, car.DriveSeat:GetPropertyChangedSignal("ThrottleFloat"):Connect(function()
    throttle = car.DriveSeat.ThrottleFloat
end))

table.insert(conns, car.DriveSeat:GetPropertyChangedSignal("SteerFloat"):Connect(function()
    steer = car.DriveSeat.SteerFloat
end))

table.insert(conns, car.DriveSeat:GetPropertyChangedSignal("Occupant"):Connect(function()
    if not car.DriveSeat.Occupant then
        destroy()
    end
end))

table.insert(conns, car.Model.Destroying:Connect(function()
    if not car.Model.Parent then
        destroy()
    end
end))