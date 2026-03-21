// Problem 47: Distinct Prime Factors
// Answer: 134043
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define LIMIT 150000

static int count_distinct_factors(int n, int *primes, int pc) {
    int count = 0;
    for (int i = 0; i < pc; i++) {
        int p = primes[i];
        if ((long long)p * p > n) break;
        if (n % p == 0) {
            count++;
            while (n % p == 0) n /= p;
        }
    }
    if (n > 1) count++;
    return count;
}

long long solve(void) {
    char *is_prime = malloc(LIMIT);
    memset(is_prime, 1, LIMIT);
    is_prime[0] = is_prime[1] = 0;
    for (int i = 2; (long long)i * i < LIMIT; i++)
        if (is_prime[i])
            for (int j = i * i; j < LIMIT; j += i)
                is_prime[j] = 0;

    int *primes = malloc(LIMIT / 5 * sizeof(int));
    int pc = 0;
    for (int i = 2; i < LIMIT; i++)
        if (is_prime[i]) primes[pc++] = i;

    int consecutive = 0;
    int result = 0;
    for (int i = 2; i < LIMIT; i++) {
        if (count_distinct_factors(i, primes, pc) == 4) {
            consecutive++;
            if (consecutive == 4) { result = i - 3; break; }
        } else {
            consecutive = 0;
        }
    }
    free(is_prime);
    free(primes);
    return result;
}

#include "../bench.h"
int main(void) { euler_bench(47, solve); return 0; }
