--local GRAY_SCALE_IDS = { 127, 122, 123, 108, 49, 97, 3, 10, 29, 50, 75, 86 }
--local COLOR_OUTER = Color3.fromRGB(41, 115, 253)
--local COLOR_INNER = Color3.new(1, 1, 1)
local TOLERANCE = 0.3
local RANGE_LIM = 360

local function between(n: number, min: number, max: number)
    return min <= n and n <= max
end

local function isGray(c: Color3)
    return (math.max(c.R, c.G, c.B) - math.min(c.R, c.G, c.B)) * 255 < RANGE_LIM
end

local function toHSL(c: Color3)
    --both hsv and hsl values are in [0, 1]
    local h, s, v = c:ToHSV()
    local l = (2 - s) * v / 2;

    if l ~= 0 then
        if l == 1 then
            s = 0;
        elseif (l < 0.5) then
            s = s * v / (l * 2);
        else
            s = s * v / (2 - l * 2);
        end
    end

    return h, s, l
end

local ColorPallete = {}

function ColorPallete:init(frame: Frame)
    self.Frame = frame

    local content = self.Frame.Content

    local colors = {}
    for i=0, 127 do
        table.insert(colors, BrickColor.palette(i).Color)
    end
    --[[for _, i in ipairs(GRAY_SCALE_IDS) do
        table.insert(colors, BrickColor.palette(i))
    end]]

    table.sort(colors, function(a: Color3, b: Color3)
        local ah, _, av = a:ToHSV()
        local bh, _, bv = b:ToHSV()

        local _, as, al = toHSL(a)
        local _, bs, bl = toHSL(b)

        local ag = isGray(a)
        local bg = isGray(b)

        local alum = 0.299*a.R + 0.587*a.G + 0.114*a.B
        local blum = 0.299*b.R + 0.587*b.G + 0.114*b.B

        if ag and bg then
            return al > bl
        elseif ag and not bg then
            return false
        elseif bg and not ag then
            return true
        end

        if al ~= bl then
            return al > bl
        elseif ah ~= bh then
            return ah < bh
        elseif as ~= bs then
            return as < bs
        end
    end)

    for i=1, #colors do
        local brickColor  = colors[i]

        local btn = Instance.new("ImageButton")
        btn.BackgroundColor3 = brickColor
        btn.BorderSizePixel = 0
        btn.LayoutOrder = i
        btn.Parent = content
    end

    --<< Initial State >>
    self.Visible = true
    self.Frame.Visible = true
end

function ColorPallete:show()
    if not self.Visible then
        self.Frame.Visible = true
        self.Visible = true
    end
end

function ColorPallete:hide()
    if self.Visible then
        self.Frame.Visible = false
        self.Visible = false
    end
end

return ColorPallete