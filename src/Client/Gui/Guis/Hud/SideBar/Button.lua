local TS = game:GetService("TweenService")
local ICON_TWEEN =  TweenInfo.new(0.1,  Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local TEXT_TWEEN =  TweenInfo.new(0.5,  Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local HOVER_TWEEN = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local PRESS_TWEEN = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local WAVE_TWEEN =  TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)

local Theme = _G.Data.Theme.Value
local Button = _G.Gui.Elements.Button

function tweenColor(frame: Frame, twinfo: TweenInfo, value: string, modifier: string)
    frame:SetAttribute("BackgroundColor3", ("%s%s"):format(value, modifier))
    TS:Create(frame, twinfo, { BackgroundColor3=Theme(value, modifier) }):Play()
end


local SideButton = {}

function SideButton.new(button: TextButton)
    local button = Button.new(button)
    local container = button.Container

    local label = container.Info.Label
    label.AnchorPoint = Vector2.new(1, 0)

    local keybind = container.Info.Keybind
    keybind.AnchorPoint = Vector2.new(1, 1)

    local icon = container.Content.Icon
    local iconSize = icon.Size

    button.MouseEnter:Connect(function()
        TS:Create(container, HOVER_TWEEN, { Position = UDim2.fromScale(0.1, 0) }):Play()
        TS:Create(icon, ICON_TWEEN, { Size = iconSize + UDim2.fromScale(0.05, 0.05) }):Play()
        TS:Create(label, TEXT_TWEEN, { AnchorPoint = Vector2.new(0, 0) }):Play()
        TS:Create(keybind, TEXT_TWEEN, { AnchorPoint = Vector2.new(0, 1) }):Play()
    end)

    button.MouseLeave:Connect(function()
        TS:Create(container, HOVER_TWEEN, { Position=UDim2.fromScale(0, 0) }):Play()
        TS:Create(icon, ICON_TWEEN, { Size = iconSize }):Play()
        TS:Create(label, TEXT_TWEEN, { AnchorPoint = Vector2.new(1, 0) }):Play()
        TS:Create(keybind, TEXT_TWEEN, { AnchorPoint = Vector2.new(1, 1) }):Play()
    end)

    return button
end

return SideButton