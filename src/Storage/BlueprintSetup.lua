--http://www.roblox.com/Game/Tools/ThumbnailAsset.ashx?fmt=png&wd=420&ht=420&aid=
local PS = game:GetService('PhysicsService')
PS:CreateCollisionGroup("Solo")

local module = {}

local function setupImage(folder)
	local assetID = folder.AssetID.Value
	folder.Image.Value = 'http://www.roblox.com/Game/Tools/ThumbnailAsset.ashx?fmt=png&wd=420&ht=420&aid=' .. assetID
end

local function createMain(model)
	local cf, size = model:GetBoundingBox()
	local main = Instance.new('Part')
	main.Anchored = true
	main.Transparency = 1
	main.Size = size
	main.CFrame = cf
	main.Parent = model
	PS:SetPartCollisionGroup(main, 'Solo')
	model.PrimaryPart = main
end

function module.setupFolder(folder)
	for _, catogory in ipairs(folder:GetChildren()) do
		if catogory:IsA('Folder') then
			for _, item in ipairs(catogory:GetChildren()) do
				setupImage(item)

				local model = item:FindFirstChildWhichIsA('Model')
				if not model then
					local module = item:FindFirstChildWhichIsA('ModuleScript')
					if module then
						model = Instance.new('Model')

						local part = require(module)()
						part.Anchord = true
						part.Material = 'SmoothPastic'
						part.BirckColor = BrickColor.new('Ghost grey')
						part.Parent = model

						createMain(model)

						model.Parent = item
					end
				else
					if not model.PrimaryPart then
						createMain(model)
					end
				end
			end
		end
	end
end

return module
