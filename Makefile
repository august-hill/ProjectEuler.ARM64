AS = as
CC = cc
CFLAGS = -O2
LDFLAGS = -lSystem
SDK = $(shell xcrun --show-sdk-path)

problem:
	$(AS) -o problem_$(N)/solve.o problem_$(N)/solve.s
	$(CC) $(CFLAGS) -o problem_$(N)/main bench.c problem_$(N)/solve.o

run: problem
	./problem_$(N)/main $(N)

clean:
	rm -f problem_*/solve.o problem_*/main

.PHONY: problem run clean
