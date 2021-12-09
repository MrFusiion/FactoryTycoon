
local ColorPallete = require(script.ColorPallete)

local Mechanic = {}

function Mechanic:init(frame: Frame, core)

    self.Frame = frame

    ColorPallete:init(frame.ColorPallete)

    --<< Initial State >>
    self.Frame.Visible = true
    self.Visible = true
end

function Mechanic:fadein()
    if not self.Visible then
        self.Visible = true
    end
end

function Mechanic:fadeout()
    if self.Visible then
        self.Visible = false
    end
end

function Mechanic:toggle()
    if self.Visible then
        self:fadeout()
    else
        self:fadein()
    end
end

return Mechanic