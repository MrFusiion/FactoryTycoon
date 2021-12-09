local GreedyMesher = require(script.GreedyMesher)
local Gizmos = _G.Shared.Debug.Gizmos

type Grid = Array<Array<Array<boolean>>>

local VoxelMesh = {}
local VoxelMesh_mt = { __index=VoxelMesh }

function VoxelMesh.new(parent: Part, voxel: Part, voxelCount: Vector3, generator: ((x: number, y: number, z: number) -> boolean)?)
    local self = {}

    self.Name = "VoxelMesh"
    self.Size = parent.Size
    self.CFrame = parent.CFrame
    self.Angle = parent.CFrame - parent.CFrame.Position
    self.Parent = parent.Parent
    self.CurrentMesh = nil

    parent.Parent = nil

    self.Voxel = voxel
    self.VoxelCount = voxelCount

    self.Grid = {}
    for x=1, self.VoxelCount.X do
        self.Grid[x] = {}
        for z=1,self.VoxelCount.Z do
            self.Grid[x][z] = {}
            for y=1, self.VoxelCount.Y do
                if generator then
                    self.Grid[x][z][y] = generator(x, y, z) and true or false
                else
                    self.Grid[x][z][y] = true
                end
            end
        end
    end

    return setmetatable(self, VoxelMesh_mt)
end

local APPLE = "Hello";
function VoxelMesh.fromModel(model: Model)
    local grid = {}
    local voxel
    local vCountX, vCountY, vCountZ = 0, 0, 0

    local min
    for _, voxelPart in ipairs(model:GetChildren()) do
        if not min or voxelPart.Position.Magnitude < min.Magnitude then
            min = voxelPart.Position
        end

        if not voxel then
            voxelPart = voxel
        end
    end
    for _, voxel in ipairs(model:GetChildren()) do
        local x, y, z =
                math.floor(math.abs(voxel.Position.X) - math.abs(min.X) + 0.5) + 1,
                math.floor(math.abs(voxel.Position.Y) - math.abs(min.Y) + 0.5) + 1,
            9 - math.floor(math.abs(voxel.Position.Z) - math.abs(min.Z) + 0.5) + 1

        vCountX = math.max(x, vCountX)
        vCountY = math.max(y, vCountY)
        vCountZ = math.max(z, vCountZ)

        if not grid[x] then
            grid[x] = {}
        end
        if not grid[x][y] then
            grid[x][z] = {}
        end
        grid[x][z][y] = true
    end

    local part = Instance.new("Part")
    part.Transparency = 1
    part.Anchored = true
    part.CanCollide = false
    part.CanTouch = false
    part.Size, part.CFrame = model:GetBoundingBox()
    part.Parent = model.Parent

    return VoxelMesh.new(part, voxel, Vector3.new(vCountX, vCountY, vCountZ), function(x, y, z)
        if grid[x] and grid[x][z] and grid[x][z][y] then
            return true
        end
        return false
    end)
end

function VoxelMesh:clone(parent: Part, voxel: Part?, voxelCount: Vector3?)-- Clones share the same grid!!!
    local clone = {}

    clone.Name = self.Name
    clone.Size = parent.Size
    clone.CFrame = parent.CFrame
    clone.Angle = parent.Angle
    clone.Parent = parent.Parent
    clone.CurrentMesh = nil

    parent.Parent = nil

    clone.Voxel = voxel or self.Voxel
    clone.VoxelCount = voxelCount or self.VoxelCount

    clone.Grid = self.Grid

    return setmetatable(clone, VoxelMesh_mt)
end

function VoxelMesh:render()
    local mesh =Instance.new("Model")
    mesh.Name = self.Name

    local voxelSize = self.Size / self.VoxelCount
    local cf = self.CFrame * CFrame.new(self.Size * 0.5):Inverse()

    for cuboid in GreedyMesher.cuboidIter(self.Grid, self.VoxelCount) do
        local voxelGroup = self.Voxel:Clone()

        voxelGroup.Size =
            (cuboid.max - cuboid.min + Vector3.new(1, 1, 1)) * voxelSize

        voxelGroup.CFrame = cf * CFrame.new(
            (cuboid.max + cuboid.min) * voxelSize * 0.5 - voxelSize * 0.5
        )

        voxelGroup.Parent = mesh
    end

    mesh.Parent = self.Parent
    if self.CurrentMesh then
        self.CurrentMesh:Destroy()
    end
    self.CurrentMesh = mesh
end

function VoxelMesh:renderRaw()
    if self.CurrentMesh then
        self.CurrentMesh:Destroy()
    end
    self.CurrentMesh = Instance.new("Model")
    self.CurrentMesh.Name = self.Name
    self.CurrentMesh.Parent = self.Parent

    local voxelSize = self.Size / self.VoxelCount
    local cf = self.CFrame * CFrame.new(self.Size * 0.5):Inverse()

    for x=0, self.VoxelCount.X-1 do
        for y=0, self.VoxelCount.Y-1 do
            for z=0, self.VoxelCount.Z-1 do
                if self.Grid[x+1][z+1][y+1] then
                    local voxelGroup = Instance.new("Part")
                    voxelGroup.Anchored = true
                    voxelGroup.Material = "SmoothPlastic"
                    voxelGroup.Color = Color3.new(
                        x / self.VoxelCount.X,
                        y / self.VoxelCount.Y,
                        z / self.VoxelCount.Z
                    )

                    voxelGroup.Size = voxelSize
                    voxelGroup.CFrame = cf * CFrame.new(
                        Vector3.new(x, y, z) * voxelSize + voxelSize * 0.5
                    )

                    voxelGroup.Parent = self.CurrentMesh
                end
            end
        end
    end
end

function VoxelMesh:localizePosition(position: Vector3)
    local cf: CFrame = self.CFrame * CFrame.new(self.Size * 0.5):Inverse()
    local point = cf:ToObjectSpace(CFrame.new(position)).Position * 1 / self.Size * self.VoxelCount

    return math.ceil(point.X),
        math.ceil(point.Y),
        math.ceil(point.Z)
end

function VoxelMesh:cell(x: number, y: number, z: number, value: boolean?)
    if x > 0 and y > 0 and z > 0
        and x <= self.VoxelCount.X
        and y <= self.VoxelCount.Y
        and z <= self.VoxelCount.Z
    then
        if value == nil then
            return self.Grid[x][z][y]
        end
        self.Grid[x][z][y] = value
    end
end

function VoxelMesh:erase(position: Vector3)
    local x, y, z = self:localizePosition(position)
    self:cell(x, y, z, false)
end

function VoxelMesh:eraseSphere(position: Vector3, radius: number)
    radius = math.floor(radius)
    local radiusSquared = radius * radius
    local voxelSize = self.Size / self.VoxelCount

    for x=-radius, radius do
        for y=-radius, radius do
            for z=-radius, radius do
                local pos = Vector3.new(x * voxelSize.X, y * voxelSize.Y, z * voxelSize.Z)
                local cf = CFrame.new(position) * self.Angle * CFrame.new(pos)

                local dist = x * x + y * y + z * z
                if -radiusSquared <= dist and dist <= radiusSquared then
                    --Gizmos.drawCube(cf, voxelSize, Color3.new(0, 1, 0))
                    self:erase(cf.Position)
                end
            end
        end
    end
end

return VoxelMesh