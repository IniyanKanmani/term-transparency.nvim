local wezterm = require("wezterm")

local config = wezterm.config_builder()

config.term = "xterm-256color"

-------------------------------------------------------------------------------

config.automatically_reload_config = true -- required

-------------------------------------------------------------------------------

config.check_for_updates = false

config.front_end = "OpenGL"

config.enable_tab_bar = false

config.use_fancy_tab_bar = false

config.default_cursor_style = "SteadyBlock"

config.color_scheme = "tokyonight_night"

config.allow_square_glyphs_to_overflow_width = "Always"

config.font_size = 13

config.font = wezterm.font("JetBrainsMono Nerd Font Mono", { weight = "Regular", stretch = "Normal", style = "Normal" })

config.window_close_confirmation = "NeverPrompt"

config.window_decorations = "RESIZE"

config.window_padding = {
    left = 10,
    right = 10,
    top = 15,
    bottom = 0,
}

-------------------------------------------------------------------------------

-- programmatically modify transparency
local is_transparent = false
if is_transparent then
    config.window_background_opacity = 0.69
    config.macos_window_background_blur = 25

    config.background = {
        {
            source = {
                Color = "#000000",
            },
            width = "100%",
            height = "100%",
            opacity = 0.69,
        },
    }
else
    config.window_background_opacity = 1
end

-------------------------------------------------------------------------------

return config
