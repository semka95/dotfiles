#!/bin/bash

cacheFile="/tmp/covername"
coverPath="/tmp/cover"
imgUrl=$(playerctl metadata --format "{{ mpris:artUrl }}")
filePrefix="file://"

if [[ -z "$imgUrl" ]]; then
	rm -f $coverPath
	exit
fi

if [ ! -f $cacheFile ]; then
    touch $cacheFile
fi

currSong=$(playerctl metadata -p playerctld --format '{{markup_escape(artist)}} - {{markup_escape(title)}}')
if [[ -s $cacheFile && $(< $cacheFile) == "$currSong" ]]; then
    exit
fi

echo $currSong > $cacheFile

if [[ $imgUrl == http?(s)://* ]]; then
    curl -s -o $coverPath $imgUrl
    exit
fi

if [[ $imgUrl == file:///* ]]; then
    cp ${imgUrl#"$filePrefix"} $coverPath
fi