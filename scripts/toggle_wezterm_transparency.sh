#!/bin/bash

wezterm_config_file="$HOME/.config/wezterm/wezterm.lua"

uname=$(uname)

if [ "$uname" == "Linux" ]
then
    sed -i -E "s/(window_background_opacity = )([0-9\.]+)/\1$1/" "$wezterm_config_file"
elif [ "$uname" == "Darwin" ]
then
    sed -i -E '' "s/(window_background_opacity = )([0-9\.]+)/\1$1/" "$wezterm_config_file"
fi
