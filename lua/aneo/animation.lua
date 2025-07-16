--[[ Animation ]]--


Config = require("aneo.config")


---@class Animation
---@field title string
---@field name string
---@field width number
---@field height number
---@field ignore_colors table[string] | nil
---@field frames table[table]
---@field frame_delays table[number] | nil
local Animation = {
    upper_half_block = "▀",
    lower_half_block = "▄",
    blank_block = "⠀",
    reset_cords = {},
    ---@type Animation[]
    animations = {},
    hl_cache = {},
    opts = {
        border = "none", -- using config module now
    },
}

---@param datatable table
---@return Animation
function Animation:new(datatable)
    local obj = {}
    setmetatable(obj, self)
    self.__index = self
    for f, v in pairs(datatable) do
        obj[f] = v
    end
    table.insert(Animation.animations, obj)
    return obj
end

Animation.list = require("aneo.animations")

---@param name string
---@return Animation | nil
function Animation.load(name)
    local found = false
    for _, a in pairs(Animation.list) do
        if a == name then
            found = true
            break
        end
    end
    if not found then
        return nil
    end
    local datatable = require("aneo.animations." .. name)
    return Animation:new(datatable)
end

---@return boolean
function Animation:is_static()
    return #self.frames == 1 and not self.frame_delays
end

