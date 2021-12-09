local function getPrice(start: number, exp: number)
    local i = 0
    return function()
        local p = start + start ^ (exp * i) - 1
        i += 1
        return p
    end
end

local function getMult(start: number, increment: number)
    local i = 0
    return function()
        local p = start + increment * i
        i += 1
        return p
    end
end

local speedPrice = getPrice(500, 1.2)
local speedMult = getMult(500, 0.4)

local accPrice = getPrice(500, 1.2)
local accMult = getMult(500, 0.4)

local storagePrice = getPrice(500, 1.2)
local storageMult = getMult(500, 0.4)


local upgrades = {}

upgrades.Speed = {
    [0] = {
        Multiplier = speedMult(),
        Price = speedPrice(),
    },

    [1] = {
        Multiplier = speedMult(),
        Price = speedPrice(),
    },

    [2] = {
        Multiplier = speedMult(),
        Price = speedPrice(),
    },

    [3] = {
        Multiplier = speedMult(),
        Price = speedPrice(),
    },

    [4] = {
        Multiplier = speedMult(),
        Price = speedPrice(),
    },

    [5] = {
        Multiplier = speedMult(),
        Price = speedPrice(),
    },
}

upgrades.Acceleration = {
    [0] = {
        Multiplier = accMult(),
        Price = accPrice(),
    },

    [1] = {
        Multiplier = accMult(),
        Price = accPrice(),
    },

    [2] = {
        Multiplier = accMult(),
        Price = accPrice(),
    },

    [3] = {
        Multiplier = accMult(),
        Price = accPrice(),
    },

    [4] = {
        Multiplier = accMult(),
        Price = accPrice(),
    },

    [5] = {
        Multiplier = accMult(),
        Price = accPrice(),
    },
}

upgrades.Storage = {
    [0] = {
        Multiplier = storageMult(),
        Price = storagePrice(),
    },

    [1] = {
        Multiplier = storageMult(),
        Price = storagePrice(),
    },

    [2] = {
        Multiplier = storageMult(),
        Price = storagePrice(),
    },

    [3] = {
        Multiplier = storageMult(),
        Price = storagePrice(),
    },

    [4] = {
        Multiplier = storageMult(),
        Price = storagePrice(),
    },

    [5] = {
        Multiplier = storageMult(),
        Price = storagePrice(),
    },
}

return upgrades