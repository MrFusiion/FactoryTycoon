type Grid = Array<Array<Array<boolean>>>

local function newVisitedList()

end

local function range(rStart: number, rEnd: number, step: number?)
    step = step or 1

    local i = rStart
    return function()
        i += step
        if i <= rEnd then
            return i
        end
        i = rStart
    end
end

local function rangeXZY(rStart: Vector3, rEnd: Vector3, step: Vector3?)
    step = step or Vector3.new(1, 1, 1)

    local x, y, z = rStart.X - step.X, rStart.Y, rStart.Z
    local xRange, yRange, zRange =
        range(x, rEnd.X, step.X),
        range(y, rEnd.Y, step.Y),
        range(z, rEnd.Z, step.Z)


    return function()
        x = xRange()
        if not x then
            x = rStart.X
            z = zRange()

            if not z then
                z = rStart.Z
                y = yRange()

                if not y then
                    y = rStart.Y
                    return
                end
            end
        end
        return x, z, y
    end
end


local function marcher(grid: Grid, size: Vector3)
    local isVisited = {}
    local function visited(x, y, z, boolean: boolean?)
        local index = Vector3.new(x, y, z)
        if boolean == nil then
            return isVisited[index] or false
        end
        isVisited[index] = boolean
    end

    local function isEmpty(x, y, z)
        return not grid[x][z][y]
    end

    local x, y, z = 1, 1, 1
    local index = rangeXZY(Vector3.new(x, y, z), size)

    return function ()
        x, z, y = index()

        if x and y and z then
            --Cleanup check
            local floating = true
---@diagnostic disable-next-line: count-down-loop
            for xo=-1, 1, 2 do
---@diagnostic disable-next-line: count-down-loop
                for zo=-1, 1, 2 do
---@diagnostic disable-next-line: count-down-loop
                    for yo=-1, 1, 2 do
                        local nx, nz, ny = x+xo, z+zo, y+yo
                        if nx > 0 and nz > 0 and ny > 0
                            and nx <= size.X and nz <= size.Z and ny <= size.Y
                        then
                            if not isEmpty(nx, ny, nz) then
                                floating = false
                                break
                            end
                        end
                    end
                end
            end

            if floating then
                grid[x][z][y] = false
            end

            if visited(x, y, z) or isEmpty(x, y, z) then
                return
            end

            local minX = x; local maxX = x
            local minZ = z; local maxZ = z
            local minY = y; local maxY = y

            visited(x, y, z, true)

            --March along x
            while maxX < size.X do
                local newMaxX = maxX + 1

                if visited(newMaxX, y, z) or isEmpty(newMaxX, y, z) then
                    break
                end

                visited(newMaxX, y, z, true)
                maxX = newMaxX
            end

            --March along z
            while maxZ < size.Z do
                local newMaxZ = maxZ + 1

                local useable = true
                for dx=minX, maxX do
                    if visited(dx, y, newMaxZ) or isEmpty(dx, y, newMaxZ) then
                        useable = false
                        break
                    end
                end

                if not useable then
                    break
                end

                for dx=minX, maxX do
                    visited(dx, y, newMaxZ, true)
                end
                maxZ = newMaxZ
            end

            --March along y
            while maxY < size.Y do
                local newMaxY = maxY + 1

                local useable = true
                for dx=minX, maxX do
                    for dz=minZ, maxZ do
                        if visited(dx, newMaxY, dz) or isEmpty(dx, newMaxY, dz) then
                            useable = false
                            break
                        end
                    end
                end

                if not useable then
                    break
                end

                for dx=minX, maxX do
                    for dz=minZ, maxZ do
                        visited(dx, newMaxY, dz, true)
                    end
                end
                maxY = newMaxY
            end

            return {
                min = Vector3.new(
                    minX, minY, minZ
                ),
                max = Vector3.new(
                    maxX, maxY, maxZ
                ),
            }
        end
        return "Done"
    end
end

local GreedyMesher = {}

function GreedyMesher.cuboidIter(grid: Grid, size: Vector3)
    local march = marcher(grid, size)
    return function ()
        local v
        while v == nil do
            v = march()
        end

        if v == "Done" then
            return
        end
        return v
    end
end

return GreedyMesher