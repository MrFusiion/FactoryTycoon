local CS = game:GetService("CollectionService")
local Players = game:GetService("Players")

local signals = {}
local function createSignals(self)
    local function signal(name: string)
        local event = Instance.new("BindableEvent")
        self[name] = event.Event
        return event
    end

    signals[self] = {
        Entered       = signal("Entered"),
        Left          = signal("Left"),
        PlayerEntered = signal("PlayerEntered"),
        PlayerLeft    = signal("PlayerLeft")
    }
end
local function fireSignal(self, name: string, ...)
    signals[self][name]:Fire(...)
end


local function isPlayer(part: BasePart)
    if part.Name == "HumanoidRootPart" and Players:GetPlayerFromCharacter(part.Parent) then
        return true
    end
    return false
end


local Trigger = {}
local Trigger_mt = {}

Trigger.Types = { PLAYERS="players", PARTS="parts", BOTH="both" }

function Trigger.new(parts: (BasePart|{BasePart}), type: string?, tags: {string}?)
    parts = typeof(parts) ~= "table" and {parts} or parts
    type = type or "both"

    assert(Trigger.Types[type:upper()], ("%s is not a valid Trigger type!"):format(tostring(type)))

    local self = {}
    self.Type = type
    self.Parts = {}

    createSignals(self)

    for _, part in ipairs(parts) do
        part.CanTouch = true
        part.CanCollide = false

        table.insert(self.Parts, part)

        part.Touched:Connect(function(otherPart)
            if type == "both" or type == "parts" then
                if tags then
                    for _, tag in ipairs(tags) do
                        if CS:HasTag(otherPart, tag) then
                            fireSignal(self, "Entered", otherPart)
                            break
                        end
                    end
                else
                    fireSignal(self, "Entered", otherPart)
                end
            end

            if (type == "both" or type == "players") and isPlayer(otherPart) then
                fireSignal(self, "PlayerEntered", Players:GetPlayerFromCharacter(otherPart.Parent))
            end
        end)

        part.TouchEnded:Connect(function(otherPart)
            if type == "both" or type == "parts" then
                if tags then
                    for _, tag in ipairs(tags) do
                        if CS:HasTag(otherPart, tag) then
                            fireSignal(self, "Left", otherPart)
                            break
                        end
                    end
                else
                    fireSignal(self, "Left", otherPart)
                end
            end

            if (type == "both" or type == "players") and isPlayer(otherPart) then
                fireSignal(self, "PlayerLeft", Players:GetPlayerFromCharacter(otherPart.Parent))
            end
        end)
    end

    return setmetatable(self, Trigger_mt)
end

return Trigger