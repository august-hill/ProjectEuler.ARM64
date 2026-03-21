// Problem 87: Prime Power Triples
// Answer: 1097343
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include "../bench.h"

#define LIMIT 50000000
#define PRIME_LIMIT 7072

static int primes[1000];
static int prime_count = 0;

static void init_primes(void) {
    char *sieve = calloc(PRIME_LIMIT + 1, 1);
    for (int i = 2; i <= PRIME_LIMIT; i++) {
        if (!sieve[i]) {
            primes[prime_count++] = i;
            for (long long j = (long long)i * i; j <= PRIME_LIMIT; j += i)
                sieve[j] = 1;
        }
    }
    free(sieve);
}

long long solve(void) {
    static int initialized = 0;
    if (!initialized) { init_primes(); initialized = 1; }

    char *seen = calloc(LIMIT, 1);
    int count = 0;

    for (int ri = 0; ri < prime_count; ri++) {
        long long r = primes[ri];
        long long r4 = r * r * r * r;
        if (r4 >= LIMIT) break;

        for (int qi = 0; qi < prime_count; qi++) {
            long long q = primes[qi];
            long long q3 = q * q * q;
            if (r4 + q3 >= LIMIT) break;

            for (int pi = 0; pi < prime_count; pi++) {
                long long p = primes[pi];
                long long p2 = p * p;
                long long total = r4 + q3 + p2;
                if (total >= LIMIT) break;

                if (!seen[total]) {
                    seen[total] = 1;
                    count++;
                }
            }
        }
    }

    free(seen);
    return count;
}

int main(void) { euler_bench(87, solve); return 0; }
