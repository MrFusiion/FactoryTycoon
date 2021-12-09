local TS = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local MAX_LOG = _G.Config.COMMAND_LOG_MAX
local COLORS = {
    cmd     = Color3.fromRGB(248, 241, 140),
    string  = Color3.fromRGB(24, 165, 241),
    number  = Color3.fromRGB(255, 203, 91),
    entity  = Color3.fromRGB(200, 255, 128),
    boolean = Color3.fromRGB(226, 109, 255),
    flag    = Color3.fromRGB(255, 49, 111)
}

local Command = require(game:GetService("ReplicatedStorage")
    :WaitForChild("Command"))

local Sugestions = require(script.Sugestions)
local InputBar = require(script.InputBar)

--<< Entries >>
local Log = require(script.Entries.Log)
local Print = require(script.Entries.Print)
local Warn = require(script.Entries.Warn)
local Error = require(script.Entries.Error)

--<< Get Commands >>
for _, command in ipairs(_G.Remotes:invokeServer("Command.getCommands")) do
    Command:addCommand(command)
end


local Console = {}

function Console:init(frame: Frame)
    self.Frame = frame.Container

    self.Visible = false
    self.LogCount = 0
    self.Log = {}

    self.LogFrame = self.Frame.Log
    local logLayout = self.Frame.Log:FindFirstChildWhichIsA("UIListLayout")

    local topbar = self.Frame.TopBar
    topbar.Close.Activated:Connect(function()
        self:fadeout()
    end)

    Print.template(self.Frame.Log.PRINT)
    Warn.template(self.Frame.Log.WARN)
    Error.template(self.Frame.Log.ERROR)
    Log.template(self.Frame.Log.LOG)
    Log.colors(COLORS)


    local input = self.Frame.Input
    InputBar:init(input, COLORS)
    Sugestions:init(input.Container.Clip.Sugestions)

    InputBar.OnCommand:Connect(function(text: string)
        self:addEntry(Log.new(text))
    end)


    logLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        local size = logLayout.AbsoluteContentSize
        self.LogFrame.CanvasSize = UDim2.fromOffset(0, size.Y)
    end)

    UIS.InputBegan:Connect(function(input: InputObject)
        if input.KeyCode == Enum.KeyCode.F8 then
            self:toggle()
        end
    end)

    _G.Remotes:onEvent("Console.toggle", function()
        self:toggle()
    end)

    _G.Remotes:onEvent("Console.cls", function()
        self:clear()
    end)

    _G.Remotes:onEvent("Console.print", function(text: string)
        self:addEntry(Print.new(text))
    end)

    _G.Remotes:onEvent("Console.warn", function(text: string)
        self:addEntry(Warn.new(text))
    end)

    _G.Remotes:onEvent("Console.error", function(text: string)
        self:addEntry(Error.new(text))
    end)

    --Initial state
    self.Frame.Visible = true
    self.Frame.Position = UDim2.fromScale(0, 1)
    self.LogFrame.CanvasSize = UDim2.new()
end


function Console:fadein()
    if not self.Visible then
        TS:Create(self.Frame, TweenInfo.new(0.025), { Position=UDim2.fromScale(0, 0) }):Play()
        InputBar:captureFocus()
        self.Visible = true
    end
end

function Console:fadeout()
    if self.Visible then
        TS:Create(self.Frame, TweenInfo.new(0.025), { Position=UDim2.fromScale(0, 1) }):Play()
        InputBar:releaseFocus()
        InputBar:clear()
        self.Visible = false
    end
end

function Console:toggle()
    if self.Visible then
        self:fadeout()
    else
        self:fadein()
    end
end


function Console:clear()
    for _, enrty in ipairs(self.Log) do
        enrty:destroy()
    end
    self.LogCount = 0
    self.Log = {}
end

function Console:addEntry(entry: table)
    if self.LogCount >= MAX_LOG then
        local rem = self.Log[1]
        rem:destroy()
        table.remove(self.Log, 1)

        for i, entry in ipairs(self.Log) do
            entry.LayoutOrder = i
        end

        self.LogCount -= 1
    end

    table.insert(self.Log, entry)
    entry:setParent(self.LogFrame)
    self.LogCount += 1

    task.defer(function()
        local absSize = self.LogFrame.AbsoluteSize
        local canvasSize = self.LogFrame.AbsoluteCanvasSize
        self.LogFrame.CanvasPosition = Vector2.new(0, canvasSize.Y - absSize.Y)
    end)
end

_G.Packages:export({
    toggle = function()
        Console:toggle()
    end
})

return Console