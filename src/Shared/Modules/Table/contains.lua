return function(t, value)
    for _, v in pairs(t) do
        if v == value then
            return true
        end
    end
    return false
end