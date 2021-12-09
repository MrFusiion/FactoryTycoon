local cmd = {}

cmd.Name = "rep"
cmd.Params = { "<string>", "<number>" }
cmd.Rank = "USER"

function cmd:execute(player: Player, text: string, repeatCount: number)
    _G.Remotes:fireClient("Console.print", player, string.rep(text, repeatCount))

    return true
end

return cmd