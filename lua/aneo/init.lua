--[[ aneo ]]--

CMD = require("aneo.cmd")

local M = {}

M.opts = {
    on_start = false,
    auto = false,
    auto_interval = 10,
    cycle = false,
    random = true,
    border = false,
}

function M.setup(opts)
    opts = opts or {}
    for o, v in pairs(opts) do
        M.opts[o] = v
    end

    vim.schedule(M.startup)
end

function M.startup()
    -- on neovim startup

    if M.opts.on_start then
        if M.opts.auto then
            -- TODO: make function auto start
            -- return CMD.auto_start(M.opts)
        end
        local last_played = CMD.get_last_played()
        if last_played ~= nil and last_played ~= "" then
            return CMD.render(last_played)
        else
            return CMD.random()
        end
    end

    -- play if last played available
    local last_played = CMD.get_last_played()
    if last_played ~= nil and last_played ~= "" then
        return CMD.render(last_played)
    end
end

return M
