#!/bin/bash

NAME=screencast-$(date +%Y%m%d%H%M)
FPS=4
THREADS=3

echo "Click the window to capture and get ready!"

tmpfile=/tmp/screengrab.tmp.$$
trap 'touch $tmpfile; rm -f $tmpfile' 0

xwininfo > $tmpfile 2>/dev/null
left=$(grep 'Absolute upper-left X:' $tmpfile | awk '{print $4}');
top=$(grep 'Absolute upper-left Y:' $tmpfile | awk '{print $4}');
width=$(grep 'Width:' $tmpfile | awk '{print $2}');
height=$(grep 'Height:' $tmpfile | awk '{print $2}');
geom="-geometry ${width}x${height}+${left}+${top}"
echo "Geometry: ${geom}"
size="${width}x${height}"
pos="${left},${top}"
echo "pos=$pos size=$size"

sleep 2
ffmpeg -y -f alsa -ac 2 -i pulse -f x11grab -r $FPS -s $size -i ${DISPLAY-0:0}+${pos} -acodec pcm_s16le $NAME-temp.wav -an -vcodec libx264 -preset ultrafast -threads 0 $NAME-temp.mp4

echo Merge audio+video and encode to webm for YouTube? && read

ffmpeg -i $NAME-temp.mp4 -i $NAME-temp.wav -acodec libvorbis -ab 128k -ac 2 -vcodec libvpx -qscale 8 -me_method full -mbd rd -flags +gmc+qpel+mv4 -trellis 1 -threads $THREADS $NAME.webm
