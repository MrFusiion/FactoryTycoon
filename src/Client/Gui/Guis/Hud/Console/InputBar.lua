local TextS = game:GetService("TextService")
local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")


local BLINK_SPEED = 4
local CURSOR_WIDTH = 1
local CURSOR_COLOR = Color3.fromRGB(227, 227, 227)

local COMMAND_HISTORY_MAX = _G.Config.COMMAND_HISTORY_MAX

local camera = workspace.CurrentCamera
local player = game:GetService("Players").LocalPlayer

local Command = require(game:GetService("ReplicatedStorage"):WaitForChild("Command"))
local Sugestions = require(script.Parent.Sugestions)


local function execute(text: string)
    _G.Remotes:fireServer("Command.execute", text)
end

local function getCharWidth(char: string, textSize: number, font: string)
    return TextS:GetTextSize(char, textSize, font, camera.ViewportSize).X
end


local InputBar = {}

function InputBar:init(frame: Frame, colors: table)
    self.Frame = frame

    local scroll = frame.Container.Scroll
    local arrow = frame.Arrow

    self.Field = scroll.Field
    self.Color = self.Field.Color
    self:clear()

    self.Cycled = false
    self.HistoryCycled = false
    self.History = {}
    self.HistoryLen = 0
    self.HistorySelected = 0

    local onCommand = Instance.new("BindableEvent")
    self.OnCommand = onCommand.Event

    --<< Cursor >>
    local cursor = Instance.new("Frame")
    cursor.BackgroundTransparency = 1
    cursor.BackgroundColor3 = CURSOR_COLOR
    cursor.AnchorPoint = Vector2.new(0, 0.5)
    cursor.BorderSizePixel = 0
    cursor.Size = UDim2.new(0, getCharWidth("0", self.Field.AbsoluteSize.Y, self.Field.Font), 1, 0)
    cursor.Position = UDim2.fromScale(0, 0.5)
    cursor.Parent = self.Field

    -- << Cursor Blink >>
    local blinkTween = TS:Create(cursor, TweenInfo.new(1/BLINK_SPEED, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, -1, true), {
        BackgroundTransparency = 0
    })


    --<< Canvas >>
    local function updateCanvasSize()
        local size = TextS:GetTextSize(self.Field.Text, self.Field.TextSize, self.Field.Font, camera.ViewportSize)
        scroll.CanvasSize = UDim2.fromOffset(size.X + cursor.AbsoluteSize.X, 0)
    end

    local function updateCanvasPosition()
        local cur = self.Field.CursorPosition
        local left = string.sub(self.Field.Text, 1, cur - 1)
        local lSize = TextS:GetTextSize(left, self.Field.TextSize, self.Field.Font, self.Field.AbsoluteSize)

        local offset = math.max(lSize.X - scroll.AbsoluteSize.X + cursor.AbsoluteSize.X, 0)
        if offset > 0 then
            scroll.CanvasPosition = Vector2.new(offset, 0)
        else
            scroll.CanvasPosition = Vector2.new()
        end
    end


    --<< Sugestions >>
    local function setSugestions(text: string)
        local sugestions = Command:sugestions(player, text)
        if #sugestions > 0 then
            Sugestions:set(sugestions)
            Sugestions:fadein()
        else
            Sugestions:clear()
            Sugestions:fadeout()
        end
    end


    --<< TextSize >>
    local size = scroll.AbsoluteSize.Y

    self.Color.TextScaled = false
    self.Color.TextSize = size
    self.Field.TextScaled = false
    self.Field.TextSize = size

    arrow.TextScaled = false
    arrow.TextSize = size

    self.Frame:GetPropertyChangedSignal("Size"):Connect(function()
        local size = scroll.AbsoluteSize.Y
        self.Color.TextSize = size
        self.Field.TextSize = size

        arrow.TextSize = size

        cursor.Size = UDim2.new(0, getCharWidth("0", self.Field.AbsoluteSize.Y, self.Field.Font), 1, 0)
    end)

    --<< Transfer Focus >>
    self.Color.Focused:Connect(function()
        self.Color:ReleaseFocus()
        self:captureFocus()
    end)

    --<< Input Events >>
    local inputConn
    self.Field.Focused:Connect(function()
        inputConn = UIS.InputBegan:Connect(function(input: InputObject)
            if input.KeyCode == Enum.KeyCode.Tab then
                self.Cycled = true
                self:releaseFocus()
                self.Field.Text = Sugestions:cycle() or self.Field.Text
                task.defer(function()
                    self:captureFocus()
                    self.Cycled = false
                end)
            elseif input.KeyCode == Enum.KeyCode.Up then
                self:historyCycle( 1)
            elseif input.KeyCode == Enum.KeyCode.Down then
                self:historyCycle(-1)
            end
        end)

        if not self.Cycled then
            setSugestions(self.Field.Text)
        end

        blinkTween:Play()
    end)

    self.Field.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            if self.Field.Text then
                local text = self.Field.Text

                onCommand:Fire(text)
                execute(text)

                self:clear()
                task.defer(function()
                    self:captureFocus()
                end)

                self:historyAdd(text)
            end
        end

        if not self.Cycled then
            Sugestions:unselect()
            Sugestions:clear()
            Sugestions:fadeout()
        end

        self.HistorySelected = 0

        blinkTween:Cancel()
        cursor.BackgroundTransparency = 1

        inputConn:Disconnect()
    end)

    self.Field:GetPropertyChangedSignal("CursorPosition"):Connect(function()
        local cur = self.Field.CursorPosition

        -- wait for the text to change
        task.defer(function()
            local left = string.sub(self.Field.Text, 1, cur-1)
            local size = TextS:GetTextSize(left, self.Field.TextSize, self.Field.Font, self.Field.AbsoluteSize)

            cursor.Position = UDim2.new(0, size.X, 0.5, 0)

            updateCanvasPosition()
        end)
    end)

    self.Field:GetPropertyChangedSignal("Text"):Connect(function()
        local text = self.Field.Text
        if text ~= "" then


            if string.match(text, "^%s+") then
                self.Field.Text = string.gsub(text, "^%s+", "")
                return
            end

            if not self.Cycled then
                setSugestions(text)
            end

            if not self.HistoryCycled then
                self.HistorySelected = 0
            end

            updateCanvasSize()
            updateCanvasPosition()

            self.Color.Text = Command:highlight(self.Field.Text, colors)
        else
            self.Color.Text = ""

            --reset the canvas
            scroll.CanvasSize = UDim2.new()
            scroll.CanvasPosition = Vector2.new()

            Sugestions:clear()
            Sugestions:fadeout()
        end
    end)
end

function InputBar:clear()
    self.Field.Text = ""
    self.Color.Text = ""
end

function InputBar:historyClear()
    self.HistoryLen = 0
    self.History = {}
    self.HistorySelected = 0
end

function InputBar:historyAdd(text: string)
    if self.History[1] == text then
        return
    end

    if self.HistoryLen >= COMMAND_HISTORY_MAX then
        table.remove(self.History, self.HistoryLen)
        self.HistoryLen -= 1
    end

    self.HistoryLen += 1
    table.insert(self.History, 1, text)

    --print(self.History, self.HistoryLen)

    self.HistorySelected = 0
end

function InputBar:historyCycle(increment: number)
    self.HistoryCycled = true
    self.HistorySelected = math.min(math.max(self.HistorySelected + increment, 1), self.HistoryLen)

    --print(self.HistorySelected, tostring(self.History[self.HistorySelected]))

    self.Field.Text = self.History[self.HistorySelected] or self.Field.Text
    self.Field.CursorPosition = #self.Field.Text + 1
    task.defer(function()
        self.HistoryCycled = false
    end)
end

function InputBar:captureFocus()
    self.Field:CaptureFocus()
end

function InputBar:releaseFocus()
    self.Field:ReleaseFocus()
end

return InputBar