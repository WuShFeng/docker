#!/bin/bash
export DISPLAY=:0
pkill -9 Xorg \
    openbox \
    x11vnc \
    pulseaudio \
    ffmpeg \
    websockify \
    nginx \
    2>/dev/null || true
mkdir -p /tmp/pulse "$XDG_RUNTIME_DIR"
chmod 777 /tmp/pulse
chmod 700 "$XDG_RUNTIME_DIR"
rm -rf ${XDG_RUNTIME_DIR:-}/pulse
nohup Xorg $DISPLAY -config /etc/X11/xorg.conf.d/Xheadless.conf \
    -nolisten tcp -background none \
    > /dev/null 2>&1 &
sleep 1
nohup openbox \
    > /dev/null 2>&1 &
nohup x11vnc -display $DISPLAY -nopw -rfbport 5900 -forever -shared -ncache -noshm \
    > /dev/null 2>&1 &
pulseaudio \
    --daemonize=yes \
    --exit-idle-time=-1 \
    --disallow-exit \
    --log-level=info \
    --load="module-native-protocol-unix socket=/tmp/pulse/native auth-anonymous=1" \
    --load="module-null-sink sink_name=VirtualSink"
for i in {1..10}; do
    [ -S /tmp/pulse/native ] && break
    sleep 0.3
done
nohup ffmpeg \
    -f pulse -i VirtualSink.monitor \
    -c:a libopus -ar 48000 -ac 2 -b:a 128k \
    -f rtsp rtsp://mediamtx:8554/audio \
    > /dev/null 2>&1 &
nohup websockify 6000 localhost:5900 \
    > /dev/null 2>&1 &
sudo nginx