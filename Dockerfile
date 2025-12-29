FROM docker.io/wushf/riscv-gnu-toolchain:2025.12.7 AS riscv-gnu-toolchain
FROM docker.io/library/archlinux:latest
WORKDIR /workspace

ENV XDG_RUNTIME_DIR=/tmp/xdg-runtime-dir
ENV PULSE_SERVER=unix:/tmp/pulse/native
ENV DISPLAY=:0
# ENV WAYLAND_DISPLAY=wayland-0
ENV PATH="/usr/lib/ccache/bin:/opt/riscv/bin:${PATH}"
RUN if id -u 1000 >/dev/null 2>&1; then \
        old_user=$(id -un 1000); \
        usermod -l devuser -m -d /home/devuser $old_user; \
        groupmod -n devuser $old_user; \
        chown -R devuser:devuser /home/devuser; \
    else \
        groupadd -g 1000 devuser && useradd -m -u 1000 -g devuser devuser; \
    fi

RUN echo -e "[archlinuxcn]\nServer = https://repo.archlinuxcn.org/\$arch" >> /etc/pacman.conf && \
    echo -e "[multilib]\nInclude = /etc/pacman.d/mirrorlist" >> /etc/pacman.conf && \
    pacman -Sy --noconfirm archlinuxcn-keyring && \
    pacman-key --init && \
    pacman-key --populate archlinux archlinuxcn && \
    pacman -S --noconfirm archlinuxcn-mirrorlist-git && \
    pacman -S --noconfirm yay sudo && \
    yay -Syu --noconfirm vim nano git autoconf which bear openssh lsof \
    sdl2_image sdl2_ttf sdl2-compat go \
    # gcc
    ccache base-devel \
    # pyenv
    pyenv tk python-pipx \
    # nvm
    nvm \
    # verilator
    verilator \
    # xserver
    x11vnc xorg-server xf86-video-dummy openbox ttf-dejavu ttf-liberation\
    # audio
    pulseaudio ffmpeg nginx \
    && rm -rf /var/cache/pacman/pkg/* /var/cache/yay/*

COPY Xheadless.conf /etc/X11/xorg.conf.d/Xheadless.conf
COPY Xwrapper.config /etc/X11/Xwrapper.config
COPY display.sh /usr/local/bin/display
COPY --from=riscv-gnu-toolchain /opt/riscv /opt/riscv
COPY nginx.conf /etc/nginx/nginx.conf
COPY noVNC /usr/share/novnc
RUN echo 'PYENV_ROOT=$HOME/.pyenv' >> /etc/bash.bashrc && \
    echo 'PATH=$PYENV_ROOT/bin:$HOME/.local/bin:$PATH' >> /etc/bash.bashrc && \
    echo 'eval "$(pyenv init - bash)"' >> /etc/bash.bashrc
RUN echo 'export NVM_DIR="$HOME/.nvm"' >> /etc/bash.bashrc && \
    echo '[ -s /usr/share/nvm/init-nvm.sh ] && source /usr/share/nvm/init-nvm.sh' >> /etc/bash.bashrc
RUN chmod a+x /usr/local/bin/display
RUN cd /opt/riscv/bin && \
    for f in riscv64-unknown-linux-gnu-*; do \
        linkname="${f/-unknown/}"; \
        ln -s "$f" "$linkname"; \
    done && \
    cd -
RUN echo 'devuser ALL=(ALL) NOPASSWD: /usr/sbin/nginx' >> /etc/sudoers
USER devuser
RUN pipx install websockify
RUN mkdir -p /tmp/pulse ${XDG_RUNTIME_DIR} && \
    chmod 777 /tmp/pulse && \
    chmod 700 ${XDG_RUNTIME_DIR}

EXPOSE 6080
