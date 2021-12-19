local Content = {}

function Content:isModelLoaded(model: Model)
    return #model:GetDescendants() == _G.Remotes:invokeServer("DescendantCount", model)
end

function Content:waitForModelLoaded(model: Model)
    local loaded = false
    while not loaded do
        loaded = Content:isModelLoaded(model)

        if loaded then
            break
        end

        task.wait()
    end

    return model
end

function Content:takeOwnership(model: Model)
    Content:waitForModelLoaded(model)

    local copy = model:Clone()
    copy.Parent = model.Parent
    model.Parent = nil

    return copy
end

return Content