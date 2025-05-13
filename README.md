# aneo

Cute pixel arts and animations in neovim

<a href="https://asciinema.org/a/719169" target="_blank">
    <video width="100%" autoplay loop muted playsinline>
        <source src="https://github-production-user-asset-6210df.s3.amazonaws.com/134631394/443428780-8a94c632-b3b9-4fd4-bbbb-6ffff923dc5c.mp4" type="video/mp4">
    </video>
</a>


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
    onstart = false,
    auto_change = false,
    auto_change_time = 10,
    auto_change_random = true,
    border = false,
}
```
