// Problem 41: Pandigital Prime
// Answer: 7652413
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_PANDIGITAL 7654321

static int is_pandigital(int n) {
    int digits[10] = {0};
    int k = 0;
    while (n > 0) {
        int d = n % 10;
        if (d == 0 || digits[d]) return 0;
        digits[d] = 1;
        n /= 10;
        k++;
    }
    for (int i = 1; i <= k; i++)
        if (!digits[i]) return 0;
    return 1;
}

long long solve(void) {
    char *is_prime = malloc(MAX_PANDIGITAL + 1);
    memset(is_prime, 1, MAX_PANDIGITAL + 1);
    is_prime[0] = is_prime[1] = 0;
    for (int i = 2; (long long)i * i <= MAX_PANDIGITAL; i++)
        if (is_prime[i])
            for (int j = i * i; j <= MAX_PANDIGITAL; j += i)
                is_prime[j] = 0;

    int result = 0;
    for (int n = MAX_PANDIGITAL; n >= 2; n--) {
        if (is_prime[n] && is_pandigital(n)) {
            result = n;
            break;
        }
    }
    free(is_prime);
    return result;
}

#include "../bench.h"
int main(void) { euler_bench(41, solve); return 0; }
