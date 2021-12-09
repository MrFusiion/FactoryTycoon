_G.Remotes:newEvent("Console.cls")


local cmd = {}

cmd.Name    = {"cls", "clear"}
cmd.Params  = {}
cmd.Rank    = "USER"

function cmd:execute(player: Player)
    _G.Remotes:fireClient("Console.cls", player)

    return true
end

return cmd