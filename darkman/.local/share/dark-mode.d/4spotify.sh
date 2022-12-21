#!/bin/sh

spicetify config color_scheme "dark"
spicetify update

if pgrep -x spotify > /dev/null 2>&1 ; then
    killall -q spotify
    while pgrep -x spotify >/dev/null; do sleep 1; done
    LD_PRELOAD=/usr/lib/spotifywm.so:/usr/lib/spotify-adblock.so /usr/bin/spotify &>/dev/null
fi