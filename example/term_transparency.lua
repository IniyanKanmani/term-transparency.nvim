return {
    { -- Term Transparency: Toggle transparency of Neovim and Terminal
        "IniyanKanmani/term-transparency.nvim",

        dependencies = {
            "folke/tokyonight.nvim",
            "nvim-lualine/lualine.nvim",
        },

        event = "VimEnter",

        priority = 1000,

        opts = {
            transparency_value = 0.80,

            term = {
                kitty = {
                    enabled = true,
                    socket = "/tmp/kitty.sock",
                },

                wezterm = {
                    enabled = false,
                },
            },
            notifications = {
                enabled = true,
            },

            on_transparency_change = function()
                require("tokyonight").setup(
                    vim.g.is_transparent and TokyoNightTransparentThemeOpts or TokyoNightNormalThemeOpts
                )
                require("lualine").setup(vim.g.is_transparent and LualineTransparentThemeOpts or LualineNormalThemeOpts)

                vim.cmd.colorscheme("tokyonight-night")
            end,
        },

        config = function(_, opts)
            local term_transparency = require("term_transparency")
            term_transparency.setup(opts)

            vim.keymap.set(
                "n",
                "<leader>bt",
                "<CMD>ToggleTermTransparency<CR>",
                { desc = "Toggle Terminal Transparency" }
            )
        end,
    },
}
