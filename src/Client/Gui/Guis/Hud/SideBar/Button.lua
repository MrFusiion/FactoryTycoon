local TS = game:GetService("TweenService")
local ICON_TWEEN = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local TEXT_TWEEN = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local HOVER_TWEEN = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local PRESS_TWEEN = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local Theme = _G.Data.Theme.Value


local Button = {}

function Button.new(button: TextButton)
    local container = button.Container

    local background = container.Background
    local backgroundColorValue = background:GetAttribute("BackgroundColor3")

    local label = container.Info.Label
    label.AnchorPoint = Vector2.new(1, 0)

    local keybind = container.Info.Keybind
    keybind.AnchorPoint = Vector2.new(1, 1)

    local icon = container.Icon
    local iconSize = container.Icon.Size

    if backgroundColorValue then
        button.MouseEnter:Connect(function()
            --TS:Create(button, HOVER_TWEEN, { Size=UDim2.fromScale(1.1, 1.1) }):Play()
            TS:Create(container, HOVER_TWEEN, { Position = UDim2.fromScale(0.1, 0) }):Play()
            TS:Create(background, HOVER_TWEEN, { BackgroundColor3 = Theme(backgroundColorValue, "Hover")} ):Play()
            TS:Create(icon, ICON_TWEEN, { Size = iconSize + UDim2.fromScale(0.05, 0.05) }):Play()
            TS:Create(label, TEXT_TWEEN, { AnchorPoint = Vector2.new(0, 0) }):Play()
            TS:Create(keybind, TEXT_TWEEN, { AnchorPoint = Vector2.new(0, 1) }):Play()
        end)
    end

    if backgroundColorValue then
        button.MouseLeave:Connect(function()
            --TS:Create(button, HOVER_TWEEN, { Size=UDim2.fromScale(1, 1) }):Play()
            TS:Create(container, HOVER_TWEEN, { Position=UDim2.fromScale(0, 0) }):Play()
            TS:Create(background, HOVER_TWEEN, { BackgroundColor3 = Theme(backgroundColorValue, "Default") }):Play()
            TS:Create(icon, ICON_TWEEN, { Size = iconSize }):Play()
            TS:Create(label, TEXT_TWEEN, { AnchorPoint = Vector2.new(1, 0) }):Play()
            TS:Create(keybind, TEXT_TWEEN, { AnchorPoint = Vector2.new(1, 1) }):Play()
        end)
    end

    if backgroundColorValue then
        button.MouseButton1Down:Connect(function()
            TS:Create(background, PRESS_TWEEN, { BackgroundColor3 = Theme(backgroundColorValue, "Pressed") }):Play()
        end)
    end

    if backgroundColorValue then
        button.MouseButton1Up:Connect(function(x, y)
            TS:Create(background, PRESS_TWEEN, { BackgroundColor3 = Theme(backgroundColorValue, "Hover") }):Play()
        end)
    end

    Theme:setColor(button, true)

    return button
end

return Button