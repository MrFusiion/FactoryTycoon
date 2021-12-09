local colors = {}

colors["Body"] = function(car: Model)
    return {
        car.Body.Frame,
        car.Body.FL.Frame,
        car.Body.FR.Frame
    }
end
--[[
    "Metal",
    "Plastic",
    "SmoothPlastic",
    "DiamondPlate",
    "Granite",
    "Foil",
]]

colors["Interior"] = function(car: Model)
    return {
        car.Body.Interior,
        car.Body.FL.Interior,
        car.Body.FR.Interior
    }
end
--[[
    "Plastic",
    "SmoothPlastic",
    "Granite",
    "Marble"
]]

colors["Windows"] = function(car: Model)
    return {
        car.WindShield
    }
end
--[[
    ["Clear"] = {
        Transparency = 0.5,
        BrickColor = "Fog"
    }
    ["Light Smoke"] = {
        Transparency = 0.75,
        BrickColor = BrickColor.new("Really black")
    }
    ["Dark Smoke"] = {
        Transparency = 0.6,
        BrickColor = BrickColor.new("Really black")
    }
    ["Limo"] = {
        Transparency = 0.5,
        BrickColor = BrickColor.new("Really black")
    }
]]

colors["Wheel Caps"] = function(car: Model)
    local wheels = {}
    for _, wheel in ipairs(car.Wheels:GetChildren()) do
        table.insert(wheels, wheel.Parts.Cap)
    end
    return wheels
end
--[[
    "Metal",
    "Plastic",
    "SmoothPlastic",
    "DiamondPlate",
    "Granite",
    "Foil",
]]

colors["Bumpers"] = function(car: Model)
    return {
        car.Body.FBumper,
        car.Body.RBumper
    }
end
--[[
    "Metal",
    "Plastic",
    "SmoothPlastic",
    "DiamondPlate",
    "Granite",
    "Foil",
]]

colors["Front Lights"] = function(car: Model)
    return {
        car.Lights.FL,
        car.Lights.FR,
    }
end

colors["Rear Lights"] = function(car: Model)
    return {
        car.Lights.RL,
        car.Lights.RR,
    }
end

return colors