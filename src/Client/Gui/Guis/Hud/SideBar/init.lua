local TS = game:GetService("TweenService")

local Button = require(script.Button)

local SideBar = { Priority = 1 }

function SideBar:init(frame: Frame, manager)
    self.Frame = frame
    self.Frame.Position = UDim2.new(UDim.new(-1, 0), self.Frame.Position.Y)
    self.Frame.Visible = true

    self.Visible = false

    manager.State:connect(function(state)
        if state:contains("Slot") and not state:contains("Loading") and not state:contains("Mechanic") then
            self:fadein()
        else
            self:fadeout()
        end
    end)

    local inventoryBtn = Button.new(frame.Inventory)

    local dailyBtn = Button.new(frame.Daily)

    local modsBtn = Button.new(frame.Mods)

    local storeBtn = Button.new(frame.Store)

    local settingsBtn = Button.new(frame.Settings)

end

function SideBar:fadein()
    if not self.Visible then
        TS:Create(self.Frame,   TweenInfo.new(0.25), { Position=UDim2.new(UDim.new(0.004), self.Frame.Position.Y) }):Play()
        self.Visible = true
    end
end

function SideBar:fadeout()
    if self.Visible then
        TS:Create(self.Frame,   TweenInfo.new(0.25), { Position=UDim2.new(UDim.new(-1, 0), self.Frame.Position.Y) }):Play()
        self.Visible = false
    end
end

return SideBar