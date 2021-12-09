local Validate = {}

function Validate.isInstanceOf(instance, className, cb)
    local boolean = (typeof(instance)=="Instance" and instance.ClassName == className)
    if typeof(cb)=="function" and boolean then
        cb()
    end
    return boolean
end

return Validate