local Symbol = _G.Shared.Symbol
local Intr = Symbol.named("Internal")

local Value = {}
local Value_mt = { __index = Value }

Value.Nil = Symbol.named("Nil")

function Value_mt:__newindex()
    warn("cannot write to Value Object!")
end

function Value_mt:__index(k: string)
    if k == "Value" then
        return self:get()
    elseif Value[k] then
        return Value[k]
    end
end

function Value.new(value: string)
    return setmetatable({
        [Intr] = {
            Value = value,
            Signals = {
                Changed = Instance.new("BindableEvent")
            }
        }
    }, Value_mt)
end

function Value:get()
    return self[Intr].Value
end

function Value:set(value: any)
    self[Intr].Value = value
    self[Intr].Signals.Changed:Fire(value)
end

function Value:update(callback: ((value: any) -> any))
    local suc, newVal = pcall(callback, self:get())

    if suc then
        if newVal == nil then
            warn("Callback did not return a new value, If removing the value was the intention please use Value.Nil instead, Value is not Updated!")
        elseif newVal == Value.Nil then
            self:set(nil)
        else
            self:set(newVal)
        end
    else
        error(("An error occurred while updating the value, %s"):format(newVal))
    end
end

function Value:increment(value: any)
    local suc, err = pcall(self.update, self, function(oldVal)
        return oldVal + value
    end)

    if not suc then
        error(("An error occurred while incrementing the value, %s"):format(err))
    end
end

function Value:connect(callback: ((value: any) -> ()))
    return self[Intr].Signals.Changed.Event:Connect(callback)
end


local Data = {}
local Data_mt = { __index = Data }

function Data.new()
    return setmetatable({}, Data_mt)
end

function Data:newValue(name: string, value: any)
    if not self[name] then
        local value = Value.new(value)
        self[name] = value
        return value
    else
        error(("Value with the name %s allready exist!"):format(name))
    end
end

local self = Data.new()

for _, dataModule in ipairs(script:GetChildren()) do
    local reqSuc, init = pcall(require, dataModule)

    if reqSuc then
        local suc, err = pcall(init, self)
        if not suc then
            warn(("An error occurred in the returned Init function from DataModule %s! %s"):format(dataModule.Name, err))
        end
    else
        warn(("An error occurred while requiring DataModule %s! %s"):format(dataModule.Name, init))
    end
end

return self