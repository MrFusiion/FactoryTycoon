local _changed = Instance.new("BindableEvent")

local _states = {}

local State = {}

function State:connect(callback: (table)->())
    callback(State)
    return _changed.Event:Connect(callback)
end

function State:append(state: string)
    _states[state] = true
    _changed:Fire(State)
end

function State:remove(state: string)
    _states[state] = nil
    _changed:Fire(State)
end

function State:get(state: string)
    local t = {}
    for state in pairs(_states) do
        table.insert(t, state)
    end
    return t
end

function State:contains(state: string)
    return _states[state] or false
end

return State