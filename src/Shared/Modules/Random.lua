local _Random = Random
local Random = {}
Random.__index = Random


---@param self table
local function init(self)
    self.__Random = _Random.new(self.__Seed)
end


---@param self table
local function generateSeed(self)
    --Random Table
    self.__RandTable = {}
    local hex = tostring(self.__RandTable):sub(7, 21)
    self.__Seed = tonumber(hex, 16) + os.time()

    if _G.Config.Debug then
        print(("Generated seed: [%d]"):format(self.__Seed))
    end

    init(self)
end


---@param seed number
---@param autoSeed boolean
---@return table
local function newRandom(seed: number, autoSeed: boolean)
    assert(typeof(seed)=="number" or seed==nil, " `seed` must be a number or nil!")
    assert(typeof(autoSeed)=="boolean" or autoSeed==nil, " `autoSeed` must be a boolean or nil!")

    local newRandomGen = setmetatable({}, Random)
    newRandomGen.__Seed = seed
    newRandomGen.__SeedGenInterval = 5*60

    if autoSeed ~= false or autoSeed == nil then
        newRandomGen:startSeedGen()
    end

    if not seed then generateSeed(newRandomGen) end
    init(newRandomGen)
    return newRandomGen
end


function Random.toWeightedList(list: Array<table>): table
    local weightedList = {}
    for _, t in ipairs(list) do
        for _=1, t.weight do
            table.insert(weightedList, t.value)
        end
    end
    return weightedList
end


--- Starts the seed generate loop
function Random:startSeedGen()
    if not self.__SeedGenRunning then
        self.__SeedGenRunning = true
        task.spawn(function()
            while self.__SeedGenRunning do
                wait(self.__SeedGenInterval)
                generateSeed(self)
            end
        end)
    else
        warn("Seed generator allready running!")
    end
end


--- Start Stops the seed generate loop
function Random:stopSeedGen()
    self.__SeedGenRunning = false
end


--- Sets the seed generate interval loop
---@param interval number
function Random:setSeedGenInterval(interval: number)
    assert(typeof(interval)=="number" or interval==nil, " `interval` must be a number or nil!")

    self.__SeedGenInterval = interval or (5*60)
end


--- Returns random integer between [min, max]
---@param min number
---@param max number
function Random:nextInt(min: number, max: number)
    assert(typeof(min)=="number" or min==nil, " `min` must be a number or nil!")
    assert(typeof(max)=="number" or max==nil, " `max` must be a number or nil!")

    if (min or 0)>=(max or 1) then
        return math.min(min, max)
    else
        return self.__Random:NextInteger(min or 0, max or 1)
    end
end


---@param t table
function Random:nextRangeInt(t: table)
    assert(typeof(t)=="table", "t must be a table!")
    assert(typeof(t.min)=="number" or t.min==nil, " `t.min` must be a number or nil!")
    assert(typeof(t.max)=="number" or t.max==nil, " `t.max` must be a number or nil!")
    return self:nextInt(t.min, t.max)
end


--- Returns a random number between [min, max[
---@param min number
---@param max number
---@return number
function Random:nextNumber(min: number, max: number)
    assert(typeof(min)=="number" or min==nil, " `min` must be a number or nil!")
    assert(typeof(max)=="number" or max==nil, " `max` must be a number or nil!")

    if (min or 0)>=(max or 1) then
        return math.min(min, max)
    else
        return self.__Random:NextNumber(min or 0, max or 1)
    end
end


--- Returns a random number from a range [min, max[
---@param t table
function Random:nextRange(t: table)
    assert(typeof(t)=="table", "t must be a table!")
    assert(typeof(t.min)=="number" or t.min==nil, " `t.min` must be a number or nil!")
    assert(typeof(t.max)=="number" or t.max==nil, " `t.max` must be a number or nil!")
    return self:nextNumber(t.min, t.max)
end


--- Returns a random value from the given table
---@param t table
function Random:choice(t: table)
    assert(typeof(t)=="table", " `t` must be a table!")

    local count = 0
    local keys = {}
    for key in pairs(t) do
        table.insert(keys, key)
        count += 1
    end
    assert(count~=0, " `t` cannot be a empty table!")

    if count == 1 then
        return t[1]
    else
        local key = keys[self:nextInt(1, count)]
        return t[key]
    end
end


local r = newRandom(nil, true)
return r