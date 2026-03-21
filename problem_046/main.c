// Problem 46: Goldbach's Other Conjecture
// Answer: 5777
#include <stdio.h>
#include <string.h>

#define LIMIT 10000
static char sieve[LIMIT + 1];

static void init_sieve(void) {
    memset(sieve, 1, sizeof(sieve));
    sieve[0] = sieve[1] = 0;
    for (int i = 2; i * i <= LIMIT; i++)
        if (sieve[i])
            for (int j = i * i; j <= LIMIT; j += i)
                sieve[j] = 0;
}

long long solve(void) {
    init_sieve();
    for (int c = 9; c < LIMIT; c += 2) {
        if (sieve[c]) continue;
        int found = 0;
        for (int p = 2; p < c && !found; p++) {
            if (!sieve[p]) continue;
            for (int y = 1; !found; y++) {
                int z = p + 2 * y * y;
                if (z > c) break;
                if (z == c) found = 1;
            }
        }
        if (!found) return c;
    }
    return 0;
}

#include "../bench.h"
int main(void) { euler_bench(46, solve); return 0; }
