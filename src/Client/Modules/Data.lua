local mt = {}
local Data = setmetatable({}, mt)
Data.__folder = game:GetService("StarterPlayer").StarterPlayerScripts.Data

function mt:__index(k: string)
    local moduleName = ("%sData"):format(k)
    local dataModule = self.__folder:FindFirstChild(moduleName)
    if dataModule then
        local suc, data = pcall(require, dataModule)
        if suc then
            self[k] = data
            return data
        else
            warn(("An error occurred while requiring module %s!"):format(moduleName))
        end
    else
        warn(("could not find Data with the name %s!"):format(k))
    end
end

return Data