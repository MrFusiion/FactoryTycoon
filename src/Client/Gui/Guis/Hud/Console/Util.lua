local TextS = game:GetService("TextService")

local function textBounds(text: string, textSize: number, font: Enum.Font, bounds: Vector2)
    text = string.gsub(text, "<[/]*font .+>", "")
    return TextS:GetTextSize(text, textSize, font, bounds)
end

local Util = {}

function Util:autoTextSize(obj: GuiObject, labels: {TextLabel})
    for _, v in ipairs(labels) do
        v.Label.TextScaled = false
    end

    local function resize()
        for _, v in ipairs(labels) do
            v.Label.TextSize = v.Ref.AbsoluteSize.Y
        end
    end

    obj:GetPropertyChangedSignal("AbsoluteSize"):Connect(resize)
    resize()
end

function Util:aspectRatio(ar: UIAspectRatioConstraint, refLabel: TextLabel, text: string)
    local size = textBounds(text, refLabel.AbsoluteSize.Y,
            refLabel.Font, Vector2.new(refLabel.AbsoluteSize.X, 4e5))

    local i = math.ceil(size.Y / refLabel.AbsoluteSize.Y)
    ar.AspectRatio = ar.AspectRatio / i
end

return Util