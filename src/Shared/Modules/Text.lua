local TextS = game:GetService("TextService")

type TextInstance = (TextLabel|TextButton|TextBox)


--______AutoResizeSignal meta___________________________________________
local AutoResizeSignal_mt = { __index={} }

function AutoResizeSignal_mt.__index:stop()
    for _, conn in ipairs(self.Connections) do
        conn:Disconnect()
    end
end


--______Text Service___________________________________________
local Connections = {}

local Text = {}
Text.Directions = { X="X", Y="Y", Both="Both" }


function Text:getTextBounds(label: TextInstance)
    return TextS:GetTextSize(label.Text, label.Font, label.TextSize, label.AbsoluteSize)
end


function Text:autoResize(label: TextInstance, dir: string, maxSize: UDim2)
    if Connections[label] then
        warn(("AutoResizeis allready enabled on %s")
            :format(label:GetFullName()))
        return
    end
    maxSize = maxSize or UDim2.fromScale(1, 1)

    local skip = false
    local function resize()
        if not skip then
            task.spawn(function()
                skip = true
                label.Size = maxSize

                task.wait()

                local x, y
                if dir == "X" or dir == "Both" then
                    x = UDim.new(0, label.TextBounds.X)
                else
                    x = UDim.new(1, 0)
                end

                if dir == "Y" or dir == "Both" then
                    y = UDim.new(0, label.TextBounds.Y)
                else
                    y = UDim.new(1, 0)
                end

                label.Size = UDim2.new(x, y)
                skip = false
            end)
        end
    end

    resize()
    local boundsConn = label:GetPropertyChangedSignal("TextBounds"):Connect(resize)

    local signal = {}
    function signal:stop()
        boundsConn:Disconnect()
        Connections[label] = nil
    end
    Connections[label] = signal

    return signal
end


function stopAutoResize(label: TextInstance)
    local conn = Connections[label]
    if conn then
        conn:stop()
    else
        warn(("AutoResize is not enabled on %s")
            :format(label:GetFullName()))
    end
end


return Text