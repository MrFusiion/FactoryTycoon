local cache = {}

local blueprintFolder = game:GetService("ReplicatedStorage"):FindFirstChild("Blueprints")
if not blueprintFolder then
    blueprintFolder = Instance.new("Folder")
    blueprintFolder.Name = "Blueprints"
    blueprintFolder.Parent = game:GetService("ReplicatedStorage")
end

local Blueprint = {}
Blueprint.__index = function(self, key)
    if Blueprint[key] then
        return Blueprint[key]
    else
        return rawget(self, "Model")[key]
    end
end

Blueprint.__newindex = function(self, key, value)
    self.Model[key] = value
end


--[[
    _____________
        Class
    _____________
]]

function Blueprint.new(object, ...)
    local newBlueprint = {}
    newBlueprint.Object = object
    newBlueprint.Args = {...}
    newBlueprint.Model = Blueprint.createModel(object)
    return setmetatable(newBlueprint, Blueprint)
end


function Blueprint.createModel(object)
    if not cache[object.Name] then
        --print("Created Model")
        local model = object.MODEL:Clone()
        local destroy = {}
        for _, descendant in ipairs(model:GetDescendants()) do
            if descendant:IsA("BasePart") then
                if descendant.CanCollide then
                    descendant.Material = "SmoothPlastic"
                    descendant.CanCollide = false
                    descendant.Transparency = .5
                    descendant.BrickColor = BrickColor.Black()
                    descendant.Parent = model
                    continue
                end
            end
            if descendant ~= model.PrimaryPart then
                table.insert(destroy, descendant)
            end
        end
        for _, child in ipairs(destroy) do
            child:Destroy()
        end
        cache[object.Name] = model
    else
        --print("Used cache Model")
    end
    return cache[object.Name]
end


function Blueprint.Place(self)
    local cf = self:GetPrimaryPartCFrame()
    return self.Object.new(self.Model.Parent, cf - cf.UpVector * self.PrimaryPart.Size.Y / 2, table.unpack(self.Args))
end


function Blueprint.Destroy(self)
    self.Model.Parent = blueprintFolder
end


function Blueprint.SetPrimaryPartCFrame(self, cf)
    self.Model:SetPrimaryPartCFrame(cf)
end


function Blueprint.GetPrimaryPartCFrame(self)
    return self.Model:GetPrimaryPartCFrame()
end

return Blueprint