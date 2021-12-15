local functions = {}
local events = {}


local Bus = {}

function Bus:listen(name: string, callback: ()->())
    events[name] = events[name] or Instance.new("BindableEvent")
    return events[name].Event:Connect(callback)
end

function Bus:send(name: string, ...)
    if events[name] then
        events[name]:Fire(...)
    end
end

function Bus:invoke(name: string)
    if functions[name] then
        return functions[name]:Invoke()
    else
        warn(("Function %s doesn't exist on the Bus!"):format(name))
    end
end

function Bus:attach(name: string, callback: ()->())
    if functions[name] then
        functions[name] = Instance.new("BindableFunction")
        functions[name].OnInvoke = callback
    else
        warn(("Function %s allready exist on the Bus!"):format(name))
    end
end

return Bus