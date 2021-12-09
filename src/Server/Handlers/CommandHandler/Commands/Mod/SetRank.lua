local Command = require(game:GetService("ReplicatedStorage"):WaitForChild("Command"))
local Datastore = _G.Server.Datastore

local cmd = {}

cmd.Name = "set-rank"
cmd.Params = { "<Player>", "<string>" }
cmd.Rank = "ADMIN"

function cmd:execute(player: Player, target: Player, rank: string)
    rank = rank:upper()

    if not Command.Ranks[rank] then
        return false, ("%s is not a valid rank!"):format(rank)
    end

    if Command:getRank(target) == rank then
        return false, ("The rank of %s is already %s!"):format(target.Name, rank)
    end

    if Command:getRank(player) ~= "CREATOR" then

        -- Sender can only give ranks that are lower then his rank
        if not Command:checkRank(Command:getRank(player), rank, false) then
            return false, ("You can only set ranks that are lower than yours!")
        end

        -- Target rank is higher or equal then sender's rank
        if not Command:checkRank(Command:getRank(player), Command:getRank(target), false) then
            return false, ("You can only set ranks of people that have lower ranks than yours!")
        end
    end

    --<< Set rank >>
    Datastore.player(target, "Rank"):set(rank)
    _G.Remotes:fireClient("Console.print", player, ("The rank of %s has been set to %s.")
                                    :format(target.Name, rank))

    return true
end

return cmd