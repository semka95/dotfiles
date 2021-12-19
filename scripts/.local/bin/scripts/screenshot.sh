#!/bin/bash
# Script taken from https://github.com/yschaeff/sway_screenshots
set -e

## USER PREFERENCES ##
RECORDER=wf-recorder
TARGET=$(xdg-user-dir PICTURES)/screenshots
SCREENSHARE=~/.local/bin/scripts/screenshare.sh

FOCUSED=$(swaymsg -t get_tree | jq '.. | ((.nodes? + .floating_nodes?) // empty) | .[] | select(.focused and .pid) | .rect | "\(.x),\(.y) \(.width)x\(.height)"')
OUTPUTS=$(swaymsg -t get_outputs | jq -r '.[] | select(.active) | .rect | "\(.x),\(.y) \(.width)x\(.height)"')
WINDOWS=$(swaymsg -t get_tree | jq -r '.. | select(.pid? and .visible?) | .rect | "\(.x),\(.y) \(.width)x\(.height)"')
REC_PID=$(pidof $RECORDER) || true

screenshareToggle() {
    if $SCREENSHARE is-recording; then
        $SCREENSHARE stop
    else
        $SCREENSHARE start
    fi
}

if [ ! -z $REC_PID ]; then
    if ! $SCREENSHARE is-recording; then
        echo pid: $REC_PID
        kill -SIGINT $REC_PID
        notify-send "Screen recorder stopped" -t 2000
        exit 0
    fi
fi

# When I click window/output menu option, looks like it registers my double click as I'm choose window.
# I opened issue https://github.com/lbonn/rofi/issues/19. Quick fix for this issue is to add sleep 0.1
# before action.
CHOICE=`rofi -dmenu -p "How to make a screenshot?" << EOF
 Screenshot Fullscreen
 Screenshot Focused
 Screenshot Selected Window
 Screenshot Selected Output
 Screenshot Region
--------------------------
 Read QR-code
 Recognize Text
--------------------------
 Record Focused
 Record Selected Window
 Record Selected Output
 Record Region
 Screenshare
EOF`

sleep 0.1

mkdir -p $TARGET
FILENAME="$TARGET/$(date +'%Y-%m-%d_%Hh%Mm%Ss_screenshot.png')"
RECORDING="$TARGET/$(date +'%Y-%m-%d_%Hh%Mm%Ss_recording.mp4')"

case $(echo $CHOICE | cut -c 5- | tr '[:upper:]' '[:lower:]') in
    "screenshot fullscreen")
        grim "$FILENAME"
        REC=0 ;;
    "screenshot region")
        slurp | grim -g - "$FILENAME"
        REC=0 ;;
    "read qr-code")
        wl-copy $(slurp | grim -g - - | zbarimg -q --raw -)
        REC=2 ;;
    "recognize text")
        wl-copy -n $(slurp | grim -g - - | tesseract - - -l eng+rus | rev | cut -c 2- | rev)
        REC=3 ;;
    "screenshot selected output")
        echo "$OUTPUTS" | slurp | grim -g - "$FILENAME"
        REC=0 ;;
    "screenshot selected window")
        echo "$WINDOWS" | slurp | grim -g - "$FILENAME"
        REC=0 ;;
    "screenshot focused")
        grim -g "$(eval echo $FOCUSED)" "$FILENAME"
        REC=0 ;;
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
    "screenshare")
        screenshareToggle ;;
    *)
        grim -g "$(eval echo $CHOICE)" "$FILENAME" ;;
esac

case $REC in
    0)
        notify-send "Screenshot" "File saved as $FILENAME\nand copied to clipboard" -t 6000 -i $FILENAME
        wl-copy < $FILENAME
        ;;
    1)
        notify-send "Recording" "Recording stopped: $RECORDING" -t 6000
        wl-copy < $RECORDING
        ;;
    2)
        qr=$(wl-paste)
        notify-send "QR-code" "QR-code successfully read and copied to clipboard:\n$qr" -t 6000
        ;;
    3)
        notify-send "Tesseract" "Text recognized and copied" -t 6000
        ;;
esac
