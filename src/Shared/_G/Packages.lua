local TIMEOUT = 5
local function waitFor(callback: () -> any, warnMsg: string )
    local warned = false

    local start, val = tick(), nil
    repeat
        val = callback()
        if val == nil then
            task.wait()
        end
        if not warned and tick() - start > TIMEOUT then
            warn(warnMsg)
            warned = true
        end
    until val ~= nil

    return val
end


--________Package___________________________
local Package = {}
local Package_mt = { __index=Package }

function Package.new()
    return setmetatable({}, Package_mt)
end

function Package:get(...: string?)
    local function get(key, ...)
        if key then
            return waitFor(
                function()
                    return self[key]
                end,
                ("Infinte yield possible on Value %s!")
                    :format(key)
            ), get(...)
        end
    end
    return get(...)
end


--________Packages___________________________
local Packages = {}

function Packages:export(...)
    local name, value = ...
    local t = ...

    if name and value then
        local env = getfenv(2)
        self[env.script.Name] = self[env.script.Name] or Package.new()
        self[env.script.Name][name] = value
    elseif t then
        for k, v in pairs(t) do
            local env = getfenv(2)
            self[env.script.Name] = self[env.script.Name] or Package.new()
            self[env.script.Name][k] = v
        end
    end
end

function Packages:get(name: string)
    local val = waitFor(function()
        return rawget(self, name)
    end),
    ("Infinte yield possible on Package %s!")
        :format(name)
    return val
end

return setmetatable({}, {
    __index=Packages
})