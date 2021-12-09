--!strict

local RS = game:GetService("RunService")
local RepStorage = game:GetService("ReplicatedStorage")

local IS_SERVER = RS:IsServer()
local IS_CLIENT = RS:IsClient()

--local Types = require(script.Parent.Types)

local folder = RepStorage:FindFirstChild("Remotes")
local events = folder and folder.Events
local functions = folder and folder.Functions
if not folder then
    folder = Instance.new("Folder")
    folder.Name = "Remotes"

        events = Instance.new("Folder")
        events.Name = "Events"
        events.Parent = folder

        functions = Instance.new("Folder")
        functions.Name = "Functions"
        functions.Parent = folder

    folder.Parent = RepStorage
end


local function new(class: string, name: string, f: Folder)
    local instance = Instance.new(class)
    instance.Name = name
    instance.Parent = f
    return instance
end


local function get(name: string, f: Folder)
    return IS_CLIENT and f:WaitForChild(name) or f:FindFirstChild(name)
end


--No invokeClient, NEVER TRUST THE CLIENT!!!
local Remotes = {}


--Client can't create RemoteEvents and Functions
function Remotes:newEvent(event: string)
    if IS_SERVER then
        return get(event, events) or new("RemoteEvent", event, events)
    end
    error("Client can't create RemoteEvents!")
end


function Remotes:newFunction(func: string)
    if IS_SERVER then
        return get(func, functions) or new("RemoteFunction", func, functions)
    end
    error("Client can't create RemoteFunctions!")
end


function Remotes:onEvent(event: string, callback: ()->())
    --[[Types.strictInterface({
        event = Types.string,
        callback = Types.callback
    }){
        event = event,
        callback = callback
    }]]

    local rEvent: RemoteEvent = get(event, events)
        or new("RemoteEvent", event, events)

    if RS:IsServer() then
        return rEvent.OnServerEvent:Connect(callback)
    end
    return rEvent.OnClientEvent:Connect(callback)
end


function Remotes:onInvoke(func: string, callback: ()->())
    --[[Types.strictInterface({
        func = Types.string,
        callback = Types.callback
    }){
        func = func,
        callback = callback
    }]]

    local rFunc: RemoteFunction = get(func, functions)
        or new("RemoteFunction", func, functions)

    if RS:IsServer() then
        rFunc.OnServerInvoke = callback
    elseif RS:IsClient() then
        rFunc.OnClientInvoke = callback
    else
        warn("Remote function not assigned, Could not determin between Server or Client")
    end
end


function Remotes:invokeServer(func: string, ...)
    --[[Types.strictInterface({
        func = Types.string,
    }){
        func = func
    }]]

    local rFunc: RemoteFunction = functions:WaitForChild(func)
    return rFunc:InvokeServer(...)
end


function Remotes:fireClient(event: string, player: Player, ...)
    --[[Types.strictInterface({
        event = Types.string,
        player = Types.class("Player")
    }){
        event = event,
        player = player
    }]]

    local rEvent: RemoteEvent = events:WaitForChild(event)
    rEvent:FireClient(player, ...)
end


function Remotes:fireClients(event: string, players: {Player}, ...)
    --[[Types.strictInterface({
        event = Types.string,
        players = Types.array(Types.class("Player"))
    }){
        event = event,
        players = players
    }]]

    local rEvent: RemoteEvent = events:WaitForChild(event)
    for _, player in ipairs(players) do
        rEvent:FireClient(player, ...)
    end
end


function Remotes:fireAllClients(event: string, ...)
    --[[Types.strictInterface({
        event = Types.string,
    }){
        event = event
    }]]

    local rEvent: RemoteEvent = events:WaitForChild(event)
    rEvent:FireAllClients(...)
end


function Remotes:fireServer(event: string, ...)
    --[[Types.strictInterface({
        event = Types.string,
    }){
        event = event
    }]]

    local rEvent: RemoteEvent = events:WaitForChild(event)
    rEvent:FireServer(...)
end


return Remotes