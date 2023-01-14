#!/usr/bin/env bash
# source https://github.com/TimoFreiberg/dotfiles/blob/e423fb86ad/bin/sway-screenshare.sh

geometry(){
    windowGeometries=$(
        swaymsg -t get_outputs -r | jq -r '.[] | select(.active) | .rect | "\(.x),\(.y) \(.width)x\(.height)"'
    )
    geometry=$(slurp -b "#45858820" -c "#45858880" -w 3 -d <<< "$windowGeometries") || exit $?
    echo "$geometry"
}

stop_recording() {
    if pgrep ffplay > /dev/null; then
        pkill ffplay > /dev/null
    fi
    if pgrep wf-recorder > /dev/null; then
        pkill wf-recorder > /dev/null
    fi
}

{
    if [ "$1" == "stop" ]; then
        stop_recording
        notify-send -t 2000 "Wayland recording has been stopped"
    elif [ "$1" == "show-state" ]; then
        if pgrep wf-recorder > /dev/null && pgrep ffplay > /dev/null; then
            notify-send -t 2000 "Wayland recording is up"
        else
            notify-send -t 2000 "No Wayland recording"
        fi
    elif [ "$1" == "is-recording" ]; then
        if pgrep wf-recorder > /dev/null && pgrep ffplay > /dev/null; then
            true
        else
            false
        fi
    elif [ "$1" == "start" ]; then
        VIDEO_DEVICE="/dev/video0"
        if ! pgrep wf-recorder > /dev/null; then
            geometry=$(geometry) || exit $?
            wf-recorder -g "$geometry" --muxer=v4l2 --codec=mjpeg_vaapi -d /dev/dri/renderD128 --file="$VIDEO_DEVICE" &
        fi
        if pgrep wf-recorder > /dev/null; then
            notify-send -t 2000 "Wayland recording has been started"
        else
            stop_recording
            notify-send -t 2000 "Failed to start wayland recording!"
        fi
    else
        cat << EOF
Usage:
$0 start
$0 stop
$0 is-recording
$0 show-state
EOF
    fi
}
