# Makefile for the One Billion Rows in COBOL project
CBL=cobc
CBLFLAGS=-Wno-others -O3 -x

SRC=c_wrapper.c 1brc.cbl
BIN=1brc-cobol

# cobc -Wno-others -O3 -x c_wrapper.c 1brc.cbl -o 1brc-cobol

.PHONY: all

all: $(BIN)

$(BIN): $(SRC)
	$(CBL) -o $@ $(CBLFLAGS) $^

clean:
	rm -rf $(BIN)
