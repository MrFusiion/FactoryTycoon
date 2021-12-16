local DeltaTime = _G.Shared.DeltaTime


local Light = {}
local Light_mt = { __index=Light }

function Light.new(model: Model)
    local self = {}

    self.On = true

    self.Model = model
    self.LightParts = {}
    self.Lights = {}
    for _, desc in ipairs(self.Model:GetDescendants()) do
        if desc:IsA("BasePart") then
            if desc.Material == Enum.Material.Neon then
                table.insert(self.LightParts, {
                    Color = desc.BrickColor,
                    Instance = desc,
                })
            end
        elseif desc:IsA("Light") then
            table.insert(self.LightParts, {
                Color = desc.Color,
                Instance = desc,
            })
        end
    end

    return setmetatable(self, Light_mt)
end

function Light:chroma(speed: number?)
    speed = speed or 1
    local h = 0
    local dt = DeltaTime.new()
    task.spawn(function()
        while self.On do
            local color = Color3.fromHSV(h / 360, 1, 1)
            for _, part in ipairs(self.LightParts) do
                part.Instance.Color = color
            end
            for _, light in ipairs(self.Lights) do
                light.Instance.Color = color
            end
            task.wait(1/speed)
            h = (h + 1 * dt:get()) % 360
        end
    end)
end

function Light:on()
    if not self.On then
        for _, part in ipairs(self.LightParts) do
            part.Instance.Material = "Neon"
        end
        for _, light in ipairs(self.Lights) do
            light.Instance.Enabled = true
        end
        self.On = true
    end
end

function Light:off()
    if self.On then
        for _, part in ipairs(self.LightParts) do
            part.Instance.Material = "SmoothPlastic"
        end
        for _, light in ipairs(self.Lights) do
            light.Instance.Enabled = false
        end
        self.On = false
    end
end

function Light:toggle()
    if self.On then
        self:off()
    else
        self:on()
    end
end

return Light