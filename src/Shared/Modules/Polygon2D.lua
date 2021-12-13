local function intersect(a: Vector2, b: Vector2, c: Vector2, d: Vector2)
    return  (((d.Y-a.Y) * (c.X-a.X)) > ((c.Y-a.Y) * (d.X-a.X))) ~= (((d.Y-b.Y) * (c.X-b.X)) > ((c.Y-b.Y) * (d.X-b.X)))
        and (((c.Y-a.Y) * (b.X-a.X)) > ((b.Y-a.Y) * (c.X-a.X))) ~= (((d.Y-a.Y) * (b.X-a.X)) > ((b.Y-a.Y) * (d.X-a.X)))
end

local Polygon = {}
local Polygon_mt = { __index=Polygon }

function Polygon.new(points: {Vector2})
    local self = {}

    self.Points = points
    self.Bounds = { Min=Vector2.new(1, 1) * 1e7, Max=Vector2.new(1, 1) * -1e7 }
    for _, point in ipairs(points) do
        self.Bounds.Min = Vector2.new(
            math.min(self.Bounds.Min.X, point.X),
            math.min(self.Bounds.Min.Y, point.Y)
        )

        self.Bounds.Max = Vector2.new(
            math.max(self.Bounds.Max.X, point.X),
            math.max(self.Bounds.Max.Y, point.Y)
        )
    end

    return setmetatable(self, Polygon_mt)
end

function Polygon:pointInPolygon(x: number, y: number)
    local c = Vector2.new(x, y)
    local d = self.Bounds.Max

    local hits = 0
    for i=2, #self.Points+1 do
        local a = self.Points[i - 1]
        local b = self.Points[i    ] or self.Points[1]

        if intersect(a, b, c, d) then
            hits += 1
        end
    end

    return hits % 2 == 1
end

return Polygon