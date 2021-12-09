local TS = game:GetService("TweenService")

local player = game:GetService("Players").LocalPlayer
local playerGui = player.PlayerGui

local TEMPLATE = playerGui:WaitForChild("Elements"):WaitForChild("Loading")

local Theme = _G.Data.Theme.Value

local function spawn(func, ...)
    local event = Instance.new("BindableEvent")
    event.Event:Connect(func)
    event:Fire(...)
    event:Destroy()
end


local Loading = {
    Gradients = {
        Default = {
            1  , 0.9, 0.8,
            0.9, 0.8, 0.7,
            0.8, 0.7, 0.6
        }
    },
    Animations = {
        Default = {
            0   , 0.25, 0.50,
            0.25, 0.50, 0.75,
            0.50, 0.75, 1   ,
        }
    }
}
local Loading_mt = { __index=Loading }

local defaultProps = _G.Client.DefaultTable.new{
    AnchorPoint = Vector2.new(0, 0),
    Position = UDim2.fromScale(0, 0),
    Size = UDim2.fromScale(1, 1),
    Speed = 0.5,
    Gradient = Loading.Gradients.Default,
    Animation = Loading.Animations.Default,
    BackgroundColor3 = "LoadingItem"
}

function Loading.new(props: table)
    local self = {}

    self.Props = defaultProps:validate(props)

    self.Frame = TEMPLATE:Clone()
    self.Frame.Visible = true
    self.Frame.AnchorPoint = self.Props.AnchorPoint
    self.Frame.Position = self.Props.Position
    self.Frame.Size = self.Props.Size
    self.Frame.Parent = self.Props.Parent

    local color = self.Props.BackgroundColor3

    self.Cells = {}
    for _, frame in ipairs(self.Frame:GetChildren()) do
        if frame:IsA("Frame") then
            self.Cells[tonumber(frame.Name)] = frame
            frame.Transparency = 1
            frame.Shade.Transparency = 1

            if typeof(color) == "Color3" then
                frame.BackgroundColor3 = color
            elseif typeof(color) == "string" then
                frame:SetAttribute("BackgroundColor3", color)
            end
        end
    end

    if typeof(color) == "string" then
        Theme:setColor(self.Frame, true)
    end

    return setmetatable(self, Loading_mt)
end

function Loading:show()
    if self.Playing then return end
    self.Playing = true

    for i, cell in ipairs(self.Cells) do
        cell.Size = UDim2.fromScale(0.333, 0.333)
        TS:Create(cell, TweenInfo.new(0.25), {
            Transparency = 0
        }):Play()
        TS:Create(cell.Shade, TweenInfo.new(0.25), {
            Transparency = self.Props.Gradient[i]
        }):Play()
    end

    spawn(function()
        task.wait(0.25)

        for i, cell in ipairs(self.Cells) do
            spawn(function()
                task.wait(self.Props.Animation[i] * self.Props.Speed)

                local size = 0
                while self.Playing do
                    TS:Create(cell, TweenInfo.new(self.Props.Speed, Enum.EasingStyle.Sine), {
                        Size = UDim2.fromScale(size, size)
                    }):Play()
                    task.wait(self.Props.Speed)

                    if size == 0 then
                        size = 0.333
                    else
                        size = 0
                    end
                end
            end)
        end
    end)
end

function Loading:hide()
    if not self.Playing then return end
    self.Playing = false

    for _, cell in ipairs(self.Cells) do
        TS:Create(cell, TweenInfo.new(0.25), {
            Transparency = 1
        }):Play()
        TS:Create(cell.Shade, TweenInfo.new(0.25), {
            Transparency = 1
        }):Play()
    end
end

return Loading