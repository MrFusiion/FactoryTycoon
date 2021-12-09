local SG = game:GetService("StarterGui")

local Notify = {}

function Notify.send(title, text, duration, extra)
    SG:SetCore("SendNotification", {
        Title = title,
        Text = text,
        Icon = extra.Icon,
        Duration = duration,
        Callback = extra.Callback,
        Button1 = extra.Button1,
        Button2 = extra.Button2
    })
end

return Notify