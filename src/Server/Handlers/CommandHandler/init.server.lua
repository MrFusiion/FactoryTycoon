local Datastore
game:GetService("Players").PlayerAdded:Connect(function(player: Player)
    while not Datastore do task.wait() end

    local rank = Datastore.player(player, "Rank", "USER")

    if player.UserId == game.CreatorId then
        rank:set("CREATOR")
    end

    local rankV = Instance.new("StringValue")
    rankV.Name = "Rank"
    rankV.Value = rank:get()
    rankV.Parent = player

    rank:onUpdate(function(value: string)
        rankV.Value = value
    end)
end)


local ChatService = require(game.ServerScriptService:WaitForChild("ChatServiceRunner").ChatService)
local ChatConstants = require(game:GetService("Chat"):WaitForChild("ClientChatModules"):WaitForChild("ChatConstants"))
while not _G.Loaded do task.wait() end

_G.Remotes:newEvent("Console.toggle")
_G.Remotes:newEvent("Console.print")
_G.Remotes:newEvent("Console.warn")
_G.Remotes:newEvent("Console.error")


--<< Register chat command for toggling the console >>
ChatService:RegisterProcessCommandsFunction("flux_console", function(fromSpeaker, message)
    if string.match(message, "^[/]flux_console") then
        local speaker = ChatService:GetSpeaker(fromSpeaker)
        local player = speaker:GetPlayer()
        _G.Remotes:fireClient("Console.toggle", player)
        return true
    end
    return false
end, ChatConstants.HighPriority)


local Command = require(game:GetService("ReplicatedStorage"):WaitForChild("Command"))
Datastore = _G.Server.Datastore

for _, desc in ipairs(script.Commands:GetDescendants()) do
    if desc:IsA("ModuleScript") then
        local suc, err = pcall(function()
            Command:addCommand(require(desc))
        end)

        if not suc then
            warn(("Error adding command %s, %s")
                :format(desc:GetFullName(), err))
        end
    end
end


_G.Remotes:onEvent("Command.execute", function(player: Player, text: string)
    if typeof(text) == "string" then
        local suc, err = Command:execute(player, text)

        if not suc then
            _G.Remotes:fireClient("Console.error", player, err)
        end
    end
end)

_G.Remotes:onInvoke("Command.getCommands", function(player: Player)
    local cmds = {}
    local checked = {}

    for _, command in pairs(Command.Commands) do
        if not checked[command] then
            table.insert(cmds, {
                Name = command.Name,
                Params = command.Params,
                Rank = command.Rank,
                execute = function()
                    warn("Commands don't work Client side!")
                end
            })
            checked[command] = true
        end
    end

    return cmds
end)

_G.Remotes:onInvoke("Command.getSugestions", function(player: Player, text: string)
    if typeof(text) == "string" then
        return Command:sugestions(player, text)
    end
    return {}
end)