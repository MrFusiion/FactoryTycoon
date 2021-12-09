local Util = require(script.Parent.Parent.Util)

local TEMPLATE

local Error = {}
local Error_mt = { __index=Error }

function Error.template(template: Frame)
    TEMPLATE = template
    TEMPLATE.Visible = false
end

function Error.new(text: string)
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

    return setmetatable(self, Error_mt)
end

function Error:setParent(parent: Instance)
    self.Frame.Parent = parent
end

function Error:destroy()
    self.Frame:destroy()
end

return Error