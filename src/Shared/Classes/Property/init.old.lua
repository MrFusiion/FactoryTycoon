local RS = game:GetService("RunService")

local String = _G.Shared.String
local Table = _G.Shared.Table

local Datastore = RS:IsServer() and _G.Server.Datastore
if Datastore then
    Datastore.combine("Data", "Land")
end

local function getStore(player, defaultValue)
    local store = Datastore.player(player, "Land", defaultValue)

    function store:serialize(data)
        return table.concat(data)
    end

    function store:deserialize(data)
        local out = {}
        for i, s in String.iter(data) do
            out[i] = tonumber(s)
        end
        return out
    end

    return store
end

local PRICES = require(script.Prices)
local Surface = require(script.Surface)
local Hover = require(script.Hover)
local Sign = require(script.Sign)

local rePropertySet = _G.Remotes("Property", "PropertySet")

local SURFACE_OVERLAP_OFFSET = .005
local function createFloor(parent, size, cf, thickness)
    thickness = thickness or 1

    local part = Instance.new("Part")

    part.Material = "Concrete"
    part.BrickColor = BrickColor.new("Fossil")

    part.Transparency = 1
    part.CanCollide = false
    part.CanTouch = false
    part.Anchored = true
    part.Size = Vector3.new(size.X, thickness, size.Y)
    part.CFrame = cf * CFrame.new(0, -thickness + SURFACE_OVERLAP_OFFSET, 0)
    part.Parent = parent
    return part
end

local function createPrimaryPart(model)
    local part = Instance.new("Part")
    part.Anchored = true
    part.CanTouch = false
    part.CanCollide = false
    part.Transparency = 1

    local cf, size = model:GetBoundingBox()
    part.CFrame = cf
    part.Size = size

    model.PrimaryPart = part
    part.Parent = model
end

local function CoordsToIndex(size, x, z)
    return (z - 1) * size.X + x
end

local function IndexToCoords(size, i)
    return i - math.floor(i-1 / size.X) * size.X,
        math.ceil(i / size.X)
end

local function loadPlayerData(data, floors)
    for i, d in ipairs(data) do
        floors[i].Part.Transparency = math.abs(d - 1)
        floors[i].Part:SetAttribute("Enabled", d == 1)
    end
end


local Property = {}
local Property_mt = { __index = Property }

function Property.new(name, part, size)
    local self = {}

    self.Owner = nil
    self.Store = nil

    self.Size = size
    self.Model = Instance.new("Model")
    self.Model.Name = ("Property(%s)"):format(name)
    self.Model:SetAttribute("Owner", -1)
    self.Model.Parent = part.Parent

    self.CFrame = part.CFrame

    local floorSize = Vector2.new(part.Size.X, part.Size.Z) / size

    self.Floors = {}
    for z=1, self.Size.Y do
        for x=1, self.Size.X do
            local i = CoordsToIndex(size, x, z)

            local cf = part.CFrame
                * CFrame.new(floorSize.X * (x - 1), 0, floorSize.Y * (z - 1)) -- coord
                * CFrame.new(-floorSize.X * (size.X -1) * .5, 0, -floorSize.Y * (size.Y-1) * .5) -- offset

            local floor = createFloor(self.Model, floorSize, cf, part.Size.Y)
            floor:SetAttribute("Index", i)
            floor:SetAttribute("X", x)
            floor:SetAttribute("Z", z)

            self.Floors[i] = {
                Part = floor,
                Surface = Surface.new(floor),
                Hover = Hover.new(floor),
                Sign = Sign.new(floor, PRICES[i], false)
            }
        end
    end

    createPrimaryPart(self.Model)
    Property.setRotation(self, math.pi)

    part:Destroy()

    return setmetatable(self, Property_mt)
end

function Property:enableFloor(i)
    if RS:IsServer() then
        if i <= #self.Floors then
            if self.Owner and self.Store then
                self.Store:update(function(data)
                    data[i] = 1
                    return data
                end)
                local floor = self.Floors[i]
                floor.Surface:setVisible(false)
                floor.Hover:enable(false)
                floor.Sign:setVisible(false)
            else
                warn(("Tried to enable floor on %s with no owner set!"):format(self.Model:GetFullName()))
            end
        else
            warn(("Floor index out of range!"))
        end
    else
        warn("reset can only be called on server side!")
    end
end

function Property:reset()
    if RS:IsServer() then
        self.Owner = nil
        self.Store = nil
        if self.Conn then
            self.Conn:Disconnect()
        end
        for _, floor in ipairs(self.Floors) do
            floor.Part.Transparency = 1
            floor.Part:SetAttribute("Enabled", false)
        end
    else
        warn("reset can only be called on server side!")
    end
end

function Property:setOwner(player)
    if RS:IsServer() then
        if player then
            self.Owner = player
            self.Model:SetAttribute("Owner", player.UserId)
            self.Store = getStore(player, Table.create(#self.Floors, function(i)
                local x1 = math.ceil(self.Size.X * .5)
                local x2 = math.ceil((self.Size.X + 1) * .5)
                return (i == x1 or i == x2) and 1 or 0
            end))

            local data = self.Store:get()
            loadPlayerData(data, self.Floors)

            self.Store:onUpdate(function(data)
                loadPlayerData(data, self.Floors)
            end)

            rePropertySet:FireClient(player, self)
        else
            Property.reset(self)
        end
    else
        warn("SetOwner can only be called on server side!")
    end
end

function Property:buildMode(enable)
    if RS:IsClient() then
        for _, floor in ipairs(self.Floors) do
            if not floor.Part:GetAttribute("Enabled") then
                floor.Surface:setVisible(enable)
                floor.Hover:enable(enable)
                floor.Sign:setVisible(enable)
            end
        end
    else
        warn("buildMode can only be called on client size")
    end
end

function Property:setRotation(r)
    if RS:IsServer() then
        self.Model:SetPrimaryPartCFrame(
            self.Model:GetPrimaryPartCFrame() * CFrame.Angles(0, r, 0))
    else
        warn("SetRotation can only be called on server side!")
    end
end

--[[
function Property:rotateTween(r, twInfo)
    self.Model:SetPrimaryPartCFrame(
        self.Model:GetPrimaryPartCFrame() * CFrame.Angles(0, r, 0))
end]]

function Property.recreate(property)
    local self = property
    for _, floor in ipairs(self.Floors) do
        Surface.recreate(floor.Surface)
        Hover.recreate(floor.Hover)
        Sign.recreate(floor.Sign)
    end
    return setmetatable(self, Property_mt)
end

return Property