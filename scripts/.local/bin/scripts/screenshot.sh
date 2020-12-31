#!/bin/bash
# Script taken from https://github.com/yschaeff/sway_screenshots
set -e

## USER PREFERENCES ##
MENU="rofi -dmenu -u 6,7,8,9"
RECORDER=wf-recorder
TARGET=$(xdg-user-dir PICTURES)/screenshots

NOTIFY=$(pidof mako || pidof dunst) || true
FOCUSED=$(swaymsg -t get_tree | jq '.. | ((.nodes? + .floating_nodes?) // empty) | .[] | select(.focused and .pid) | .rect | "\(.x),\(.y) \(.width)x\(.height)"')
OUTPUTS=$(swaymsg -t get_outputs | jq -r '.[] | select(.active) | .rect | "\(.x),\(.y) \(.width)x\(.height)"')
WINDOWS=$(swaymsg -t get_tree | jq -r '.. | select(.pid? and .visible?) | .rect | "\(.x),\(.y) \(.width)x\(.height)"')
REC_PID=$(pidof $RECORDER) || true

notify() {
    ## if the daemon is not running notify-send will hang indefinitely
    if [ $NOTIFY ]; then
        notify-send "$@"
    else
        echo NOTICE: notification daemon not active
        echo "$@"
    fi
}

if [ ! -z $REC_PID ]; then
    echo pid: $REC_PID
    kill -SIGINT $REC_PID
    notify-send "Screen recorder stopped" -t 2000
    exit 0
fi

CHOICE=`$MENU -p "How to make a screenshot?" << EOF
 Screenshot Fullscreen
 Screenshot Focused
 Screenshot Selected Window
 Screenshot Selected Output
 Screenshot Region
------------
 Record Focused
 Record Selected Window
 Record Selected Output
 Record Region
EOF`

mkdir -p $TARGET
FILENAME="$TARGET/$(date +'%Y-%m-%d_%Hh%Mm%Ss_screenshot.png')"
RECORDING="$TARGET/$(date +'%Y-%m-%d_%Hh%Mm%Ss_recording.mp4')"

case $(echo $CHOICE | cut -c 5- | tr '[:upper:]' '[:lower:]') in
    "screenshot fullscreen")
        grim "$FILENAME" ;;
    "screenshot region")
        slurp | grim -g - "$FILENAME" ;;
    "screenshot selected output")
        echo "$OUTPUTS" | slurp | grim -g - "$FILENAME" ;;
    "screenshot selected window")
        echo "$WINDOWS" | slurp | grim -g - "$FILENAME" ;;
    "screenshot focused")
        grim -g "$(eval echo $FOCUSED)" "$FILENAME" ;;
    "record selected output")
        $RECORDER -g "$(echo "$OUTPUTS"|slurp)" -f "$RECORDING"
        REC=1 ;;
    "record selected window")
        $RECORDER -g "$(echo "$WINDOWS"|slurp)" -f "$RECORDING"
        REC=1 ;;
    "record region")
        $RECORDER -g "$(slurp)" -f "$RECORDING"
        REC=1 ;;
    "record focused")
        $RECORDER -g "$(eval echo $FOCUSED)" -f "$RECORDING"
        REC=1 ;;
    *)
        grim -g "$(eval echo $CHOICE)" "$FILENAME" ;;
esac


if [ $REC ]; then
    notify-send "Recording" "Recording stopped: $RECORDING" -t 6000
    wl-copy < $RECORDING
else
    notify-send "Screenshot" "File saved as $FILENAME\nand copied to clipboard" -t 6000 -i $FILENAME
    wl-copy < $FILENAME
fi
