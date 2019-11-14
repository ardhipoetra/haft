#!/usr/bin/env bash

apk update
apk add git wget

mkdir -p /root/bin/benchmarks/
cd /root/bin/benchmarks/
git clone https://github.com/ardhipoetra/phoenix-pthreads
cd phoenix-pthreads

export HOME='/root'
make CONFIG=clang

cd ${HAFT}src/benches/phoenix_pthread
./copyinputs.sh
./collect.sh
