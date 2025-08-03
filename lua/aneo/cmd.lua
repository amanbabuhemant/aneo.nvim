--[[ commands ]]--

Animation = require("aneo.animation")
Config = require("aneo.config")
Manager = require("aneo.manager")
paths = require("aneo.paths")

local M = {}

function M.render(name, opts, animation)
    opts = opts or {}

    if not animation then
        animation = Animation.load(name)
    end

    if not animation then
        print("animation not found, try `:Aneo -l` for get list")
        M.clear_last_played()
        return
    end

    animation:set_opts(opts)
    local x, y = vim.api.nvim_win_get_width(0), 1
    x = x - animation.width
    animation:render(x, y)
    M.save_last_played(animation.name)
    return animation
end

function M.list()
    for _, a in pairs(Animation.list) do
        print(a)
    end
    print("--------------------------")
    print("Total arts/animations: ", #Animation.list)
end

function M.help()
    local help_text = {
        "Aneo - Pixel animation is your neovim",
        "use `:Aneo <animation-name>` to play the animation",
        "use `:Aneo -l` for get the list of all animation names",
        "all options:",
    }
    local command_helps = {
        { "<animation-name>", "Render the animation" },
        { "%", "Render animation by current file" },
        { "-l", "List all the animation names" },
        { "-h", "Show this message" },
        { "-c", "Close latest played animation" },
    }
    for _, line in pairs(help_text) do
        print(line)
    end
    print()
    for _, command_help in pairs(command_helps) do
        print("\t", command_help[1], ":", command_help[2])
    end
end

function M.close()
    if #Animation.animations > 0 then
        local a = Animation.animations[#Animation.animations]
        table.remove(Animation.animations, #Animation.animations)
        a:stop()
        a:terminate_window()
    else
        print("no animations runing to close")
    end
    M.clear_last_played()
end

function M.random()
    math.randomseed(os.time())
    local i = math.random(#Animation.list)
    local a = Animation.list[i]
    M.render(a)
end

function M.this()
    local file_name = vim.api.nvim_buf_get_name(0)
    local load = dofile(file_name)
    local animation = Animation:new(load)
    M.render(nil, nil, animation)
end

---@param name string
function M.save_last_played(name)
    local file = io.open(paths.last_played, "w")
    file:write(name)
    file:close()
end

function M.clear_last_played()
    local file = io.open(paths.last_played, "w")
    file:write("")
    file:close()
end

---@return string | nil
function M.get_last_played()
    local file = io.open(paths.last_played, "r")
    if not file then
        return nil
    end
    return file:read("*l")
end

function M.preview()
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, Animation.list)
    vim.bo[buf].modifiable = false
    local win = vim.api.nvim_open_win(buf, true, {
        relative="win",
        width = 30,
        height = math.min(vim.api.nvim_win_get_height(0)-2, #Animation.list),
        row = 0,
        col = 0,
        border = "single",
    })
    vim.wo[win].cursorline = true

    local function on_esc()
        vim.api.nvim_buf_delete(buf, { force = true })
        vim.api.nvim_feedkeys(
            vim.api.nvim_replace_termcodes(
                "<Esc>", true, false, true
            ),
            "n", false
        )
        M.close()
    end

    local function on_line_change()
        local line = vim.api.nvim_get_current_line()
        if #Animation.animations ~= 0 then
            M.close()
        end
        local animation = Animation.load(line)
        animation.opts.border = "single"
        animation:render(31, -1)
    end

    vim.api.nvim_create_autocmd("CursorMoved", { buffer = buf, callback = on_line_change })
    vim.keymap.set("n", "<Esc>", on_esc, { buffer=buf })
    vim.keymap.set("n", "q", on_esc, { buffer=buf })
end

function M.update()
    local count = Manager.update(true)
    print(count .. " Animations updated")
end

function M.set(opts)
    local args = opts.args
    local sp = string.find(args, " ")
    local name = string.sub(args, 1, sp-1)
    local value = string.sub(args, sp+1)
    Config.set(name, value)
    Config.save()
end

function M.cmd(opts)
    local args = opts.args
    if args == "%" then
        return M.this()
    end
    if args:sub(1, 1) ~= "-" then
        M.render(args)
    elseif args == "-l" then
        M.list()
    elseif args == "-h" then
        M.help()
    elseif args == "-c" then
        M.close()
    elseif args == "-r" then
        M.random()
    end
end

function M.cmd_complete(name, command, pos)
    if table.maxn(Animation.list) == 0 and vim.fn.filereadable(paths.index) == 0 then
        print("Updating Index")
        Manager.update_index()
        print("Syncing Animations")
        Manager.sync()
        Animation.list = Manager.list(true)
    else
        print("file found")
    end
    return Animation.list
end

vim.api.nvim_create_user_command("Aneo", M.cmd, {
    nargs = "*",
    complete = M.cmd_complete
})

vim.api.nvim_create_user_command("AneoHelp", M.help,{})
vim.api.nvim_create_user_command("AneoList", M.list,{})
vim.api.nvim_create_user_command("AneoClose", M.close,{})
vim.api.nvim_create_user_command("AneoRandom", M.random,{})
vim.api.nvim_create_user_command("AneoThis", M.this, {})
vim.api.nvim_create_user_command("AneoPreview", M.preview, {})
vim.api.nvim_create_user_command("AneoSet", M.set, { nargs = "*", complete = Config.cmp })
vim.api.nvim_create_user_command("AneoUpdate", M.update, {})
vim.api.nvim_create_user_command("AneoSync", Manager.sync, {})

return M
