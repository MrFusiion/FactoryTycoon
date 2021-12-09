local MS = game:GetService("MarketplaceService")

local Datastore = _G.Datastore


local signals = {}
local function createSignals(self)
    local purchased = Instance.new("BindableEvent")

    signals[self] = {
        Purchased = purchased
    }

    return purchased.Event
end
local function signalFire(self, name: string, ...)
    signals[self][name]:Fire(...)
end


local store = {}
store.__index = store

function newStore()
    local self = setmetatable({}, store)
    self.ProductLookup = require(script.products)

    self.GamepassLookup = require(script.gamepasses)
    self.GamepassCache = {}

    game:GetService("Players").PlayerAdded:Connect(function(player)
        self.GamepassCache[player.UserId] = {}
    end)

    game:GetService("Players").PlayerRemoving:Connect(function(player)
        self.GamepassCache[player.UserId] = nil
    end)

    self.Purchased = createSignals(self)

    return self
end

function store:hasGamepass(player : Player, asset : any)
    local assetID = typeof(asset) == "number" or asset and self.GamepassLookup[asset].id
    if assetID then
        local has = self.GamepassCache[player.UserId][assetID] ~= nil and
            self.GamepassCache[player.UserId][assetID] or
            MS:UserOwnsGamePassAsync(player.UserId, assetID)

        self.GamepassCache[player.UserId][assetID] = has
        return has
    end
    return false
end

function store:promptGamepass(player : Player, asset : any)
    local assetID = typeof(asset) == "number" or asset and self.GamepassLookup[asset].id

    if assetID then
        --local data = datastore.combined.global("Gamepasses", player.UserId, assetID)
        if not self:hasGamepass(player, assetID) then
            local conn
            conn = MS.PromptGamePassPurchaseFinished:Connect(function(plr, id, wasPurchased)
                if plr == player and id == assetID then
                    self.GamepassCache[player.UserId][assetID] = wasPurchased
                    self:fireEvent(player, self.GamepassLookup[assetID].event)
                    if wasPurchased then
                        signalFire(self, "Purchased", asset)
                    end
                    conn:Disconnect()
                end
            end)

            MS:PromptGamePassPurchase(player, assetID)
        else
            warn(("Player %s owns allready the gamepass with id %d!"):format(player.Name, assetID))
        end
    end
end

function store:getGamepassData(asset : any)
    local assetID = typeof(asset) == "number" or asset and self.GamepassLookup[asset].id
    if assetID then
        local data
        local suc, err = pcall(function()
            data = MS:GetProductInfo(assetID, Enum.InfoType.GamePass)
        end)
        if not suc then
            warn(("Error happend while fetching gamepass data of %d :"):format(assetID), err)
        else
            data['Image'] = ("rbxassetid://%d"):format(data.IconImageAssetId)
            return data
        end
    end
end

local s = newStore()
return s