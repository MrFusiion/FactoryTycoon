local growingClient = require(script.Parent.Parent.GrowingClient)

if _G.Config.RESOURCES_ENABLED then
    local mainParts = {workspace.Terrain.Baseplate }

    local mainSection = growingClient.Section.new(170, {
        { value=require(script.Parent.Parent.Trees.subclasses.Oak), weight=3},
        { value=require(script.Parent.Parent.Ores.subclasses.Stone), weight=1}
    }, mainParts)

    local region = growingClient.new("Plains", { mainSection }, 200)

    region:init()
    region:start()
end