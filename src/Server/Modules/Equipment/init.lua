---@diagnostic disable: duplicate-doc-class

local Datastore
task.spawn(function()
    while not _G.Server do
        task.wait()
    end
    Datastore = _G.Server.Datastore
    Datastore.combine("Data", "Vacuum", "Backpack")
end)


local VACUUMS = game:GetService("ReplicatedStorage"):WaitForChild("Vacuums")
local VACUUM_CLIENT_SCRIPT = script.Vacuum
local DEFUALT_VACUUM = "Starter"

local BACKPACKS = game:GetService("ReplicatedStorage"):WaitForChild("Backpacks")
local BACKPACK_CLIENT_SCRIPT = script.Backpack
local DEFUALT_BACKPACK = "Starter"


--- Creates a weld between 2 BaseParts
---@param part0 BasePart
---@param part1 BasePart
---@return WeldConstraint
local function createWeld(part0: BasePart, part1: BasePart)
    local weld = Instance.new("WeldConstraint")
    weld.Part0 = part0
    weld.Part1 = part1
    weld.Parent = part1
    return weld
end


--- ====================================================================
---                                 Init
--- ====================================================================

for _, vacuum in ipairs(VACUUMS:GetChildren()) do
    local handle = vacuum.Handle

    local test = vacuum:FindFirstChild("Test")
    if test then test:Destroy() end

    if handle then
        for _, descendant in ipairs(vacuum:GetDescendants()) do
            if handle ~= descendant and descendant:IsA("BasePart") then
                createWeld(handle, descendant)
                descendant.Anchored = false
            end
        end
        handle.Anchored = false
    else
        warn(("Vacuum %s has no %s!"):format(vacuum.Name, "Handle"))
    end

    vacuum:SetAttribute("Vacuum", true)
    VACUUM_CLIENT_SCRIPT:Clone().Parent = vacuum
end

for _, backpack in ipairs(BACKPACKS:GetChildren()) do

    local handle = backpack:FindFirstChild("Handle")
    if handle then
        for _, descendant in ipairs(backpack:GetDescendants()) do
            if handle ~= descendant and descendant:IsA("BasePart") then
                createWeld(handle, descendant)
                descendant.Anchored = false
            end
        end
        handle.Anchored = false
    else
        warn(("Backpack %s has no %s!"):format(backpack.Name, "Handle"))
    end

    local surface = Instance.new("SurfaceGui")
    surface.PixelsPerStud = 200
    surface.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
    surface.Parent = backpack.Display

    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Size = UDim2.fromScale(1, 1)
    label.Text = "0/0"
    label.TextScaled = true
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Parent = surface

    backpack:SetAttribute("Backpack", true)
    BACKPACK_CLIENT_SCRIPT:Clone().Parent = backpack
end

--- ====================================================================
---                                 Equipment
--- ====================================================================


--- Gets a vacuum Instance by name
---@param name string
---@return Tool
local function getVacuumInstance(name: string)
    return (VACUUMS:FindFirstChild(name) or VACUUMS:FindFirstChild(DEFUALT_VACUUM)):Clone()
end


--- Gets a backpack Instance by name
---@param name string
---@return Accessory
local function getBackpackInstance(name: string)
    return (BACKPACKS:FindFirstChild(name) or BACKPACKS:FindFirstChild(DEFUALT_BACKPACK)):Clone()
end


--- Removes all Accessories that are attached to the back of the player's Model
---@param player Player
---@param humanoid Humanoid
local function removeBackAccessories(player: Player, humanoid: Humanoid)

end


--- Creates a RopeConstraint between the vacuum and bacpack
---@param vacuum Tool
---@param Backpack Accessory
local function createTube(vacuum: Tool, Backpack: Accessory)
    local tube = Instance.new("RopeConstraint")
    tube.Visible = true
    tube.Thickness = .3
    tube.Color = BrickColor.new("Really black")
    tube.Attachment0 = Backpack.Handle.TubeAttachment
    tube.Attachment1 = vacuum.Handle.TubeAttachment
    tube.Parent = vacuum
    return tube
end


--- Setups the player Equipment
---@param self table
local function setupEquipment(self: table)

    --/ Removes the players back accessories
    while not self.Player:HasAppearanceLoaded() do task.wait() end
    for _, part in ipairs(self.Humanoid:GetAccessories()) do
        if not part:GetAttribute("Backpack") then
            local handle = part:FindFirstChild("Handle")
            local weld = handle and handle:FindFirstChildWhichIsA("Weld")
            if weld and weld.Part1.Name == "UpperTorso" then
                part:Destroy()
            end
        end
    end

    --/ Set vacuum
    self.Vacuum = getVacuumInstance(self.VacuumStore:get())
    self.Vacuum.Parent = self.Player.Backpack

    --/ Set backpack
    self.Backpack = getBackpackInstance(self.BackpackStore:get())
    self.Humanoid:AddAccessory(self.Backpack)

    self.Tube = createTube(self.Vacuum, self.Backpack)
end

--- Gets a vacuum and a bacpack Store
---@param player Player
---@return table
---@return table
local function getStores(player: Player)
    local stores = {}
    for i, name in ipairs{"Vacuum", "Backpack"} do
        stores[i] = Datastore.player(player, name, "Starter")
    end
    return table.unpack(stores)
end


---@class Equipment
local Equipment = {}
local Equipment_mt = { __index = Equipment }


--- Creates a new Equipment
--- @param player Player
function Equipment.new(player: Player)
    local self = {}
    self.Player = player
    self.Character = player.Character or player.CharacterAdded:Wait()
    self.Humanoid = self.Character:WaitForChild("Humanoid")

    self.VacuumStore, self.BackpackStore = getStores(player)

    setupEquipment(self)

    self.Conn = self.Player.CharacterAdded:Connect(function(char)
        self.Character = char
        self.Humanoid = char:WaitForChild("Humanoid")
        setupEquipment(self)
    end)

    return setmetatable(self, Equipment_mt)
end


--- Sets the vacuum of the player
function Equipment:setVacuum(name)
    self.Vacuum = getVacuumInstance(name)
        self.Vacuum.Parent = self.Player.Backpack

    if self.Tube then self.Tube:Destroy() end
    self.Tube = createTube(self.Vacuums, self.Backpack)

    self.VacuumStore:set(self.Vacuum.Name)
end


--- Sets the backpack of the player
function Equipment:setBackpack(name)
    self.Backpack = getBackpackInstance(name)
    self.Humanoid:AddAccessory(self.Backpack)

    if self.Tube then self.Tube:Destroy() end
    self.Tube = createTube(self.Vacuums, self.Backpack)

    self.BackpackStore:set(self.Backpack.Name)
end


--- Returns the current player's vacuum info
function Equipment:getVacuumInfo()
    if self.Vacuum then
        return {
            name = self.Vacuum.Name,
            damage = self.Vacuum:GetAttribute("Damage"),
            speed = self.Vacuum:GetAttribute("Speed"),
            range = self.Vacuum:GetAttribute("Range")
        }
    end
end


--- Returns the current player's backpack info
function Equipment:getBackpackInfo()
    if self.Backpack then
        return {
            name = self.Backpack.Name,
            maxstorage = self.Backpack:GetAttribute("MaxStorage")
        }
    end
end


--- Disconnects all connections
function Equipment:cleanup()
    if self.Conn then
        self.Conn:Disconnect()
    end
end

return Equipment