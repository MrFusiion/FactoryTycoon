local Command = require(game:GetService("ReplicatedStorage")
    :WaitForChild("Command"))
local Util = require(script.Parent.Parent.Util)

local TEMPLATE, COLORS



local Log = {}
local Log_mt = { __index=Log }

function Log.template(template: Frame)
    TEMPLATE = template
    TEMPLATE.Visible = false
end

function Log.colors(colors: table)
    COLORS = colors
end

function Log.new(text: string)
    local self = {}

    self.Frame = TEMPLATE:Clone()
    self.Frame.Visible = true

    local label = self.Frame.Label
    label.Text = Command:highlight(text, COLORS)

    local arrow = self.Frame.Container.Arrow

    local ar = self.Frame:FindFirstChildWhichIsA("UIAspectRatioConstraint")
    --Util:autoSize(TEMPLATE, TEMPLATE.Label, self.Frame, label)
    Util:aspectRatio(ar, TEMPLATE.Label, text)
    Util:autoTextSize(self.Frame, {
        { Ref = TEMPLATE.Label, Label = label },
        { Ref = TEMPLATE.Container.Arrow, Label = arrow }
    })

    return setmetatable(self, Log_mt)
end

function Log:setParent(parent: Instance)
    self.Frame.Parent = parent
end

function Log:destroy()
    self.Frame:destroy()
end

return Log