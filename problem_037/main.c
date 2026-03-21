// Problem 37: Truncatable Primes
// Answer: 748317
#include <stdio.h>
#include <string.h>

#define LIMIT 1000000
static char sieve[LIMIT];

static void init_sieve(void) {
    memset(sieve, 1, LIMIT);
    sieve[0] = sieve[1] = 0;
    for (int i = 2; i * i < LIMIT; i++)
        if (sieve[i])
            for (int j = i * i; j < LIMIT; j += i)
                sieve[j] = 0;
}

static int is_left_trunc(int n) {
    int d = 1;
    while (d <= n) d *= 10;
    d /= 10;
    while (d > 1) {
        n = n % d;
        if (n == 0 || !sieve[n]) return 0;
        d /= 10;
    }
    return 1;
}

static int is_right_trunc(int n) {
    n /= 10;
    while (n > 0) {
        if (!sieve[n]) return 0;
        n /= 10;
    }
    return 1;
}

long long solve(void) {
    static int inited = 0;
    if (!inited) { init_sieve(); inited = 1; }
    long long sum = 0;
    int count = 0;
    for (int p = 11; p < LIMIT && count < 11; p++) {
        if (sieve[p] && is_left_trunc(p) && is_right_trunc(p)) {
            sum += p;
            count++;
        }
    }
    return sum;
}

#include "../bench.h"
int main(void) { euler_bench(37, solve); return 0; }
