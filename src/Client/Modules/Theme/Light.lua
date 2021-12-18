local Values = {}

--[[
    Text
]]
Values.Text = {
    Default =   Color3.new(0.270588, 0.258823, 0.313725),
    Disabled =  Color3.new(0.219607, 0.211764, 0.254901),
}

Values.Font = {
    Default = Enum.Font.Arial,
    Bold =  Enum.Font.ArialBold
}


--[[
    LoadingScreen
]]
Values.LoadingBackground = {
    Default =   Color3.fromHSV(0, 0, 0.98),
}

Values.LoadingPattern = {
    Default = Color3.fromHSV(0, 0, 0.831),
}


--[[
    SideBar
]]
Values.SideBarInventory = {
    Default = Color3.fromRGB(211, 158, 67),
    Image =     "rbxassetid://8015530592"
}

Values.SideBarInventoryStroke = {
    Default = Color3.fromRGB(158, 119, 50),
}

Values.SideBarDaily = {
    Default = Color3.fromRGB(194, 84, 84),
    Image =     "rbxassetid://6761849209"
}

Values.SideBarDailyStroke = {
    Default = Color3.fromRGB(146, 63, 63),
}

Values.SideBarMods = {
    Default = Color3.fromRGB(121, 129, 221),
    Image =     "rbxassetid://6886791467"
}

Values.SideBarModsStroke = {
    Default = Color3.fromRGB(91, 97, 166),
}

Values.SideBarStore = {
    Default = Color3.fromRGB(80, 141, 58),
    Image =     "rbxassetid://7986843841"
}

Values.SideBarStoreStroke = {
    Default = Color3.fromRGB(60, 106, 44),
}

Values.SideBarSettings = {
    Default = Color3.fromRGB(129, 129, 129),
    Image =     "rbxassetid://6761858079"
}

Values.SideBarSettingsStroke = {
    Default = Color3.fromRGB(97, 97, 97),
}

Values.SideBarKeyBind = {
    Default =  Color3.fromHSV(0, 0,  0.290),
}


--[[
    Frames
]]
Values.Background = {
    Default =   Color3.fromHSV(0, 0.0, 0.875),
}

Values.Border = {
    Default =   Color3.fromHSV(0, 0.0, 0.72),
}

Values.Block = {
    Default =   Color3.new(0.807843, 0.945098, 1),
}

Values.Item = {
    Default =   Color3.new(0.784313, 0.784313, 0.784313),
}

Values.LoadingItem = {
    Default =   Color3.fromRGB(113, 179, 255),
}

Values.ItemBorder = {
    Default =   Color3.new(0.564705, 0.564705, 0.564705),
}


--[[
    Buttons
]]
Values.MainButtonText = {
    Default =   Color3.fromRGB(113, 179, 255),
}

Values.MainButton = {
    Default =   Color3.fromHSV(0, 0.0, 0.84),
    Hover =     Color3.fromHSV(0, 0.0, 0.95),
    Pressed =   Color3.fromHSV(0, 0.0, 0.65),
    Disabled =  Color3.fromHSV(0, 0.0, 0.63),
}

Values.MainButtonBorder = {
    Default =   Color3.fromHSV(0, 0.0, 0.65),
}

Values.ButtonBackground = {
    Default =   Color3.fromHSV(0, 0.0, 0.84),
    Hover =     Color3.fromHSV(0, 0.0, 0.65),
    Pressed =   Color3.fromHSV(0, 0.0, 0.65),
    Disabled =  Color3.fromHSV(0, 0.0, 0.63),
    Selected =  Color3.fromRGB(113, 179, 255),
}

Values.ButtonContent = {
    Default =   Color3.fromHSV(0, 0.0, 0.84),
    Hover =     Color3.fromHSV(0, 0.0, 0.95),
    Pressed =   Color3.fromHSV(0, 0.0, 0.65),
    Disabled =  Color3.fromHSV(0, 0.0, 0.63),
}

Values.ButtonBorder = {
    Default =   Color3.fromHSV(0, 0, 0.65),
    Hover =     Color3.fromHSV(0, 0.0, 0.55),
    Pressed =   Color3.fromHSV(0, 0.0, 0.55),
    Selected =  Color3.fromRGB(88, 140, 199),
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
    Default =   Color3.fromRGB(110, 198, 72),
}

Values.AcceptText = {
    Default =   Color3.fromHSV(0, 0, 0.9),
    Disabled =  Color3.fromHSV(0, 0, 0.6),
}


--[[
    Cancel
]]
Values.CancelBackground = {
    Default =   Color3.fromRGB(193, 72, 72),
}

Values.CancelText = {
    Default =   Color3.fromHSV(0, 0, 0.9),
    Disabled =  Color3.fromHSV(0, 0, 0.6),
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