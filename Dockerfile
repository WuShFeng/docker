FROM ubuntu:24.04
WORKDIR /workspace

ENV DEBIAN_FRONTEND=noninteractive
ENV XDG_RUNTIME_DIR=/tmp/xdg-runtime-dir
ENV DISPLAY=:0
# ENV WAYLAND_DISPLAY=wayland-0

RUN sed -i 's@//.*archive.ubuntu.com@//mirrors.ustc.edu.cn@g' /etc/apt/sources.list && \
    sed -i 's/security.ubuntu.com/mirrors.ustc.edu.cn/g' /etc/apt/sources.list && \
    sed -i 's@//.*archive.ubuntu.com@//mirrors.ustc.edu.cn@g' /etc/apt/sources.list.d/ubuntu.sources && \
    sed -i 's/security.ubuntu.com/mirrors.ustc.edu.cn/g' /etc/apt/sources.list.d/ubuntu.sources

RUN apt-get update && \
    apt-get install -y --fix-missing\
    git help2man perl python3 make autoconf g++ flex bison ccache vim lsof cmake\
    libgoogle-perftools-dev numactl perl-doc bear libsdl2-dev libsdl2-image-dev libsdl2-ttf-dev \
    pkg-config meson ninja-build\
    && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/*

COPY verilator.sh ./
RUN chmod +x verilator.sh && ./verilator.sh

COPY xorg.sh ./
COPY xorg.conf /etc/X11/xorg.conf.d/10-headless.conf
RUN chmod +x xorg.sh && ./xorg.sh

# COPY weston.sh ./
# RUN chmod +x weston.sh && ./weston.sh

RUN rm -rf ./* ./.[!.]* ./..?* 
RUN if id -u 1000 >/dev/null 2>&1; then \
    old_user=$(id -un 1000); \
    usermod -l devuser -m -d /home/devuser $old_user; \
    chown -R 1000:1000 /home/devuser; \
    else \
    useradd -m -u 1000 devuser; \
    fi
EXPOSE 6080
