---@diagnostic disable: undefined-global

local os = { path = { sep = "/" } }
function os.path.join(...)
    return table.concat({...}, os.path.sep)
end

local function cloneFile(target, path)
    assert(remodel.isFile(target), "`target` is not an dir.")

    local content = remodel.readFile(target)
    remodel.writeFile(path, content)
end

local function cloneDir(target, path, recursive)
    assert(remodel.isDir(target), "`target` is not an dir.")
    recursive = recursive ~= nil and recursive or false

    remodel.createDirAll(path)
    for _, name in ipairs(remodel.readDir(target)) do
        child = os.path.join(target, name)
        childPath = os.path.join(path, name)

        if remodel.isFile(child) then
            cloneFile(child, childPath)
        elseif recursive then
            cloneDir(child, childPath, true)
        else
            remodel.createDirAll(childPath)
        end
    end
end

local function readJson(path)
    return json.fromString(remodel.readFile(path))
end

for name, data in pairs(readJson("vendor/layout.json")) do
    local target = data.src
    local path = data.path

    if remodel.isFile(target) then
        cloneFile(target, path)
    else
        cloneDir(target, os.path.join(path, name), true)
    end
end