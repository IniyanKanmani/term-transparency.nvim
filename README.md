# term-transparency.nvim

A plugin to control transparency mode of neovim and wezterm

## Installation

### lazy.nvim

```lua
{
    'IniyanKanmani/term-transparency.nvim',

    dependencies = {
        -- all transparency changeable plugins
    },
}
```

## Default Options

```lua
require('term_transparency').setup({
    -- filepath to save transparency state
    transparency_state_file = vim.fn.expand("~") .. "/.local/state/term/transparency.txt",

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

```lua
vim.keymap.set('n', '<leader>bt', function()
    require('term_transparency').toggle_transparency()
end, { desc = 'Toggle [B]ackground [T]ransparency' })
```
