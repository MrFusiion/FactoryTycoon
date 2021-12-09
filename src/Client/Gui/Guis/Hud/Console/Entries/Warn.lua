local Util = require(script.Parent.Parent.Util)

local TEMPLATE

local Warn = {}
local Warn_mt = { __index=Warn }

function Warn.template(template: Frame)
    TEMPLATE = template
    TEMPLATE.Visible = false
end

function Warn.new(text: string)
    local self = {}

    self.Frame = TEMPLATE:Clone()
    self.Frame.Visible = true

    local label = self.Frame.Message
    label.Text = text

    local ar = self.Frame:FindFirstChildWhichIsA("UIAspectRatioConstraint")
    --Util:autoSize(TEMPLATE, TEMPLATE.Message, self.Frame, label)
    Util:aspectRatio(ar, TEMPLATE.Message, text)
    Util:autoTextSize(self.Frame, {
        { Ref = TEMPLATE.Message, Label = label }
    })

    return setmetatable(self, Warn_mt)
end

function Warn:setParent(parent: Instance)
    self.Frame.Parent = parent
end

function Warn:destroy()
    self.Frame:destroy()
end

return Warn