NAME= rot-cc
SRC= rot-cc

CCFLAGS := $(CCFLAGS) -DNODPRINTF #-DFAULTINJECTION

TX_RUNTIME_FLAGS := $(TX_RUNTIME_FLAGS) -D THRESHOLD=5000

# LIBS := -pthread $(LIBS)

TX_PASS_FLAGS := $(TX_PASS_FLAGS) -called-from-outside=thread_func

include ../../Makefile.$(ACTION)
