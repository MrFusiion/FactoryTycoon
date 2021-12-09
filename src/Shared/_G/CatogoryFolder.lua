local CatogoryFolder = {}
local CatogoryFolder_mt = { __index = CatogoryFolder }
local sSelf = require(script.Parent.Parent.Modules.Symbol).named("Self")

function CatogoryFolder_mt:__call(catogory, name)
    catogory = catogory or sSelf
    if self.Cache[catogory] and self.Cache[catogory][name] then
        return self.Cache[catogory][name]
    else
        local folder = catogory == sSelf and self.Folder
            or self.Folder:WaitForChild(catogory)
        if folder then
            self.Cache[catogory] = self.Cache[catogory] or {}
            local child = folder:WaitForChild(name)
            if child then
                self.Cache[catogory][name] = child
                return child
            else
                warn(("Did not find a child %s inside %s"):format(name or "nil", folder.Name))
            end
        else
            warn(("Did not find catogory Folder %s inside %s"):format(catogory or "nil", self.Folder.Name or "nil"))
        end
    end
end

function CatogoryFolder.new(folder: Folder)
    local self = {}

    self.Cache = {}
    self.Folder = folder

    return setmetatable(self, CatogoryFolder_mt)
end

return CatogoryFolder