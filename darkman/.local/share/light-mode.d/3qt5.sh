#!/bin/sh

filepath=~/.config/qt5ct/qt5ct.conf

sed -i "s|^color_scheme_path.*|color_scheme_path=$HOME/.config/qt5ct/colors/oomox-simple-rainbow.conf|" $filepath
sed -i 's|^icon_theme.*|icon_theme=oomox-simple-rainbow|' $filepath
sed -i 's|^style.*|style=Lightly|' $filepath