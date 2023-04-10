#!/bin/sh

filepath=~/.config/gtk-3.0/settings.ini

sed -i "s|^gtk-theme-name=.*|gtk-theme-name=Adwaita-light|" $filepath