# standard amuse configuration include
# config.mk will be made after ./configure has run
ifeq ($(origin AMUSE_DIR), undefined)
  AMUSE_DIR := $(shell amusifier --get-amuse-dir)
endif
-include ${AMUSE_DIR}/config.mk

MPICXX ?= mpicxx

OBJ = interface.o
GPU_OBJ = interface.gpuo cuda_fastkick.o


NVCCFLAGS ?= $(NVCC_FLAGS)

all: fastkick_worker

worker_code.cc: interface.py
	$(CODE_GENERATOR) --type=c interface.py FastKickInterface -o $@

worker_code.h: interface.py
	$(CODE_GENERATOR) --type=h interface.py FastKickInterface -o $@

fastkick_worker: worker_code.cc worker_code.h $(OBJ)
	$(MPICXX) $(CXXFLAGS) $(LDFLAGS) $< $(OBJ) -o $@   $(LIBS)

fastkick_worker_gpu: worker_code.cc worker_code.h  $(GPU_OBJ)
	$(MPICXX) $(CXXFLAGS) $(LDFLAGS) $< $(GPU_OBJ) -o $@ $(CUDA_LIBS) -DGPU  $(LIBS)

interface.o: interface.cc
	$(MPICXX) $(CXXFLAGS) -c -o $@ $<

interface.gpuo: interface.cc
	$(MPICXX) $(CXXFLAGS) -c -o $@ $< -DGPU

cuda_fastkick.o: cuda_fastkick.cu
	$(NVCC) $(NVCCFLAGS) -c $< -o $@

clean:
	rm -f *.o *.gpuo *.pyc worker_code.cc worker_code.h
	rm -f fastkick_worker fastkick_worker_gpu
