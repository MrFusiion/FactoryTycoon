local debug = {}
debug.__index = debug

local function createTextBox(parent, y)
    local textbox = Instance.new("TextBox")
    textbox.Active = false
    textbox.BackgroundTransparency = 1
    textbox.Size = UDim2.new(1, 0, 0, 50)
    textbox.Position = UDim2.fromOffset(0, y)
    textbox.Font = "SourceSansSemibold"
    textbox.RichText = true
    textbox.TextColor3 = Color3.new(.85, .85, .85)
    textbox.TextStrokeColor3 = Color3.new()
    textbox.TextStrokeTransparency = 0
    textbox.Text = ""
    textbox.TextSize = 40
    textbox.Parent = parent
    return textbox
end

local ENABLED = true
function debug.new(resource)
    if ENABLED then
        local self = setmetatable({}, debug)
        self.Resource = resource

        local debugPart = Instance.new("Part")
        debugPart.Name = "Debug"
        debugPart.Anchored = true
        debugPart.CanCollide = false
        debugPart.Transparency = 1
        debugPart.CFrame = resource.OriginCFrame * CFrame.new(0, 2, 0)
        debugPart.Parent = resource.Model

        local billboard = Instance.new("BillboardGui")
        billboard.Name = "Debug"
        billboard.MaxDistance = 30
        billboard.Size = UDim2.fromOffset(200, 200)
        billboard.ZIndexBehavior = "Sibling"
        billboard.AlwaysOnTop = true
        billboard.Adornee = debugPart
        billboard.Parent = debugPart

        self.Stage = createTextBox(billboard)
        self.TimeUntil = createTextBox(billboard, 50)
        self.GrowCalls = createTextBox(billboard, 100)

        self:update()

        return self
    end
end

function debug:update()
    local stageValue = self.Resource.Stage or "None"
    local timeUntilValue = self.Resource.TimeUntilDeath or 0
    local growcallsValue = self.Resource.GrowCalls or 0

    local color = stageValue == "Growing" and Color3.fromRGB(255, 219, 61) or
        stageValue == "Grown" and Color3.fromRGB(61, 255, 80) or
        stageValue == "Leaves Fallen" and Color3.fromRGB(255, 190, 61) or
        (stageValue == "Dead" or stageValue == "Broken Up") and Color3.fromRGB(255, 61, 61)
    if color then
        self.Stage.Text = ("<font color=\"rgb(%d, %d, %d)\">%s</font>"):format(color.R * 255, color.G * 255, color.B * 255, stageValue)
    else
        self.Stage.Text = stageValue
    end

    self.TimeUntil.Text = ("<font color=\"rgb(%d,%d,%d)\">%.2f</font>"):format(
        table.unpack(timeUntilValue >= 0 
            and {61, 255, 80, timeUntilValue}
            or {255, 61, 61, timeUntilValue}))

    self.GrowCalls.Text = ("<font color=\"rgb(%d,%d,%d)\">%d</font>/%d"):format(
        table.unpack(self.Resource.GrowCalls > self.Resource.MaxGrowCalls 
            and {61, 168, 255, self.Resource.GrowCalls, self.Resource.MaxGrowCalls}
            or {61, 255, 80, self.Resource.GrowCalls, self.Resource.MaxGrowCalls}))
end

return debug