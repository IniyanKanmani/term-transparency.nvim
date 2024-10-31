# term-transparency.nvim

A Neovim plugin to seamlessly control transparency settings for both Neovim and WezTerm.

## Features

- Toggle transparency for all instances of Neovim and WezTerm with a single command
- Persistent transparency state across sessions

## Prerequisites

- WezTerm (currently the only supported terminal emulator)

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
        -- wezterm is the only terminal supported as of now
        wezterm = {
            enabled = true,
            transparency_toggle_file = "", -- filepath to wezterm toggle script
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

### Basic Keybinding

```lua
vim.keymap.set( "n", "<leader>bt", "<CMD>ToggleTermTransparency<CR>", { desc = "Toggle Terminal Transparency" })
```

### Commands

- `:ToggleTermTransparency` - Toggle transparency for both Neovim and WezTerm

## Example Setup

Check out these example configurations to get started:

- [Plugin Config](example/term_transparency.lua)
- [Wezterm Config](example/wezterm.lua)
- [Wezterm Toggle Script](example/toggle_wezterm_transparency.sh)

## Acknowledgments

- This plugin was created as a learning project to understand Neovim plugin development.
