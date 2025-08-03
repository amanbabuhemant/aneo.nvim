--[[ paths ]]--

local paths = {}

paths.data_dir = vim.fn.stdpath("data") .. "/aneo"
vim.fn.mkdir(paths.data_dir, "p")

paths.animations_dir = paths.data_dir .. "/animations"
vim.fn.mkdir(paths.animations_dir, "p")

paths.last_played = paths.data_dir .. "/last-played"
paths.config = paths.data_dir .. "/config.txt"
paths.index = paths.data_dir .. "/index.txt"

return paths
