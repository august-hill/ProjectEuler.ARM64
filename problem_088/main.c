// Problem 88: Product-sum Numbers
// Answer: 7587457
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "../bench.h"

#define K_MAX 12000
#define LIMIT (2 * K_MAX)

static int min_ps[K_MAX + 1];

static void factorize(int product, int sum, int count, int min_factor) {
    int k = product - sum + count;
    if (k <= K_MAX) {
        if (product < min_ps[k]) {
            min_ps[k] = product;
        }
    }

    for (int f = min_factor; f <= LIMIT; f++) {
        long long new_product = (long long)product * f;
        if (new_product > LIMIT) break;
        factorize((int)new_product, sum + f, count + 1, f);
    }
}

long long solve(void) {
    for (int i = 0; i <= K_MAX; i++)
        min_ps[i] = LIMIT + 1;

    for (int f = 2; f <= LIMIT; f++) {
        factorize(f, f, 1, f);
    }

    char *seen = calloc(LIMIT + 2, 1);
    long long total = 0;
    for (int k = 2; k <= K_MAX; k++) {
        int v = min_ps[k];
        if (!seen[v]) {
            seen[v] = 1;
            total += v;
        }
    }
    free(seen);
    return total;
}

int main(void) { euler_bench(88, solve); return 0; }
