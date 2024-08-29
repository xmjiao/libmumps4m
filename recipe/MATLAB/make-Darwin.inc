# make.inc for Mac with x86_64 or arm64 version of MATLAB.
# We assume matlab, mex, and gfortran are in the path.

SYSTEM       = Darwin
ARCH         = $(shell uname -m)

# Detect architecture and set MACHINE and MATLABROOT accordingly
ifeq ($(ARCH), x86_64)
    MACHINE      = x86_64
    MATLABROOT  := $(shell dirname $(shell dirname `which matlab`))
    LIBFORT      = -L$(shell dirname $(shell dirname `which gfortran`))/lib -lgfortran -L$(MATLABROOT)/sys/os/maci64 -liomp5
else ifeq ($(ARCH), arm64)
    MACHINE      = arm64
    MATLABROOT  := $(shell dirname $(shell dirname `which matlab`))
    LIBFORT      = -L$(shell dirname $(shell dirname `which gfortran`))/lib -lgfortran -L$(MATLABROOT)/bin/maca64 -lomp
else
    $(error Unsupported architecture: $(ARCH))
endif

MEX          = mex

# Main MUMPS_DIR
topdir = ..
install_libdir = $(topdir)/../lib/$(SYSTEM)-$(MACHINE)
install_incdir = $(topdir)/../include

MUMPS_DIR = $(topdir)/..

# Orderings (see main Makefile.inc file from MUMPS)
LMETIS     = -L$(install_libdir) -lmetis
LPORD      = -L$(install_libdir) -lpord
LORDERINGS = $(LPORD) $(LMETIS)

# OpenBLAS library
LIBBLAS = -L$(install_libdir) -lopenblas LDFLAGS='-Wl,-no_compact_unwind $$LDFLAGS'

# extra options passed via mex command
OPTC    = -g -I$(install_incdir) -I$(topdir)/include
