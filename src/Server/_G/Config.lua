local RS = game:GetService("RunService")
local isStudio = RS:IsStudio()

local shared = game:WaitForChild("ReplicatedStorage")
    :WaitForChild("Modules")

local Table = require(shared:WaitForChild("Table"))
local Format = require(shared:WaitForChild("Format"))

local Config = {}


--Datastore
do
    local verbose = false
    local save = true

    Config.DATASTORE_CONFIGURATION = {
        SaveInStudio = save,
        Verbose = RS:IsStudio() and verbose,
        Warnings = {
            SAVE_NO_DATA = false,
            SAVE_VALUE_NOT_UPDATED = false
        }
    }
end

Config.DEBUG = false
Config.CAR_DEBUG = false
Config.PRINT = true
Config.DATE_FORMAT = Format.new("{day}/{month}/{year}")


--- Resources
Config.RESOURCES_REGION_PARENT = workspace.Terrain.Regions
Config.RESOURCES_DEBUG_ENABLED = false
Config.RESOURCES_ENABLED = false
Config.RESOURCES_MAX_FIND_SPOT_TRIES = 200
Config.RESOURCES_RAY_HEIGHT = 100
Config.RESOURCES_AGE_CHECK = false
Config.RESOURCES_BLACKLIST_NAMES = { -- Resources cannot grow on parts with blacklisted names
    ["NoTree"] = true
}


--- Game Analytics
Config.GA_INFO = false
Config.GA_VERBOSE = false


--- Slots
Config.ALLOWED_SLOTS = { [1] = true, [2] = true, [3] = true, [4] = true }
Config.MIN_TIME_BETWEEN_SLOT_CHANGE = 6


--- Data
do
    --- Property
    Config.LAND_SIZE = Vector2.new(5, 5)
    local volume = Config.LAND_SIZE.X * Config.LAND_SIZE.Y

    --- Default
    Config.DFLT_CASH = 50
    Config.DFLT_LAND = Table.create(volume, function(i)
        if i == math.ceil(volume * 0.5) then
            return 1
        end
        return 0
    end)
end


return Config