local TS = game:GetService("TweenService")
local RS = game:GetService("RunService")

local COLOR = Color3.fromRGB(119, 227, 107)
local MESHPART = script.Parent.Gradient

local Hover = {}
local Hover_mt = { __index = Hover }

local function createClick(self)
    local click = self.HoverPart:FindFirstChildWhichIsA("ClickDetector") or Instance.new("ClickDetector")
    click.MaxActivationDistance = 1000
    click.CursorIcon = "rbxasset://textures/ArrowFarCursor.png"
    click.MouseHoverEnter:Connect(function()
        if self.Enabled then
            Hover.setVisible(self, true)
        end
    end)
    click.MouseHoverLeave:Connect(function()
        if self.Enabled then
            Hover.setVisible(self, false)
        end
    end)


    click.Parent = self.HoverPart
    return click
end

function Hover.new(part)
    local self = {}
    self.Part = part
    self.Enabled = false

    local lightPart = part:Clone()
    lightPart.Transparency = 1
    lightPart.Size = part.Size - Vector3.new(.5, 0, .5)
    lightPart.CFrame = part.CFrame * CFrame.new(0, part.Size.Y * .5, 0)
    lightPart.Parent = part

    self.Light = Instance.new("SurfaceLight")
    self.Light.Angle = 60
    self.Light.Brightness = 0
    self.Light.Color = COLOR
    self.Light.Face = Enum.NormalId.Top
    self.Light.Range = 5
    self.Light.Enabled = true
    self.Light.Parent = lightPart

    self.HoverPart = Instance.new("Part")
    self.HoverPart.Transparency = 1
    self.HoverPart.CanCollide = false
    self.HoverPart.CanTouch = false
    self.HoverPart.Anchored = true
    self.HoverPart.Size = Vector3.new(part.Size.X, 2, part.Size.Z)
    self.HoverPart.CFrame = lightPart.CFrame * CFrame.new(0, self.HoverPart.Size.Y * .5, 0)
    self.HoverPart.Parent = part

    self.Click = createClick(self)
    self.Activated = self.Click.MouseClick

    local meshPart = MESHPART:Clone()
    meshPart.Size = Vector3.new(part.Size.X, 10, part.Size.Z)
    meshPart.CFrame = lightPart.CFrame * CFrame.new(0, meshPart.Size.Y * .5, 0)
    meshPart.Parent = part

    self.Textures = {}
    for i, face in ipairs{
        Enum.NormalId.Left, Enum.NormalId.Right,
        Enum.NormalId.Front, Enum.NormalId.Back
    } do
        local texture = Instance.new("Texture")
        texture.Color3 = COLOR
        texture.Transparency = 1
        texture.Texture = "rbxassetid://7172803600"
        texture.Face = face
        texture.OffsetStudsU = meshPart.Size.Z * .5
        texture.OffsetStudsV = meshPart.Size.Y * .5
        texture.StudsPerTileU = meshPart.Size.Z
        texture.StudsPerTileV = meshPart.Size.Y
        texture.Parent = meshPart
        self.Textures[i] = texture
    end

    return setmetatable(self, Hover_mt)
end

function Hover:enable(enable)
    enable = false
    self.Enabled = enable
    if not enable then
        Hover.setVisible(self, false)
    end
end

function Hover:setVisible(visible)
    TS:Create(self.Light, TweenInfo.new(visible and .25 or .1), {
        Brightness = visible and 3 or 0
    }):Play()
    for _, texture in ipairs(self.Textures) do
        TS:Create(texture, TweenInfo.new(visible and .25 or .1), {
            Transparency = visible and .5 or 1
        }):Play()
    end
end

function Hover.recreate(self)
    self.Click = createClick(self)
    self.Activated = self.Click.MouseClick

    if RS:IsClient() then
        self.Activated:Connect(function()
            _G.Remotes("Property", "ExpandProperty"):FireServer(self.Part:GetAttribute("Index"))
        end)
    end

    return setmetatable(self, Hover_mt)
end

return Hover