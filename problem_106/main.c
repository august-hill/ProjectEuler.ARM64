// Problem 106: Special Subset Sums: Meta-testing
// Answer: 21384
#include <stdio.h>

static long long comb(int n, int k) {
    if (k > n || k < 0) return 0;
    if (k > n - k) k = n - k;
    long long result = 1;
    for (int i = 0; i < k; i++) {
        result = result * (n - i) / (i + 1);
    }
    return result;
}

static long long catalan(int n) {
    return comb(2 * n, n) / (n + 1);
}

long long solve(void) {
    int n = 12;
    long long total = 0;

    for (int k = 2; k <= n / 2; k++) {
        long long pairs_total = comb(n, 2 * k) * comb(2 * k, k) / 2;
        long long pairs_ok = comb(n, 2 * k) * catalan(k);
        total += pairs_total - pairs_ok;
    }

    return total;
}

#include "../bench.h"
int main(void) { euler_bench(106, solve); return 0; }
