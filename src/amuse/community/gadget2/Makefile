# standard amuse configuration include
# config.mk will be made after ./configure has run
ifeq ($(origin AMUSE_DIR), undefined)
  AMUSE_DIR := $(shell amusifier --get-amuse-dir)
endif
-include ${AMUSE_DIR}/config.mk

MPICXX ?= mpicxx

SRCDIR		= src

TARGETS := $(patsubst makefile_options_%, gadget2_worker_%, ${shell ls makefile_options_*})

BUILDDIR = build


#PROFLIBS ?= -L$(AMUSE_DIR)/lib/ibis/src/profiling -libisprofiling -lmpi

ifneq ($(MAKEFILE_OPTIONS_FILE), )
include $(MAKEFILE_OPTIONS_FILE)
endif

GSL_FLAGS ?= $(shell gsl-config --cflags)
GSL_LIBS ?= $(shell gsl-config --libs)
GSL_INCL = $(GSL_FLAGS)

ifeq ($(MPI_ENABLED),yes)
AM_LIBS = -L$(AMUSE_DIR)/lib/amuse_mpi -lamuse_mpi
AM_CFLAGS = -I$(AMUSE_DIR)/lib/amuse_mpi
endif

LIBFILES = $(SRCDIR)/run.c  $(SRCDIR)/predict.c  $(SRCDIR)/begrun.c \
	$(SRCDIR)/endrun.c  $(SRCDIR)/global.c  \
	$(SRCDIR)/init.c  $(SRCDIR)/restart.c  $(SRCDIR)/io.c  \
	$(SRCDIR)/accel.c  $(SRCDIR)/read_ic.c  $(SRCDIR)/ngb.c  \
	$(SRCDIR)/system.c  $(SRCDIR)/allocate.c  $(SRCDIR)/density.c  \
	$(SRCDIR)/gravtree.c  $(SRCDIR)/hydra.c  $(SRCDIR)/driftfac.c  \
	$(SRCDIR)/domain.c  $(SRCDIR)/allvars.c  $(SRCDIR)/potential.c  \
	$(SRCDIR)/forcetree.c  $(SRCDIR)/peano.c  $(SRCDIR)/gravtree_forcetest.c  \
	$(SRCDIR)/pm_periodic.c  $(SRCDIR)/pm_nonperiodic.c  $(SRCDIR)/longrange.c  \
	$(SRCDIR)/density_at_pos.c \
	$(SRCDIR)/timestep_limit.c  $(SRCDIR)/sigvel.c
#  ^^^ Durier & Dalla Vecchia timestepping fix ^^^

#	$(SRCDIR)/timestep.c
#  ^^^ original timestepping ^^^

.SECONDARY:

.PHONY: all 

gadget2_worker: ${TARGETS}

${TARGETS}: gadget2_worker_%: worker_code.cc interface_%.o $(BUILDDIR)_%/libgadget.a $(BUILDDIR)_%/allvars.o
	$(MPICXX) $(CXXFLAGS) $(SC_FLAGS) $(GSL_FLAGS) $(LDFLAGS) -o $@ $^ $(SC_MPI_CLIBS) $(GSL_LIBS) $(AM_LIBS) $(LIBS)
 
$(BUILDDIR)_%:
	-mkdir $@

$(BUILDDIR)_%/Makefile: $(SRCDIR)/Makefile | $(BUILDDIR)_%
	cp $(SRCDIR)/Makefile $@

$(BUILDDIR)_%/makefile_options: makefile_options_% | $(BUILDDIR)_%
	cp makefile_options_$* $@

$(BUILDDIR)_%/libgadget.a: $(BUILDDIR)_%/Makefile $(BUILDDIR)_%/makefile_options
	make -C $(BUILDDIR)_$* all VPATH=../src

$(BUILDDIR)_%/allvars.o: $(BUILDDIR)_%/libgadget.a ;

interface_%.o:  interface.cc makefile_options_%  worker_code.h
ifeq ($(MAKEFILE_OPTIONS_FILE), )
	make -C . $@ MAKEFILE_OPTIONS_FILE=makefile_options_$*
else
	$(MPICXX) $(CXXFLAGS) -DTOOLBOX $(OPT) $(SC_FLAGS) $(AM_CFLAGS)  $(GSL_FLAGS) -c -o $@ $< 
endif

clean:
	-rm -f *.o worker_code.cc worker_code.h
	-rm -f gadget2_worker* gadget2_worker_*.exe
	-rm -rf *.dSYM
	-rm -Rf build_*
	-rm -Rf build
    
worker_code.cc: interface.py worker_code.h
	$(CODE_GENERATOR) --type=c $< Gadget2Interface -o $@ 

worker_code.h: interface.py
	$(CODE_GENERATOR) --type=h $< -i amuse.community.interface.stopping_conditions.StoppingConditionInterface Gadget2Interface -o $@

