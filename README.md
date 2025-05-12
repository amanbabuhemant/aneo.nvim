# aneo

Cute pixel arts and animations in neovim


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

