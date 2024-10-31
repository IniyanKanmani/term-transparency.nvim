#!/bin/bash

# macOS
sed -E -i '' "1,/is_transparent = (true|false)/s/(is_transparent = )(true|false)/\1${1}/" ~/.config/wezterm/wezterm.lua

# # Linux
# sed -E -i "1,/is_transparent = (true|false)/s/(is_transparent = )(true|false)/\1${1}/" ~/.config/wezterm/wezterm.lua
