local RS = game:GetService("RunService")

while not _G.Loaded do task.wait() end

local Datastore = RS:IsServer() and _G.Server.Datastore
if Datastore then
    Datastore.combine("Data", "Land")
end


--- Converts a Vector2 Coord to an Index coord
---@param x number
---@param z number
---@param size Vector2
---@return number
local function index(x: number, z: number, size: Vector2)
    return (z - 1) * size.X + x
end

---@class Property
local Property = {}
local Property_mt = { __index = Property }


--- Creates a new Property.
---@param model Model
---@return Property
function Property.new(model: Model)
    assert(model:GetAttribute("Property"), "Given Model is not a valid Model.\
        Please call Property.create(model: Model) on the Model first.")

    local self = {}

    self.Model = model
    self.Owner = nil
    self.Store = nil
    self.Size = self.Model:GetAttribute("Size")

    self.Floors = {}
    self.FloorCount = 0
    for _, floor in ipairs(self.Model:GetChildren()) do
        local i = floor:GetAttribute("Index")
        self.Floors[i] = floor
        self.FloorCount += 1
    end

    return setmetatable(self, Property_mt)
end


--- Creates a property out of a model.
--- A property Model needs a PrimaryPart
--- With the desired dimensions for one Floor.
---@param model Model
---@return Property
function Property.create(model: Model, size: Vector2)
    model:SetAttribute("Property", true)
    model:SetAttribute("Size", size)
    model:SetAttribute("Owner", -1)

    local refPart = model.PrimaryPart
    for _, child in ipairs(model:GetChildren()) do
        if child ~= refPart then
            child:Destroy()
        end
    end

    local cf = refPart.CFrame
        * CFrame.new(-refPart.Size.X * (size.X-1) * .5, 0, -refPart.Size.Z * (size.Y-1) * .5) -- offset

    for x=1, size.X do
        for z=1, size.Y do
            local floor = refPart:Clone()
            floor.Name = "Floor"
            floor:SetAttribute("Index", index(x, z, size))
            floor.Transparency = 1
            floor.CFrame = cf * CFrame.new(refPart.Size.X * (x - 1), 0, refPart.Size.Z * (z - 1))-- coord
            floor.Parent = model
        end
    end
    refPart:Destroy()

    return Property.new(model)
end


--- Internal function that hides or shows the chosen floor
---@param show boolean
---@param i number Floor index
function Property:__showFloor(show: boolean, i: number)
    assert(i > 0 and i <= self.FloorCount,
        ("Floor index %d is out of range! Max size is %d"):format(i, self.FloorCount))

    local floor = self.Floors[i]
    floor.Transparency = show and 0 or 1
end


--- Internal function that loads the player data
function Property:__loadData()
    assert(self.Owner ~= nil, "No owner has been set!")

    local data = self.Store:get()
    if data then
        for i, d in ipairs(data) do
            self:__showFloor(d == 1, i)
        end
    else
        warn("Could not retrieve land Data!")
    end
end


--- Enables a plate
--- @param i number Floor index
function Property:enableFloor(i: number)
    assert(self.Owner ~= nil, "No owner has been set!")
    assert(i > 0 and i <= self.FloorCount,
        ("Floor index %d is out of range! Max size is %d"):format(i, self.FloorCount))

    self.Store:update(function(data)
        data[i] = 1
        return data
    end)

    self:__showFloor(true, i)
end


--- Sets the onwer for the Property
---@param player Player
function Property:setOwner(player: Player)
    if not self.Owner then
        self.Owner = player
        self.Store = Datastore.player(player, "Land")

        self:__loadData()

        self.Model:SetAttribute("Owner", player.UserId)
    end
end


--- Resets the Property
function Property:reset()
    self.Owner = nil
    self.Store = nil

    self.Model:SetAttribute("Owner", -1)
end

return Property