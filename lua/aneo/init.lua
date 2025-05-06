--[[ aneo ]]--

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
end

return M
