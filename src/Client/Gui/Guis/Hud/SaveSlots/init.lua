local TS = game:GetService("TweenService")

local Backpack = _G.Client.Backpack

local Theme = _G.Data.Theme.Value

local SHADE_TRANSPARENCY = 0.5
local HIDDEN_POSITION = UDim2.fromScale(-1.05, 0)

local Slots = { Priority = 1 }

function Slots:init(frame: Frame, manager)
    self.Frame = frame.Left.Container
    self.Shade = frame.Shade

    Backpack:show()

    local Slot = require(script.Slot)
    Slot.TEMPLATE = self.Frame.Slots.TEMPLATE
    Slot.TEMPLATE.Parent = nil

    self.Visible = false
    self.Frame.Position = HIDDEN_POSITION
    self.Shade.Transparency = 1
    frame.Visible = true

    local slotInfo = _G.Remotes:invokeServer("Slot.GetSlotData")
    for i, info in ipairs(_G.Config.SLOTS) do
        Slot.new{
            Parent = self.Frame.Slots,
            Id = info.Id,
            Name = info.Name,
            Cash = slotInfo[i].Cash,
            Date = slotInfo[i].Date,
        }
    end

    manager:subscribe("Slots.SetVisible", function(visible)
        if visible ~= self.Visible then
            if visible then
                self:fadein()
            else
                self:fadeout()
            end
            self.Visible = visible
        end
    end)

    local slotV = game:GetService("Players").LocalPlayer:WaitForChild("Slot")
    slotV:GetPropertyChangedSignal("Value"):Connect(function()
        manager:dispatch("Slots.SetVisible", slotV.Value == -1)
    end)
end

function Slots:fadein()
    TS:Create(self.Frame,   TweenInfo.new(0.5), { Position=UDim2.fromScale(0, 0) }):Play()
    TS:Create(self.Shade,       TweenInfo.new(0.5), { Transparency=SHADE_TRANSPARENCY }):Play()
end

function Slots:fadeout()
    TS:Create(self.Frame,   TweenInfo.new(0.5), { Position=HIDDEN_POSITION }):Play()
    TS:Create(self.Shade,       TweenInfo.new(0.5), { Transparency=1 }):Play()
end

return Slots