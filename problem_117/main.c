// Problem 117: Red, Green, and Blue Tiles
// Answer: 100808458960497
#include <stdio.h>

long long solve(void) {
    int n = 50;
    long long dp[51];
    dp[0] = 1;
    for (int i = 1; i <= n; i++) {
        dp[i] = dp[i - 1];
        if (i >= 2) dp[i] += dp[i - 2];
        if (i >= 3) dp[i] += dp[i - 3];
        if (i >= 4) dp[i] += dp[i - 4];
    }
    return dp[n];
}

#include "../bench.h"
int main(void) { euler_bench(117, solve); return 0; }
