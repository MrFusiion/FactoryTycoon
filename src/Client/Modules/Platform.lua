local UIS = game:GetService("UserInputService")

--local PlatformChanged = Instance.new("BindableEvent")
local InputTypeChanged = Instance.new("BindableEvent")

local PLAFORM_INPUT_TYPE = {
    CONSOLE = "GAMEPAD",
    MOBILE = "TOUCH",
    PC = "KEYBOARD"
}

local Platform = {}
Platform.LastInputType = nil
--Platform.PlatformChanged = PlatformChanged.Event
Platform.InputTypeChanged = InputTypeChanged.Event

--========================/init/========================--
if (game:GetService("GuiService"):IsTenFootInterface()) then
    Platform.LastInputType = Enum.UserInputType.Gamepad1
elseif (game:GetService("UserInputService").TouchEnabled and not game:GetService("UserInputService").MouseEnabled) then
    Platform.LastInputType = Enum.UserInputType.Touch
else
    Platform.LastInputType = Enum.UserInputType.Keyboard
end
--========================/init/========================--

function Platform:getPlatform()
    if game:GetService("GuiService"):IsTenFootInterface() then
        return "CONSOLE"
    elseif game:GetService("UserInputService").TouchEnabled and not game:GetService("UserInputService").MouseEnabled then
        return "MOBILE"
    end
    return "PC"
end

function Platform:getInputType()
    if self.LastInputType then
        if self.LastInputType == Enum.UserInputType.Focus then
            return PLAFORM_INPUT_TYPE[self:getPlatform()]
        end
        if self.LastInputType == Enum.UserInputType.Keyboard or self.LastInputType == Enum.UserInputType.TextInput then
            return PLAFORM_INPUT_TYPE.PC
        elseif self.LastInputType == Enum.UserInputType.Touch then
            return PLAFORM_INPUT_TYPE.MOBILE
        elseif string.find(tostring(self.LastInputType), "Enum.UserInputType.Gamepad") then
            return PLAFORM_INPUT_TYPE.CONSOLE
        end

        for _, inputType in pairs{ Enum.UserInputType.MouseButton1, Enum.UserInputType.MouseButton2,
            Enum.UserInputType.MouseButton3, Enum.UserInputType.MouseMovement, Enum.UserInputType.MouseWheel }
        do
            if self.LastInputType == inputType then
                return PLAFORM_INPUT_TYPE.PC
            end
        end
    end
end

function Platform:getConsoleButtonImage(keycode: Enum.KeyCode)
    local gamepadButtonImage = {
        [Enum.KeyCode.ButtonX] =    "rbxassetid://4954053197",
        [Enum.KeyCode.ButtonY] =    "rbxassetid://5528142049",
        [Enum.KeyCode.ButtonA] =    "rbxassetid://5528141664",
        [Enum.KeyCode.ButtonB] =    "rbxassetid://4954313180",
        [Enum.KeyCode.DPadUp] =     "rbxassetid://6292428951",
        [Enum.KeyCode.DPadRight] =  "rbxassetid://6292429056",
        [Enum.KeyCode.DPadDown] =   "rbxassetid://6292429251",
        [Enum.KeyCode.DPadLeft] =   "rbxassetid://6292429148",
    }
    if not gamepadButtonImage[keycode] then
        warn("No image found for that button!")
    end
    return gamepadButtonImage[keycode]
end

function Platform:getKeycodeText(keycode: Enum.KeyCode)
    local KeyCodeTextMapping = {}
    if not KeyCodeTextMapping[keycode] then
        KeyCodeTextMapping[keycode] = tostring(keycode):split()[3]
    end
    return KeyCodeTextMapping[keycode]
end

UIS.LastInputTypeChanged:Connect(function(inputType: Enum.UserInputType)
    Platform.LastInputType = inputType
    InputTypeChanged:Fire(Platform:getInputType())
end)

return Platform