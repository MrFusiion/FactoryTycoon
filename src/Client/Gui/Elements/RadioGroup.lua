local Button = require(script.Parent.Button)

local signals = {}
local function createSignals(self)
    local function signal(name: string)
        local event = Instance.new("BindableEvent")
        self[name] = event.Event
        return event
    end

    signals[self] = {
        Selected = signal("SelectedChanged")
    }
end
local function fireSignal(self, name: string, ...)
    signals[self][name]:Fire(...)
end

local RadioGroup = {}
local RadioGroup_mt = { __index=RadioGroup }

function RadioGroup.new(container: GuiObject)
    local self = {}
    createSignals(self)

    self.Frame = container
    self.Buttons = {}
    self.Conns = {}

    for _, btn in ipairs(container:GetChildren()) do
        if btn:IsA("GuiButton") then
            RadioGroup.add(self, btn)
        end
    end

    self.Frame.ChildAdded:Connect(function(btn)
        if btn:IsA("GuiButton") then
            RadioGroup.add(self, btn)
        end
        RadioGroup._sort(self)
    end)

    self.Frame.ChildRemoved:Connect(function(btn)
        if btn:IsA("GuiButton") and self.Conns[btn] then
            self.Conns[btn]:Disconnect()
            self.Conns[btn] = nil

            for i, button in ipairs(self.Buttons) do
                if button == btn then
                    table.remove(self.Buttons, i)
                end
            end
        end
    end)

    RadioGroup._sort(self)

    return setmetatable(self, RadioGroup_mt)
end

function RadioGroup:add(btn: GuiButton)
    table.insert(self.Buttons, btn)

    self.Conns[btn] = btn.Activated:Connect(function()
        if btn ~= self.Selected then
            RadioGroup.select(self, btn)
        end
    end)
end

function RadioGroup:selected()
    return self.Selected.Name, self.Selected
end

function RadioGroup:select(btn: GuiButton)
    if btn.Parent == self.Frame then
        if self.Selected then
            self.Selected.Selected = false
        end
        self.Selected = btn
        self.Selected.Selected = true
        fireSignal(self, "Selected", btn.Name, btn)
    else
        warn(("Button %s is not a member of this RadioGroup!"):format(btn:GetFullName()))
    end
end

function RadioGroup:_sort()
    if not self.Sorting then
        self.Sorting = true
        task.defer(function()
            table.sort(self.Buttons, function(a, b)
                return a.LayoutOrder < b.LayoutOrder
            end)
            self.Sorting = false
        end)
    end
end

return RadioGroup