while not _G.Loaded do task.wait() end

--Wait one thread for the StateManager to initialize
task.wait()

local Theme = _G.Data.Theme.Value

local player = game:GetService("Players").LocalPlayer
local playerGui = player.PlayerGui

local function spawn(func, ...)
    local event = Instance.new("BindableEvent")
    event.Event:Connect(func)
    event:Fire(...)
    event:Destroy()
end


local manager = require(script.GuiManager)
manager:configureGroup("Hud", {
    MaxActive = 1
})


game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)


--local modules = {}
for _, folder in ipairs(script.Guis:GetChildren()) do
    local screenGui = playerGui:WaitForChild(folder.Name)
    Theme:setColor(screenGui, true)
    if screenGui then
        for _, frameModule in ipairs(folder:GetChildren()) do
            local suc, module = pcall(require, frameModule)
            if suc then
                local obj = screenGui:WaitForChild(frameModule.Name)
                if obj then
                    spawn(function()
                        module:init(obj, manager)
                    end)
                    --table.insert(modules, module)
                else
                    warn(("Did not find a Frame named %s inside ScreenGui %s!")
                        :format(screenGui.Name, frameModule.Name))
                end
            else
                warn(("An error occurred while requiring GuiSubModule %s!")
                    :format(frameModule.Name))
            end
        end
    else
        warn(("Did not find a ScreenGui named %s!"):format(folder.Name))
    end
end