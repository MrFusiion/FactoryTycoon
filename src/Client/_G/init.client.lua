--[[
    Loading Flux Framework in _G table
]]
local RS = game:GetService("RunService")
local player = game:GetService("Players").LocalPlayer

_G.Loaded = false

local _GModules = game:GetService("ReplicatedStorage"):WaitForChild("_G")
local CatogoryFolder = require(_GModules:WaitForChild("CatogoryFolder"))

--+++ Config +++
_G.Config = require(script.Config)

--+++ Remote Events and Functions +++
_G.Remotes = require(_GModules:WaitForChild("Remotes"))

--+++ Local Events and Functions +++
_G.Bus = require(_GModules:WaitForChild("Bus"))

--+++ Packages +++
_G.Packages = require(_GModules:WaitForChild("Packages"))

--+++ Print +++ | overiding print when in public build
if not _G.Config.PRINT then
    _G.print = function() end
end

--+++ Modules +++
_G.Shared = require(game:GetService("ReplicatedStorage"):WaitForChild("Modules"))
_G.Client = require(game:GetService("StarterPlayer").StarterPlayerScripts.Modules)

--+++ Data +++
_G.Data = require(script.Parent:WaitForChild("Data"))

--+++ Gui +++
_G.Gui = { Elements = {}, Manager = require(script.Parent.Gui.GuiManager) }
for _, element in ipairs(player.PlayerScripts:WaitForChild("Gui").Elements:GetChildren()) do
    _G.Gui.Elements[element.Name] = require(element)
end

--+++ Finished +++
setmetatable(_G, {
    __newindex = function()
        error("_G is locked by the Flux Framework!")
    end
})
_G.Loaded = true