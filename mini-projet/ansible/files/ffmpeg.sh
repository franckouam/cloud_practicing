#!/bin/bash

ffmpeg -i ~/video.mp4 -c:v libx264 -preset fast -b:v 1500k -maxrate 1500k -bufsize 3000k -vf "scale=-2:720" -g 60 -c:a aac -b:a 128k -ar 44100 -f flv rtmp://127.0.0.1/live/stream
