local cmd = {}

cmd.Name    = "print"
cmd.Params  = { "<any>", "*[any]" }
cmd.Rank    = "USER"

function cmd:execute(player: Player, a: any, ...: any)
    local text = tostring(a)
    for _, v in ipairs{...} do
        text = ("%s %s"):format(text, tostring(v))
    end
    _G.Remotes:fireClient("Console.print", player, text)

    return true
end

return cmd