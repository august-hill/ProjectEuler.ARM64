// Problem 49: Prime Permutations
// Answer: 296962999629
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

static char sieve[10001];

static void init_sieve(void) {
    memset(sieve, 1, sizeof(sieve));
    sieve[0] = sieve[1] = 0;
    for (int i = 2; i * i <= 10000; i++)
        if (sieve[i])
            for (int j = i * i; j <= 10000; j += i)
                sieve[j] = 0;
}

static int cmp_char(const void *a, const void *b) { return *(char*)a - *(char*)b; }

static void sorted_digits(int n, char *out) {
    sprintf(out, "%d", n);
    qsort(out, strlen(out), 1, cmp_char);
}

long long solve(void) {
    init_sieve();
    for (int p = 1000; p < 10000; p++) {
        if (!sieve[p] || p == 1487) continue;
        char sig[5];
        sorted_digits(p, sig);
        int perms[100], pc = 0;
        for (int q = p; q < 10000; q++) {
            char qs[5];
            sorted_digits(q, qs);
            if (sieve[q] && strcmp(sig, qs) == 0)
                perms[pc++] = q;
        }
        for (int i = 0; i < pc; i++)
            for (int j = i + 1; j < pc; j++) {
                int diff = perms[j] - perms[i];
                int third = perms[j] + diff;
                for (int k = j + 1; k < pc; k++)
                    if (perms[k] == third)
                        return (long long)perms[i] * 100000000LL + (long long)perms[j] * 10000LL + third;
            }
    }
    return 0;
}

#include "../bench.h"
int main(void) { euler_bench(49, solve); return 0; }
