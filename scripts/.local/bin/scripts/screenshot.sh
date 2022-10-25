#!/bin/bash
# Script taken from https://github.com/yschaeff/sway_screenshots
set -e

## USER PREFERENCES ##
RECORDER=wf-recorder
SCREENSHOTS=$(xdg-user-dir PICTURES)/screenshots
RECORDINGS=$(xdg-user-dir VIDEOS)/recordings
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
󰆟 Screenshot Fullscreen
󰛐 Screenshot Focused
󰖯 Screenshot Selected Window
󰹑 Screenshot Selected Output
󰆞 Screenshot Region
--------------------------
󰐲 Read QR-code
󰊄 Recognize Text
--------------------------
󰛐 Record Focused
󰖯 Record Selected Window
󰹑 Record Selected Output
󰆞 Record Region
󰤲 Screenshare
EOF`

sleep 0.1

mkdir -p $SCREENSHOTS
mkdir -p $RECORDINGS
FILENAME="$SCREENSHOTS/$(date +'%Y-%m-%d_%Hh%Mm%Ss_screenshot.png')"
RECORDING="$RECORDINGS/$(date +'%Y-%m-%d_%Hh%Mm%Ss_recording.mp4')"

case "$CHOICE" in
    "󰆟 Screenshot Fullscreen")
        grim "$FILENAME"
        REC=0 ;;
    "󰆞 Screenshot Region")
        slurp | grim -g - "$FILENAME"
        REC=0 ;;
    "󰐲 Read QR-code")
        wl-copy $(slurp | grim -g - - | zbarimg -q --raw -)
        REC=2 ;;
    "󰊄 Recognize Text")
        wl-copy -n $(slurp | grim -g - - | tesseract - - -l eng+rus | rev | cut -c 2- | rev)
        REC=3 ;;
    "󰹑 Screenshot Selected Output")
        echo "$OUTPUTS" | slurp | grim -g - "$FILENAME"
        REC=0 ;;
    "󰖯 Screenshot Selected Window")
        echo "$WINDOWS" | slurp | grim -g - "$FILENAME"
        REC=0 ;;
    "󰛐 Screenshot Focused")
        grim -g "$(eval echo $FOCUSED)" "$FILENAME"
        REC=0 ;;
    "󰹑 Record Selected Output")
        $RECORDER -g "$(echo "$OUTPUTS"|slurp)" -f "$RECORDING"
        REC=1 ;;
    "󰖯 Record Selected Window")
        $RECORDER -g "$(echo "$WINDOWS"|slurp)" -f "$RECORDING"
        REC=1 ;;
    "󰆞 Record Region")
        $RECORDER -g "$(slurp)" -f "$RECORDING"
        REC=1 ;;
    "󰛐 Record Focused")
        $RECORDER -g "$(eval echo $FOCUSED)" -f "$RECORDING"
        REC=1 ;;
    "󰤲 Screenshare")
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
        notify-send "QR-code" "QR-code successfully read and copied to clipboard: <i>$qr</i>" -t 6000
        ;;
    3)
        notify-send "Tesseract" "Text recognized and copied" -t 6000
        ;;
esac
