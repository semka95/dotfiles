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
        data=($(curl -s https://en.wttr.in/\?0qnT 2>&1))

        echo ${data[0]} | cut -f1 -d, > $cachedir/$cachefile
        echo ${data[0]} >> $cachedir/$cachefile

        echo ${data[1]} | sed -e 's/^\(.\{14\}\).*/\1/' >> $cachedir/$cachefile
        echo ${data[2]} | sed -e 's/^\(.\{14\}\).*/\1/' >> $cachedir/$cachefile
        echo ${data[3]} | sed -e 's/^\(.\{14\}\).*/\1/' >> $cachedir/$cachefile
        echo ${data[4]} | sed -e 's/^\(.\{14\}\).*/\1/' >> $cachedir/$cachefile
        echo ${data[5]} | sed -e 's/^\(.\{14\}\).*/\1/' >> $cachedir/$cachefile

        echo ${data[1]} | sed -E 's/^.{16}//' >> $cachedir/$cachefile
        echo ${data[2]} | sed -E 's/^.{16}//' >> $cachedir/$cachefile
        echo ${data[3]} | sed -E 's/^.{16}//' >> $cachedir/$cachefile
        echo ${data[4]} | sed -E 's/^.{16}//' >> $cachedir/$cachefile
        echo ${data[5]} | sed -E 's/^.{16}//' >> $cachedir/$cachefile
    fi

    weather=($(cat $cachedir/$cachefile))
} 3>$cachedir/$cachefile

# Restore IFSClear
IFS=$SAVEIFS

temperature=$(echo ${weather[8]} | sed -E 's/([[:digit:]]+)\.\./\1 to /g')
temperatureShort=$(echo ${weather[8]} | sed -E 's/(-?[0-9]+\.\.)//g')

# https://fontawesome.com/icons?s=solid&c=weather
case $(echo ${weather[7]##*,} | tr '[:upper:]' '[:lower:]') in
"clear" | "sunny")
    condition=""
    ;;
"partly cloudy")
    condition=""
    ;;
"cloudy")
    condition=""
    ;;
"overcast")
    condition=""
    ;;
"mist" | "fog" | "freezing fog")
    condition=""
    ;;
"patchy rain possible" | "patchy light drizzle" | "light drizzle" | "patchy light rain" | "light rain" | "light rain shower" | "rain")
    condition=""
    ;;
"moderate rain at times" | "moderate rain" | "heavy rain at times" | "heavy rain" | "moderate or heavy rain shower" | "torrential rain shower" | "rain shower")
    condition=""
    ;;
"patchy snow possible" | "patchy sleet possible" | "patchy freezing drizzle possible" | "freezing drizzle" | "heavy freezing drizzle" | "light freezing rain" | "moderate or heavy freezing rain" | "light sleet" | "ice pellets" | "light sleet showers" | "moderate or heavy sleet showers" | "snow grains")
    condition=""
    ;;
"blowing snow" | "moderate or heavy sleet" | "patchy light snow" | "light snow" | "light snow showers")
    condition=""
    ;;
"blizzard" | "patchy moderate snow" | "moderate snow" | "patchy heavy snow" | "heavy snow" | "moderate or heavy snow with thunder" | "moderate or heavy snow showers")
    condition=""
    ;;
"thundery outbreaks possible" | "patchy light rain with thunder" | "moderate or heavy rain with thunder" | "patchy light snow with thunder")
    condition=""
    ;;
*)
    condition=""
    ;;
esac

printf -v tooltip '<tt><b>%s</b>\n\n%s  %s\n%s  %s\n%s  %s\n%s  %s\n%s  %s</tt>' "${weather[1]}" "${weather[2]}" "${weather[7]}" "${weather[3]}" "${weather[8]}" "${weather[4]}" "${weather[9]}" "${weather[5]}" "${weather[10]}" "${weather[6]}" "${weather[11]}"
tooltip=$( echo "${tooltip}" | jq -Rs )

printf '{"text":"%s %s", "alt":"%s", "tooltip":"%s"}\n' "$temperatureShort" "$condition" "${weather[0]}" "${tooltip:1:-3}"
