local TS = game:GetService("TweenService")
local ICON_TWEEN = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local TEXT_TWEEN = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local HOVER_TWEEN = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local PRESS_TWEEN = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local WAVE_TWEEN = TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)

local Theme = _G.Data.Theme.Value

function tweenColor(frame: Frame, twinfo: TweenInfo, value: string, modifier: string)
    frame:SetAttribute("BackgroundColor3", ("%s%s"):format(value, modifier))
    TS:Create(frame, twinfo, { BackgroundColor3=Theme(value, modifier) }):Play()
end


local Button = {}

function Button.new(button: TextButton)
    local container = button.Container

    local background = container.Background
    local backgroundColorValue = background:GetAttribute("BackgroundColor3")

    local hover = Instance.new("Sound")
    hover.SoundId = "rbxassetid://421058925"
    hover.Parent = button

    local click = Instance.new("Sound")
    click.SoundId = "rbxassetid://452267918"
    click.Parent = button

    local wave = container.Wave
    wave.BackgroundTransparency = 1

    local label = container.Info.Label
    label.AnchorPoint = Vector2.new(1, 0)

    local keybind = container.Info.Keybind
    keybind.AnchorPoint = Vector2.new(1, 1)

    local icon = container.Icon
    local iconSize = container.Icon.Size

    button.MouseEnter:Connect(function()
        TS:Create(container, HOVER_TWEEN, { Position = UDim2.fromScale(0.1, 0) }):Play()
        TS:Create(icon, ICON_TWEEN, { Size = iconSize + UDim2.fromScale(0.05, 0.05) }):Play()
        TS:Create(label, TEXT_TWEEN, { AnchorPoint = Vector2.new(0, 0) }):Play()
        TS:Create(keybind, TEXT_TWEEN, { AnchorPoint = Vector2.new(0, 1) }):Play()
        tweenColor(background, HOVER_TWEEN, backgroundColorValue, "Hover")
        hover:Play()
    end)

    button.MouseLeave:Connect(function()
        TS:Create(container, HOVER_TWEEN, { Position=UDim2.fromScale(0, 0) }):Play()
        TS:Create(icon, ICON_TWEEN, { Size = iconSize }):Play()
        TS:Create(label, TEXT_TWEEN, { AnchorPoint = Vector2.new(1, 0) }):Play()
        TS:Create(keybind, TEXT_TWEEN, { AnchorPoint = Vector2.new(1, 1) }):Play()
        tweenColor(background, HOVER_TWEEN, backgroundColorValue, "Default")
    end)

    button.MouseButton1Down:Connect(function()
        tweenColor(background, PRESS_TWEEN, backgroundColorValue, "Pressed")
    end)

    button.MouseButton1Up:Connect(function()
        tweenColor(background, PRESS_TWEEN, backgroundColorValue, "Hover")
        click:Play()
    end)

    button.Activated:Connect(function()
        wave.BackgroundTransparency = 0
        wave.Size = UDim2.fromScale(1, 1)
        TS:Create(wave, WAVE_TWEEN, {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(2, 2)
        }):Play()
    end)

    Theme:setColor(button, true)

    return button
end

return Button