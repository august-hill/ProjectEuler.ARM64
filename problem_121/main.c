// Problem 121: Disc Game Prize Fund
// Answer: 2269
#include <stdio.h>
#include <string.h>

long long solve(void) {
    int n = 15;
    long long dp[16];
    memset(dp, 0, sizeof(dp));
    dp[0] = 1;

    for (int k = 1; k <= n; k++) {
        for (int j = k; j >= 1; j--) {
            dp[j] = dp[j] * k + dp[j - 1];
        }
        dp[0] *= k;
    }

    long long denom = 1;
    for (int i = 1; i <= n + 1; i++) denom *= i;

    long long win_num = 0;
    for (int j = (n / 2) + 1; j <= n; j++) {
        win_num += dp[j];
    }

    return denom / win_num;
}

#include "../bench.h"
int main(void) { euler_bench(121, solve); return 0; }
