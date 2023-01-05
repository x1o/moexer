## Test environments

* Debian Linux, R-release, GCC (debian-gcc-release)
* Windows Server 2022, R-devel, 64 bit
* Ubuntu Linux 20.04.1 LTS, R-release, GCC
* Fedora Linux, R-devel, clang, gfortran

## R CMD check results

There were no ERRORs or WARNINGs. 

There was one NOTE on Fedora Linux (R-devel):

```
* checking HTML version of manual ... NOTE
Skipping checking HTML validation: no command 'tidy' found
```

The note does not seem to be critical and does not reoccur on other platforms.
