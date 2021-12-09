---@param classname string
---@param parent Instance
---@param props table
---@return Instance
return function(classname: string, parent: Instance, props: table)
    local suc, instance = pcall(function()
        local instance = Instance.new(classname)
        for propname, propvalue in pairs(props) do
            instance[propname] = propvalue
        end
        instance.Parent = parent
        return instance
    end)

    if not suc then
        error(instance)
    end

    return instance
end