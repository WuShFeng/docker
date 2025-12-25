apt-get update
apt-get install -y --fix-missing \
    novnc websockify xorg openbox libvncserver-dev xserver-xorg-video-dummy libxtst-dev

git clone https://github.com/LibVNC/x11vnc.git --depth 1 --branch 0.9.17
cd x11vnc
./autogen.sh
./configure
make install -j `nproc`
cd .. && rm -rf x11vnc

apt-get clean
rm -rf /var/lib/apt/lists/* /tmp/*
