#!/bin/bash

cachedir=~/.cache/rbn
cachefile=${0##*/}-$1

if [ ! -d $cachedir ]; then
    mkdir -p $cachedir
fi

if [ ! -f $cachedir/$cachefile ]; then
    touch $cachedir/$cachefile
fi

# Save current IFS
SAVEIFS=$IFS
# Change IFS to new line.
IFS=$'\n'

{
    # locking cache file only needed if you have more than 2 monitors
    # I don't know why, but exec script in module settings executes 
    # separately for each monitor (waybar issue #662), so you have 
    # to lock cache to avoid race condition
    flock -x 3
    cacheage=$(($(date +%s) - $(stat -c '%Y' "$cachedir/$cachefile")))
    if [ $cacheage -gt 1750 ] || [ ! -s $cachedir/$cachefile ]; then
        data=($(curl -s https://en.wttr.in/$LOCATION\?0QnT 2>&1))

        echo $LOCATION_NAME > $cachedir/$cachefile

        echo ${data[0]} | sed -e 's/^\(.\{14\}\).*/\1/' | cut -c 4- >> $cachedir/$cachefile
        echo ${data[1]} | sed -e 's/^\(.\{14\}\).*/\1/' | cut -c 4- >> $cachedir/$cachefile
        echo ${data[2]} | sed -e 's/^\(.\{14\}\).*/\1/' | cut -c 4- >> $cachedir/$cachefile
        echo ${data[3]} | sed -e 's/^\(.\{14\}\).*/\1/' | cut -c 4- >> $cachedir/$cachefile
        echo ${data[4]} | sed -e 's/^\(.\{14\}\).*/\1/' | cut -c 4- >> $cachedir/$cachefile

        echo ${data[0]} | sed -E 's/^.{16}//' >> $cachedir/$cachefile
        echo ${data[1]} | sed -E 's/^.{16}//' >> $cachedir/$cachefile
        echo ${data[2]} | sed -E 's/^.{16}//' >> $cachedir/$cachefile
        echo ${data[3]} | sed -E 's/^.{16}//' >> $cachedir/$cachefile
        echo ${data[4]} | sed -E 's/^.{16}//' >> $cachedir/$cachefile
    fi

    weather=($(cat $cachedir/$cachefile))
} 3>$cachedir/$cachefile

# Restore IFSClear
IFS=$SAVEIFS

temperatureShort=$(echo ${weather[7]} | sed -E 's/(\(-?[0-9]+\)\s)//g')

# https://fontawesome.com/icons?s=solid&c=weather
case $(echo ${weather[6]%%,*} | tr '[:upper:]' '[:lower:]') in
"clear" | "sunny")
    condition="󰖙"
    ;;
"partly cloudy")
    condition="󰖕"
    ;;
"cloudy" | "overcast")
    condition="󰖐"
    ;;
"mist" | "fog" | "freezing fog" | "patches of fog" | "shallow fog")
    condition="󰖑"
    ;;
"patchy rain possible" | "drizzle" | "patchy light drizzle" | "light drizzle" | "patchy light rain" | "light rain" | "light rain shower" | "rain")
    condition="󰖗"
    ;;
"moderate rain at times" | "moderate rain" | "heavy rain at times" | "heavy rain" | "moderate or heavy rain shower" | "torrential rain shower" | "rain shower")
    condition="󰖖"
    ;;
"patchy sleet possible" | "patchy freezing drizzle possible" | "freezing drizzle" | "heavy freezing drizzle" | "freezing rain" | "light freezing rain" | "moderate or heavy freezing rain" | "light sleet" | "ice pellets" | "light sleet showers" | "moderate or heavy sleet showers" | "snow grains" | "light rain and snow" | "light snow shower")
    condition="󰼵"
    ;;
"moderate or heavy sleet" | "patchy light snow" | "light snow" | "patchy snow possible" | "light snow showers")
    condition="󰖘"
    ;;
"snow" | "low drifting snow " | "blizzard" | "patchy moderate snow" | "moderate snow" | "patchy heavy snow" | "heavy snow" | "moderate or heavy snow with thunder" | "moderate or heavy snow showers" | "blowing snow" | "snow shower" | "heave snow shower")
    condition="󰼶"
    ;;
"thundery outbreaks possible" | "patchy light rain with thunder" | "moderate or heavy rain with thunder" | "patchy light snow with thunder")
    condition="󰖓"
    ;;
*)
    condition="󰗖"
    ;;
esac

printf -v tooltip '<tt><big><b>%s</b></big>\n\n%s  <i>%s</i>\n%s  <span foreground="aqua">%s</span>\n%s  <span foreground="coral">%s</span>\n%s  %s\n%s  <span foreground="lightseagreen">%s</span></tt>' "${weather[0]}" "${weather[1]}" "${weather[6]}" "${weather[2]}" "${weather[7]}" "${weather[3]}" "${weather[8]}" "${weather[4]}" "${weather[9]}" "${weather[5]}" "${weather[10]}"
tooltip=$( echo "${tooltip}" | jq -Rs )

printf '{"text":"%s %s", "alt":"%s", "tooltip":"%s"}\n' "$temperatureShort" "$condition" "${weather[0]}" "${tooltip:1:-3}"
