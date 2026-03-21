// Problem 72: Counting Fractions
// Answer: 303963552391
#include <stdio.h>
#include <stdlib.h>
#include "../bench.h"

#define LIMIT 1000001

static int phi[LIMIT];

long long solve(void) {
    for (int i = 0; i < LIMIT; i++) phi[i] = i;

    for (int i = 2; i < LIMIT; i++) {
        if (phi[i] == i) {
            for (int j = i; j < LIMIT; j += i) {
                phi[j] -= phi[j] / i;
            }
        }
    }

    long long total = 0;
    for (int i = 2; i < LIMIT; i++) {
        total += phi[i];
    }
    return total;
}

int main(void) { euler_bench(72, solve); return 0; }
