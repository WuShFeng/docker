FROM docker.io/library/archlinux:latest
WORKDIR /workspace

ENV XDG_RUNTIME_DIR=/tmp/xdg-runtime-dir
ENV DISPLAY=:0
# ENV WAYLAND_DISPLAY=wayland-0
ENV PATH="/usr/lib/ccache/bin:${PATH}"

RUN if id -u 1000 >/dev/null 2>&1; then \
        old_user=$(id -un 1000); \
        usermod -l devuser -m -d /home/devuser $old_user; \
        groupmod -n devuser $old_user; \
        chown -R devuser:devuser /home/devuser; \
    else \
        groupadd -g 1000 devuser && useradd -m -u 1000 -g devuser devuser; \
    fi && \
    mkdir -p ${XDG_RUNTIME_DIR} && \
    chown devuser:devuser ${XDG_RUNTIME_DIR}

RUN echo -e "[archlinuxcn]\nServer = https://repo.archlinuxcn.org/\$arch" >> /etc/pacman.conf && \
    echo -e "[multilib]\nInclude = /etc/pacman.d/mirrorlist" >> /etc/pacman.conf && \
    pacman -Sy --noconfirm archlinuxcn-keyring && \
    pacman-key --init && \
    pacman-key --populate archlinux archlinuxcn && \
    pacman -S --noconfirm archlinuxcn-mirrorlist-git && \
    pacman -S --noconfirm yay sudo && \
    rm -rf /var/cache/pacman/pkg/*

RUN yay -Syu --noconfirm vim nano git autoconf which bear ssh \
    sdl2_image sdl2_ttf sdl2-compat \
    # gcc
    ccache base-devel \
    # pyenv
    pyenv tk python-pipx \
    # nvm
    nvm \
    # verilator
    verilator \
    # xserver
    x11vnc xorg-server xf86-video-dummy openbox && \
    rm -rf /var/cache/pacman/pkg/* /var/cache/yay/*
COPY Xheadless.conf /etc/X11/xorg.conf.d/Xheadless.conf
COPY Xwrapper.config /etc/X11/Xwrapper.config
COPY display.sh /usr/local/bin/display
RUN echo 'PYENV_ROOT=$HOME/.pyenv' >> /etc/bash.bashrc && \
    echo 'PATH=$PYENV_ROOT/bin:$HOME/.local/bin:$PATH' >> /etc/bash.bashrc && \
    echo 'eval "$(pyenv init - bash)"' >> /etc/bash.bashrc && \
    # nvm
    echo 'export NVM_DIR="$HOME/.nvm"' >> /etc/bash.bashrc && \
    echo '[ -s /usr/share/nvm/init-nvm.sh ] && source /usr/share/nvm/init-nvm.sh' >> /etc/bash.bashrc && \
    # xserver
    git clone https://github.com/novnc/noVNC.git /usr/share/novnc --depth 1 --branch v1.6.0 && \
    ln -s vnc_lite.html /usr/share/novnc/index.html && \
    chmod a+x /usr/local/bin/display 

RUN git clone https://github.com/riscv/riscv-gnu-toolchain --depth 1 && \
    cd riscv-gnu-toolchain && \
    ./configure --prefix=/opt/riscv --enable-multilib --with-languages=c,c++ && \
    make linux -j `nproc` && \
    cd .. && rm -rf riscv-gnu-toolchain

USER devuser
RUN pipx install websockify

EXPOSE 6080
