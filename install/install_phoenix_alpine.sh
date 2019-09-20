#!/usr/bin/env bash

apk update
apk add mercurial wget

mkdir -p /root/bin/benchmarks/
cd /root/bin/benchmarks/
hg clone https://bitbucket.org/dimakuv/phoenix-pthreads  # TODO: change to github
cd phoenix-pthreads

export HOME='/root'
make CONFIG=clang

cd ${HAFT}src/benches/phoenix_pthread
./copyinputs.sh
./collect.sh
