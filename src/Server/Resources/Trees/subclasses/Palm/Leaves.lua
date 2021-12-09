local Random = _G.Shared.Random

local Leaves = {}
local Leaves_mt = { __index = Leaves }

function Leaves.new()
    return setmetatable({}, { __index = Leaves_mt })
end

function Leaves:init(tree)
    tree.NumLeafs = tree.NumLeafs or Random:nextRangeInt({ min=5, max=7 })

    local shader = Random:choice(tree.LeafColors)

    self.Model = Instance.new("Model")

    self.Main = Instance.new("Part")
    self.Main.Anchored = true
    self.Main.BrickColor = shader.color
    self.Main.Material = shader.material
    self.Main.Parent = self.Model

    local segmentCount = 4
    self.Leaves = {}
    for _=1, tree.NumLeafs do
        local lastPart = self.Main
        local first
        for _=1, segmentCount do
            local subLeaf = Instance.new("Part")
            subLeaf.Anchored = true
            subLeaf.BrickColor = shader.color
            subLeaf.Material = shader.material
            subLeaf.Parent = lastPart
            lastPart = subLeaf
            if not first then
                first = subLeaf
            end
        end
        table.insert(self.Leaves, first)
    end

    self.Model.Parent = tree.LeafModel
end

function Leaves:update(section)
    local function scaleLeaf(leaf, theta, rho, multiplier)
        leaf.Size = leaf.Parent.Size * multiplier
        leaf.CFrame = leaf.Parent.CFrame
                * CFrame.Angles(0, math.rad(theta), 0)
                * CFrame.new(0, 0, leaf.Parent.Size.Z*.5)
                * CFrame.Angles(math.rad(rho), 0, 0)
                * CFrame.new(0, 0, leaf.Size.Z*.5)
        local childLeaf  = leaf:FindFirstChildWhichIsA("Part")
        if childLeaf then
            scaleLeaf(childLeaf, 0, rho, Vector3.new(1, 1, multiplier.Z))
        end
    end
    if self.Model.Parent then
        self.Main.Size = self.LeafSizeFactor * section.Thickness
        self.Main.CFrame = section.StartCFrame * CFrame.new(0, section.Length + self.Main.Size.Y*.5, 0)

        for i, leaf in ipairs(self.Leaves) do
            scaleLeaf(leaf, i * (360 / #self.Leaves), 15, Vector3.new(.6, 1, .6 ))
        end
    end
end

function Leaves:destroy()
    if self.Model.Parent then
        self.Model:Destroy()
    end
end

return Leaves