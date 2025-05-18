# aneo

Cute pixel arts and animations in neovim

[![Image](https://github.com/user-attachments/assets/4cfa40a2-3ae9-4ab2-b813-0a31c50db9da)](https://asciinema.org/a/719169)

The above media might seem distorted in some places, because it's GIF conversion of original recording, watch the original recording [here](https://asciinema.org/a/719169)

## Why?

Because... why not?


## Installation

### Lazy.nvim

```lua
{
    "amanbabuhemant/aneo.nvim",
    config = function()
        require("aneo").setup()
    end
}
```
or
```lua
{
    "amanbabuhemant/aneo.nvim",
    opts = {
        -- your configuration options here
    }
}
```

### Packer.nvim
```lua
use {
    "amanbabuhemant/aneo.nvim",
    config = function()
        require("aneo").setup({
            -- your configuration options here
        })
    end
}
```

## Configuration

Default settings:

```lua
{
    on_start = false,
    auto = false,
    auto_interval = 10,
    cycle = false,
    random = true,
    border = false,
}
```
