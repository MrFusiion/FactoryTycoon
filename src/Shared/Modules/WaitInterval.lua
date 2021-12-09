
--@class WaitInterval
local WaitInterval = {}
WaitInterval.__index = WaitInterval


---@param interval number
function WaitInterval.new(interval: number)
    local self = setmetatable({}, WaitInterval)
    self.LastTick = tick()
    self.Interval = interval
    return self
end


--- Waits every interval
function WaitInterval:checkWait()
    if tick() - self.LastTick > self.Interval then
        wait()
        self.LastTick = tick()
    end
end


return WaitInterval