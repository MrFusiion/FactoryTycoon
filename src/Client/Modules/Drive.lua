local RS = game:GetService("RunService")

local flipWait = tick()
local flipping = false

local throttle = 0
local speed = 0
local steer = 0
local angle = 0


local Drive = {}

function Drive:run(car)
    if self.TickConn then
        warn(("Drive is allready running!"))
        return
    end

    self.EngineSound = car.Sounds.Engine
    self.EngineSound.PlaybackSpeed = car.Tune.SoundIdleSpeed
    self.EngineSound:Play()

    self.Car = car
    print(self.Car)

    self.TickConn = RS.Heartbeat:Connect(function(dt)
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

            wheel.Steer.CFrame = wheel.Base.CFrame * CFrame.Angles(0, -math.rad(angle), 0)
        end


        -- Flip
        --Detect Orientation
        if flipping or self:flipped() then
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
        self.EngineSound.PlaybackSpeed = (car.Tune.SoundIdleSpeed + (car.Tune.SoundMaxSpeed - car.Tune.SoundIdleSpeed) * (math.abs(speed) / car.Tune.RPS))


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

end

function Drive:flipped()
    if self.Car then
        return (self.Car.DriveSeat.CFrame * CFrame.Angles(math.pi/2, 0, 0)).LookVector.Y > 0.1
    end
    return false
end

function Drive:stop()
    if self.Car then
        local force = false
        local conns = {}

        local car = self.Car
        local sound = self.EngineSound

        if self.SeatConn then
            self.SeatConn:Disconnect()
            self.SeatConn = nil
        end

        if self.SoundConn then
            self.SoundConn:Disconnect()
            self.SoundConn = nil
        end

        self.TickConn:Disconnect()
        self.TickConn = nil

        throttle = 0
        speed = 0
        steer = 0
        angle = 0

        self.Car = nil
        self.EngineSound = nil

        for _, wheel in ipairs(car.Wheels) do
            if wheel.AV then
                wheel.AV.AngularVelocity = Vector3.new(0, 0, 0)
            end
            if wheel.Steer then
                wheel.Steer.CFrame = wheel.Base.CFrame
            end
        end

        self.SeatConn = car.DriveSeat:GetPropertyChangedSignal("Occupant"):Connect(function()
            if car.DriveSeat.Occupant  then
                force = true
            end
        end)

        self.SoundConn = game:GetService("RunService").RenderStepped:Connect(function(dt)
            if force or sound.PlaybackSpeed <= 0 then
                self.SeatConn:Disconnect()
                self.SoundConn:Disconnect()
            elseif not force then
                sound.PlaybackSpeed = sound.PlaybackSpeed - 0.35 * dt
            end
        end)
    end
end

function Drive:getCar()
    return self.Car
end

function Drive:throttle(val: number)
    throttle = val
end

function Drive:getThrottle()
    return throttle
end

function Drive:steer(val: number)
    steer = val
end

function Drive:getSteer()
    return steer
end


return Drive