local _typeof = typeof
local function typeof(value: any)
    local tp = _typeof(value)
    if tp == "Instance" then
        return value.ClassName
    elseif tp == "table" and value.__type then
        return tostring(value)
    end
    return tp
end

local cmd = {}

cmd.Name    = "type"
cmd.Params  = { "<any>", "*[any]" }
cmd.Rank    = "USER"

function cmd:execute(player: Player, a: any, ...: any)
    local types = typeof(a)
    for _, v in ipairs{...} do
        types = ("%s %s"):format(types, typeof(v))
    end
    _G.Remotes:fireClient("Console.print", player, types)

    return true
end

return cmd