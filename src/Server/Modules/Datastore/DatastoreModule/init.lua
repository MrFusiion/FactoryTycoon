local Settings = require(script.Settings)
local Type = require(script.Type)
local Profile = require(script.Profile)
local warn = require(script.Warnings)

local Symbol = require(script.Symbol)
local Global = Symbol.named("Global")
local LEN = Symbol.named("LEN")

local Util = require(script.Util)
local info = Util.info
local clone = Util.clone

local Datastore = require(script.Datastore)
local CombinedDatastore = require(script.CombinedDatastore)

local Closing = false
local Cache = { [LEN] = 0 }
local CombinedInfo = {}
local Profiles = {}


--- Removes the [state] from a name example: Data[slot1] > Data
--- @param name string
--- @return string
local function raw(name: string): string
    return name:gsub("%[+.-%]+", "")
end


--- Get [state] from a name example: Data[slot1] > Data
--- @param name String
--- @return String
local function state(name: string): string
    local s = name:match("%[+.-%]+")
    return s and s:sub(2, -2)
end


--- Sets [state] from a name example: Data, Slot1 > Data[Slot1]
--- @param name String
--- @param state String | nil
--- @return String
local function setState(name: string, state: string | nil): string
    if state then
        return ("%s[%s]"):format(name, state)
    end
    return raw(name)
end


--- Gets a datastore from the cache.
--- @param name string
--- @param scope string
--- @return table
local function getFromCache(scope: string, name: string): table
    local scope = scope or Global
    if Cache[scope] then
        local store = Cache[scope][name]
        if store then
            info(("[Datastore.New]"), "Fetched from cache:", store:getName())
            --*TODO print Get Datastore From Cache
            return store
        end
    end
end


--- Removes a datastore from the cache.
--- @param name string
--- @param scope string
local function remFromCache(scope: string, name: string)
    local scope = scope or Global
    if not name and Cache[scope] then
        Cache[LEN] -= Cache[scope][LEN]
        Cache[scope] = nil
        info("[Datastore.Cache] Remove scope: ", scope, "New length: ", Cache[LEN])
        --*TODO print Remove Scope From Cache
    elseif Cache[scope] then
        Cache[LEN] -= 1
        Cache[scope][LEN] -= 1
        info("[Datastore.Cache] Remove: ", Cache[scope][name]:getName(), "New length: ", Cache[LEN])
        --*TODO print Remove Datastore From Cache
        Cache[scope][name] = nil
    end

    if Cache[LEN] < 0 then
        assert(false, ("Cache length is less then zero(%d) this is a BUG!")
            :format(Cache[LEN]))
    end
end


--- Adds the datastore to the cache.
--- @param name string
--- @param scope string
---  disable-next-line
--- @diagnostic disable-line | @param datastore Datastore | CombinedDatastore
local function addToCache(scope: string, name: string, datastore: table)
    local scope = scope or Global
    Cache[scope] = Cache[scope] or { [LEN] = 0 }
    if not Cache[scope][name] then
        Cache[LEN] += 1
        Cache[scope][LEN] += 1
        Cache[scope][name] = datastore

        info("[Datastore.Cache] Added: ", datastore:getName(), "New length: ", Cache[LEN])
        --*TODO print Added Datastore From Cache
    else
        assert(false, ("Tried to overide an existing datastore in cache this is a BUG!")
            :format(Cache[LEN]))
    end

    if Cache[LEN] < 0 then
        assert(false, ("Cache length is less then zero(%d) this is a BUG!")
            :format(Cache[LEN]))
    end
end


--- Creates a new Datastore or gets one from the cache if one with the same props exists.
--- @param name string
--- @param scope string
--- @param defaultValue any
--- @param backupValue any
local function getDatastore(name: string, scope: string, defaultValue: any, backupValue: any)
    local rawName = raw(name)
    local store = getFromCache(scope, name)
    if store then
        return store
    elseif CombinedInfo[rawName] then
        local rawMainName = CombinedInfo[rawName]
        local mainName = setState(rawMainName, state(name))
        local mainStore = getDatastore(mainName, scope, {}, {})

        function mainStore:serialize(data)
            for k in pairs(data) do
                if CombinedInfo[k] == rawMainName then
                    local subStore = getDatastore(setState(k, state(mainName)), scope)
                    local suc, val = nil, subStore:_get()
                    if val ~= nil then
                        suc, val = pcall(subStore.serialize, self, clone(val))
                        if suc then
                            if val == nil then
                                warn("SERIALIZE_RETURNED_NIL")
                            else
                                data[k] = val
                            end
                        else
                            warn("SERIALIZE_ERROR", val)
                        end
                    end
                end
            end
            return data
        end

        local profileName = ("%s.%s"):format(rawMainName, rawName)
        store = CombinedDatastore.new(mainStore, rawName, defaultValue, backupValue, Profiles[profileName])
        info(("[Datastore.New]"), "Created new CombinedDatastore:", store:getName())
        addToCache(scope, name, store)
        --*TODO print Created New CombinedDatastore
        return store
    end

    store = Datastore.new(name, scope, defaultValue, backupValue, Profiles[rawName])
    info(("[Datastore.New]"), "Created new Datastore:", store:getName())
    addToCache(scope, name, store)
    --*TODO print Created New Datastore
    return store
end


