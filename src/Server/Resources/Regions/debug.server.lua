local growingClient = require(script.Parent.Parent.GrowingClient)

if _G.Config.RESOURCES_DEBUG_ENABLED then
    local parts = { workspace.Terrain.DebugPart }

    local treeSection = growingClient.Section.new(5, {
        { value=require(script.Parent.Parent.Trees.subclasses.Oak), weight=1},
    }, parts)

    local stoneSection = growingClient.Section.new(5, {
        { value=require(script.Parent.Parent.Ores.subclasses.Stone), weight=1}
    }, parts)

    local region = growingClient.new("Debug", { treeSection, stoneSection }, 200)
    region:init()
    region:start()
end