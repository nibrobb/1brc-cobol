# 1brc-cobol

A simple solution for Gunnar Morling's [One Billion Row Challenge](https://github.com/gunnarmorling/1brc) written in COBOL.


## Quick start
Prerequisites:
* [GnuCOBOL](https://gnucobol.sourceforge.io/) `cobc`
* Any C-compiler e.g., `gcc`
* Optionally `make`, command to compile is simple.

100 measurements are available in a file in `data/measurements.txt` which you can use for testing. For the full (~13 GB) file see procedures on how to generate it at the [1BRC](https://github.com/gunnarmorling/1brc) repo.

Simply compile with make
```bash
make
```

or run this command
```bash
cobc -Wno-others -O3 -x c_wrapper.c 1brc.cbl -o 1brc-cobol
```

And to run with the data set of your choosing
```bash
./1brc-cobol measurements.txt
```

## Performance
Test system:
|     |                            |
|:----|:---------------------------|
| CPU | 16c/32t AMD Ryzen 9 7950X  |
| RAM | 64GB DDR5 @ 6000 MHz       |
| SSD | Samsung 990 Pro NVMe 2TB   |

Running with the full 1 billion row file on my machine the results are as follows

```bash
real    18m 59.010s
user    18m 57.122s
sys      0m  1.880s
```
For comparison the baseline Java implementation runs in 
```bash
real    1m 30.335s
user    1m 28.930s
sys     0m  2.482s
```
Meaning my implementation runs about 12.6 times slower than the baseline 😅 
