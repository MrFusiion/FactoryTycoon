local Text = _G.Shared.Text

local Data = _G.Data
local Theme = Data.Theme.Value

local player = game:GetService("Players")

local Cash = {}

function Cash:init(frame: Frame)
    self.Frame = frame

    self.CashLabel = frame.Content.Label
    Text:autoResize(self.CashLabel, Text.Directions.X)

    Data.Cash:connect(function()
        self.CashLabel.Text = Data.Cash:get()
    end)
    self.CashLabel.Text = Data.Cash:get()
end

return Cash