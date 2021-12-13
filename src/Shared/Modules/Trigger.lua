local CS = game:GetService("CollectionService")
local Players = game:GetService("Players")

local signals = {}
local function createSignals(self)
    signals[self] = {
        Entered       = Instance.new("BindableEvent"),
        Left          = Instance.new("BindableEvent"),
        PlayerEntered = Instance.new("BindableEvent"),
        PlayerLeft    = Instance.new("BindableEvent")
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

Trigger.Types = { PLAYERS="players", PARTS="parts" }

function Trigger.new(parts: {BasePart}, tags: {string}?)

    local self = {}
    self.Type = type or "parts"

    createSignals(self)

    for _, part in ipairs(parts) do
        part.Touched:Connect(function(otherPart)
            if type == "parts" then
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

            if type == "players" and isPlayer(otherPart) then
                fireSignal(self, "PlayerEntered", otherPart)
            end
        end)

        part.TouchEnded:Connect(function(otherPart)
            if type == "parts" then
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

            if type == "players" and isPlayer(otherPart) then
                fireSignal(self, "PlayerLeft", otherPart)
            end
        end)
    end

    return setmetatable(self, Trigger_mt)
end

function Trigger:allowed(part: BasePart)
    if self.Type == "parts" then

    elseif self.Type == "players" and isPlayer() then
    end
end

return Trigger