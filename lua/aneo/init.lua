--[[ aneo ]]--

CMD = require("aneo.cmd")

local M = {}

M.opts = {
    onstart = false,
    auto_change = false,
    auto_change_time = 10,
    auto_change_random = true,
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
    if M.opts.onstart then
        if M.opts.auto_change_random then
            CMD.random()
        else
            -- TODO: retrive and show last played animation
        end
    end
end

return M
