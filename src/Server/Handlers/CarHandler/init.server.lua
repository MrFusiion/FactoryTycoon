local RepStorage = game:GetService("ReplicatedStorage")

local Car = require(RepStorage:WaitForChild("Classes"):WaitForChild("Car"))

local function spawnCar(name: string)
    local suc, err = pcall(function()
        Car.create(name).Parent = workspace
    end)

    if not suc then
        warn(err)
    end
end

for _, car in pairs(RepStorage.Cars:GetChildren()) do
    spawnCar(car.Name)
end