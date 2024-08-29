# Recipe and Binaries of MUMPS for MATLAB with OpenMP Support

This repository contains the recipe for building multithreaded MUMPS for MATLAB on Linux, Mac, and Windows. The multithreading relies on the OpenMP version of `OpenBLAS` as well as some additional OpenMP features in MUMPS.

## Binary Distributions of MEX files
The easiest way for MATLAB users is to download the MEX files prebuilt for your system.

|        | double precision real | double precision complex   |
|--------|-----------------------|----------------------------|
|Linux(1)   | [dmumpsmex.mexa64](https://github.com/xmjiao/mumps4m-openmp/releases/download/v5.3.4/dmumpsmex.mexa64) | [zmumpsmex.mexa64](https://github.com/xmjiao/mumps4m-openmp/releases/download/v5.3.4/zmumpsmex.mexa64)
|Windows(2) | [dmumpsmex.mexw64](https://github.com/xmjiao/mumps4m-openmp/releases/download/v5.3.4/dmumpsmex.mexw64) | [zmumpsmex.mexw64](https://github.com/xmjiao/mumps4m-openmp/releases/download/v5.3.4/zmumpsmex.mexw64)
|Mac(3) (x86_64) | [dmumpsmex.mexmaci64](https://github.com/xmjiao/mumps4m-openmp/releases/download/v5.3.4/dmumpsmex.mexmaci64) | [zmumpsmex.mexmaci64](https://github.com/xmjiao/mumps4m-openmp/releases/download/v5.3.4/zmumpsmex.mexmaci64)
|Mac(3) (arm64) | [dmumpsmex.mexmaca64](https://github.com/xmjiao/mumps4m-openmp/releases/download/v5.3.4/dmumpsmex.mexmaca64) | [zmumpsmex.mexmaca64](https://github.com/xmjiao/mumps4m-openmp/releases/download/v5.3.4/zmumpsmex.mexmaca64)

These MEX files were built with MUMPS v5.3.4, OpenBLAS v0.3.21, METIS 5.1.0, and MATLAB R2022a (except for Mac arm64, which was built with MATLAB R2024a). They work with MUMPS's MATLAB interface, which is included in the [`MATLAB`](https://github.com/xmjiao/mumps4m-openmp/tree/main/MATLAB) directory in this repository. Simply download these prebuilt MEX files in the `MATLAB` folder.

Notes:
1. The MEX files should work out of the box on Linux systems in both desktop and command-line mode. However, when running in command-line mode, you should start `matlab` with the `-nojvm` option instead of simply `-nodesktop` or `-nodisplay`, or JAVA is prone to throwing errors during the shutdown process.
2. For Windows users, you must also install the MinGW-w64 C/C++ compiler, which provides `libgfortran` and `libgomp` required by OpenBLAS and MUMPS.
3. For Mac users with Intel processors, you need to create a soft link `/Applications/MATLAB_<MATLAB_VERSION>.app/sys/os/maci64/libomp.dylib` pointing to `libiomp5.dylib` in the same directory. In addition, you need to add four `gfortran` libraries to MATLAB's `sys/os/maci64` folder, namely `libgfortran.5.dylib`, `libquadmath.0.dylib`, `libgcc_s.1.1.dylib`, and `libc++.1.dylib`. If you already installed `gfortran` using `anaconda`, `miniconda`, or `homebrew`, you could create soft links to these files in the `/Applications/MATLAB_<MATLAB_VERSION>.app/sys/os/maci64` folder. Otherwise, you can simply run the following command:
```shell
   curl -Ls https://github.com/xmjiao/mumps4m-openmp/releases/download/v5.3.4/libgfortran_dylibs.tgz | tar zxv - -C /Applications/MATLAB_<MATLAB_VERSION>.app/sys/os/maci64
```
4. For Mac users with Apple silicon processors, you need to add three `gfortran` libraries to MATLAB's `sys/os/maca64` folder, namely `libgfortran.5.dylib`, `libquadmath.0.dylib`, and `libgcc_s.1.1.dylib`. If you already installed `gfortran` using `anaconda`, `miniconda`, or `homebrew`, you could create soft links to these files in the `/Applications/MATLAB_<MATLAB_VERSION>.app/sys/os/maca64` folder. Otherwise, you can simply run the following command:
```shell
   curl -Ls https://github.com/xmjiao/mumps4m-openmp/releases/download/v5.3.4/libgfortran_dylibs-arm64.tgz | tar zxv - -C /Applications/MATLAB_<MATLAB_VERSION>.app/sys/os/maca64
```


Of course, you need to replace `R2022a` with the version of your MATLAB installation.


## Binary Distributions of Static Libraries

If you want to link MUMPS into your own MEX files for MATLAB, for example, to
support single-precision arithmetic, you can download the following prebuilt
static libraries of MUMPS, OpenBLAS, and METIS.
See https://github.com/xmjiao/mumps4m-openmp/tree/main/recipe/MATLAB to see how these files can be used in the `mex` command.

|        | Static libraries |
|--------|---------------------------------------------------|
|Linux   | [libmumps_5.3.4_Linux-x86_64.tar.gz](https://github.com/xmjiao/mumps4m-openmp/releases/download/v5.3.4/libmumps_5.3.4_Linux-x86_64.tar.gz)
|Windows | [libmumps_5.3.4_MINGW64-x86_64.tar.gz](https://github.com/xmjiao/mumps4m-openmp/releases/download/v5.3.4/libmumps_5.3.4_MINGW64-x86_64.tar.gz)
|Mac (x86_64)     | [libmumps_5.3.4_Darwin-x86_64.tar.gz](https://github.com/xmjiao/mumps4m-openmp/releases/download/v5.3.4/libmumps_5.3.4_Darwin-x86_64.tar.gz)
|Mac (arm64)    | [libmumps_5.3.4_Darwin-arm64.tar.gz](https://github.com/xmjiao/mumps4m-openmp/releases/download/v5.3.4/libmumps_5.3.4_Darwin-arm64.tar.gz)

## AUTHOR
`mumps4m-openmp` was developed and maintained by Xiangmin (Jim) Jiao (xiangmin.jiao@stonybrook.edu) mainly for comparative research. If you need robust and efficient linear solvers for large-scale problems, please also consider the software
[hifir](https://github.com/hifirworks/hifir). For comparisons between HIFIR and MUMPS, please see the following papers:

```bibtex
@Article{chen2021hilucsi,
  author  = {Chen, Qiao and Ghai, Aditi and Jiao, Xiangmin},
  title   = {{HILUCSI}: Simple, robust, and fast multilevel {ILU} for
             large-scale saddle-point problems from {PDE}s},
  journal = {Numer. Linear Algebra Appl.},
  year    = {2021},
  number  = {6},
  pages   = {e2400},
  volume  = {28},
  doi     = {10.1002/nla.2400}
}
```

```bibtex
@Article{chen2022hifir,
  author  = {Chen, Qiao and Jiao, Xiangmin},
  title   = {{HIFIR}: Hybrid incomplete factorization with iterative refinement
             for preconditioning ill-conditioned and singular systems},
  journal = {ACM Trans. Math. Softw.},
  year    = {2022},
  doi     = {10.1145/3536165}
}
```
