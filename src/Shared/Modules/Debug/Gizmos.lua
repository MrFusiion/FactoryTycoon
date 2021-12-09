local Root = Instance.new("Folder")
Root.Name = ("Gizmos%s")
    :format(game:GetService("RunService"):IsServer() and "Server" or "Client")
Root.Parent = workspace

local function createPart(name: string)
    local part = Instance.new("Part")
    part.Name = name
    part.Transparency = 1
    part.Anchored = true
    part.CanCollide = false
    part.CanTouch = false
    part.Size = Vector3.new(1, 1, 1)
    part.CFrame = CFrame.new()
    part.Parent = Root
    return part
end

local function createAttachment(position: Vector3, parent: Instance)
    local att = Instance.new("Attachment")
    att.WorldPosition = position
    att.Parent = parent
    return att
end

local Gizmos = {}

function Gizmos.drawRay(origin: Vector3, direction: Vector3, thickness: number?, color: Color3?)
    local part = createPart("Ray")

    local beam = Instance.new("Beam")
    beam.Color = color or Color3.new(1, 0, 0)
    beam.Attachment0 = createAttachment(origin               , part)
    beam.Attachment1 = createAttachment(origin + direction   , part)
    beam.Transparency = 0.25
    beam.Width0 = (thickness or 5) * 0.01
    beam.Width1 = (thickness or 5) * 0.01
    beam.Parent = part

    return part
end

function Gizmos.drawPoint(point: Vector3, radius: number?, color: Color3?)
    local part = createPart("Point")
    part.Position = point

    local sphere = Instance.new("SphereHandleAdornment")
    sphere.Color3 = color or Color3.new(1, 0, 0)
    sphere.Adornee = part
    sphere.AlwaysOnTop = true
    sphere.ZIndex = 1
    sphere.Radius = (radius or 1) * 0.25
    sphere.Parent = part

    return part
end

function Gizmos.drawCube(cf: CFrame, size: Vector3?, color: Color3?)
    local part = createPart("Cube")
    part.CFrame = cf
    part.Size = size or Vector3.new(1, 1, 1)

    local surface = Instance.new("SelectionBox")
    surface.Transparency = 0
    surface.SurfaceTransparency = 0
    surface.Color3 = color or Color3.new(1, 0, 0)
    surface.SurfaceColor3 = color or Color3.new(1, 0, 0)
    surface.Adornee = part
    surface.Parent = part

    return part
end

return Gizmos