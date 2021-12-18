local TS = game:GetService("TweenService")
local HOVER_TWEEN = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local PRESS_TWEEN = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local SELECT_TWEEN = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local WAVE_TWEEN = TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)

local Text = _G.Shared.Text
local Theme = _G.Data.Theme.Value

function tweenColor(frame: Frame, twinfo: TweenInfo, value: string, modifier: string)
    frame:SetAttribute("BackgroundColor3", ("%s%s"):format(value, modifier))
    TS:Create(frame, twinfo, { BackgroundColor3=Theme(value, modifier) }):Play()
end


local Button = {}

function Button.new(button: (TextButton|ImageButton))

    local background = button.Background
    local content = button.Content
    local shadow = button.Shadow

    local wave = button:FindFirstChild("Wave")

    local hover = Instance.new("Sound")
    hover.SoundId = "rbxassetid://421058925"
    hover.Parent = button

    local click = Instance.new("Sound")
    click.SoundId = "rbxassetid://452267918"
    click.Parent = button

    local contentColorValue = content:GetAttribute("BackgroundColor3")
    local backgroundColorValue = background:GetAttribute("BackgroundColor3")
    local shadowColorValue = shadow:GetAttribute("BackgroundColor3")
    --self.Shadow = button:FindFirstChild("Shadow")

    --self.ContentPadding = button.Content:FindFirstChildWhichIsA("UIPadding")
    --self.ContentLayout = button.Content:FindFirstChildWhichIsA("Layout")
    --local label = button.Content:FindFirstChild("Label")
    --self.Icon = button.Content:FindFirstChild("Icon")

    --[[if label then
        Text:autoResize(label, Text.Directions.X)
    end]]

    local hovering = false
    if backgroundColorValue and contentColorValue and shadowColorValue then
        button.MouseEnter:Connect(function()
            tweenColor(content   , HOVER_TWEEN, contentColorValue, "Hover")
            if not button.Selected then
                tweenColor(background, HOVER_TWEEN, backgroundColorValue, "Hover")
                tweenColor(shadow    , HOVER_TWEEN, shadowColorValue, "Hover")
            end
            hovering = true
            hover:Play()
        end)

        button.MouseLeave:Connect(function()
            tweenColor(content   , HOVER_TWEEN, contentColorValue, "Default")
            if not button.Selected then
                tweenColor(background, HOVER_TWEEN, backgroundColorValue, "Default")
                tweenColor(shadow    , HOVER_TWEEN, shadowColorValue, "Default")
            end
            hovering = false
        end)

        button.MouseButton1Down:Connect(function()
            tweenColor(content   , PRESS_TWEEN, contentColorValue, "Pressed")
            if not button.Selected then
                tweenColor(background, PRESS_TWEEN, backgroundColorValue, "Pressed")
                tweenColor(shadow    , PRESS_TWEEN, shadowColorValue, "Pressed")
            end
        end)

        button.MouseButton1Up:Connect(function()
            tweenColor(content   , PRESS_TWEEN, contentColorValue, "Hover")
            if not button.Selected then
                tweenColor(background, PRESS_TWEEN, backgroundColorValue, "Hover")
                tweenColor(shadow    , PRESS_TWEEN, shadowColorValue, "Hover")
            end
            click:Play()
        end)

        button:GetPropertyChangedSignal("Selected"):Connect(function()
            if button.Selected then
                tweenColor(background, SELECT_TWEEN, backgroundColorValue, "Selected")
                tweenColor(shadow    , SELECT_TWEEN, shadowColorValue, "Selected")
            elseif hovering then
                tweenColor(background, HOVER_TWEEN, backgroundColorValue, "Hover")
                tweenColor(shadow    , HOVER_TWEEN, shadowColorValue, "Hover")
            else
                tweenColor(background, HOVER_TWEEN, backgroundColorValue, "Default")
                tweenColor(shadow    , HOVER_TWEEN, shadowColorValue, "Default")
            end
        end)
    end

    if wave then
        wave.BackgroundTransparency = 1

        button.Activated:Connect(function()
            wave.BackgroundTransparency = 0
            wave.Size = UDim2.fromScale(1, 1)
            TS:Create(wave, WAVE_TWEEN, {
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(2, 2)
            }):Play()
        end)
    end

    --Theme:setColor(button, true)

    return button
end

return Button