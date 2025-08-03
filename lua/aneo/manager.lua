--[[ Aneo Manager ]]--

Curl = require("aneo.curl")
paths = require("aneo.paths")
Config = require("aneo.config")
Manager = {}

Manager.list_cache = nil
Manager.server = Config.opts.server.value


function Manager.download(name)
    local res = Curl.get(Manager.server .. "/api/animation/" .. name)
    if res.code ~= 200 then
        return false
    end
    local animation_file = io.open(paths.animations_dir .. "/" .. name .. ".lua", "w")
    if not animation_file then
        return false
    end
    animation_file:write(res.body)
    animation_file:close()
    return true
end

function Manager.remove(name)
    local animation_filepath = paths.animations_dir .. "/" .. name .. ".lua"
    local success, _ = os.remove(animation_filepath)
    return success
end

function Manager.update_index()
    local res = Curl.get(Manager.server .. "/api/index")
    if res.code ~= 200 then
        return false
    end
    local index_file = io.open(paths.index, "w")
    if not index_file then
        return false
    end
    index_file:write(res.body)
    index_file:close()
    Manager.list(true)
    return true
end

function Manager.sync()
    local count = 0
    local list = Manager.list()
    local maxn = table.maxn(list)
    local buf = vim.api.nvim_create_buf(false, true)
    local w = vim.api.nvim_win_get_width(0)
    local h = vim.api.nvim_win_get_height(0)
    local win = vim.api.nvim_open_win(buf, false, {
        relative="editor",
        row=math.floor(h*0.1),
        col=math.floor(w*0.1),
        width=math.floor(w*0.8),
        height=math.floor(h*0.8),
        border="rounded",
    })
    vim.wo[win].cursorline = true

    vim.api.nvim_buf_set_lines(buf, 0, -1, true, {"Downloading Animations [" .. tostring(maxn) .. "]"})
    vim.api.nvim_buf_set_lines(buf, 1, -1, true, list)
    vim.cmd("redraw")

    for i, animation_name in ipairs(list) do
        vim.api.nvim_win_set_cursor(win, {i+1, 1})
        vim.api.nvim_buf_set_lines(buf, i, i+1, false, {"[Down] " .. animation_name})
        vim.cmd("redraw")

        local s = Manager.download(animation_name)
        if s then
            count = count + 1
            vim.api.nvim_buf_set_lines(buf, i, i+1, false, {"[Done] " .. animation_name})
        else
            vim.api.nvim_buf_set_lines(buf, i, i+1, false, {"[Fail] " .. animation_name})
        end
        vim.api.nvim_buf_set_lines(buf, 0, 1, false, {"Downloading Animations [" .. tostring(count) .. "/" .. tostring(maxn) .. "]"})

        vim.cmd("redraw")
    end

    vim.wait(300, function()
    pcall(vim.api.nvim_win_close, win, false)
    end)
    return count
end

function Manager.update()
    Manager.update_index()
    return Manager.sync()
end

function Manager.list(new)
    if not new and Manager.list_cache then
        return Manager.list_cache
    end

    if vim.fn.filereadable(paths.index) == 0 then
        -- vim.schedule(Manager.update_index)
        -- if vim.fn.filereadable(paths.index) == 0 then
        return {}
        -- end
    end

    local list = {}
    for line in io.lines(paths.index) do
        if line == "\n" or line == "" then
            goto continue
        end
        local animation_name = line:sub(1, line:find(":")-1)
        table.insert(list, animation_name)
        ::continue::
    end

    Manager.list_cache = list
    return list
end

return Manager
