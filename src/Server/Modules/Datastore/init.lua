local Datastore = require(script.DatastoreModule)
local RS = game:GetService("RunService")

Datastore.configure(_G.Config.DATASTORE_CONFIGURATION)

--- Combine keys
Datastore.combine("Data", "Cash", "Land", "Slots", "Rank")

--- Adding profiles
require(script.Profiles)(Datastore)

local SlotKeys = { ["Cash"] = true, ["Land"] = true, ["Vacuum"] = true, ["Backpack"] = true }
local _player = Datastore.player
function Datastore.player(player: Player, name: string, defaultValue: any, backupValue: any)
    if SlotKeys[name] then
        local slotV = player.Slot
        return _player(player, ("%s[Slot%s]"):format(name, slotV.Value), defaultValue, backupValue)
    end
    return _player(player, name, defaultValue, backupValue)
end

return Datastore