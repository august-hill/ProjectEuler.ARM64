// Problem 114: Counting Block Combinations I
// Answer: 16475640049
#include <stdio.h>

long long solve(void) {
    int n = 50;
    long long dp[51];
    dp[0] = 1;

    for (int i = 1; i <= n; i++) {
        dp[i] = dp[i - 1];
        for (int len = 3; len <= i; len++) {
            int start = i - len;
            if (start == 0) {
                dp[i] += 1;
            } else if (start == 1) {
                dp[i] += 1;
            } else {
                dp[i] += dp[start - 1];
            }
        }
    }

    return dp[n];
}

#include "../bench.h"
int main(void) { euler_bench(114, solve); return 0; }
