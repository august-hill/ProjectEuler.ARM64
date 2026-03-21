// Problem 70: Totient Permutation
// Answer: 8319823
#include <stdio.h>
#include <stdlib.h>
#include "../bench.h"

#define LIMIT 10000000

static int phi[LIMIT];

static int is_permutation(int a, int b) {
    int digits_a[10] = {0};
    int digits_b[10] = {0};
    while (a > 0) { digits_a[a % 10]++; a /= 10; }
    while (b > 0) { digits_b[b % 10]++; b /= 10; }
    for (int i = 0; i < 10; i++) {
        if (digits_a[i] != digits_b[i]) return 0;
    }
    return 1;
}

long long solve(void) {
    for (int i = 0; i < LIMIT; i++) phi[i] = i;

    for (int i = 2; i < LIMIT; i++) {
        if (phi[i] == i) {
            for (int j = i; j < LIMIT; j += i) {
                phi[j] -= phi[j] / i;
            }
        }
    }

    long long best_n = 0;
    double best_ratio = 1e18;

    for (int n = 2; n < LIMIT; n++) {
        if (is_permutation(n, phi[n])) {
            double ratio = (double)n / phi[n];
            if (ratio < best_ratio) {
                best_ratio = ratio;
                best_n = n;
            }
        }
    }

    return best_n;
}

int main(void) { euler_bench(70, solve); return 0; }
