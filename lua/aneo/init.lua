--[[ aneo ]]--

CMD = require("aneo.cmd")
Config = require("aneo.config")

local M = {}

function M.setup(opts)
    opts = opts or {}
    for o, v in pairs(opts) do
        Config.set(o, v)
    end

    -- Config.load()
    vim.schedule(M.startup)
end

function M.startup()
    -- on neovim startup

    if Config.opts.on_start.value then
        if Config.opts.auto.value then
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
