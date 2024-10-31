return {
    { -- Term Transparency: Toggle transparency of Neovim and Wezterm
        "IniyanKanmani/term-transparency.nvim",

        dependencies = {
            "folke/tokyonight.nvim",
            "nvim-lualine/lualine.nvim",
        },

        event = "VimEnter",

        priority = 1000,

        opts = {
            term = {
                wezterm = {
                    enabled = true,
                    transparency_toggle_file = vim.fn.expand("~") .. "/.config/wezterm/toggle_wezterm_transparency.sh",
                },
            },

            notifications = {
                enabled = false,
            },

            -- Note: Dependency plugins doesn't have to be setup. They will be setup when this plugin is setup with this callback.
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
