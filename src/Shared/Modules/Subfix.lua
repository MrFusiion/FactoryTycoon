---@class Subfix
local Subfix = {}
Subfix.Symbols = { "", "K", "M", "B", "T", "qD"}
Subfix.symbolsLen = #Subfix.Symbols

---@param n number
---@param decimals number
---@return number
function Subfix.addSubfix(n: number, decimals: number)
    decimals = decimals or 3
    assert(typeof(n)=="number", " `n` must be a number!")
    local count = 1
    local divider = 1e3
    while not (count == Subfix.symbolsLen or n / divider < 1) do
        count += 1
        divider *= 1e3
    end

    return ("%s%s"):format(("%%.%df"):format(decimals)
        :format(n / (divider / 1e3)):gsub("[.]0+$", ""), Subfix.Symbols[count] == "" and "" or (" %s"):format(Subfix.Symbols[count]))
end

return Subfix