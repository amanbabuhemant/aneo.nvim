--[[ commands ]]--

Animation = require("aneo.animation")

local M = {}

function M.render(name, opts)
    opts = opts or {}
    local animation = Animation.load(name)
    if not animation then
        print("animation not found, try `:Aneo -l` for get list")
        return
    end
    animation:set_opts(opts)
    local x, y = vim.api.nvim_win_get_width(0), 1
    x = x - animation.width
    animation:render(x, y)
end

function M.list()
    for _, a in pairs(Animation.list) do
        print(a)
    end
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
        a:terminate_window()
    else
        print("no animations runnig to close")
    end
end

function M.cmd(opts)
    local args = opts.args
    if args:sub(1, 1) ~= "-" then
        M.render(args)
    elseif args == "-l" then
        M.list()
    elseif args == "-h" then
        M.help()
    elseif args == "-c" then
        M.close()
    end
end

function M.cmd_complete(name, command, pos)
    return Animation.list
end

vim.api.nvim_create_user_command("Aneo", M.cmd, {
    nargs = "*",
    complete = M.cmd_complete
})

vim.api.nvim_create_user_command("AneoHelp", M.help,{})
vim.api.nvim_create_user_command("AneoList", M.list,{})
vim.api.nvim_create_user_command("AneoClose", M.close,{})

return M
