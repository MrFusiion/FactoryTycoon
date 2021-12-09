local Lexer = {}

local BOOLEAN_TRUE = 	"^[Tt]rue"
local BOOLEAN_FALSE = 	"^[Ff]alse"
local FLAG_A = 			"^[-][-]%a+"
local FLAG_B = 			"^[-]%a+"
local NUMBER_A = 		"^0x[%da-fA-F]+"
local NUMBER_B = 		"^%d+%.?%d*[eE][%+%-]?%d+"
local NUMBER_C = 		"^%d+[%._]?[%d_eE]*"
local IDEN = 			"^[%a_][%w_]*"
local CMD_IDEN = 		"^[%a_-][%w_-]*"
local WSPACE = 			"^[ \t\n]+"
local STRING_EMPTY = 	"^(['\"])%1"									--Empty String
local STRING_PLAIN = 	[=[^(['"])[%w%p \t\v\b\f\r\a]-([^%\]%1)]=]		--TODO: Handle escaping escapes
local STRING_INCOMP_A = "^(['\"]).-\n"									--Incompleted String with next line
local STRING_INCOMP_B = "^(['\"])[^\n]*"								--Incompleted String
local ENTITY_VAR = 		"^@%S*"

local TABLE_EMPTY = {}

local function idump(tok)
	return coroutine.yield("iden", tok)
end

local function ndump(tok)
	return coroutine.yield("number", tok)
end

local function sdump(tok)
	return coroutine.yield("string", tok)
end

local function invsdump(tok)
	return coroutine.yield("string", tok, {
		Invalid = true
	})
end

local function wsdump(tok)
	return coroutine.yield("space", tok)
end

local function edump(tok)
	return coroutine.yield("entity", tok)
end

local function fdump(tok)
	return coroutine.yield("flag", tok)
end

local function lua_vdump(tok)
	if string.match(tok, BOOLEAN_TRUE) or string.match(tok, BOOLEAN_FALSE) then
		return coroutine.yield("boolean", tok)
	elseif Lexer.Commands[tok] then
		return coroutine.yield("cmd", tok)
	end
	return coroutine.yield("iden", tok)
end

local function cdump(tok)
	if Lexer.Commands[tok] then
		return coroutine.yield("cmd", tok)
	end
	return coroutine.yield("iden", tok)
end

local LUA_MATCHES = {
	-- Flags
	{FLAG_B, fdump},
	{FLAG_A, fdump},

	-- Indentifiers
	--{CMD_IDEN, cdump},
	{CMD_IDEN, lua_vdump},

	 -- Whitespace
	{WSPACE, wsdump},

	-- Numbers
	{NUMBER_A, ndump},
	{NUMBER_B, ndump},
	{NUMBER_C, ndump},

	-- Strings
	{STRING_EMPTY, sdump},
	{STRING_PLAIN, sdump},
	{STRING_INCOMP_A, invsdump},
	{STRING_INCOMP_B, invsdump},

	-- Entities
	{ENTITY_VAR, edump},

	{"^.", idump}
}

--- Create a plain token iterator from a string.
-- @tparam string s a string.

function Lexer.scan(s)
	local function lex()
		local line_nr = 1
		local sz = #s
		local idx = 1


		-- res is the value used to resume the coroutine.
		local function handle_requests(res)
			while res do
				local tp = type(res)
				-- Insert a token list:
				if tp == "table" then
					res = coroutine.yield("", "")
					for _, t in ipairs(res) do
						res = coroutine.yield(t[1], t[2])
					end
				elseif tp == "string" then -- Or search up to some special pattern:
					local i1, i2 = string.find(s, res, idx)
					if i1 then
						idx = i2 + 1
						res = coroutine.yield("", string.sub(s, i1, i2))
					else
						res = coroutine.yield("", "")
						idx = sz + 1
					end
				else
					res = coroutine.yield(line_nr, idx)
				end
			end
		end

		--[[
		local b, e = string.find(s, "%S+")
		if b then
			idx = e + 1
			handle_requests(coroutine.yield("cmd", string.sub(s, b, e)))
		end]]

		while true do
			if idx > sz then
				while true do
					handle_requests(coroutine.yield())
				end
			end

			for _, m in ipairs(LUA_MATCHES) do
				local i1, i2 = string.find(s, m[1], idx)
				local findres = {i1, i2}
				if i1 then
					local tok = string.sub(s, i1, i2)
					idx = i2 + 1

					local res = m[2](tok, findres)

					if string.find(tok, "\n") then
						-- Update line number:
						local _, newlines = string.gsub(tok, "\n", TABLE_EMPTY)
						line_nr = line_nr + newlines
					end

					handle_requests(res)
					break
				end
			end
		end
	end
	return coroutine.wrap(lex)
end

return Lexer