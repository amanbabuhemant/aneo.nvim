--[[

Author: Aman Babu Hemant

--]]

local nums = {
    ["0"] = {
        "***",
        "* *",
        "* *",
        "* *",
        "***",
    },
    ["1"] = {
        "  *",
        "  *",
        "  *",
        "  *",
        "  *",
    },
    ["2"] = {
        "***",
        "  *",
        "***",
        "*  ",
        "***",
    },
    ["3"] = {
        "***",
        "  *",
        "***",
        "  *",
        "***",
    },
    ["4"] = {
        "* *",
        "* *",
        "***",
        "  *",
        "  *",
    },
    ["5"] = {
        "***",
        "*  ",
        "***",
        "  *",
        "***",
    },
    ["6"] = {
        "***",
        "*  ",
        "***",
        "* *",
        "***",
    },
    ["7"] = {
        "***",
        "  *",
        "  *",
        "  *",
        "  *",
    },
    ["8"] = {
        "***",
        "* *",
        "***",
        "* *",
        "***",
    },
    ["9"] = {
        "***",
        "* *",
        "***",
        "  *",
        "***",
    },
}

local strokes = {}

local function count_key()
    strokes[os.time()] = (strokes[os.time()] or 0) + 1
end

local function get_speed()
    local total_keystrokes = 0
    for sec = os.time() - 60, os.time() do
        local s = strokes[sec]
        if s ~= nil then
            s = s - 1 -- don't know but the value is 1 insteod of 0
            total_keystrokes = total_keystrokes + s
        end
    end
    strokes[os.time() - 61] = nil
    return total_keystrokes
end

local function get_color(speed)
    local color

    if speed <= 50 then
        color = "666666"
    elseif 51 <= speed and speed <= 150 then
        color = "FF5F56"
    elseif 151 <= speed and speed <= 300 then
        color = "FFBD2E"
    elseif 301 <= speed and speed <= 500 then
        color = "27C93F"
    elseif 501 <= speed and speed <= 800 then
        color = "1BC5E0"
    elseif 801 <= speed and speed <= 1000  then
        color = "C792EA"
    else
        color = ({
            "ff0000", "00ff00", "0000ff", "FFFFFF",
        })[math.random(1, 4)]
    end

    return color
end

local function frame()
    local speed = tostring(get_speed())
    while #speed < 4 do
        speed = "0" .. speed
    end
    local fb = math.floor(15/(1000/tonumber(speed)))
    local bar = " " .. string.rep("*", fb) .. string.rep(" ", 15-fb) .." "
    local f = {
        string.rep(" ", 17),
        " " .. nums[speed:sub(1,1)][1] .. " " .. nums[speed:sub(2,2)][1] .. " " .. nums[speed:sub(3,3)][1] .. " " .. nums[speed:sub(4,4)][1] .. " ",
        " " .. nums[speed:sub(1,1)][2] .. " " .. nums[speed:sub(2,2)][2] .. " " .. nums[speed:sub(3,3)][2] .. " " .. nums[speed:sub(4,4)][2] .. " ",
        " " .. nums[speed:sub(1,1)][3] .. " " .. nums[speed:sub(2,2)][3] .. " " .. nums[speed:sub(3,3)][3] .. " " .. nums[speed:sub(4,4)][3] .. " ",
        " " .. nums[speed:sub(1,1)][4] .. " " .. nums[speed:sub(2,2)][4] .. " " .. nums[speed:sub(3,3)][4] .. " " .. nums[speed:sub(4,4)][4] .. " ",
        " " .. nums[speed:sub(1,1)][5] .. " " .. nums[speed:sub(2,2)][5] .. " " .. nums[speed:sub(3,3)][5] .. " " .. nums[speed:sub(4,4)][5] .. " ",
        string.rep(" ", 17),
        bar
    }
    local ff = {}
    local color = get_color(tonumber(speed))
    for _, l in pairs(f) do
        local fl = {}
        for c in l:gmatch(".") do
            local r = false
            if c == "*" then
                r = color
            end
            table.insert(fl, r)
        end
        table.insert(ff, fl)
    end
    return ff
end

vim.on_key(count_key)

return {
    title = "Speedometer",
    name = "speedometer",
    width = 16,
    height = 8,
    frame_delays = { 1 },
    frames = { frame }
}
