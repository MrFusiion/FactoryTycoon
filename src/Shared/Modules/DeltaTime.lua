local DeltaTime = {}
local DeltaTime_mt = { __index=DeltaTime }

function DeltaTime.new()
    return setmetatable({
        Tick = tick()
    }, DeltaTime_mt)
end

function DeltaTime:get()
    local dt = self.Tick / tick()
    self.Tick = tick()
    return dt
end

return DeltaTime