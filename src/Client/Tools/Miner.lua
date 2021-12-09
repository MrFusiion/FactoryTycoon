local RS = game:GetService("RunService")

local function v3Snap(v: Vector3, grid: Vector3)
    return Vector3.new(
        math.floor(v.X / grid.X + 0.5) * grid.X,
        math.floor(v.Y / grid.Y + 0.5) * grid.Y,
        math.floor(v.Z / grid.Z + 0.5) * grid.Z
    )
end

local Miner = {}
local Miner_mt = { __index=Miner }

function Miner.new(tool: Tool)
    local self = {}

    self.Tool = tool

    local range = 1000
    self.Tool.Activated:Connect(function()
        local unit = game:GetService("Players").LocalPlayer:GetMouse().UnitRay
        local params = RaycastParams.new()
        params.FilterDescendantsInstances = { workspace.GizmosServer }
        params.FilterType = Enum.RaycastFilterType.Blacklist

        local result = workspace:Raycast(unit.Origin, unit.Direction * range, params)
        if result then
            local id = result.Instance:GetAttribute("StoneId")
            if id then
                _G.Remotes:fireServer("Test.Mine", id, result.Position - result.Normal * Vector3.new(1, 1, 1) * .1)
            end
        end
    end)

    return setmetatable(self, Miner_mt)
end

return Miner