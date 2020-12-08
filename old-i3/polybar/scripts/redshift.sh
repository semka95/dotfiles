#!/bin/sh

case "$1" in
    --on)
        redshift -l 48.72:44.51 -t 6500:3600 -b 1.0:1.0
        ;;
    --off)
        killall -q redshift
        ;;
    *)
        echo  ""
        ;;
esac
