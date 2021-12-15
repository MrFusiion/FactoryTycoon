local player = game:GetService("Players").LocalPlayer
local playerGui = player.PlayerGui

local Sound = {}
local Sound_mt = { __index=Sound }

function Sound.new(id: (number|string), props: table?)
    id = typeof(id) == "number" and ("rbxassetid://%d"):format(id) or id

    local self = {}

    self.Instance = Instance.new("Sound")
    self.Instance.SoundId = id

    for propName, propVal in pairs(props or {}) do
        self.Instance[propName] = propVal
    end

    return setmetatable(self, Sound_mt)
end

function Sound:play()
    local sound = self.Instance:Clone()
    sound.Ended:Connect(function()
        sound:Destroy()
    end)
    sound.Parent = playerGui
    return sound
end

return Sound