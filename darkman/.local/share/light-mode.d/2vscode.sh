#!/bin/sh

filepath=~/.config/VSCodium/User/settings.json

sed -i "s|^    \"workbench.colorTheme\":.*|    \"workbench.colorTheme\": \"Capo-Light\",|" $filepath