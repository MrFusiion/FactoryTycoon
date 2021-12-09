local Datastore = _G.Server.Datastore

local cmd = {}

cmd.Name = "set-data"
cmd.Params = { "<Player>", "<string>" }
cmd.Rank = "DEV"

function cmd:execute(player: Player, target: Player, key: string, val: string)

    if Datastore.getMainKey(key) ~= "Data" then
        return false, ("%s is not a valid Data key!"):format(key)
    end

    if key == "Rank" then
        return false, "Please use the command \"set-rank\" instead!"
    end

    local store = Datastore.player(target, key)
    store:set(val)

    _G.Remotes:fireClient("Console.print", player, ("[%s]_[%s] <- %s")
                                    :format(target.Name, key, tostring(store:get())))

    return true
end

return cmd