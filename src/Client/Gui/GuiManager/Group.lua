local Group = {}
local Group_mt = { __index = Group }

local function remove(t: table, guiObject: GuiObject)
    for i, object in ipairs(t) do
        if object == guiObject then
            table.remove(t, i)
        end
    end
end

local function add(t: table, max: number, guiObject: GuiObject)
    if max > 0 and #t >= max then
        t[1].Visible = false
    end
    table.insert(t, guiObject)
end

function Group.new()
    local self = {}

    self.Configs = {
        ["MaxActive"] = -1
    }

    self.Active = {}
    self.Connections = {}

    return setmetatable(self, Group_mt)
end

function Group:add(guiObject: GuiObject)
    self.Connections[guiObject] = guiObject:GetPropertyChangedSignal("Visible"):Connect(function()
        if guiObject.Visible then
            add(self.Active, self.Configs.MaxActive, guiObject)
        else
            remove(self.Active, guiObject)
        end
    end)
end

function Group:remove(guiObject: GuiObject)
    if self.Connections[guiObject] then
        self.Connections[guiObject]:Disconnect()
        remove(self.Active, guiObject)
    end
end

function Group:configure(configs: table)
    for k, v in pairs(configs) do
        if self.Configs[k] ~= nil then
            self.Configs[k] = v
        end
    end
end

function Group:cleanup()
    for _, conn in pairs(self.Connections) do
        conn:Disconnect()
    end
    self.Connections = {}
end

return Group