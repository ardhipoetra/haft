NAME= h264d
SRC= h264d

CCFLAGS := $(CCFLAGS) -DNODPRINTF #-DFAULTINJECTION

TX_RUNTIME_FLAGS := $(TX_RUNTIME_FLAGS) -D THRESHOLD=1500

LIBS := -lpthread  $(LIBS)

TX_PASS_FLAGS := $(TX_PASS_FLAGS) -called-from-outside=frame_worker_thread

include ../../Makefile.$(ACTION)
