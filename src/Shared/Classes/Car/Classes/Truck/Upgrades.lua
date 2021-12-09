local upgrades = {}

upgrades.Speed = {
    MaxLevel = 5,
    Upgrade = function(tune: table, level: number)
        tune.Speed = 1 + 0.4 * level
        return tune
    end,
    Price = function(level: number)
        return 500 + 500 ^ (1.2 * level) - 1
    end,
}

upgrades.Acceleration = {
    MaxLevel = 5,
    Upgrade = function(tune: table, level: number)
        tune.Acceleration = 1 + 0.4 * level
        return tune
    end,
    Price = function(level: number)
        return 500 + 500 ^ (1.2 * level) - 1
    end,
}

upgrades.Storage = {
    MaxLevel = 5,
    Upgrade = function(tune: table, level: number)
        tune.Storage = 1 + 0.4 * level
        return tune
    end,
    Price = function(level: number)
        return 500 + 500 ^ (1.2 * level) - 1
    end,
}

return upgrades