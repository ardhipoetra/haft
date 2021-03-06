#!/bin/bash

#==============================================================================#
# download inputs and move them into corresponding dirs
#==============================================================================#

set -x #echo on

declare -a benchmarks=("histogram" "linear_regression" "string_match" "word_count")

for bmidx in "${!benchmarks[@]}"; do
  bm="${benchmarks[$bmidx]}"

  wget -nc http://csl.stanford.edu/~christos/data/${bm}.tar.gz
  tar -xzf ${bm}.tar.gz
  mkdir -p ${bm}/input/

  #in linux
  #mv -uf ${bm}_datafiles/* ${bm}/input/

  #in alpine :
  mv -f ${bm}_datafiles/* ${bm}/input/
  
  rm -rf ${bm}_datafiles/
done
