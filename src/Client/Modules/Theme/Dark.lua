local Values = {}

--[[
    Text
]]
Values.Text = {
    Default =   Color3.new(0.901960, 0.901960, 0.901960),
    Disabled =  Color3.new(.45, .45, .45),
}

Values.Font = {
    Default = Enum.Font.Arial,
    Bold =  Enum.Font.ArialBold
}


--[[
    LoadingScreen
]]
Values.LoadingBackground = {
    Default =   Color3.fromHSV(0, 0, 0.067),
}

Values.LoadingPattern = {
    Default = Color3.fromHSV(0, 0, 0.196),
}


--[[
    SideBar
]]
Values.SideBarInventory = {
    Default = Color3.fromRGB(255, 190, 80),
    Image =     "rbxassetid://8015530592"
}

Values.SideBarInventoryStroke = {
    Default = Color3.fromRGB(191, 143, 60),
}

Values.SideBarDaily = {
    Default = Color3.fromRGB(230, 100, 100),
    Image =     "rbxassetid://6761849209"
}

Values.SideBarDailyStroke = {
    Default = Color3.fromRGB(173, 75, 75),
}

Values.SideBarMods = {
    Default = Color3.fromRGB(140, 150, 255),
    Image =     "rbxassetid://6886791467"
}

Values.SideBarModsStroke = {
    Default = Color3.fromRGB(105, 113, 191),
    Image =     "rbxassetid://6886791467"
}

Values.SideBarStore = {
    Default = Color3.fromRGB(97, 170, 70),
    Image =     "rbxassetid://7986843841"
}

Values.SideBarStoreStroke = {
    Default = Color3.fromRGB(73, 128, 53),
}

Values.SideBarSettings = {
    Default = Color3.fromRGB(150, 150, 150),
    Image =     "rbxassetid://6761858079"
}

Values.SideBarSettingsStroke = {
    Default = Color3.fromRGB(113, 113, 113),
}

Values.SideBarKeyBind = {
    Default =  Color3.fromHSV(0, 0, 0.784),
}


--[[
    Frames
]]
Values.Background = {
    Default =   Color3.fromHSV(0, 0, 0.173),
}

Values.Border = {
    Default =   Color3.fromHSV(0, 0, .12),
}

Values.Block = {
    Default =   Color3.new(0.14, 0.14, 0.14),
    Hover =     Color3.new(0.16, 0.16, 0.16),
}

Values.Item = {
    Default =   Color3.new(0.115, 0.115, 0.115),
}

Values.LoadingItem = {
    Default =   Color3.fromRGB(121, 190, 255),
}

Values.ItemBorder = {
    Default =   Color3.new(0.09, 0.09, 0.09),
}


--[[
    Buttons
]]
Values.MainButtonText = {
    Default =   Color3.fromRGB(121, 190, 255),
}

Values.MainButton = {
    Default =   Color3.fromHSV(0, 0, 0.155),
    Hover =     Color3.fromHSV(0, 0, 0.2),
    Pressed =   Color3.fromHSV(0, 0, 0.1),
    Disabled =  Color3.fromHSV(0, 0, 0.08),
}

Values.MainButtonBorder = {
    Default =   Color3.fromHSV(0, 0, 0.1),
}

Values.ButtonBackground = {
    Default =   Color3.fromHSV(0, 0, 0.155),
    Hover =     Color3.fromHSV(0, 0, 0.1),
    Pressed =   Color3.fromHSV(0, 0, 0.1),
    Disabled =  Color3.fromHSV(0, 0, 0.08),
    Selected =  Color3.fromRGB(121, 190, 255),
}

Values.ButtonContent = {
    Default =   Color3.fromHSV(0, 0, 0.155),
    Hover =     Color3.fromHSV(0, 0, 0.2),
    Pressed =   Color3.fromHSV(0, 0, 0.1),
    Disabled =  Color3.fromHSV(0, 0, 0.08),
}

Values.ButtonBorder = {
    Default =   Color3.fromHSV(0, 0, 0.1),
    Hover =     Color3.fromHSV(0, 0, 0.075),
    Pressed =   Color3.fromHSV(0, 0, 0.075),
    Selected =  Color3.fromRGB(85, 138, 187),
}


--[[
    Colors
]]
Values.Red = {
    Default =   Color3.new(1, 0.455, 0.455),
}

Values.Green = {
    Default =   Color3.new(0.651, 0.906, 0.557),
}

Values.Blue = {
    Default =   Color3.new(.333, .667, 1),
}

Values.Yellow = {
    Default =   Color3.new(1, 1, 0.565),
}

Values.Orange = {
    Default =   Color3.new(1, 0.651, 0.478),
}

Values.Purple = {
    Default =   Color3.new(0.859, 0.506, 0.859),
}



--[[
    Accept
]]
Values.AcceptBackground = {
    Default =   Color3.fromRGB(125, 200, 97),
}

Values.AcceptText = {
    Default =   Color3.new(0.792, 0.792, 0.792),
    Disabled =  Color3.new(.45, .45, .45),
}


--[[
    Cancel
]]
Values.CancelBackground = {
    Default =   Color3.fromRGB(200, 112, 112),
}

Values.CancelText = {
    Default =   Color3.new(0.792, 0.792, 0.792),
    Disabled =  Color3.new(.45, .45, .45),
}


--[[
    Cash
]]
Values.CashText = {
    Default =   Color3.fromRGB(69, 172, 6),
    Image =       "rbxassetid://6857979558"
}

Values.CashFont = Enum.Font.GothamBold


--[[
    Robux
]]
Values.RobuxText = {
    Default =   Color3.new(0.792, 0.792, 0.792),
    Disabled =  Color3.new(.45, .45, .45),
    Image =       "rbxassetid://6747490905"
}

Values.RobuxBackground = {
    Default =   Color3.fromRGB(85, 170, 0),
}

return Values