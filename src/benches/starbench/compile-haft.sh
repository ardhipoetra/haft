#!/bin/bash
set -x bash

declare -a benchmarks=( \
"c-ray-mt" \
"kmeans" \
"md5" \
"rgbyuv" \
"rot-cc" \
"streamcluster" \
"tinyjpeg" \
"rotate" \  
"ray-rot" 
)

declare -a typesarr=("native" "ilr" "tx" "haft")

# compiling
for bm in "${benchmarks[@]}"; do

  pushd ${bm}
  find -name "${bm}*.exe" -exec rm {} \;
  find -name "${bm}*.o" -exec rm {} ;
  rm obj/*
  cp ${bm}.bc obj/
  popd

  for type in "${typesarr[@]}"; do
    make -C ${bm} ACTION=${type} clean
    make -C ${bm} ACTION=${type} object
    make -C ${bm} ACTION=${type}
  done
  find -name "${bm}*.o" -exec cp {} /data/star_obj \;
done
