local shared = game:GetService("ReplicatedStorage")
    :WaitForChild("Modules")

local Table = require(shared:WaitForChild("Table"))

local Config = {}

Config.DEBUG = false
Config.PRINT = true
Config.COMMAND_LOG_MAX = 100
Config.COMMAND_HISTORY_MAX = 20

Config.LOADING_ENABLED = true
Config.CHANGE_THEME_BUTTON_ENABLED = false

Config.SLOTS = {
    { Name="Slot 1", Id=1 },
    { Name="Slot 2", Id=2 },
    { Name="Slot 3", Id=3 },
    { Name="Slot 4", Id=4 }
}

return Config