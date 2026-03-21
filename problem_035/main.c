// Problem 35: Circular Primes
// Answer: 55
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

#define LIMIT 1000000

static char sieve[LIMIT];

static void init_sieve(void) {
    memset(sieve, 1, LIMIT);
    sieve[0] = sieve[1] = 0;
    for (int i = 2; i * i < LIMIT; i++) {
        if (sieve[i]) {
            for (int j = i * i; j < LIMIT; j += i)
                sieve[j] = 0;
        }
    }
}

static int num_digits(int n) {
    int c = 0;
    while (n > 0) { c++; n /= 10; }
    return c;
}

static int rotate(int n) {
    int d = num_digits(n);
    int last = n % 10;
    int rest = n / 10;
    int mul = 1;
    for (int i = 1; i < d; i++) mul *= 10;
    return last * mul + rest;
}

static int is_circular_prime(int n) {
    int d = num_digits(n);
    int r = n;
    for (int i = 0; i < d; i++) {
        if (r >= LIMIT || !sieve[r]) return 0;
        r = rotate(r);
    }
    return 1;
}

long long solve(void) {
    static int inited = 0;
    if (!inited) { init_sieve(); inited = 1; }
    int count = 0;
    for (int n = 2; n < LIMIT; n++) {
        if (sieve[n] && is_circular_prime(n)) count++;
    }
    return count;
}

#include "../bench.h"
int main(void) { euler_bench(35, solve); return 0; }
