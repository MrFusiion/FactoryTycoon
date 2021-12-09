local Color = {}

function Color.fromHex(hex)
    hex = hex:gsub("#","")
    return Color3.fromRGB(
        tonumber(("0x%s"):format(hex:sub(1,2))),
        tonumber(("0x%s"):format(hex:sub(3,4))),
        tonumber(("0x%s"):format(hex:sub(5,6)))
    )
end

function Color.shade(clr, factor)
    return Color3.new(
        clr.R * (1 - factor),
        clr.G * (1 - factor),
        clr.B * (1 - factor)
    )
end

function Color.tint(clr, factor)
    return Color3.new(
        clr.R * (1 + factor),
        clr.G * (1 + factor),
        clr.B * (1 + factor)
    )
end

function Color.fromGrey(n)
    return Color3.fromHSV(0, 0, n)
end

return Color