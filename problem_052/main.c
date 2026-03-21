// Problem 52: Permuted Multiples
// Answer: 142857
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

static int cmp_char(const void *a, const void *b) { return *(char*)a - *(char*)b; }

static void digit_sig(int n, char *out) {
    sprintf(out, "%d", n);
    qsort(out, strlen(out), 1, cmp_char);
}

long long solve(void) {
    for (int x = 1; ; x++) {
        char sig[10], test[10];
        digit_sig(x, sig);
        int ok = 1;
        for (int m = 2; m <= 6; m++) {
            digit_sig(x * m, test);
            if (strcmp(sig, test) != 0) { ok = 0; break; }
        }
        if (ok) return x;
    }
}

#include "../bench.h"
int main(void) { euler_bench(52, solve); return 0; }
