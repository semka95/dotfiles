#!/bin/sh

filepath=~/.config/Code/User/settings.json

sed -i "s|^  \"workbench.colorTheme\":.*|  \"workbench.colorTheme\": \"Capo-Light\",|" $filepath