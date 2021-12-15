local RS = game:GetService("RunService")
local Players = game:GetService("Players")
local RepStorage = game:GetService("ReplicatedStorage")

local IS_SERVER = RS:IsServer()
local IS_CLIENT = RS:IsClient()
local NIL       = "NIL"

local TUNINGS = {}
for _, mod in ipairs(script.Tunings:GetChildren()) do
	TUNINGS[mod.Name] = require(mod)
end

local create = require(script.create)
local cache = {}

local Car = {}
local Car_mt = {}
local Cars = RepStorage:FindFirstChild("Cars")


--<< Props Listener >>
function Car_mt:__newindex(key: string, val: any)
    pcall(function()
        self.Model[key] = val
    end)
end


function Car_mt:__index(key: string)
    if Car[key] then
        return Car[key]
    else
        local suc, val = pcall(function()
            return self.Model[key]
        end)

        if suc then
            return val
        else
            error(val, 2)
        end
    end
end


-- Debug
function Car.reload(name: string)
    local mod = script.Tunings:FindFirstChild(name)
    if mod then
        local c = mod:Clone()
        TUNINGS[name] = require(c)
        c:Destroy()
    end
end


function Car.create(name: string)
    if Cars then
        local car = Cars:FindFirstChild(name)
        if car then
            local tune = TUNINGS[name or "Default"] or TUNINGS["Default"]
            return Car.new(create(car:Clone(), tune))
        else
            warn(("Car %s doesn't exist!"):format(name))
        end
    else
        error(("Tried to create a car %s, But this game has no Cars!"):format(name), 2)
    end
end

function Car.new(model: Model)
    if cache[model] then
        return cache[model]
    end

    local tune = type and TUNINGS[model.Name or "Default"] or TUNINGS["Default"]
    if not tune then return end

    local self = {}
    cache[model] = self

    --<< Upgrades>>
    self.Levels = {
        Speed = 0,
        Acceleration = 0,
        Storage = 0
    }

    self.Model = model
    self.DriveSeat = model:FindFirstChildWhichIsA("VehicleSeat")
    self.Sounds = {
        Engine = self.DriveSeat.EngineSound
    }

    --<< Flip >>
    self.FlipG = self.DriveSeat["#FLIP"]

    --<< Wheels >>
    self.Wheels = {}
    self.Front  = {}
    self.Rear   = {}
    for _, wheel in ipairs(model.Wheels:GetChildren()) do
        local name = wheel.Name

        local wheelT = {
            Name        = wheel.Name,
            Part        = wheel,

            AV          = wheel:FindFirstChild("#AV"),

            Arm         = wheel["#ARM"],
            Steer       = wheel["#ARM"]:FindFirstChild("#STEER"),
            Base        = wheel["#BASE"],
        }
        table.insert(self.Wheels, wheelT)

        if name == "FL" or name == "FR" or name == "F" then
            table.insert(self.Front, wheelT)
        elseif name == "RL" or name == "RR" or name == "R" then
            table.insert(self.Rear, wheelT)
        end
    end

    --<< Tuning >>
        -- rpm      = (speed * 2 / d) / 60
        -- speed    = (rpm / 60) / (2π) * (d * π)

    self.Tune = tune

    local w = self.Rear[1].Part
    local d = math.max(w.Size.X, w.Size.Y, w.Size.Z)

    self.Tune.RPS = tune.Speed * 2 / d
    self.Tune.RPM = self.Tune.RPS / 60

    self.Tune.ReverseRPS = tune.ReverseSpeed * 2 / d
    self.Tune.ReverseRPM = self.Tune.ReverseRPS / 60

    --<< Driveseat connection >>
    if IS_SERVER then
        self.Model.Destroying:Connect(function()
            cache[self.Model] = nil
        end)
    end

    return setmetatable(self, Car_mt)
end

function Car:getDriveWheels()
    if self.Tune.Config == "AWD" then
        return self.Wheels
    elseif self.Tune.Config == "FWD" then
        return self.Front
    elseif self.Tune.Config == "RWD" then
        return self.Rear
    else
        warn(("%s is not a valid config please chouse out of [AWD, FWD, RWD]!"):format(self.Tune.Config))
    end
    return {}
end

function Car:setColor(category: string, color: Color3)

end

function Car:upgrade(category: string, n: number)

end

return Car