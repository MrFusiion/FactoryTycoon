local SignModel = _G.Models("Property", "Sign")

local Subfix = _G.Shared.Subfix

local function setCFrameSign(model, cf)
    model:SetPrimaryPartCFrame(cf * CFrame.new(0, model.PrimaryPart.Size.Y * .5, 0))
end

local Sign = {}
local Sign_mt = { __index = Sign }

function Sign.new(parent: Part, price: number, visible: boolean)
    local self = {}

    self.Model = SignModel:Clone()
    setCFrameSign(self.Model, parent.CFrame * CFrame.new(0, parent.Size.Y * .5, 0))
    self.Model.Parent = parent

    self.Button = self.Model.Plate.SurfaceGui.TextButton

    Sign.setPrice(self, price or 0)
    Sign.setVisible(self, visible or false)

    return setmetatable(self, Sign_mt)
end

function Sign:setVisible(visible)
    for _, des in ipairs(self.Model:GetDescendants()) do
        if des:IsA("BasePart") then
            des.Transparency = visible and 0 or 1
        elseif des:IsA("TextButton") then
            des.Visible = visible
        end
    end
end

function Sign:setPrice(price)
    self.Price = price
    self.Button.Text = ("$ %s"):format(Subfix.addSubfix(price))
end

function Sign.recreate(t)
    return setmetatable(t, Sign_mt)
end

return Sign