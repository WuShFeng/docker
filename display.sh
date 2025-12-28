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
    > /dev/null 2>&1 &
nohup openbox \
    > /dev/null 2>&1 &
nohup x11vnc -display $DISPLAY -nopw -rfbport 5900 -forever -shared -ncache -noshm \
    > /dev/null 2>&1 &
pulseaudio \
    --daemonize=yes \
    --exit-idle-time=-1 \
    --disallow-exit \
    --log-level=info \
    --load="module-native-protocol-unix socket=$PULSE_SERVER auth-anonymous=1" \
    --load="module-null-sink sink_name=VirtualSink"

nohup ffmpeg -f pulse -i VirtualSink.monitor -c:a libopus -ar 48000 -ac 2 -b:a 128k \
    -f rtsp rtsp://mediamtx:8554/audio \
    > /dev/null 2>&1 &
nohup websockify 6000 \
    localhost:5900 \
    > /tmp/novnc.log 2>&1 &
