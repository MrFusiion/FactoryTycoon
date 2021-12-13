local cmd = {}

cmd.Name = "speed"
cmd.Params = { "<number>" }
cmd.Rank = "ADMIN"

function cmd:execute(player: Player, speed: number)
    local char = player.Character or player.CharacterAdded:Wait()
    local hum = char:WaitForChild("Humanoid")

    hum.WalkSpeed = speed

    _G.Remotes:fireClient("Console.print", player, ("Speed set to %d.")
                                    :format(speed))

    return true
end

return cmd