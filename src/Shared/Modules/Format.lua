---@class Format
local Format = {}
local Format_mt = { __index = Format }


local function isNumber(str: string)
	return tonumber(str) ~= nil
end


--- Returns a formated string
---@return string
function Format_mt:__mod(t: {})
    return self:format(t)
end


--- Returns the unformated string
---@return string
function Format_mt:__tostring()
    return self.String
end


--- Creates a new Format string
---@param formatString string
---@return Format
function Format.new(formatString: string)
    local self = {}
    self.String = formatString
    return setmetatable(self, Format_mt)
end


--- Formats the string with the given info
---@param t table
---@return string
function Format:format(t: {})
    local str = tostring(self)
    if not t then
        t = str
        str = t[1]
    end
    local out = string.gsub(str, "({([^}]+)})", function(whole, i)
        if isNumber(i) then
            return t[tonumber(i)] or whole
        end
        return t[i] or whole
    end)
    return out
end


return Format