NAME= rotate
SRC= rotate

CCFLAGS := $(CCFLAGS)  -ffast-math -O2 -DNODPRINTF #-DFAULTINJECTION

TX_RUNTIME_FLAGS := $(TX_RUNTIME_FLAGS) -D THRESHOLD=5000

# LIBS := -pthread $(LIBS)

TX_PASS_FLAGS := $(TX_PASS_FLAGS) -called-from-outside=rethread

include ../../Makefile.$(ACTION)
