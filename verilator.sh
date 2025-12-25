#!/bin/bash
git clone https://github.com/verilator/verilator --depth 1 --branch v5.042
cd verilator
autoconf
./configure
make -j `nproc`
make install
cd ..
rm -rf verilator