# term-transparency.nvim

A Neovim plugin to seamlessly control transparency settings of Neovim and Terminal

## Features

- Toggle transparency for all Neovim instances and Terminal with a single command
- Persistent transparency state across sessions

## Prerequisites

- Kitty Or WezTerm

## Installation

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
    "IniyanKanmani/term-transparency.nvim",

    dependencies = {
        -- Add your transparency-related plugin dependencies here
    },
}
```

## Default Options

```lua
require("term_transparency").setup({
    -- terminal emulators settings
    term = {
        transparency_value = 0.80,

        -- terminal emulators settings
        kitty = {
            enabled = false,
            socket = "/tmp/kitty.sock", -- socket that kitty listens to
        },

        wezterm = {
            enabled = false,
        },
    },

    -- notification settings
    notifications = {
        enabled = true,
    },

    -- callback function to be triggered when transparency changes
    on_transparency_change = function() end,
})
```

## Usage

Set up required files for your terminal like in [Example Setup](#example-setup) section

### Command

- `:ToggleTermTransparency` - Toggle transparency of Neovim and Terminal

### Basic Keybinding

```lua
vim.keymap.set( "n", "<leader>bt", "<CMD>ToggleTermTransparency<CR>", { desc = "Toggle Terminal Transparency" })
```

## Example Setup

Check out these example configurations to get started

### Neovim

- [Plugin Config](example/term_transparency.lua)

### Kitty

- [Kitty Config](example/kitty.conf)

### Wezterm

- [Wezterm Config](example/wezterm.lua)

## Acknowledgments

- This plugin was created as a learning project to understand Neovim plugin development.
