--[[ paths ]]--

local paths = {}

paths.data_dir = vim.fn.stdpath("data") .. "/aneo"
vim.fn.mkdir(paths.data_dir, "p")

paths.last_played = paths.data_dir .. "/last-played"
paths.config = paths.data_dir .. "/config.txt"

return paths
