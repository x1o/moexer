## Test environments

* Ubuntu Linux 22.04.4 LTS, R-release 4.3.3, GCC
* Windows Server 2022, R-devel, 64 bit
* Windows x86_64-w64-mingw32, R 2024-03-11 r86098 ucrt
* Ubuntu Linux 20.04.1 LTS, R-release, GCC
* Fedora Linux, R-devel, clang, gfortran

## R CMD check results

There were no ERRORs or WARNINGs. 

There were two NOTE's on Windows Server 2022, R-devel, 64 bit:

```
* checking for non-standard things in the check directory ... NOTE
Found the following files/directories:
  ''NULL''
```

This could be due to a bug/crash in MiKTeX and can likely be ignored.

```
* checking for detritus in the temp directory ... NOTE
Found the following files/directories:
  'lastMiKTeXException'
```

This seems to be an Rhub issue and so can likely be ignored.

There was one NOTE on both the Fedora Linux (R-devel) and Ubuntu Linux 20.04.1 
LTS (R-release):

```
* checking HTML version of manual ... NOTE
Skipping checking HTML validation: no command 'tidy' found
```

Caused by missing system package `tidy` --- does not seem to be critical and 
does not reoccur on other platforms.
