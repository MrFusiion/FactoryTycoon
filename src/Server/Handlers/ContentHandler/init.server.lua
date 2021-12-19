while not _G.Loaded do task.wait() end

_G.Remotes:onInvoke("DescendantCount", function(_, model: Model)
    return #model:GetDescendants()
end)