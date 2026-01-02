# Fortran-Specific Information

## Prereqisite

Building and testing reqiures the Fortran Package Manager  (`fpm`), which can
be obtained via package manager (e.g., `brew install fpm` on macOS) or by
compiling the single-file concatenation of the `fpm` source that is included
among the release assets.  For the 0.12.0 release, for example, compiling
[fpm-0.12.0.F90](https://github.com/fortran-lang/fpm/releases/download/v0.12.0/fpm-0.12.0.F90)
and placing the resulting executable program in your `PATH` suffices.

## Building and testing

|        |             | Minimum  |                                                       |
| Vendor | Compiler    | Version  | Build/Test Command                                    |
|--------|-------------|----------|-------------------------------------------------------|
| GCC    | `gfortran`  | 13       | fpm test --compiler gfortran --profile release        |
| Intel  | `ifx`       | 2025.1.2 | FOR_COARRAY_NUM_IMAGES=1 fpm test --compiler ifx --flag "-fpp -O3 -coarray" --profile release |
| LLVM   | `flang-new` | 19       | fpm test --compiler flang-new --flag "-O3"            |
| NAG    | `nagfor`    | 7.2      | fpm test --compiler nagfor --flag "-O3 -fpp"          |

**Known Issues**
1. With GCC 13, append `--flag "-ffree-line-length-none"` to the `fpm` command.
2. With `fpm` versions _after_ 0.12.0, `flang-new` can be shortened to `flang`.
3. With LLVM 19, add ` -mmlir -allow-assumed-rank` to the `--flag` argument.
4. With NAG 7.2, Build 7235 or later is recommmend, but earlier builds might work.
