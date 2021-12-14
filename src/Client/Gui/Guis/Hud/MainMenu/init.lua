local TS = game:GetService("TweenService")
local SG = game:GetService("StarterGui")

local Backpack = _G.Client.Backpack

local Button = _G.Gui.Elements.Button
local Loading = _G.Gui.Elements.Loading

local function spawn(func: () -> (), ...)
    local event = Instance.new("BindableEvent")
    event.Event:Connect(func)
    event:Fire(...)
    event:Destroy()
end

local function setCore(name: string, value: any)
    while true do
        local suc, err = pcall(function()
            SG:SetCore(name, value)
        end)

        if suc then
            break
        else
            warn(err)
        end

        task.wait()
    end
end

local MainMenu = { Priority = 9999 }

function MainMenu:init(frame: Frame, manager)

    local background = frame.Background
    local pattern = frame.Pattern
    local bottom = background.Bottom
    local top = background.Top

    local playButton = Button.new(frame.PlayButton)
    playButton.AnchorPoint = Vector2.new(0.5, 0)
    playButton.Position = UDim2.fromScale(0.5, 1)

    self.Loading = Loading.new{
        Parent = frame.LoadingContainer,
        Speed = 0.75
    }

    local logo = frame.LogoContainer.Logo

    task.desynchronize()

    self.Tweens = {
        --<< Pattern >>
        PatternAnim = TS:Create(pattern, TweenInfo.new(3, Enum.EasingStyle.Linear), {
            Position=UDim2.fromOffset(0, 0)
        }),

        PatternFadeOut = TS:Create(pattern, TweenInfo.new(0.5), {
            ImageTransparency=1
        }),


        --<< Background >>
        TopOpen = TS:Create(top, TweenInfo.new(0.5), {
            Position=UDim2.fromScale(0.5, -0.05)
        }),

        BottomOpen = TS:Create(bottom, TweenInfo.new(0.5), {
            Position=UDim2.fromScale(0.5,  1.05)
        }),

        TopMove = TS:Create(top, TweenInfo.new(  1), {
            Position=UDim2.fromScale(0.5, -1)
        }),

        BottomMove = TS:Create(bottom, TweenInfo.new(  1), { Position=UDim2.fromScale(0.5,  2)
        }),

        BackgroundRotate = TS:Create(background, TweenInfo.new(0.5), {
            Rotation=45
        }),


        --<< Button >>
        PlayButtonFadeIn = TS:Create(playButton,  TweenInfo.new(0.5), {
            AnchorPoint=Vector2.new(0.5, 1),
            Position=UDim2.fromScale(0.5, 0.95)
        }),

        PlayButtonFadeOut = TS:Create(playButton,  TweenInfo.new(0.5), {
            AnchorPoint=Vector2.new(0.5, 0),
            Position=UDim2.fromScale(0.5, 1)
        }),


        --<< Logo >>
        LogoGrow = TS:Create(logo, TweenInfo.new(   1), {
            Size=UDim2.fromScale(1.3, 1.3)
        }),
        LogoShrink = TS:Create(logo, TweenInfo.new(0.25), {
            Size=UDim2.fromScale(  0,   0)
        })
    }

    --<< Pattern Loop Connection >>
    self.PatternConn = self.Tweens.PatternAnim.Completed:Connect(function()
        pattern.Position = UDim2.fromOffset(-200, -200)
        self.Tweens.PatternAnim:Play()
    end)

    --<< Play Button >>
    local btnConn
    btnConn = playButton.Activated:Connect(function()
        btnConn:Disconnect()

        self:hide()
        manager.State:remove("Loading")
    end)

    --<< State Manager >>
    manager.State:connect(function(State)
        if State:contains("Loading") then
            frame.Visible = true
            self:play()
        else
            frame.Visible = false
        end
    end)
end

function MainMenu:play()
    setCore("ResetButtonCallback", false)
    Backpack:hide()

    --<< Loading Icon >>
    self.Loading:show()

    --<< Background Pattern Animation >>
    self.Tweens.PatternAnim:Play()

    if not game:IsLoaded() then
        game.Loaded:Wait()
    end
    self.Loading:hide()

    self.Tweens.PlayButtonFadeIn:Play()
end

function MainMenu:hide()
    spawn(function()
        self.Tweens.PatternFadeOut:Play()
        self.Tweens.PlayButtonFadeOut:Play()

        self.Tweens.TopOpen:Play()
        self.Tweens.BottomOpen:Play()
        task.wait(0.5)

        self.Tweens.BackgroundRotate:Play()
        task.wait(0.5)

        self.Tweens.TopMove:Play()
        self.Tweens.BottomMove:Play()
    end)

    spawn(function()
        self.Tweens.LogoGrow:Play()
        task.wait(1)
        self.Tweens.LogoShrink:Play()
    end)

    task.wait(2)

    if self.PatternConn then
        self.PatternConn:Disconnect()
    end

    setCore("ResetButtonCallback", true)
    Backpack:show()
end

return MainMenu