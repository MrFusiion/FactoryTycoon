
local TIMEOUT = 5
local GuiManager = {
    Groups = {},
    Signals = {}
}

local Group = require(script.Group)
function GuiManager:group(name: string)
    if not self.Groups[name] then
        self.Groups[name] = Group.new()
    end
    return self.Groups[name]
end

function GuiManager:configureGroup(name: string, configs: table)
    local group = self:group(name)
    group:configure(configs)
end

function GuiManager:subscribe(action: string, callback: () -> ()): RBXScriptSignal
    if not self.Signals[action] then
        self.Signals[action] = Instance.new("BindableEvent")
    end
    return self.Signals[action].Event:Connect(callback)
end

function GuiManager:dispatch(action: string, ...)
    local start = tick()
    while not self.Signals[action] and tick() - start <= TIMEOUT do
        task.wait()
    end

    if self.Signals[action] then
        self.Signals[action]:Fire(...)
    else
        warn(("Could not dispatch %s no function subscribed to it!"):format(action))
    end
end

return GuiManager