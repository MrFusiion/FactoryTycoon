local TS = game:GetService("TweenService")

local Backpack = _G.Client.Backpack

local Button = _G.Gui.Elements.Button
local Loading = _G.Gui.Elements.Loading

local Loaded = false

local function spawn(func: () -> (), ...)
    local event = Instance.new("BindableEvent")
    event.Event:Connect(func)
    event:Fire(...)
    event:Destroy()
end

local MainMenu = { Priority = 9999 }

function MainMenu:init(frame: Frame, manager)
    if not _G.Config.LOADING_ENABLED then
        task.wait()
        frame.Visible = false
        manager:dispatch("Slots.SetVisible", true)
        return
    end

    if Loaded then
        manager:dispatch("Slots.SetVisible", false)
        return
    end

    game:GetService("StarterGui"):SetCore("ResetButtonCallback", false)

    frame.Visible = true
    frame.Sound:Play()
    Backpack:hide()

    self.Background = frame.Background
    self.Pattern = frame.Pattern
    self.Bottom = self.Background.Bottom
    self.Top = self.Background.Top

    self.PlayButton = Button.new(frame.PlayButton)
    self.PlayButton.AnchorPoint = Vector2.new(0.5, 0)
    self.PlayButton.Position = UDim2.fromScale(0.5, 1)

    self.Loading = Loading.new{
        Parent = frame.LoadingContainer,
        Speed = 0.75
    }
    self.Loading:show()

    self.Logo = frame.LogoContainer.Logo

    local pattermTw = TS:Create(self.Pattern, TweenInfo.new(3, Enum.EasingStyle.Linear), { Position=UDim2.fromOffset(0, 0) })
    self.PatternConn = pattermTw.Completed:Connect(function()
        self.Pattern.Position = UDim2.fromOffset(-200, -200)
        pattermTw:Play()
    end)
    pattermTw:Play()

    if not game:IsLoaded() then
        game.Loaded:Wait()
    end
    self.Loading:hide()

    TS:Create(self.PlayButton,  TweenInfo.new(0.5), {
        AnchorPoint=Vector2.new(0.5, 1),
        Position=UDim2.fromScale(0.5, 0.95)
    }):Play()

    self.PlayButton.Activated:Connect(function()
        self:hide()
        task.wait(1)
        Loaded = true
        game:GetService("StarterGui"):SetCore("ResetButtonCallback", true)
        manager:dispatch("Slots.SetVisible", true)
    end)
end

function MainMenu:hide()

    TS:Create(self.Pattern,     TweenInfo.new(0.5), {
        ImageTransparency=1
    }):Play()

    TS:Create(self.PlayButton,  TweenInfo.new(0.5), {
        AnchorPoint=Vector2.new(0.5, 0),
        Position=UDim2.fromScale(0.5, 1)
    }):Play()

    spawn(function()
        TS:Create(self.Top,         TweenInfo.new(0.5), { Position=UDim2.fromScale(0.5, -0.05) }):Play()
        TS:Create(self.Bottom,      TweenInfo.new(0.5), { Position=UDim2.fromScale(0.5,  1.05) }):Play()
        task.wait(0.5)
        TS:Create(self.Background,  TweenInfo.new(0.5), { Rotation=45 }):Play()
        task.wait(0.5)
        TS:Create(self.Top,         TweenInfo.new(  1), { Position=UDim2.fromScale(0.5, -1) }):Play()
        TS:Create(self.Bottom,      TweenInfo.new(  1), { Position=UDim2.fromScale(0.5,  2) }):Play()
    end)

    spawn(function()
        TS:Create(self.Logo, TweenInfo.new(   1), { Size=UDim2.fromScale(1.3, 1.3) }):Play()
        task.wait(1)
        TS:Create(self.Logo, TweenInfo.new(0.25), { Size=UDim2.fromScale(  0,   0) }):Play()
    end)

    if self.PatternConn then
        self.PatternConn:Disconnect()
    end
end

return MainMenu