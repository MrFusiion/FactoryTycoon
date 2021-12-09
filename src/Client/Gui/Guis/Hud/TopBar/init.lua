local TS = game:GetService("TweenService")

local Theme = _G.Data.Theme

local TopBar = { Priority = 1 }

function TopBar:init(frame: Frame, manager)
    self.Frame = frame
    self.Frame.Position = UDim2.fromScale(0, -1)
    self.Frame.Visible = true

    self.Visible = false

    self.Cash = require(script.Cash):init(frame.Cash)

    manager:subscribe("Slots.SetVisible", function(visible)
        if not visible then
            self:fadein()
        else
            self:fadeout()
        end
    end)
end

function TopBar:fadein()
    if not self.Visible then
        TS:Create(self.Frame, TweenInfo.new(0.5), { Position=UDim2.fromScale(0, 0.005) }):Play()
        self.Visible = true
    end
end

function TopBar:fadeout()
    if self.Visible then
        TS:Create(self.Frame, TweenInfo.new(0.5), { Position=UDim2.fromScale(0, -1) }):Play()
        self.Visible = false
    end
end

return TopBar