---@return boolean
function Animation:is_animated()
    return not not (#self.frames ~= 1 or self.frame_delays)
end

---@param color string
---@return boolean
function Animation:ignore(color)
    if not self.ignore_colors then return false end
    if color == nil then return true end
    if color == "NONE" then return true end
    for _, c in pairs(self.ignore_colors) do
        if c == color then
            return true
        end
    end
    return false
end

function Animation:set_opts(opts)
    for n, v in pairs(opts) do
        self.opts[n] = v
    end
end

function Animation:setup_for_rendering()
    local win = self.win
    local buf = self.buf
    vim.wo[win].relativenumber = false
    vim.wo[win].number = false
    vim.wo[win].cursorline = false
    vim.wo[win].cursorcolumn = false

    -- parent bg inherit
    local parent_bg = vim.api.nvim_get_hl(0, { name = "Normal" }).bg
    vim.api.nvim_set_hl(0, "aneo-trasparent", { bg = parent_bg })
    vim.api.nvim_win_set_option(win, 'winhl', 'Normal:aneo-trasparent')

    vim.api.nvim_buf_set_lines(buf, 0, -1, false, {})
    local lines = {}
    local line = ""
    for _=1, self.width do
        line = line .. "▀"
    end
    for _=1, math.floor(self.height/2)+self.height%2 do
        table.insert(lines, line)
    end
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

    vim.bo[buf].modifiable = false
    vim.bo[buf].filetype = "aneo-pixels"
    vim.bo[buf].swapfile = false
    vim.bo[buf].buftype = "nofile"
    vim.bo[buf].bufhidden = "hide"
    vim.bo[buf].undofile = false
    vim.bo[buf].undolevels = 0
	vim.api.nvim_buf_call(buf, function()
		vim.opt_local.wrap = false
	end)
end

---@param line number
---@param col number
---@param char string
function Animation:set_char(line, col, char)
    local buf = self.buf
    local l = vim.api.nvim_buf_get_lines(buf, line, line+1, false)[1]
    l = vim.fn.strcharpart(l, 0, col) .. char .. vim.fn.strcharpart(l, col+1, vim.fn.strcharlen(l))
    vim.bo[buf].modifiable = true
    vim.api.nvim_buf_set_lines(buf, line, line+1, false, { l })
    vim.bo[buf].modifiable = false
end

---@param frame_number number
---@return table
function Animation:get_frame(frame_number)
    --- Expend Frame, Rows, and Columns and return as table

    -- Expendig frame
    local frame = self.frames[frame_number]
    if type(frame) == "function" then
        frame = frame(frame_number)
    end

    -- Expending rows
    for row_index, row in pairs(frame) do
        if type(row) == "function" then
            row = row(row_index, frame_number)
        end

        -- Expending columns
        local expended_row = {}
        local repeat_cell = 1
        local next_col_index = 1
        for i = 1, #row do
            local col = row[i]
            if type(col) == "number" then
                repeat_cell = col
                goto continue
            end
            while repeat_cell > 0 do
                local color = col
                if type(color) == "function" then
                    color = color(next_col_index, row_index, frame_number)
                end
                if not color then color = false end
                table.insert(expended_row, color)
                next_col_index = next_col_index + 1
                repeat_cell = repeat_cell - 1
            end
            repeat_cell = 1
            ::continue::
        end

        frame[row_index] = expended_row
    end

    return frame
end

---@param frame_number number
function Animation:render_frame(frame_number)
    -- reseting buffer text
    for _, cord in pairs(self.reset_cords) do
        self:set_char(cord[1], cord[2], self.upper_half_block)
    end
    self.reset_cords = {}

    local frame = self:get_frame(frame_number)

    -- drawing
    vim.api.nvim_buf_clear_namespace(self.buf, 0, 0, -1)
    for r=1, self.height, 2 do
        local hl_groups = {}
        for c=1, self.width do
            local fg_color = frame[r][c] or "NONE"
            local bg_color = "NONE"
            if r+1 <= self.height then
                bg_color = frame[r+1][c] or "NONE"
            end

            if self:ignore(fg_color) then fg_color = "NONE" end
            if self:ignore(bg_color) then bg_color = "NONE" end

            local hl_name = "aneo-color-" .. fg_color .. "-" .. bg_color

            if fg_color ~= "NONE" then
                fg_color = "#" .. fg_color
            end
            if bg_color ~= "NONE" then
                bg_color = "#" .. bg_color
            end

            -- transprancy
            if fg_color == "NONE" and bg_color == "NONE" then
                self:set_char(math.floor(r/2), c-1, self.blank_block)
                table.insert(self.reset_cords, { math.floor(r/2), c-1 })
            end
            if fg_color == "NONE" and bg_color ~= "NONE" then
                self:set_char(math.floor(r/2), c-1, self.lower_half_block)
                hl_name = hl_name .. fg_color
                fg_color, bg_color = bg_color, fg_color
                table.insert(self.reset_cords, { math.floor(r/2), c-1 })
            end

            table.insert(hl_groups, hl_name)

            if not Animation.hl_cache[hl_name] then
                vim.api.nvim_set_hl(0, hl_name, { fg=fg_color, bg=bg_color })
                Animation.hl_cache[hl_name] = true
            end
        end

        for i, hl_name in pairs(hl_groups) do
            vim.api.nvim_buf_add_highlight(self.buf, 0, hl_name, math.max(math.floor(r/2), 0), (i-1)*3, i*3)
            -- multiply by 3 becouse they are UTF-8 charecters
        end

    end

    -- clearnig undotree
    vim.api.nvim_buf_call(self.buf, function()
        vim.cmd("silent! undojoin | silent! normal! u")
    end)

end

function Animation:animate()
    if not self.timer then
        self.timer = vim.uv.new_timer()
        self.current_frame = 1
        self.current_delay = 1

        if not self.frame_delays or #self.frame_delays == 0 then
            self.frame_delays = { 1 }
        end
    end

    if self._stop == true then
        self.timer:stop()
        self.timer:close()
        self.timer = nil
        return
    end

    local delay = self.frame_delays[self.current_delay] * 1000

    self:render_frame(self.current_frame)

    self.current_delay = self.current_delay + 1
    if self.current_delay > #self.frame_delays then
        self.current_delay = 1
    end

    self.current_frame = self.current_frame + 1
    if self.current_frame > #self.frames then
        self.current_frame = 1
    end

    self.timer:start(delay, 0, function() vim.schedule( function()
        self:animate()
    end)end)
end

-- Render animation on neovim
function Animation:render(x, y)

    self:create_window(x, y)

    self:setup_for_rendering()

    if self:is_static() then
        self:render_frame(1)
    else
        self:animate()
    end

end

function Animation:play()
    self._stop = false
    self:animate()
end

function Animation:stop()
    self._stop = true
end

function Animation:create_window(x, y)
    local buf = vim.api.nvim_create_buf(false, true)
    local win = vim.api.nvim_open_win(buf, false, {
        width = self.width,
        height = math.floor(self.height/2) + self.height % 2,
        relative = "win",
        row = y,
        col = x,
        border = Config.opts.border.value
    })

    self.buf = buf
    self.win = win
end

function Animation:terminate_window()
    pcall(function()vim.api.nvim_win_close(self.win, true)end)
end

return Animation
