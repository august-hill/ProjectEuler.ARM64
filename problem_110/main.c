// Problem 110: Diophantine Reciprocals II
// Answer: 9350130049860600
#include <stdio.h>
#include <math.h>

static int primes[] = {2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47};
static int nprimes = 15;

static long double best;
static int best_exps[15];

static void search(int idx, long double logn, long long div_count, int max_exp, int exps[]) {
    if (div_count > 7999999) {
        if (logn < best) {
            best = logn;
            for (int i = 0; i < nprimes; i++) best_exps[i] = exps[i];
        }
        return;
    }

    if (idx >= nprimes) return;

    long long remaining = 1;
    for (int i = idx; i < nprimes; i++) {
        remaining *= (2 * max_exp + 1);
        if (remaining > (long long)1e18) break;
    }
    if (div_count * remaining <= 7999999) return;

    for (int e = max_exp; e >= 1; e--) {
        long double new_logn = logn + e * logl(primes[idx]);
        if (new_logn >= best) continue;
        exps[idx] = e;
        search(idx + 1, new_logn, div_count * (2 * e + 1), e, exps);
    }
    exps[idx] = 0;
    search(idx + 1, logn, div_count, max_exp, exps);
}

long long solve(void) {
    best = 1e30;
    int exps[15] = {0};

    search(0, 0.0, 1, 7, exps);

    long long result = 1;
    for (int i = 0; i < nprimes; i++) {
        for (int j = 0; j < best_exps[i]; j++) {
            result *= primes[i];
        }
    }

    return result;
}

#include "../bench.h"
int main(void) { euler_bench(110, solve); return 0; }
