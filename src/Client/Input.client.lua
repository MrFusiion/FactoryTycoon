local CAS = game:GetService("ContextActionService")

while not _G.Loaded do task.wait() end


_G.Bus:listen("EnableInput", function(enable: boolean)
    if not enable then
        CAS:BindAction("FREEZE_MOVEMENT", function()
                return Enum.ContextActionResult.Sink
        end, false, unpack(Enum.PlayerActions:GetEnumItems()))
    else
        CAS:UnbindAction("FREEZE_MOVEMENT")
    end
end)