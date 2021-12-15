--[[
    Loading Flux Framework in _G table
]]
local RS = game:GetService("RunService")

_G.Loaded = false

local _GModules = game:GetService("ReplicatedStorage"):WaitForChild("_G")

--+++ Config +++
_G.Config = require(script.Config)

--+++ Remote Events and Functions +++
_G.Remotes = require(_GModules:WaitForChild("Remotes"))

--+++ Local Events and Functions +++
_G.Remotes = require(_GModules:WaitForChild("Bus"))

--+++ Packages +++
_G.Packages = require(_GModules:WaitForChild("Packages"))

--+++ Print +++ | overiding print when in public build
if not _G.Config.PRINT then
    _G.print = function() end
end

--+++ Modules +++
_G.Shared = require(game:GetService("ReplicatedStorage"):WaitForChild("Modules"))
_G.Server = require(game:GetService("ServerScriptService").Modules)

--+++ Finished +++
setmetatable(_G, {
    __newindex = function()
        error("_G is locked by the Flux Framework!")
    end
})

_G.Loaded = true