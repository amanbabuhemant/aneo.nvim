--[[ Animation ]]--

---@class Animation
---@field title string
---@field name string
---@field width number
---@field height number
---@field ignore_colors table[string]
---@field frames table[table]
local Animation = {
    upper_half_block = "▀",
    lower_half_block = "▄",
    blank_block = "⠀",
    ---@type Animation[]
    animations = {},
    opts = {
        border = "none"
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
    return #self.frames == 1
end

---@return boolean
function Animation:is_animated()
    return #self.frames ~= 1
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

    vim.api.nvim_buf_set_lines(buf, 0, -1, false, {})
    local lines = {}
    local line = ""
    for _=1, self.width do
        line = line .. "▀"
    end
    for _=1, self.height do
        table.insert(lines, line)
    end
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

    vim.bo[buf].modifiable = false
    vim.bo[buf].filetype = "aneo-pixels"
    vim.bo[buf].swapfile = false
    vim.bo[buf].buftype = "nofile"
    vim.bo[buf].bufhidden = "hide"

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

---@param frame number
function Animation:render_frame(frame)
    -- drowing
    for r=1, self.height, 2 do
        local hl_groups = {}
        for c=1, self.width do
            local fg_color = self.frames[frame][r][c] or "NONE"
            local bg_color = "NONE"
            if r+1 <= self.height then
                bg_color = self.frames[frame][r+1][c] or "NONE"
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
            end
            if fg_color == "NONE" and bg_color ~= "NONE" then
                self:set_char(math.floor(r/2), c-1, self.lower_half_block)
                hl_name = hl_name .. fg_color
                vim.api.nvim_set_hl(0, hl_name, { fg=bg_color, bg=fg_color })
                fg_color, bg_color = bg_color, fg_color
            end

            table.insert(hl_groups, hl_name)

            vim.api.nvim_set_hl(0, hl_name, { fg=fg_color, bg=bg_color })
        end

        for i, hl_name in pairs(hl_groups) do
            vim.api.nvim_buf_add_highlight(self.buf, 0, hl_name, math.max(math.floor(r/2), 0), (i-1)*3, i*3)
            -- multiply by 3 becouse they are UTF-8 charecters
        end

    end
end

--- Render animation on neovim
function Animation:render(x, y)

    local buf = vim.api.nvim_create_buf(false, true)
    local win = vim.api.nvim_open_win(buf, false, {
        width = self.width,
        height = math.floor(self.height/2) + self.height % 2,
        relative = "editor",
        row = y,
        col = x,
        border = self.opts.border,
    })

    self.buf = buf
    self.win = win

    self:setup_for_rendering()

    if self:is_static() then
        self:render_frame(1)
    else
        print("animatetd rendring not implimented yet")
    end

end

function Animation:terminate_window()
    vim.api.nvim_win_close(self.win, true)
end

return Animation
