local wezterm = require("wezterm")

local config = wezterm.config_builder()

config.term = "xterm-256color"

-------------------------------------------------------------------------------

config.automatically_reload_config = true -- required

-------------------------------------------------------------------------------

config.check_for_updates = false

config.front_end = "OpenGL" -- "Software"

config.enable_tab_bar = false

config.enable_wayland = false

config.use_fancy_tab_bar = false

config.default_cursor_style = "SteadyBlock"

config.color_scheme = "tokyonight_night"

config.allow_square_glyphs_to_overflow_width = "Always"

config.font_size = 10

config.dpi = 96.0

config.font = wezterm.font("JetBrainsMono Nerd Font", { weight = "Regular", stretch = "Normal", style = "Normal" })

config.window_close_confirmation = "NeverPrompt"

config.window_decorations = "NONE"

config.window_padding = {
    left = 10,
    right = 10,
    top = 15,
    bottom = 0,
}

config.window_background_opacity = 0.8
config.macos_window_background_blur = 25

return config
