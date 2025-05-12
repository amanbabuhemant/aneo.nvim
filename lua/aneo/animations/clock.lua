--[[

Clock
Author: Aman Babu Hemant

--]]


local chars = {
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
    [":"] = {
        "   ",
        " * ",
        "   ",
        " * ",
        "   ",
    }
}

local char_join = function(s, c)
    local l = #s[1]
    if l == 0 then
        for i = 1, 7 do
            s[i] = s[i] .. " "
        end
    end

    for i=1, 5 do
        s[i+1] = s[i+1] .. c[i]
    end

    s[1] = s[1] .. "   "
    s[7] = s[7] .. "   "
    for i=1, 7 do
        s[i] = s[i] .. " "
    end

    return s
end

local clock_face = function()
    local date = os.date("*t")
    local hr, min = tostring(date.hour), tostring(date.min)
    if #hr == 1 then
        hr = "0" .. hr
    end
    if #min == 1 then
        min = "0" .. min
    end

    local text = { "", "", "", "", "", "", "" }
    text = char_join(text, chars[hr:sub(1, 1)])
    text = char_join(text, chars[hr:sub(2, 2)])
    text = char_join(text, chars[":"])
    text = char_join(text, chars[min:sub(1, 1)])
    text = char_join(text, chars[min:sub(2, 2)])

    local frame = {}
    for _, line in pairs(text) do
        local line_colors = {}
        for c in line:gmatch(".") do
            if c == " " then
                table.insert(line_colors, false)
            elseif c == "*" then
                table.insert(line_colors, "ffffff")
            end
        end
        table.insert(frame, line_colors)
    end

    return frame
end

local clock = {
    width = 21,
    height = 7,
    frame_delays = { 5 },
    frames = {
        clock_face
    }
}


return clock
