#!/bin/bash

# Note: We assume gfortran and gdown are installed using `anaconda`.
# If not, install it using `conda -c conda-forge install gdown`

set -e

# Detect architecture
ARCH=$(uname -m)

if [ "$ARCH" == "x86_64" ]; then
    export MACHINE="x86_64"
elif [ "$ARCH" == "arm64" ]; then
    export MACHINE="arm64"
else
    echo "Unsupported architecture: $ARCH"
    exit 1
fi

export SYSTEM=$(uname -s | cut -d'_' -f1)
export MUMPS_VERSION=5.5.1
export MUMPS_MAJOR_VERSION=$(echo ${MUMPS_VERSION} | cut -d'.' -f1)
MUMPS_FILEID=1_ewOpU2tLaN6NEvJ8s2EFbMTjFISF3_v

OPENBLAS_VERSION=0.3.21
METIS_VERSION=5.1.0

MAKE=$([ "${SYSTEM}" = 'MINGW64' ] && echo 'mingw32-make' || echo 'make')
PREFIX=$(cd $(dirname "${BASH_SOURCE:-$0}") && pwd)

# Initialize ARCH_CMD to empty string if not set
ARCH_CMD="${ARCH_CMD:-}"

# Check for maci64 or maca64 subdirectories in the folder containing matlab
if [ "${SYSTEM}" = 'Darwin' -a -z "${ARCH_CMD}" ]; then
    MATLAB_PATH=$(which matlab)
    if [ -n "$MATLAB_PATH" ]; then
        MATLAB_DIR=$(dirname "$MATLAB_PATH")
        if [ -d "$MATLAB_DIR/maci64" ]; then
            MATLAB_ARCH="x86_64"
        elif [ -d "$MATLAB_DIR/maca64" ]; then
            MATLAB_ARCH="arm64"
        else
            echo "Error: Unable to determine MATLAB architecture. Please set ARCH_CMD explicitly."
            exit 1
        fi

        # Set ARCH_CMD based on MATLAB architecture
        if [ "${ARCH}" = 'arm64' ] && [ "${MATLAB_ARCH}" = 'x86_64' ]; then
            ARCH_CMD="arch -x86_64"
        fi
    else
        echo "Error: MATLAB not found in the path."
        exit 1
    fi
fi

build_openblas() {
    # Download and unpack
    rm -rf OpenBLAS-${OPENBLAS_VERSION}
    curl -L https://github.com/xianyi/OpenBLAS/archive/v${OPENBLAS_VERSION}.tar.gz | tar zxf -
    cd OpenBLAS-${OPENBLAS_VERSION}

    # Build static library
    ${ARCH_CMD} ${MAKE} DYNAMIC_ARCH=1 DYNAMIC_OLDER=1 INTERFACE64=0 NO_LAPACKE=1 NO_CBLAS=1 NO_SHARED=1 USE_OPENMP=1

    # Copy static library
    mkdir -p "${PREFIX}/lib/${SYSTEM}-${MACHINE}"
    cp libopenblas*-r${OPENBLAS_VERSION}.a "${PREFIX}/lib/${SYSTEM}-${MACHINE}/libopenblas.a"
    cd $PREFIX
}

build_metis() {
    # Download and unpack
    curl -L https://github.com/xijunke/METIS-1/raw/master/metis-${METIS_VERSION}.tar.gz | tar zxf -
    cd metis-${METIS_VERSION}

    # Build METIS static library
    MACVER=$([ "${SYSTEM}" = 'Darwin' -a "$(uname -m)" = 'arm64' ] && echo 'CC=gcc CFLAGS=-mmacosx-version-min=10.15' || true)
    ${ARCH_CMD} ${MAKE} ${MACVER} config
    ${ARCH_CMD} ${MAKE}

    # Copy static library
    mkdir -p "${PREFIX}/lib/${SYSTEM}-${MACHINE}" "${PREFIX}/include"
    cp build/${SYSTEM}-${MACHINE}/libmetis/libmetis.a "${PREFIX}/lib/${SYSTEM}-${MACHINE}"
    cp include/metis.h "${PREFIX}/include"
    cd $PREFIX
}

fix_matlab() {
    # We need some fixes to MATLAB in order to get gfortran and openmp working correctly
    if [ "${SYSTEM}" = 'Darwin' -a "${MACHINE}" = 'x86_64' ]; then
        MATLABROOT=$(dirname $(dirname $(which matlab)))
        [ -f "$MATLABROOT/sys/os/maci64/libgfortran.5.dylib" ] || \
            cp lib/Darwin-x86_64/lib*.*.dylib $MATLABROOT/sys/os/maci64
        ln -s -f libiomp5.dylib $MATLABROOT/sys/os/maci64/libomp.dylib
    elif [ "${SYSTEM}" = 'Darwin' -a "${MACHINE}" = 'arm64' ]; then
        MATLABROOT=$(dirname $(dirname $(which matlab)))
        [ -f "$MATLABROOT/sys/os/maca64/libgfortran.5.dylib" ] || \
            cp lib/Darwin-${MACHINE}/lib*.*.dylib $MATLABROOT/sys/os/maca64
    fi
}

[ -f "MUMPS_${MUMPS_VERSION}.tar.gz" ] || gdown $MUMPS_FILEID

rm -rf MUMPS && mkdir MUMPS && tar xvf MUMPS_${MUMPS_VERSION}.tar.gz --strip-components=1 -C MUMPS
cp Makefile-${SYSTEM}.inc MUMPS/Makefile.inc
cp src/Makefile MUMPS/src/Makefile
cp libseq/Makefile MUMPS/libseq/Makefile
cp MATLAB/make-${SYSTEM}.inc MUMPS/MATLAB/make.inc

# Build openblas
[ -f "$PREFIX/lib/${SYSTEM}-${MACHINE}/libopenblas.a" ] || build_openblas

# Build metis
[ -f "$PREFIX/include/metis.h" -a -f "$PREFIX/lib/${SYSTEM}-${MACHINE}/libmetis.a" ] || build_metis

# Build shared objects for single-precision real and complex arithemetic
${ARCH_CMD} ${MAKE} -C MUMPS/libseq clean
${ARCH_CMD} ${MAKE} -C MUMPS MACHINE=${MACHINE} clean s
(cd MUMPS/examples; ./ssimpletest < input_simpletest_real)
${ARCH_CMD} ${MAKE} -C MUMPS MACHINE=${MACHINE} clean c
(cd MUMPS/examples; ./csimpletest < input_simpletest_cmplx)

# Build shared objects for double-precision real and complex arithemetic
${ARCH_CMD} ${MAKE} -C MUMPS MACHINE=${MACHINE} clean d
(cd MUMPS/examples; ./dsimpletest < input_simpletest_real)
${ARCH_CMD} ${MAKE} -C MUMPS MACHINE=${MACHINE} clean z
(cd MUMPS/examples; ./zsimpletest < input_simpletest_cmplx)

# Build MATLAB and run tests
${ARCH_CMD} ${MAKE} -C MUMPS/MATLAB MACHINE=${MACHINE} clean d z
fix_matlab
(cd MUMPS/MATLAB; matlab -nojvm -batch 'simple_example; zsimple_example')