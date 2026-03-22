// Problem 116: Red, Green or Blue Tiles
// Answer: 20492570929
#include <stdio.h>

static long long count_ways(int tile_len, int n) {
    long long dp[51];
    dp[0] = 1;
    for (int i = 1; i <= n; i++) {
        dp[i] = dp[i - 1];
        if (i >= tile_len) {
            dp[i] += dp[i - tile_len];
        }
    }
    return dp[n] - 1;
}

long long solve(void) {
    int n = 50;
    return count_ways(2, n) + count_ways(3, n) + count_ways(4, n);
}

#include "../bench.h"
int main(void) { euler_bench(116, solve); return 0; }
