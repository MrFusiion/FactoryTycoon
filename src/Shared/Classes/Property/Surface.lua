local COLOR = Color3.fromRGB(42, 162, 35)

local Surface = {}
local Surface_mt = { __index = Surface }

function Surface.new(part)
    local self = {}

    local surfacePart = part:Clone()
    surfacePart.Transparency = 1
    surfacePart.CFrame = part.CFrame
    surfacePart.Size = surfacePart.Size - Vector3.new(.5, 0, .5)

    self.Gui = Instance.new("SurfaceGui")
    self.Gui.Enabled = false
    self.Gui.Face = Enum.NormalId.Top
    self.Gui.Adornee = surfacePart
    self.Gui.Parent = surfacePart

    for _, anchor in ipairs{ Vector2.new(1, 0), Vector2.new(0, 1) } do
        for _, size in ipairs{ UDim2.new(1, 0, 0, 10), UDim2.new(0, 10, 1, 0) } do
            local frame = Instance.new("Frame")
            frame.BackgroundColor3 = COLOR
            frame.BorderSizePixel = 0
            frame.AnchorPoint = anchor
            frame.Position = UDim2.fromScale(anchor.X, anchor.Y)
            frame.Size = size
            frame.Parent = self.Gui
        end
    end

    surfacePart.Parent = part

    return setmetatable(self, Surface_mt)
end

function Surface:setVisible(visible)
    print(visible)
    self.Gui.Enabled = visible
end

function Surface.recreate(surface)
    return setmetatable(surface, Surface_mt)
end

return Surface