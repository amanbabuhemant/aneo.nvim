# aneo

Cute pixel animations in neovim


## Why?

Because... why not?


## Installation

### Lazy.nvim

```lua
{
    "amanbabuhemnt/aneo.nvim",
    config = function()
        require("aneo").setup()
    end
}
```
or
```lua
{
    "amanbabuhemnt/aneo.nvim",
    opts = {
        -- your configuration options here
    }
}
```

### Packer.nvim
```lua
use {
    "amanbabuhemnt/aneo.nvim",
    config = function()
        require("aneo").setup({
            -- your configuration options here
        })
    end
}
```

