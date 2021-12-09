local Slot = {}
Slot.TEMPLATE = nil

function Slot.new(props: table)
    assert(Slot.TEMPLATE~=nil, "Slot TEMPLATE was never set!")

    --props = defaultProps:validate(props)

    local frame = Slot.TEMPLATE:Clone()
    frame.Name = props.Name or ""
    frame.LayoutOrder = props.Id or 0
    frame.Parent = props.Parent

    -- Label
    frame.Data.Label.Text = props.Name or ""

    -- Cash
    frame.Data.Info.Cash.Label.Text = props.Cash or 0

    -- Date
    frame.Data.Info.Date.Label.Text = props.Date or "none"

    if props.Id then
        frame.Data.Buttons.Load.Activated:Connect(function()
            _G.Remotes:fireServer("Slot.SetSlot", props.Id)
        end)

        frame.Data.Buttons.Delete.Activated:Connect(function()
            -- Todo add delete functionality
        end)
    end
end

return Slot