// Problem 50: Consecutive Prime Sum
// Answer: 997651
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define LIMIT 1000000

long long solve(void) {
    char *is_prime = malloc(LIMIT + 1);
    memset(is_prime, 1, LIMIT + 1);
    is_prime[0] = is_prime[1] = 0;
    for (int i = 2; (long long)i * i <= LIMIT; i++)
        if (is_prime[i])
            for (int j = i * i; j <= LIMIT; j += i)
                is_prime[j] = 0;

    int *primes = malloc(LIMIT / 5 * sizeof(int));
    int pc = 0;
    for (int i = 2; i <= LIMIT; i++)
        if (is_prime[i]) primes[pc++] = i;

    int max_len = 0, max_sum = 0;
    for (int i = 0; i < pc; i++) {
        long long sum = 0;
        for (int j = 0; i + j < pc; j++) {
            sum += primes[i + j];
            if (sum >= LIMIT) break;
            if (is_prime[(int)sum] && j > max_len) {
                max_len = j;
                max_sum = (int)sum;
            }
        }
    }
    free(is_prime);
    free(primes);
    return max_sum;
}

#include "../bench.h"
int main(void) { euler_bench(50, solve); return 0; }
