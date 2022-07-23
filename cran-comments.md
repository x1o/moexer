## Test environments

* MacOS Monterey 12.4, R-4.2.0 (local)
* Debian Linux, R-release, GCC (debian-gcc-release)
* Ubuntu Linux 20.04.1 LTS, R-release, GCC
* Fedora Linux, R-devel, clang, gfortran
* Windows Server 2022, R-devel, 64 bit

## R CMD check results

There were no ERRORs or WARNINGs. 

There is one NOTE that is only found on Windows (Server 2022, R-devel 64-bit): 

```
* checking for detritus in the temp directory ... NOTE
Found the following files/directories:
  'lastMiKTeXException'
```

As noted in [R-hub issue #503](https://github.com/r-hub/rhub/issues/503), this could be due to a bug/crash in MiKTeX and can likely be ignored.

`devtools::check_win_devel()` worked well, though, even though it appears to
have the same configuration.
