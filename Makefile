# Makefile for the One Billion Rows in COBOL project
CC=gcc
CBL=cobc
CBLFLAGS=-Wno-others -O3

CBL_SRC=1brc.cbl
C_SRC=c_wrapper.c
BIN=1brc

# cobc -Wno-others -O3 -x c_wrapper.c 1brc.cbl -o 1brc

.PHONY: all
.PHONY: clean

all: $(BIN)

1brc.o: $(CBL_SRC)
	$(CBL) $(CBLFLAGS) -c -o $@ $^

wrapper.o: $(C_SRC)
	$(CC) -std=gnu17 $(CBLFLAGS) -c -o $@ $^

$(BIN): 1brc.o wrapper.o
	$(CBL) $(CBLFLAGS) -x -o $@ $^

clean:
	rm -rfv $(BIN) *.o

