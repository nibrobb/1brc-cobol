# 1brc-cobol

A simple solution for Gunnar Morling's [One Billion Row Challenge](https://github.com/gunnarmorling/1brc) written in COBOL.


## Quick start
Prerequisites:
* [Gnu COBOL](https://gnucobol.sourceforge.io/) `cobc`
* Any C-compiler e.g., `gcc`
* Optionally `make`, command to compile is simple.

100 measurements are available in a file in `data/measurements.txt` which you can use for testing. For the full (~13 GB) file see procedures on how to generate it at the [1BRC](https://github.com/gunnarmorling/1brc) repo.

Simply compile with make
```bash
$ make
```

or run this command
```bash
$ cobc -Wno-others -O3 -x c_wrapper.c 1brc.cbl -o 1brc-cobol
```

And to run with the data set of your choosing
```bash
$ ./1brc-cobol measurements.txt
```
