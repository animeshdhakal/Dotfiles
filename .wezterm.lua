local wezterm = require("wezterm")

local config = wezterm.config_builder()

config.font = wezterm.font("JetBrainsMono Nerd Font")
config.font_size = 11
config.enable_tab_bar = false
config.color_scheme = 'Tokyo Night Storm'


return config
