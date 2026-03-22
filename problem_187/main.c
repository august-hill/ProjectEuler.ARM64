// Problem 187: Semiprimes
// Answer: 17427258
#include <stdlib.h>
#include <string.h>
#include "../bench.h"

#define LIMIT 100000000

static int *primes;
static int nprimes;
static char *sieve;

static void init(void) {
    sieve = (char *)calloc(LIMIT, 1);
    sieve[0] = sieve[1] = 1;
    for (long i = 2; i * i < LIMIT; i++)
        if (!sieve[i])
            for (long j = i * i; j < LIMIT; j += i)
                sieve[j] = 1;
    nprimes = 0;
    for (int i = 2; i < LIMIT; i++)
        if (!sieve[i]) nprimes++;
    primes = (int *)malloc(nprimes * sizeof(int));
    int idx = 0;
    for (int i = 2; i < LIMIT; i++)
        if (!sieve[i]) primes[idx++] = i;
}

long long solve(void) {
    static int initialized = 0;
    if (!initialized) { init(); initialized = 1; }

    long long count = 0;
    for (int i = 0; i < nprimes; i++) {
        long p = primes[i];
        if (p * p >= LIMIT) break;
        long max_q = (LIMIT - 1) / p;
        int lo = i, hi = nprimes - 1, ans = i - 1;
        while (lo <= hi) {
            int mid = (lo + hi) / 2;
            if (primes[mid] <= max_q) { ans = mid; lo = mid + 1; }
            else hi = mid - 1;
        }
        if (ans >= i) count += ans - i + 1;
    }

    return count;
}

int main(void) { euler_bench(187, solve); return 0; }
