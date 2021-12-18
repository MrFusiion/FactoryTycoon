local Theme = {}
local Theme_mt = { __index = Theme }

local Symbol = _G.Shared.Symbol
local Intr = Symbol.named("Internal")

local PROPERTIES = {
    ["BackgroundColor3"] = true, ["ImageColor3"] = true,
    ["TextColor3"] = true, ["BorderColor3"] = true,
    ["ScrollBarImageColor3"] = true, ["PlaceHolderColor3"] = true,
    ["TextStrokeColor3"] = true, ["Font"] = true, ["Image"] = true
}

local MODIFIERS = {
    ["Default"] = true, ["Hover"] = true, ["Pressed"] = true,
    ["Disabled"] = true, ["Selected"] = true,
    ["Image"] = true, ["From"] = true, ["To"] = true, ["Bold"] = true
}

local function getThemes()
    local themes = {}
    for _, theme in ipairs(script:GetChildren()) do
        themes[theme.Name] = theme
    end
    return themes
end

local function isParentLocked(instance: Instance)
    local parent = instance.Parent
    local suc = pcall(function()
        instance.Parent = workspace
        instance.Parent = parent
    end)
    return suc
end

local function getThemeValues(name: string)
    local module = script:FindFirstChild(name)
    if not module and name == "Dark" then
        return {}
    elseif not module then
        return getThemeValues("Dark")
    end

    local values = require(module)
    if values.Base then
        for k, v in pairs(getThemeValues(values.Base)) do
            if not values[k] then
                values[k] = v
            else
                for state, color in pairs(v) do
                    values[k][state] = values[k][state] or color
                end
            end
        end
    end
    values.Base = nil
    return values
end

local function getModifier(name: string)
    for modifier in pairs(MODIFIERS) do
        if name:match(modifier) then
            return modifier
        end
    end
    return "Default"
end

function Theme_mt:__call(name: string, modifier: string|nil)
    modifier = modifier or "Default"

    assert(MODIFIERS[modifier], ("%s is not a valid modifier!")
        :format(modifier))

    local colors = self[Intr].Values[name]
    if typeof(colors) == "table" then
        return colors[modifier] or colors["Default"]
    elseif colors ~= nil then
        return colors
    else
        warn(("Color %s not found in theme %s!"):format(tostring(name), self.Name))
    end

    if modifier == "Image" then
        return ""
    elseif name:find("Font") then
        return Enum.Font.Legacy
    else
        return Color3.new(1, 1, 1)
    end
end

function Theme:get(name: string)
    local modifier = getModifier(name)
    name = name:gsub(("%s([_]*)"):format(modifier), "")
    return self(name, modifier)
end

function Theme.new(themename: string)
    return setmetatable({
        Name = themename,
        [Intr] = {
            Values = getThemeValues(themename),
            Objects = {}
        },
        Themes = getThemes()
    }, Theme_mt)
end

function Theme:setTheme(themename: string)
    self.Name = themename
    self[Intr].Values = getThemeValues(themename)

    for object in pairs(self[Intr].Objects) do
        if object.Parent ~= nil or not isParentLocked(object) then-- Check if the object is not destroyed
            self:setColor(object)
        else
            --Remove the object from the ObjectCache because its probably destoyed
            self[Intr].Objects[object] = nil
        end
    end
end

function Theme:setColor(guiObject: GuiObject, descendants: boolean?)
    descendants = descendants ~= nil and true or false

    for name, value in pairs(guiObject:GetAttributes()) do
        if PROPERTIES[name] then

            local gradient = guiObject:FindFirstChildWhichIsA("UIGradient")
            if gradient then
                guiObject[name] = Color3.new(1, 1, 1)
                gradient.Color = ColorSequence.new(
                    self:get(("%sFrom"):format(value)), self:get(("%sTo"):format(value))
                )
            else
                guiObject[name] = self:get(value)
            end

            if not self[Intr].Objects[guiObject] then
                self[Intr].Objects[guiObject] = true
            end
        end
    end

    if descendants then
        for _, descendant in ipairs(guiObject:GetDescendants()) do
            self:setColor(descendant)
        end
    end
end

return Theme