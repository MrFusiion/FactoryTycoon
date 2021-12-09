local modules = {}

for _, module in ipairs(script:GetChildren()) do
    modules[module.Name] = require(module)
end

return setmetatable(modules, {
    __call = function(self, key)
        local module = self[key]
        if not module then
            warn(("Client Module %s doesn't exist!"):format(key))
        end
        return modules
    end,
    __newindex = function(self, key)
        warn("Cannot assign new values to Modules")
    end
})