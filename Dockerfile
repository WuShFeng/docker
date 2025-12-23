FROM ubuntu:24.04
WORKDIR /workspace

ENV DEBIAN_FRONTEND=noninteractive
RUN sed -i 's@//.*archive.ubuntu.com@//mirrors.ustc.edu.cn@g' /etc/apt/sources.list && \
    sed -i 's/security.ubuntu.com/mirrors.ustc.edu.cn/g' /etc/apt/sources.list && \
    sed -i 's@//.*archive.ubuntu.com@//mirrors.ustc.edu.cn@g' /etc/apt/sources.list.d/ubuntu.sources && \
    sed -i 's/security.ubuntu.com/mirrors.ustc.edu.cn/g' /etc/apt/sources.list.d/ubuntu.sources

RUN apt-get update && \
    apt-get install -y --fix-missing git help2man perl python3 make autoconf g++ flex bison ccache \
    libgoogle-perftools-dev numactl perl-doc && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/verilator/verilator --depth 1 --branch v5.042 && \
    cd verilator && \
    autoconf && \
    ./configure && \
    make -j `nproc` && \
    make install && \
    cd .. && \
    rm -rf verilator

RUN if id -u 1000 >/dev/null 2>&1; then \
    old_user=$(id -un 1000); \
    usermod -l devuser -m -d /home/devuser $old_user; \
    chown -R 1000:1000 /home/devuser; \
    else \
    useradd -m -u 1000 devuser; \
    fi
# USER devuser
USER root
