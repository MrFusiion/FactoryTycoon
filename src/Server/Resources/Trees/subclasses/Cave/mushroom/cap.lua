
local Random = _G.Shared:get("Random")

local Cap = {}
local Cap_mt = { __index = Cap }

function Cap.new()
    return setmetatable({}, Cap_mt)
end

function Cap:init(tree)
    local shader = Random:choice(tree.LeafColors)

    self.Model = Instance.new("Model")

    self.Main = Instance.new("Part")
    self.Main.Anchored = true
    self.Main.BrickColor = shader.color
    self.Main.Material = shader.material
    self.Main.Shape = Enum.PartType.Cylinder
    self.Main.Parent = self.Model

    self.Top = Instance.new("Part")
    self.Top.Anchored = true
    self.Top.BrickColor = shader.color
    self.Top.Material = shader.material
    self.Top.Shape = Enum.PartType.Cylinder
    self.Top.Parent = self.Main

    --Dots
    local texture = Instance.new("Texture")
    texture.Face = Enum.NormalId.Right
    texture.Texture = "rbxassetid://6400832823"
    texture.StudsPerTileU = Random:nextRange({min=.4, max=2.5})
    texture.StudsPerTileV = texture.StudsPerTileU
    texture.Parent = self.Top

    texture:Clone().Parent = self.Main

    self.Model.Parent = tree.LeafModel
end

function Cap:update(section)
    if self.Model.Parent then
        self.Main.Size = self.LeafSizeFactor * section.Thickness
        self.Main.CFrame = section.StartCFrame * CFrame.new(0, section.Length + self.Main.Size.X*.5, 0)
            * self.LeafAngle * CFrame.Angles(0, 0, math.pi*.5)

        self.Top.Size = self.Main.Size * Vector3.new(.4, .9, .9)
        self.Top.CFrame = section.StartCFrame * CFrame.new(0, section.Length + self.Main.Size.X + self.Top.Size.X * .5, 0)
            * CFrame.Angles(0, 0, math.pi*.5)
    end
end

function Cap:destroy()
    if self.Model.Parent then
       self.Main:Destroy()
    end
end

return Cap