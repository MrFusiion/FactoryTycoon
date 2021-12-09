local Equipment
local equipments = {}

local beAddResource = Instance.new("BindableEvent")
local beSetVacuum   = Instance.new("BindableEvent")
local beSetBackpack = Instance.new("BindableEvent")

local MAX_LOOP = 200
function getEquipment(player)
    local count = 0
    while true do
        if equipments[player.UserId] then
            return equipments[player.UserId]
        elseif count >= MAX_LOOP  then
            return print("GetEquipment Timeout!")
        end
        count += 1
        task.wait()
    end
end


function getVacuumInfo(player)
    local playerEquipment = getEquipment(player)
    if playerEquipment then
        return playerEquipment:getVacuumInfo()
    end
end

beAddResource.Event:Connect(function(player, name, value)
    local playerEquipment = getEquipment(player)
    if playerEquipment then
        playerEquipment.Content:addResource(name, value)
        playerEquipment.Content:render()
    end
end)

beSetVacuum.Event:Connect(function(player, vacuumName)
    local playerEquipment = getEquipment(player)
    if playerEquipment then
        playerEquipment:setVacuum(vacuumName)
        playerEquipment:createTube()
    end
end)

beSetBackpack.Event:Connect(function(player, backpackName)
    local playerEquipment = getEquipment(player)
    if playerEquipment then
        playerEquipment:setBackpack(backpackName)
        playerEquipment:createTube()
    end
end)


while not _G.Loaded do task.wait() end

local LoadSlot, UnloadSlot = _G.Packages:get("SlotHandler"):get("LoadSlot", "UnloadSlot")

LoadSlot:Connect(function(player)
    while not Equipment do task.wait() end

    local newEquipment = Equipment.new(player)
    equipments[player.UserId] = newEquipment
end)

UnloadSlot:Connect(function(player)
    local playerEquipment = getEquipment(player)
    if playerEquipment then
        equipments[player] = playerEquipment:cleanup()
    end
end)


_G.Remotes:onInvoke("Equipment.GetBaseStats", function(player)
    local playerEquipment = getEquipment(player)
    if playerEquipment then
        local backpackInfo = playerEquipment:getBackpackInfo()
        local vacuumInfo = playerEquipment:getVacuumInfo()

        return {
            power =     vacuumInfo.damage,
            speed =     vacuumInfo.speed,
            range =     vacuumInfo.range,
            storage =   backpackInfo.maxstorage
        }
    end
end)


_G.Remotes:onInvoke("Equipment.GetStats", function(player)
    local playerEquipment = getEquipment(player)
    if playerEquipment then
        local backpackInfo = playerEquipment:getBackpackInfo()
        local vacuumInfo = playerEquipment:getVacuumInfo()
        local statsMultiplier = game:GetService("ServerScriptService").InventoryHandler.GetStatsMultiplier:Invoke()

        return {
            power =     vacuumInfo.damage       * (statsMultiplier.power      or 1),
            speed =     vacuumInfo.speed        * (statsMultiplier.speed      or 1),
            range =     vacuumInfo.range        * (statsMultiplier.range      or 1),
            storage =   backpackInfo.maxstorage * (statsMultiplier.storage    or 1)
        }
    end
end)


_G.Remotes:onInvoke("Equipment.GetEquipment", function(player)
    local playerEquipment = getEquipment(player)
    if playerEquipment then
        local backpack = playerEquipment.Backpack
        local vacuum = playerEquipment.Vacuum
        return backpack, vacuum
    end
end)

Equipment = _G.Server.Equipment


_G.Packages:export({
    GetVacuumInfo   = getVacuumInfo,
    AddResource     = beAddResource.Event,
    SetVacuum       = beSetVacuum.Event,
    SetBackback     = beSetBackpack.Event
})