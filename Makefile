####################
# User-set variables
####################

FC=mpifort
# Hypre include directory
HYPRE_DIR ?= ./hypre/src/hypre
# C++ compiler (user must set this)
CPP_COMPILE = mpic++
# LibPFASST directory
LIBPFASST ?= ../LibPFASST/

MKVERBOSE=TRUE

CPP_SRC_DIR=src/

CPP_FILES = \
        $(CPP_SRC_DIR)global_fortran_state.cpp \
        $(CPP_SRC_DIR)hypre_struct.cpp \
        $(CPP_SRC_DIR)hypre_vector.cpp \
        $(CPP_SRC_DIR)hypre_solver.cpp \
        $(CPP_SRC_DIR)hypre_fortran.cpp

CPP_INCLUDE = \
	-I./include \
	-I$(HYPRE_DIR)/include \
	-I$(DYNOMPI_DIR)

BUILDDIR = build

EXE = main.exe

# Must use Makefile.defaults included in this repo
#include $(LIBPFASST)/Makefile.defaults

FSRC = src/global_state.f90 src/comm.f90 src/encap.f90 src/level.f90 src/probin.f90 src/sweeper.f90 src/hooks.f90 src/pfasst_hypre.f90 src/main.f90
CSRC = src/global_fortran_state.cpp src/hypre_struct.cpp src/hypre_vector.cpp src/hypre_solver.cpp src/hypre_fortran.cpp

OBJ  = $(subst src, build,$(FSRC:.f90=.o))
OBJ += $(subst src, build,$(CSRC:.cpp=.o))

LDFLAGS += $(shell mpic++ --showme:link) $(HYPRE_DIR)/lib/libHYPRE.so -lmpi -lstdc++

FFLAGS  += -I$(LIBPFASST)/include -I$(DYNOMPI_DIR)/include -ffree-line-length-512 -cpp -g

all: hypre_cpp $(EXE)

hypre_cpp:
	mkdir -p build
	$(CPP_COMPILE) -v -Wno-error -c $(CPP_FILES) $(CPP_INCLUDE) $(CPPFLAGS)
	mv $(subst src, .,$(CPP_FILES:.cpp=.o)) build/

VPATHS = src

include Makefile.rules

#include .depend
main.exe : $(LIBPFASST)/lib/libpfasst.a
