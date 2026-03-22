// Problem 193: Squarefree Numbers
// Answer: 684465067343069
#include <stdlib.h>
#include <string.h>
#include "../bench.h"

#define LIMIT 33554432  // 2^25 = sqrt(2^50)

static signed char *mu;
static int *primes;
static int nprimes;

static void init(void) {
    mu = (signed char *)malloc(LIMIT * sizeof(signed char));
    primes = (int *)malloc(2100000 * sizeof(int));
    nprimes = 0;

    for (int i = 0; i < LIMIT; i++) mu[i] = 1;
    mu[0] = 0;

    // Linear sieve to compute Mobius function
    int *lp = (int *)calloc(LIMIT, sizeof(int)); // least prime factor
    for (int i = 2; i < LIMIT; i++) {
        if (lp[i] == 0) {
            lp[i] = i;
            primes[nprimes++] = i;
        }
        for (int j = 0; j < nprimes && primes[j] <= lp[i] && (long long)i * primes[j] < LIMIT; j++) {
            lp[i * primes[j]] = primes[j];
        }
    }
    free(lp);

    // Compute mu via sieve of primes
    for (int i = 0; i < nprimes; i++) {
        long long p = primes[i];
        for (long long j = p; j < LIMIT; j += p)
            mu[j] = (signed char)(-mu[j]);
        long long p2 = p * p;
        for (long long j = p2; j < LIMIT; j += p2)
            mu[j] = 0;
    }
}

long long solve(void) {
    static int initialized = 0;
    if (!initialized) { init(); initialized = 1; }

    long long N = 1LL << 50;
    long long count = 0;

    for (long long k = 1; k < LIMIT; k++) {
        if (mu[k] == 0) continue;
        long long k2 = k * k;
        if (k2 > N) break;
        count += mu[k] * (N / k2);
    }

    return count;
}

int main(void) { euler_bench(193, solve); return 0; }
