#!/bin/bash

kitty_sockets=$(find "$2" -name "$1-*" 2> /dev/null)

IFS=$'\n' read -r -d '' kitten <<< "$kitty_sockets"

for kitty in $kitten
do
    kitty @ --to unix:"$kitty" set-background-opacity "$3"
done

kitty_config_file="$HOME/.config/kitty/kitty.conf"

uname=$(uname)

if [ "$uname" == "Linux" ]
then
    sed -i -E "s/^(background_opacity )([0-9\.]+)/\1$3/" "$kitty_config_file"
elif [ "$uname" == "Darwin" ]
then
    sed -i -E '' "s/^(background_opacity )([0-9\.]+)/\1$3/" "$kitty_config_file"
fi
