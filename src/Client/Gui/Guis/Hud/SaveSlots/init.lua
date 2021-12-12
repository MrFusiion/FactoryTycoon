local TS = game:GetService("TweenService")

local Backpack = _G.Client.Backpack

local Theme = _G.Data.Theme.Value

local SHADE_TRANSPARENCY = 0.5
local HIDDEN_POSITION = UDim2.fromScale(-1.05, 0)

local Slot = require(script.Slot)

local Slots = { Priority = 1 }

function Slots:init(frame: Frame, manager)
    self.Frame = frame.Left.Container
    self.Shade = frame.Shade

    Backpack:show()

    Slot.TEMPLATE = self.Frame.Slots.TEMPLATE
    Slot.TEMPLATE.Parent = nil

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

    --<< Initial State >>
    self.Visible = false
    self.Frame.Position = HIDDEN_POSITION
    self.Shade.Transparency = 1
    frame.Visible = true

    manager.State:connect(function(State)
        if not State:contains("Slot") and not State:contains("Loading") then
            self:fadein()
        else
            self:fadeout()
        end
    end)
end

function Slots:fadein()
    if not self.Visible then
        TS:Create(self.Frame, TweenInfo.new(0.5), { Position=UDim2.fromScale(0, 0) }):Play()
        TS:Create(self.Shade, TweenInfo.new(0.5), { Transparency=SHADE_TRANSPARENCY }):Play()
        self.Visible = true
    end
end

function Slots:fadeout()
    if self.Visible then
        TS:Create(self.Frame, TweenInfo.new(0.5), { Position=HIDDEN_POSITION }):Play()
        TS:Create(self.Shade, TweenInfo.new(0.5), { Transparency=1 }):Play()
        self.Visible = false
    end
end

return Slots