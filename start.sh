Xorg $DISPLAY -config /etc/X11/xorg.conf.d/10-headless.conf \
    -nolisten tcp -background none \
    > /tmp/xorg.log 2>&1 &
openbox \
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
x11vnc -display $DISPLAY -nopw -rfbport 5900 -forever -shared > /tmp/x11vnc.log 2>&1 &
websockify --web /usr/share/novnc \
    6080 localhost:5900 \
    > /tmp/novnc.log 2>&1 &

