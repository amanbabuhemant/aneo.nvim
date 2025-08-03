-- [[ config ]] --

paths = require("aneo.paths")

---@class opt
---@field name string
---@field type string | string[]
---@field value any
local Opt = {
}

Opt.__index = Opt

function Opt:new(data)
    local obj = {
        name = data[1],
        type = data[2],
        value = data[3],
    }
    setmetatable(obj, self)
    return obj
end

function Opt:set(value)
    self.value = value
end

function Opt:get()
    return self.value
end


local C = {}

C.config_file_path = paths.config

C.opts = {
    on_start        = Opt:new({ "on_start", "boolean", false }),
    auto            = Opt:new({ "auto", "boolean", false }),
    auto_interval   = Opt:new({ "auto_interval", "number", false }),
    cycle           = Opt:new({ "cycle", "boolean", false }),
    random          = Opt:new({ "random", "boolean", false }),
    border          = Opt:new({ "border", "string", "none" }),
    server          = Opt:new({ "server", "string", "aneo.artizote.com" }),
}

C.sep = "|"

function C.get(name)
    local opt = C.opts[name]
    if opt then return opt.value end
end

function C.set(name, value)
    local opt = C.opts[name]
    if opt then
        opt:set(value)
    else
        C.opts[name] = Opt:new({ name, type(value), value })
    end
end

function C.load()
    local file = io.open(C.config_file_path, "r")
    if not file then
        C.save()
        return C.load()
    end
    for line in file:lines() do
        if #line == 0 then goto continue end
        local sp = string.find(line, "|")
        local name = string.sub(line, 1, sp-1)
        local value = string.sub(line, sp+1)
        local type = "string"
        local o = C.opts[name]
        if o then
            type = type
            if type == "number" then
                value = tonumber(value)
            end
            if type == "boolean" then
                value = value == "true"
            end
        end
        if C.opts[name] then
            C.opts[name]:set(value)
        else
            C.opts[name] = Opt:new({ name, type, value })
        end
        ::continue::
    end
end

function C.save()
    local text = ""
    for k, v in pairs(C.opts) do
        text = text .. k .. C.sep .. tostring(v:get()) .. "\n"
    end
    local file = io.open(C.config_file_path, "w")
    file:write(text)
    file:close()
end

function C.cmp(name, command, pos)
    print("name:", name)
    print("command:", command)
    print("pos:", pos)

end

C.load()

return C
