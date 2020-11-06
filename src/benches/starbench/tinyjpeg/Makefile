NAME= tinyjpeg
SRC= tinyjpeg

CCFLAGS := $(CCFLAGS) -DNODPRINTF #-DFAULTINJECTION

TX_RUNTIME_FLAGS := $(TX_RUNTIME_FLAGS) -D THRESHOLD=5000

# LIBS := -pthread $(LIBS)

TX_PASS_FLAGS := $(TX_PASS_FLAGS) -called-from-outside=tinyjpeg_decode_thread -called-from-outside=tinyjpeg_process_huffman -called-from-outside=tinyjpeg_decode_idct -called-from-outside=tinyjpeg_color_convert

include ../../Makefile.$(ACTION)
