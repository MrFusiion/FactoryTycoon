local Theme = _G.Data.Theme.Value

local Button = _G.Gui.Elements.Button

local ThemeButton = { Priority = 1 }

function ThemeButton:init(frame: Frame)
    if not _G.Config.CHANGE_THEME_BUTTON_ENABLED then
        frame:Destroy()
        return
    end

    frame.Visible = true
    self.Button = Button.new(frame.Button)
    self.Button.Activated:Connect(function()
        local name = next(Theme.Themes, Theme.Name)
        if not name then
            name = next(Theme.Themes)
        end
        Theme:setTheme(name)
    end)
end

return ThemeButton