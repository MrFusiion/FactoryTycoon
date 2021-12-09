local Players = game:GetService("Players")

local _typeof = typeof
local Lexer = require(script.Lexer)

--<< Custom Types >>
local TYPE_META = { __tostring = function(self) return self.__type end }
local function newType(name: string)
    return setmetatable({
        __type = name
    }, TYPE_META)
end

local NIL_PLAYER = newType("NilPlayer")


local function typeof(value: any)
    local tp = _typeof(value)
    if tp == "Instance" then
        return value.ClassName
    elseif tp == "table" and value.__type then
        return tostring(value)
    end
    return tp
end


local function getCmd(text: string, commands: table)
    local cmdStr = string.match(text, "%S+")
    local cmd = commands[cmdStr]
    if not cmd then
        error(("%s is not a valid command!"):format(cmdStr or ""), 2)
    end
    return cmd
end



local Command = {}
Command.Commands = {}
Command.Lexer = require(script.Lexer)
Command.Lexer.Commands = Command.Commands
Command.Ranks = { CREATOR=1000, DEV=10, SUPER=3, ADMIN=2, USER=1 }


function Command:parseCmd(player: Player, text: string)
    local suc, cmd = pcall(getCmd, text, self.Commands)
    if not suc then
        error(cmd, 2)
    end
    local cmdName = string.match(text, "%S+")

    --<< Check rank >>
    if not self:checkRank(self:getRank(player), cmd.Rank, true) then
        error(("You don't have permissions to use this %s!, Required rank: %s Current rank: %s")
            :format(cmdName, cmd.Rank, player.Rank.Value), 2)
        return function () end
    end

    local args = {}
    local first = true
    for tok, src, meta in Lexer.scan(text) do
        if tok == "cmd" then
            if first then
                first = false
                continue
            end
            table.insert(args, setmetatable({}, {
                __index = { __type = ("Command(%s)"):format(src) },
                __tostring = function(flag) return flag.__type end
            }))

        elseif tok == "space" then
            continue

        --<< Type [flag] >>
        elseif tok == "flag" then
            table.insert(args, setmetatable({}, {
                __index = { __type = ("Flag(%s)"):format(src) },
                __tostring = function(flag) return flag.__type end
            }))

        --<< Type [string] >>
        elseif tok == "iden" then
            table.insert(args, src)

        --<< Type [string] >>
        elseif tok == "string" then
            if meta and meta.Invalid then
                error("EOL while scanning for string literal!", 2)
            end
            table.insert(args, string.sub(src, 2, -2))

        --<< Type [number] >>
        elseif tok == "number" then
            table.insert(args, tonumber(src))

        --<< Type [boolean] >>
        elseif tok == "boolean" then
            table.insert(args, src == "true")

        --<< Type [Player] >>
        elseif tok == "entity" then
            local id = tonumber(string.match(src, "^@(%d+)"))
            local name = string.match(src, "^@(%S+)")

            if src == "@me" then
                table.insert(args, player)
            elseif id then
                table.insert(args, Players:GetPlayerByUserId(id))
            elseif name then
                table.insert(args, Players:FindFirstChild(name))
            else
                table.insert(args, NIL_PLAYER)
            end
        end
    end

    local i = 0
    for _, param in ipairs(cmd.Params) do
        local isVarArgs = string.match(param, "*[%S+]") ~= nil
        local isAny = string.find(param, "any") ~= nil

        while true do
            i += 1

            local arg = args[i]
            if not arg and isVarArgs then
                break
            end

            --<< Error invalid arg type >>
            if arg == nil or not string.find(param, typeof(arg)) and not isAny then
                error(("Invalid argument #%d for %s, got <%s> expected %s!")
                    :format(i, cmdName, typeof(arg), param), 2)
            end

            if not isVarArgs then
                break
            end
        end
    end

    -- Return parsed command
    return function()
        local suc, err = cmd:execute(player, table.unpack(args))
        if not suc then
            error(err, 2)
        end
        return suc
    end
end


function Command:execute(player: Player, text: string)
    local parseSuc, cmd = pcall(Command.parseCmd, self, player, text)
    if parseSuc and cmd then
        return pcall(cmd)
    end
    return false, cmd
end


function Command:isCmd(text: string)
    local suc, exists = pcall(function()
        return getCmd(text, self.Commands) ~= nil
    end)
    return suc and exists
end


function Command:get(text: string)
    local suc, cmd = pcall(getCmd, text, self.Commands)
    if suc then
        return cmd
    end
    warn(cmd)
end


function Command:addCommand(command: table)
    command.Name = typeof(command.Name) == "table" and command.Name or {command.Name}
    for _, name in ipairs(command.Name) do
        if not self.Commands[name] then
            self.Commands[name] = command
        else
            warn(("Colliding command name %s!"):format(name))
        end
    end
end


function Command:highlight(text: string, colors: table)
    local richText = ""
    local function append(text: string)
        richText = ("%s%s"):format(richText, text)
    end

    local function esc(str: string)
        for _, esc in pairs({
            { "&", "&amp;"  },
            { "<", "&lt;"   },
            { ">", "&gt;"   },
            { '"', "&quot;" },
            { "'", "&apos;" },
        }) do
            str = string.gsub(str, esc[1], esc[2])
        end
        return str
    end

    local function color(str: string, color: Color3)
        local cs = ("\"rgb(%d, %d, %d)\""):format(
            math.floor(color.R * 255),
            math.floor(color.G * 255),
            math.floor(color.B * 255)
        )

        return ("<font color=%s>%s</font>")
            :format(cs, str)
    end

    for token, src in Lexer.scan(text) do
        if colors[token] then
            append(color(esc(src), colors[token]))
        else
            append(esc(src))
        end
    end

    return richText
end


function Command:sugestions(player: Player, text: string)
    local t = {}

    local pName = string.match(text, ".* @(%w*)$")
    if pName then
        local left = string.match(text, "(.* @)%w*")

        for _, player in ipairs(Players:GetPlayers()) do
            local name
            if player.DisplayName ~= player.Name then
                name = ("%s(%s)"):format(player.Name, player.DisplayName)
            else
                name = player.Name
            end

            if string.find(name, pName, 1, true) then
                table.insert(t, {
                    Name = name,
                    Value = ("%s%s"):format(left, player.Name)
                })
            end
        end
    else
        local cmd = string.match(text, "%S+%s*")
        if cmd then
            for name, command in pairs(Command.Commands) do
                if self:checkRank(self:getRank(player), command.Rank, true) then
                    if string.find(name, cmd, 1, true) and cmd ~= name then
                        table.insert(t, { Name=name, Value=name })
                    end
                end
            end
        end
    end

    return t
end


function Command:checkRank(rankA: string, rankB: string, allowEql: boolean)
    local a = self.Ranks[rankA]
    local b = self.Ranks[rankB]
    if a and b then
        return allowEql and a >= b or a > b
    end

    --TODO add warning
    return false
end


function Command:getRank(player: Player)
    return player.Rank.Value
end

return Command