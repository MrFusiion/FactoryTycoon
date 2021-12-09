local cmd = {}

cmd.Name = "get-rank"
cmd.Params = { "<Player>" }
cmd.Rank = "ADMIN"

function cmd:execute(player: Player, target: Player)
    local rank = target.Rank.Value
    _G.Remotes:fireClient("Console.print", player, ("The rank of %s is %s.")
                                    :format(target.Name, rank))

    return true
end

return cmd