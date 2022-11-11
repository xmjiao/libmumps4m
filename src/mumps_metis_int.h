/*
 *
 *  This file is part of MUMPS 5.3.4, released
 *  on Mon Sep 28 07:16:41 UTC 2020
 *
 *
 *  Copyright 1991-2020 CERFACS, CNRS, ENS Lyon, INP Toulouse, Inria,
 *  Mumps Technologies, University of Bordeaux.
 *
 *  This version of MUMPS is provided to you free of charge. It is
 *  released under the CeCILL-C license 
 *  (see doc/CeCILL-C_V1-en.txt, doc/CeCILL-C_V1-fr.txt, and
 *  https://cecill.info/licences/Licence_CeCILL-C_V1-en.html)
 *
 */
#ifndef MUMPS_METIS_INT_H
#define MUMPS_METIS_INT_H
#include "mumps_common.h" /* includes mumps_compat.h and mumps_c_types.h */
#define MUMPS_METIS_IDXSIZE \
  F_SYMBOL(metis_idxsize,METIS_IDXSIZE)
void MUMPS_CALL
MUMPS_METIS_IDXSIZE(MUMPS_INT *metis_idx_size);
#endif