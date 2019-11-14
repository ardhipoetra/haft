# HAFT (Hardware Assisted Fault Tolerance) on SCONE

HAFT is a compiler framework that transforms unmodified multithreaded applications to support fault detection via instruction-level replication (ILR) and fault recovery via hardware transactional memory (HTM, in our case Intel TSX). See [HAFT paper](link) for details.

## Docker
### Object preparation

* Please build a new docker image locally:

```sh
make build   # creates haft-alpine image
```

As we also compile LLVM, it will take time (and resource). At this point, we include phoenix benchmark to be compiled into LLVM IR.

* To run the docker image, use:

```sh
make run   # runs haft_alpine container
```

* In docker, to compile the LLVM IR into necessary objects:

```sh
./src/benches/phoenix_pthread/generate.sh
```
It will also copies the generated object to `./data/objects/`. You can exit the container.

### Running HAFT-ed program on SCONE

First of all, make sure that you are: 
1. able to get `sconecuratedimages/apps:pypy2-fork` image. 
2. put the object of the program we want to run is available on `./data/objects`. It is generated on previous phase.
3. (optional) get custom SCONE loader to able to run `perf` on programs

Most of the benchmarks need arguments to run. Please consult [this file](https://github.com/ardhipoetra/haft/blob/master/src/benches/phoenix_pthread/run.sh "this file") to see what kind of argument a particular program needs. In this example, we will use `histogram` program.

- Run the pypy2-fork container such as 
```sh
docker run --privileged --cap-add SYS_ADMIN --cap-add=SYS_PTRACE --security-opt seccomp=unconfined -it -v `pwd`/data:/data sconecuratedimages/apps:pypy2-fork
```

- Inside the container, compile objects residing in `/data/objects`
```sh
gcc /data/objects/histogram.haft.o -o /root/histogram.haft.exe
```

- Run the application with the correct arguments. All the necessary inputs should be in `/data/input/`. For example : 
```sh
/root/histogram.haft.exe /data/input/small.bmp
```

- To run on SCONE, simply add necessary environment variables such as : 
```sh
SCONE_VERSION=1 SCONE_ALPINE=1 /root/histogram.haft.exe /data/input/small.bmp
```

#### Measuring performance
- Put custom SCONE loader to `/data` so you can access that from inside the container
- Install perf : 
```sh
apk add linux-tools --repository=http://dl-cdn.alpinelinux.org/alpine/edge/testing
```
- Run with custom loader. You can omit the environment variables : 
```sh
perf stat -B /data/ld-scone-x86_64.so.1 /root/histogram.haft.exe /data/input/small.bmp
```

The output should be something like this : 
```
export SCONE_QUEUES=4
export SCONE_SLOTS=256
export SCONE_SIGPIPE=0
export SCONE_MMAP32BIT=0
export SCONE_SSPINS=100
export SCONE_SSLEEP=4000
export SCONE_LOG=1
export SCONE_HEAP=536870912
export SCONE_STACK=8388608
export SCONE_CONFIG=/etc/sgx-musl.conf
export SCONE_ESPINS=10000
export SCONE_MODE=hw
export SCONE_ALLOW_DLOPEN=no
export SCONE_MPROTECT=no
musl version: 1.1.20
Revision: 66f32ef6f7029c575a9c6cf3d29bba1569d5db55 (Thu May 30 17:56:09 2019 +0200)
Branch: pamenas-fork-new-master

Enclave hash: 70704e46e7a4807da1de5230d1f46f0bc205c4ec38b94da4f3031ae9cf735af8
This file has 104530176 bytes of image data, 34843392 pixels
Starting pthreads histogram

 Performance counter stats for '/data/ld-scone-x86_64.so.1 /root/histogram.haft.exe /data/input/small.bmp':                                                                                                

       2522.604450      task-clock (msec)         #    1.177 CPUs utilized
              2738      context-switches          #    0.001 M/sec
               108      cpu-migrations            #    0.043 K/sec
             12336      page-faults               #    0.005 M/sec
        8886846944      cycles                    #    3.523 GHz
        4130442465      instructions              #    0.46  insn per cycle
         639007777      branches                  #  253.313 M/sec
           2471673      branch-misses             #    0.39% of all branches

       2.143024756 seconds time elapsed

       0.686717000 seconds user
       1.844553000 seconds sys
```
