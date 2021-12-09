local Datastore
local slotChanged = {}
local beUnloadSlot = Instance.new("BindableEvent")
local beLoadSlot = Instance.new("BindableEvent")

game:GetService("Players").PlayerAdded:Connect(function(player)
    while not Datastore do task.wait() end

    local slotV = Instance.new("IntValue", player)
    slotV.Name = "Slot"
    slotV.Value = -1
    --player:SetAttribute("Slot", -1)

    local cashV = Instance.new("IntValue", player)
    cashV.Name = "Cash"
    cashV.Value = 0
    --player:SetAttribute("Cash", -1)
end)



while not _G.Loaded do task.wait() end
Datastore = _G.Server.Datastore


local function loadSlot(player, slot)
    local slotV = player.Slot
    local cashV = player.Cash

    --Unload the previous slot
    if slotV.Value > 0 then
        Datastore.removeFromCache(player.UserId)

        local slotV = player.Slot
        slotV.Value = -1

        beUnloadSlot:Fire(player)
    end
    slotV.Value = slot

    local cash = Datastore.player(player, "Cash")
    local slots = Datastore.player(player, "Slots")

    cashV.Value = cash:get()

    cash:onUpdate(function(c)
        cashV.Value = c
        slots:update(function(data)
            data[slotV.Value] = {
                Date = _G.Config.DATE_FORMAT % os.date("*t"),
                Cash = c
            }
            return data
        end)
    end)

    beLoadSlot:Fire(player, slot)
end


local function canChangeSlot(player)
    return not slotChanged[player]
        or os.time() - slotChanged[player] >= _G.Config.MIN_TIME_BETWEEN_SLOT_CHANGE
end


_G.Remotes:onEvent("Slot.SetSlot", function(player, slot)
    if canChangeSlot(player) and _G.Config.ALLOWED_SLOTS[slot] then
        loadSlot(player, slot)
        slotChanged[player] = os.time()
    else
        warn(("Need to wait %d between changing slots!"):format(_G.Config.MIN_TIME_BETWEEN_SLOT_CHANGE))
        --TODO: Notify player need to wait MIN... between switching slots!
    end
end)


_G.Remotes:onInvoke("Slot.GetSlotData", function(player)
    local slotsStore = Datastore.player(player, "Slots")
    return slotsStore:get()
end)


_G.Packages:export({
    UnloadSlot = beUnloadSlot.Event,
    LoadSlot = beLoadSlot.Event
})