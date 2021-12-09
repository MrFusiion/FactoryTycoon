local Datastore = _G.Server.Datastore

local cmd = {}

cmd.Name = "get-data"
cmd.Params = { "<Player>", "<string>" }
cmd.Rank = "DEV"

function cmd:execute(player: Player, target: Player, key: string)

    if Datastore.getMainKey(key) ~= "Data" then
        return false, ("%s is not a valid Data key!"):format(key)
    end

    local store = Datastore.player(target, key)
    _G.Remotes:fireClient("Console.print", player, ("[%s]_[%s] -> %s")
                                    :format(target.Name, key, tostring(store:get())))

    return true
end

return cmd