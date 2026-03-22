// Problem 108: Diophantine Reciprocals I
// Answer: 180180
#include <stdio.h>

static int primes[] = {2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43};
static int nprimes = 14;

static long long best;

static void search(int idx, long long n, long long div_count, int max_exp) {
    long long solutions = (div_count + 1) / 2;
    if (solutions > 1000) {
        if (n < best) best = n;
        return;
    }
    if (idx >= nprimes) return;

    for (int e = max_exp; e >= 1; e--) {
        long long new_n = n;
        int overflow = 0;
        for (int j = 0; j < e; j++) {
            if (new_n > best / primes[idx]) { overflow = 1; break; }
            new_n *= primes[idx];
        }
        if (overflow || new_n >= best) continue;
        search(idx + 1, new_n, div_count * (2 * e + 1), e);
    }
}

long long solve(void) {
    best = (long long)1e18;
    search(0, 1, 1, 20);
    return best;
}

#include "../bench.h"
int main(void) { euler_bench(108, solve); return 0; }
