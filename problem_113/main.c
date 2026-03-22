// Problem 113: Non-bouncy Numbers Below a Googol
// Answer: 51161058134250
#include <stdio.h>

static long long comb(int n, int k) {
    if (k > n || k < 0) return 0;
    if (k > n - k) k = n - k;
    __int128 result = 1;
    for (int i = 0; i < k; i++) {
        result = result * (n - i) / (i + 1);
    }
    return (long long)result;
}

long long solve(void) {
    int n = 100;
    long long increasing = comb(n + 9, 9) - 1;
    long long decreasing = comb(n + 10, 10) - (n + 1);
    long long flat = 9LL * n;

    return increasing + decreasing - flat;
}

#include "../bench.h"
int main(void) { euler_bench(113, solve); return 0; }
