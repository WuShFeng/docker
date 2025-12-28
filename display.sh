#!/bin/bash
export DISPLAY=:0
pkill -9 Xorg
pkill -9 openbox
pkill -9 x11vnc
pkill -9 pulseaudio
pkill -9 ffmpeg
pkill -9 websockify
nohup Xorg $DISPLAY -config /etc/X11/xorg.conf.d/Xheadless.conf \
    -nolisten tcp -background none \
    > /tmp/xorg.log 2>&1 &
nohup openbox \
    > /tmp/openbox.log 2>&1 &
# weston \
#     --backend=x11-backend.so \
#     --xwayland \
#     --width=1920 \
#     --height=1080 \
#     --socket=${WAYLAND_DISPLAY} \
#     > /tmp/weston.log 2>&1 &
# Xvnc $DISPLAY \
#     -SecurityTypes None \
#     -AlwaysShared \
#     -rfbport 5900 \
#     > /tmp/xvnc.log 2>&1 &
nohup x11vnc -display $DISPLAY -nopw -rfbport 5900 -forever -shared -ncache -noshm > /tmp/x11vnc.log 2>&1 &
nohup pulseaudio --start --exit-idle-time=-1 > /tmp/pulseaudio.log 2>&1 &
nohup pactl load-module module-null-sink sink_name=VirtualSink > /tmp/pactl.log 2>&1 &
nohup ffmpeg -f pulse -i VirtualSink.monitor -c:a libopus -ar 48000 -ac 2 -b:a 128k \
    -f rtsp rtsp://mediamtx:8554/audio \
    > /dev/null 2>&1 &
# nohup parec -d VirtualSink.monitor | \
#     ffmpeg -f s16le -ar 44100 -ac 2 -i - \
#     -c:a aac -b:a 128k \
#     -f hls \
#     -hls_time 1 \
#     -hls_list_size 3 \
#     -hls_flags delete_segments+append_list \
#     /usr/share/novnc/audio/audio.m3u8 > /tmp/ffmpeg.log 2>&1 &

nohup websockify 6000 \
    localhost:5900 \
    > /tmp/novnc.log 2>&1 &
