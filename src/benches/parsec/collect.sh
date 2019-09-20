#!/bin/bash

#==============================================================================#
# collect main *.0.4.opt.bc files from Parsec builds
#==============================================================================#

set -x #echo on

PARSECPATH=${HOME}/bin/benchmarks/parsec-3.0
LLVMBENCHPATH=.
CONFIG=amd64-linux.clang

mkdir -p ${LLVMBENCHPATH}/blackscholes/obj/
mkdir -p ${LLVMBENCHPATH}/ferret/obj/
mkdir -p ${LLVMBENCHPATH}/swaptions/obj/
mkdir -p ${LLVMBENCHPATH}/vips/obj/
mkdir -p ${LLVMBENCHPATH}/x264/obj/
mkdir -p ${LLVMBENCHPATH}/canneal/obj/
mkdir -p ${LLVMBENCHPATH}/streamcluster/obj/
mkdir -p ${LLVMBENCHPATH}/dedup/obj/

cp ${PARSECPATH}/pkgs/apps/blackscholes/obj/${CONFIG}/blackscholes.0.4.opt.bc ${LLVMBENCHPATH}/blackscholes/obj/blackscholes.opt.bc

cp ${PARSECPATH}/pkgs/apps/ferret/obj/${CONFIG}/parsec/bin/ferret-pthreads.0.4.opt.bc ${LLVMBENCHPATH}/ferret/obj/ferret-pthreads.opt.bc

cp ${PARSECPATH}/pkgs/apps/swaptions/obj/${CONFIG}/swaptions.0.4.opt.bc ${LLVMBENCHPATH}/swaptions/obj/swaptions.opt.bc

cp ${PARSECPATH}/pkgs/apps/vips/obj/${CONFIG}/tools/iofuncs/vips.0.4.opt.bc ${LLVMBENCHPATH}/vips/obj/vips.opt.bc

cp ${PARSECPATH}/pkgs/apps/x264/obj/${CONFIG}/x264.0.4.opt.bc ${LLVMBENCHPATH}/x264/obj/x264.opt.bc

cp ${PARSECPATH}/pkgs/kernels/canneal/obj/${CONFIG}/canneal.0.4.opt.bc ${LLVMBENCHPATH}/canneal/obj/canneal.opt.bc

cp ${PARSECPATH}/pkgs/kernels/streamcluster/obj/${CONFIG}/streamcluster.0.4.opt.bc ${LLVMBENCHPATH}/streamcluster/obj/streamcluster.opt.bc

cp ${PARSECPATH}/pkgs/kernels/dedup/obj/${CONFIG}/dedup.0.4.opt.bc ${LLVMBENCHPATH}/dedup/obj/dedup.opt.bc
