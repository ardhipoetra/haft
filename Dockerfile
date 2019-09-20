# Dockerfile for HAFT and LLVM 10 (Sep 2019)

FROM ubuntu

LABEL authors="Dmitrii Kuvaiskii (dmitrii.kuvaiskii@tu-dresden.de), Ardhi Putra Pratama Hartono (ardhi_pp.hartono@tu-dresden.de)"

# == Basic packages ==
RUN apt-get update && \
    apt-get install -y git \
                       texinfo \
                       vim \
                       libxml2-dev \
                       cmake \
                       python \
                       gcc \
                       build-essential \
                       flex \
                       bison \
                       linux-tools-generic

# use bash not sh
RUN rm /bin/sh && \
    ln -s /bin/bash /bin/sh

# get correct perf
RUN list=( /usr/lib/linux-tools/*-generic/perf ) && \
    ln -sf ${list[-1]} /usr/bin/perf

# == LLVM & CLang ==
# prepare environment
ENV LLVM_SOURCE=/root/bin/llvm/llvm/ \
    LLVM_BUILD=/root/bin/llvm/build/ \
    CLANG_SOURCE=/root/bin/llvm/clang/ \
    COMRT_SOURCE=/root/bin/llvm/compiler-rt/ \
    ROOT_LLVM=/root/bin/llvm/ \
    GOLD_SRC=/root/bin/binutils/

RUN mkdir -p $LLVM_SOURCE $LLVM_BUILD $CLANG_SOURCE $COMRT_SOURCE

# get correct versions of sources
RUN git clone --recurse-submodule https://github.com/ardhipoetra/llvm $LLVM_SOURCE && \
    git clone --depth 1 git://sourceware.org/git/binutils-gdb.git $GOLD_SRC

# TODO:enable openmp
#    git clone http://llvm.org/git/openmp.git ${LLVM_SOURCE}projects\openmp && \

RUN mv $LLVM_SOURCE/tools/clang $ROOT_LLVM && mv $LLVM_SOURCE/projects/compiler-rt $ROOT_LLVM

RUN mkdir -p ${GOLD_SRC}/../build-gold

WORKDIR ${GOLD_SRC}/../build-gold
RUN ${GOLD_SRC}/configure --enable-gold --enable-plugins --disable-werror
RUN make -j8 all-gold && make -j8

RUN  cp gold/ld-new /usr/bin/ld && \
     cp binutils/ar /usr/bin/ar && \
     cp binutils/nm-new /usr/bin/nm-new

# build LLVM
WORKDIR $LLVM_BUILD
RUN cmake -G "Unix Makefiles" -DCMAKE_BUILD_TYPE="Release" -DLLVM_TARGETS_TO_BUILD="X86" -DLLVM_BINUTILS_INCDIR=${GOLD_SRC}/include \
          -DCMAKE_INSTALL_PREFIX=${LLVM_BUILD} -DLLVM_ENABLE_PROJECTS="clang" ../llvm && \
    make -j8 && \
    make install

RUN mkdir -p /usr/lib/bfd-plugins && cp ${LLVM_BUILD}/lib/LLVMgold.so /usr/lib/bfd-plugins

RUN mkdir -p ${COMRT_SOURCE}/build
WORKDIR ${COMRT_SOURCE}/build
RUN cmake ../ -DLLVM_CONFIG_PATH=${LLVM_BUILD}/bin/llvm-config && make -j8 && make install

# == HAFT ==
ENV HAFT=/root/code/haft/
COPY ./ ${HAFT}

RUN make -C ${HAFT}src/tx/pass && \
    make -C ${HAFT}src/tx/runtime && \
    make -C ${HAFT}src/ilr/pass && \
    \
    make -C ${HAFT}src/benches/util/libc ACTION=helper && \
    make -C ${HAFT}src/benches/util/renamer

VOLUME /data

WORKDIR /root/code/haft/

# == Environment variables ==
# number of runs in each performance experiment
ENV NUM_RUNS=1

# == Interface ==
ENTRYPOINT ["/bin/bash"]
