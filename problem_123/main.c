// Problem 123: Prime Square Remainders
// Answer: 21035
#include <stdio.h>
#include <string.h>
#include <stdint.h>

#define SIEVE_SIZE 1000000

static uint8_t sieve[SIEVE_SIZE / 8 + 1];
static int primes[100000];
static int nprimes;

static void init(void) {
    memset(sieve, 0, sizeof(sieve));
    sieve[0] |= 3;
    for (long i = 2; (long)i * i < SIEVE_SIZE; i++) {
        if (!(sieve[i / 8] & (1 << (i % 8)))) {
            for (long j = i * i; j < SIEVE_SIZE; j += i)
                sieve[j / 8] |= (1 << (j % 8));
        }
    }
    nprimes = 0;
    for (int i = 2; i < SIEVE_SIZE; i++) {
        if (!(sieve[i / 8] & (1 << (i % 8))))
            primes[nprimes++] = i;
    }
}

long long solve(void) {
    static int initialized = 0;
    if (!initialized) { init(); initialized = 1; }

    long long target = 10000000000LL;
    for (int i = 0; i < nprimes; i++) {
        int n = i + 1;
        if (n % 2 == 0) continue;
        long long p = primes[i];
        long long r = 2LL * n * p;
        long long p2 = p * p;
        r = r % p2;
        if (r > target) return n;
    }
    return -1;
}

#include "../bench.h"
int main(void) { euler_bench(123, solve); return 0; }
