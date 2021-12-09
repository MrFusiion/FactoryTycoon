local Util = require(script.Parent.Parent.Util)

local TEMPLATE

local Print = {}
local Print_mt = { __index=Print }

function Print.template(template: Frame)
    TEMPLATE = template
    TEMPLATE.Visible = false
end

function Print.new(text: string)
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

    return setmetatable(self, Print_mt)
end

function Print:setParent(parent: Instance)
    self.Frame.Parent = parent
end

function Print:destroy()
    self.Frame:destroy()
end

return Print