--- Returns true if the name consist of non-illegal characters or else false.
--- @param name string
--- @return boolean
local function isValidName(name: string): boolean
    return name:match("%p") == nil
end


--[[
    ___________________________________________________________________________________
    Public Libary
    ___________________________________________________________________________________
]]


local Lib = {}


--- Lets the Libary now when to combine 2 or more keys in one Datastore.
--- @param mainKey string
--- @vararg string
function Lib.combine(mainKey: string, ...: {string})
    if not isValidName(mainKey) then
        warn("COMBINE_KEYS_ILLEGAL_SYMBOLS", mainKey)
        return
    end

    for _, name in ipairs{...} do
        if not isValidName(name) then
            warn("COMBINE_KEYS_ILLEGAL_SYMBOLS", name)
            continue
        end

        if not CombinedInfo[name] then
            CombinedInfo[name] = mainKey
        elseif CombinedInfo[name] ~= mainKey then
            warn("COMBINE_KEYS_OVERIDE", name, mainKey, CombinedInfo[name])
        end
    end
end


--- Gets the MainKey attached to this key if one exists.
--- @param key string
function Lib.getMainKey(key: string)
    return CombinedInfo[key]
end


--- Creates a specific profile for a key.
--- @param name string
--- @param profile table
function Lib.addProfile(name: string, profile: {string: any})
    if not Profiles[name] then
        Profiles[name] = Profile.new(profile)
    else
        warn("PROFILE_OVERIDE", name)
    end
end


--- Remove from cache if not name is provide the full scope will be removed.
--- @param scope string
--- @param name? string
function Lib.removeFromCache(scope: string, name: string?)
    if Cache[scope] then
        Lib.saveScope(scope)
        remFromCache(scope, name)
    else
        error("Scope doesn't exist!")
    end
end


--- Creates a new Datastore for a specific player
--- @param player Player
--- @param name string
--- @param defaultValue any
--- @param backupValue any
--- @return Datastore | CombinedDatastore
function Lib.player(player: Player, name: string, defaultValue: any, backupValue: any)
    local store = getDatastore(name, player.UserId, defaultValue, backupValue)

    return store
end


--- Creates a new Global Datastore
--- @param name string
--- @param defaultValue any
--- @param backupValue any
--- @return Datastore | CombinedDatastore
function Lib.global(name: string, defaultValue: any, backupValue: any)
    local store = getDatastore(name, nil, defaultValue, backupValue)

    return store
end


--- Creates a new Datastore
--- @param name string
--- @param scope string
--- @param defaultValue any
--- @param backupValue any
--- @return Datastore | CombinedDatastore
function Lib.new(name: string, scope: string, defaultValue: any, backupValue: any)
    local store = getDatastore(name, scope, defaultValue, backupValue)

    return store
end


--- Returns the current cache
function Lib.getCache()
    return clone(Cache)
end


--- Configure Settings
--- @param t table
function Lib.configure(t: table)
    Settings:configure(t)
end


--- Save a specific scope
function Lib.saveScope(scope: string)
    local total = 0
    if Cache[scope] then
        for _, store in pairs(Cache[scope]) do
            if Type.of(store) == "Datastore" then
                total += 1
                task.spawn(function()
                    store:save()
                    total -= 1
                end)
            end
        end
    end

    while total > 0 do
        task.wait()
    end
end


--[[
    Autosaving
]]
local function save(force: boolean)
    local total = 0
    for _, t in pairs(Cache) do
        if typeof(t) == "table" then
            for _, store in pairs(t) do
                if Type.of(store) == "Datastore" then
                    total += 1
                    task.spawn(function()
                        store:save(force)
                        total -= 1
                    end)
                end
            end
        end
    end

    local lastTotal
    while total > 0 do
        if not lastTotal or lastTotal ~= total then
            lastTotal = total
            info(("[DATASTORE.Autosave] Waiting for %d Datastore's!"):format(lastTotal))
        end
        task.wait()
    end
end


task.spawn(function()
    local start = tick()
    while not Closing do
        if (not game:GetService("RunService"):IsStudio() or Settings.SaveInStudio)
            and Settings.Autosave
        then
            if tick() - start >= Settings.AutosaveInterval then
                local autosaveStart = tick()
                info("[Datastore.Autosave] Started")
                if not Closing then
                    save(false)
                end
                info("[Datastore.Autosave] Completed: ",
                    ("%.3f s"):format(tick() - autosaveStart))
                start = tick()
            end
        end
        task.wait()
    end
end)


game:GetService("Players").PlayerAdded:Connect(function(player)
    local conn
    conn = player.AncestryChanged:Connect(function()
        if Closing then
            conn:Disconnect()
            return
        elseif player:IsDescendantOf(game) then
            return
        end

        local stores = Cache[player.UserId] or { [LEN] = 0 }
        info(("[Datastore.Autosave] Player %s left, Saving %d Datastore's!")
            :format(player.Name, stores[LEN]))

        local total = 0
        for _, store in pairs(stores) do
            if Type.of(store) == "Datastore" then
                total += 1
                task.spawn(function()
                    store:save()
                    total -= 1
                end)
            end
        end

        while total > 0 do
            task.wait()
        end

        remFromCache(player.UserId)
        conn:Disconnect()
    end)
end)


game:BindToClose(function()
    Closing = true
    save(true)
end)


return Lib