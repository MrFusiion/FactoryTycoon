local TS = game:GetService("TweenService")
local HOVER_TWEEN = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local PRESS_TWEEN = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local Text = _G.Shared.Text
local Theme = _G.Data.Theme.Value

local Button = {}

function Button.new(button: (TextButton|ImageButton))

    local background = button.Background
    local backgroundColorValue = background:GetAttribute("BackgroundColor3")
    --self.Shadow = button:FindFirstChild("Shadow")

    --self.ContentPadding = button.Content:FindFirstChildWhichIsA("UIPadding")
    --self.ContentLayout = button.Content:FindFirstChildWhichIsA("Layout")
    local label = button.Content:FindFirstChild("Label")
    --self.Icon = button.Content:FindFirstChild("Icon")

    if label then
        Text:autoResize(label, Text.Directions.X)
    end

    if backgroundColorValue then
        button.MouseEnter:Connect(function()
            TS:Create(background, HOVER_TWEEN, { BackgroundColor3 = Theme(backgroundColorValue, "Hover")}):Play()
        end)
    end

    if backgroundColorValue then
        button.MouseLeave:Connect(function()
            TS:Create(background, HOVER_TWEEN, { BackgroundColor3 = Theme(backgroundColorValue, "Default")}):Play()
        end)
    end

    if backgroundColorValue then
        button.MouseButton1Down:Connect(function()
            TS:Create(background, PRESS_TWEEN, { BackgroundColor3 = Theme(backgroundColorValue, "Pressed")}):Play()
        end)
    end

    if backgroundColorValue then
        button.MouseButton1Up:Connect(function(x, y)
            TS:Create(background, PRESS_TWEEN, { BackgroundColor3 = Theme(backgroundColorValue, "Hover")}):Play()
        end)
    end

    Theme:setColor(button, true)

    return button
end

return Button