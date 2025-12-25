#!/bin/bash
git clone https://gitlab.freedesktop.org/wayland/wayland.git --depth 1 --branch 1.24
cd wayland
meson build && ninja -C build install
cd .. && rm -rf wayland
git clone https://gitlab.freedesktop.org/wayland/wayland-protocols.git --depth 1 --branch 1.38
cd wayland-protocols
meson build && ninja -C build install
cd .. && rm -rf wayland-protocols
git clone https://gitlab.freedesktop.org/wayland/weston.git --depth 1 --branch 14.0
cd weston/
meson build \
    --prefix=/usr \
    --libdir=/usr/lib/x86_64-linux-gnu \
    -Dbackend-drm-screencast-vaapi=false \
    -Dsystemd=false -Dremoting=false \
    -Ddemo-clients=false \
    -Dtest-junit-xml=false \
    -Dtests=false
ninja -C build install
cd .. && rm -rf weston/

git clone https://github.com/any1/wayvnc.git --depth 1
git clone https://github.com/any1/neatvnc.git --depth 1
git clone https://github.com/any1/aml.git --depth 1
mkdir wayvnc/subprojects
cd wayvnc/subprojects
ln -s ../../neatvnc .
ln -s ../../aml .
cd - && cd wayvnc
meson build && ninja -C build install
cd - && cd neatvnc
meson build && ninja -C build install
cd - && cd aml
meson build && ninja -C build install
cd - && rm -rf wayvnc neatvnc aml

mkdir -p $XDG_RUNTIME_DIR
mkdir -p /tmp/.X11-unix
chmod 700 $XDG_RUNTIME_DIR
chmod 1777 /tmp/.X11-unix
