#!/bin/bash
# first argument: name of benchmark (e.g., 'blackscholes')

LIMIT=50
BASE_RUNS=1
NUM_RUNS=50
TIMEOUT=3600

DTR_DIR=/pool/

# we want sequences [BASE_RUNS; BASE_RUNS+NUM_RUNS)
NUM_RUNS=$((10#${BASE_RUNS}+10#${NUM_RUNS}-1))

export SDE=/sde/sde64
export GDB=~/bin/binutils-gdb/gdb/gdb

echo "========== $1 =========="
echo "---- 0: prepare trace logs if necessary -----"
export FIGDBRUN=prepare
mkdir -p tmp/${FIGDBRUN}/
source $1/params.sh

mkdir -p ${DTR_DIR}/$1/

echo 0 | sudo tee /proc/sys/kernel/yama/ptrace_scope > /dev/null
if [ ! -f ${DTR_DIR}/$1/$1.tx.log ]; then
  $SDE -rtm-mode nop -debugtrace -odebugtrace ${DTR_DIR}/sde-debugtrace-out.txt -- $1/$1.tx.exe $ARGS
  grep 'INS 0x0000000000' ${DTR_DIR}/sde-debugtrace-out.txt > ${DTR_DIR}/$1/$1.tx.log
fi
if [ ! -f ${DTR_DIR}/$1/$1.haft.log ]; then
  $SDE -rtm-mode nop -debugtrace -odebugtrace ${DTR_DIR}/sde-debugtrace-out.txt -- $1/$1.haft.exe $ARGS
  grep 'INS 0x0000000000' ${DTR_DIR}/sde-debugtrace-out.txt > ${DTR_DIR}/$1/$1.haft.log
fi
rm -f ${DTR_DIR}/sde-debugtrace-out.txt

for idx in `seq -w ${BASE_RUNS} ${NUM_RUNS}`; do
  mkdir -p tmp/tsxparts/${idx}/
  mkdir -p tmp/allparts/${idx}/
done


echo "---- 1: inject into TSX-covered parts only -----"
for idx in `seq -w ${BASE_RUNS} ${NUM_RUNS}`; do
  export FIGDBRUN=tsxparts/${idx}
  GDBPORT=$((10#10000+10#${idx}))
  export FIGDBARGS=" -x --limit ${LIMIT} --timeout ${TIMEOUT} -f -o ${GDBPORT} --sde ${SDE} --gdb ${GDB} "
  ./runone.sh $1 &
done
wait


echo "---- 2: inject into all parts of benchmark, including unprotected -----"
for idx in `seq -w ${BASE_RUNS} ${NUM_RUNS}`; do
  export FIGDBRUN=allparts/${idx}
  GDBPORT=$((10#10000+10#${idx}))
  export FIGDBARGS=" --limit ${LIMIT} --timeout ${TIMEOUT} -f -o ${GDBPORT} --sde ${SDE} --gdb ${GDB} "
  ./runone.sh $1 &
done
wait


# we have NUM_RUNS as number of directories under experiment (number of runs, independently?)
# also limit -> number of fault injection, may fail. 6-digits in filename
# also timout -> timeout per program
