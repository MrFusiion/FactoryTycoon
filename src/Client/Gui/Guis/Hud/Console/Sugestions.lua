local TS = game:GetService("TweenService")


local Sugestions = {}

function Sugestions:init(frame: Frame)
    self.Frame = frame
    self.Container = frame.Container
    self.Content = self.Container.Content

    self.EntryTemplate = self.Content.TEMPLATE
    self.EntryTemplate.Visible = false

    self.SelectedTemplate = self.Content.SELECTED
    self.SelectedTemplate.Visible = false

    local layout = self.Content:FindFirstChildWhichIsA("UIGridLayout")
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        self.Content.Size = UDim2.new(1, 0, 0, math.max(layout.AbsoluteContentSize.Y, self.Container.AbsoluteSize.Y))
    end)

    self.Sugestions = {}
    self.Selected = 0
    self.Visible = false

    --Initial state
    self.Frame.Position = UDim2.fromScale(0, 1)
end

function Sugestions:fadein()
    if not self.Visible then
        TS:Create(self.Frame, TweenInfo.new(0.025), { Position=UDim2.fromScale(0, 0) }):Play()
        self.Visible = true
    end
end

function Sugestions:fadeout()
    if self.Visible then
        TS:Create(self.Frame, TweenInfo.new(0.025), { Position=UDim2.fromScale(0, 1) }):Play()
        self.Visible = false
    end
end

function Sugestions:cycle()
    local old = self.Sugestions[self.Selected]
    if old then
        old.Label.TextColor3 = self.EntryTemplate.TextColor3
    end

    self.Selected += 1
    if self.Selected > #self.Sugestions then
        self.Selected = 1
    end

    local new = self.Sugestions[self.Selected]
    if new then
        new.Label.TextColor3 = self.SelectedTemplate.TextColor3
        local offset = math.max(new.Label.AbsoluteSize.Y * (self.Selected-1) - self.Container.AbsoluteSize.Y, 0)
        if offset > 0 then
            self.Content.Position = UDim2.new(0, 0, 1, offset + new.Label.AbsoluteSize.Y)
        else
            self.Content.Position = UDim2.fromScale(0, 1)
        end
    end

    return new and new.Value
end

function Sugestions:unselect()
    local old = self.Sugestions[self.Selected]
    if old then
        old.Label.TextColor3 = self.EntryTemplate.TextColor3
    end
    self.Content.Position = UDim2.fromScale(0, 1)
    self.Selected = 0
end

function Sugestions:set(sugestions: {string})
    table.sort(sugestions, function(a, b)
        return a.Name < b.Name
    end)

    if self.Selected > 0 then
        self:unselect()
    end

    local t = {}
    for i=1, math.max(#self.Sugestions, #sugestions) do
        local sugestion = sugestions[i]
        local oldSugestion = self.Sugestions[i]

        if sugestion and oldSugestion then
            oldSugestion.Text = sugestion.Name
            oldSugestion.Value = sugestion.Value
            oldSugestion.Label.Text = sugestion.Name
            table.insert(t, oldSugestion)
        elseif oldSugestion then
            oldSugestion.Label:Destroy()
        elseif sugestion then
            local clone = self.EntryTemplate:Clone()
            clone.Text = sugestion.Name
            clone.Visible = true
            clone.Parent = self.Content

            table.insert(t, {
                Text = sugestion.Name,
                Value = sugestion.Value,
                Label = clone
            })
        end
    end

    self.Sugestions = t
end

function Sugestions:clear(exceptList: {string: any}?)
    exceptList = exceptList or {}
    for _, child in ipairs(self.Content:GetChildren()) do
        if child:IsA("TextLabel") and not exceptList[child.Name] then
            child:Destroy()
        end
    end

    if self.Selected > 0 then
        self:unselect()
    end
    self.Sugestions = {}
end

return Sugestions