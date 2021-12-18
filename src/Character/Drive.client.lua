local UIS = game:GetService("UserInputService")
local CAS = game:GetService("ContextActionService")

while not _G.Loaded do task.wait() end

local Drive = _G.Client.Drive
local Car = require(game:GetService("ReplicatedStorage")
    :WaitForChild("Classes")
    :WaitForChild("Car")
)


local function enableJump(enable: boolean)
    if not enable then
        CAS:BindAction("DISABLE_JUMP", function()
            return Enum.ContextActionResult.Sink
        end, false, Enum.KeyCode.Space)
    else
        CAS:UnbindAction("DISABLE_JUMP")
    end
end


local conns = {}
local hum = script.Parent:WaitForChild("Humanoid")
hum:GetPropertyChangedSignal("SeatPart"):Connect(function()
    local seat = hum.SeatPart

    if seat and seat:GetAttribute("IsCarSeat") then
        table.insert(conns, UIS.InputBegan:Connect(function(input)
            if input.KeyCode == Enum.KeyCode.E then
                hum.Sit = false
                task.wait()
                hum.RootPart.CFrame = CFrame.new(seat.ExitPosition.WorldPosition, seat.ExitPosition.WorldPosition + seat.ExitPosition.WorldAxis * 10)
            end
        end))

        enableJump(false)

        if hum.SeatPart:IsA("VehicleSeat") then
            local car = Car.new(hum.SeatPart.Parent)

            Drive:run(car)

            table.insert(conns, car.DriveSeat:GetPropertyChangedSignal("ThrottleFloat"):Connect(function()
                Drive:throttle(car.DriveSeat.ThrottleFloat)
            end))

            table.insert(conns, car.DriveSeat:GetPropertyChangedSignal("SteerFloat"):Connect(function()
                Drive:steer(car.DriveSeat.SteerFloat)
            end))
        end
    else
        Drive:stop()

        for _, conn in ipairs(conns) do
            conn:Disconnect()
        end
        conns = {}
        enableJump(true)
    end
end)