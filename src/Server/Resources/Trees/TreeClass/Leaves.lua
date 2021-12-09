while not _G.Loaded do task.wait() end

local Random = _G.Shared.Random

local Leaves = {}
local Leaves_mt = { __index = Leaves }


function Leaves.new()
    return setmetatable({}, Leaves_mt)
end

--- Creates the leaf parts
---@param tree table
function Leaves:init(tree: table)
    self.Main = Instance.new("Part")
    self.Main.Name = "LeafPart"
    self.Main.Anchored = true
    self.Main.CanCollide = false

    local shader = Random:choice(tree.LeafColors)
    self.Main.BrickColor = shader.color
    self.Main.Material = shader.material
    self.Main.Transparency = Random:nextRange(shader.transparency or { min=0, max=0 })

    self.Main.Parent = tree.LeafModel
end


--- Updates the size and position for the leafes
---@param section table
function Leaves:update(section: table)
    if self.Main.Parent then
        self.Main.Size = self.LeafSizeFactor * section.Thickness
        self.Main.CFrame = section.StartCFrame * CFrame.new(0, section.Length + .75 * self.Main.Size.Y*.5, 0) * self.LeafAngle
    end
end


--- Destroys the Leavess
function Leaves:destroy()
    if self.Main.Parent then
        self.Main:Destroy()
    end
end


return Leaves