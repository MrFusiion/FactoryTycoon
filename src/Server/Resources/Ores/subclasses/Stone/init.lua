local oreClass = require(script.Parent.Parent.OreClass)

local oreType = setmetatable({}, { __index = oreClass })
local oreType_mt = { __index = oreType }
oreType.Name = "Stone"

--===============================================================================================================--
--===============================================/     Stats     /===============================================--

oreType.RawPrice = 0
oreType.ProcessedPrice = 0
oreType.Hardness = .2

--===============================================/     Stats     /===============================================--
--===============================================================================================================--
--===============================================/   Apearence   /===============================================--

oreType.OreColor = BrickColor.new("Medium stone grey")
oreType.OreMaterial = "Slate"

oreType.Effects = nil

oreType.TextColor = oreType.OreColor.Color

--===============================================================================================================--
--===============================================/ Grow Behavior /===============================================--

--//////////////////////////////--
--//////////[ Main ]//////////--

oreType.GrowInterval = { min=8, max=12 }--Seconds between :grow() is called

oreType.MaxGrowCalls = { min=15, max=20 }--Total growcalls

oreType.LifetimePerVolume = .1 --Ore will break after this much time after it stops growing

oreType.SectionCount = { min=4, max=6 }

oreType.SectionSize = { min=.5, max=1 }--Initial size

oreType.SectionOffset = { min=-.5, max=.5 }

oreType.SizeGrow = { min=.2, max=.23 }

oreType.SectionPhi = { min=-20, max=20 }

oreType.SectionTheta = { min=-360, max=360 }

oreType.MinSpawnDistanceToOther = 10

--//////////[ Main ]//////////--
--//////////////////////////////--

function oreType.new(...)
    return setmetatable(oreClass.new(...), oreType_mt)
end

return oreType