weston \
    --backend=headless-backend.so \
    --xwayland \
    --width=1920 \
    --height=1080 \
    --socket=wayland-${DISPLAY#:} \
    > /tmp/weston.log 2>&1 &
Xvnc $DISPLAY \
    -SecurityTypes None \
    -geometry 1920x1080 \
    -AlwaysShared \
    -rfbport 5900 \
    > /tmp/xvnc.log 2>&1 &
websockify --web /usr/share/novnc \
    6080 localhost:5900 \
    > /tmp/novnc.log 2>&1 &

