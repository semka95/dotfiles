#!/bin/bash

icon=""
tooltip=""

checkIfRunning() {
    if pgrep -x gammastep >/dev/null 2>&1
    then
        icon="󰛩"
        tooltip="Gammastep is ON"
    else
        icon="󰌶"
        tooltip="Gammastep is OFF"
    fi
}

changeModeToggle() {
  checkIfRunning
  if [ "$tooltip" == "Gammastep is ON" ]
  then
    icon="󰌶"
    tooltip="Gammastep is OFF"
    # If you want to activate fade=1 in gammastep config, you have to add --wait flag to
    # killall, without this flag icon/tooltip will not refresh when you turning off gammastep.
    # It happens because when fade is activated, gammastep will not be killed immediately, it takes
    # about 5 seconds to finish fade animation, and all this time gammastep is stil considered running.
    # As I understand, exec script runs after on-click script. And this exec script gets information
    # that gammastep is on, and it it displays it, while gammastep is turning off, so it looks like
    # tooltip/icon is not updated. So if you will add --wait flag, tooltip/icon will not update
    # immediately, only after about 5 seconds, after fade animation finishes.
    killall -q gammastep
    pkill -SIGRTMIN+12 waybar
  else
    icon="󰛩"
    tooltip="Gammastep is ON"
    gammastep &
    pkill -SIGRTMIN+12 waybar
  fi
}

case $1 in
toggle)
    changeModeToggle
    ;;
*)
    checkIfRunning
    ;;
esac

echo -e "{\"text\":\""$icon"\", \"tooltip\":\""$tooltip"\"}"