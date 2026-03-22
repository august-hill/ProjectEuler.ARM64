// Problem 164: Numbers for which no three consecutive digits have a sum > 9
// Answer: 378158756814587
#include <stdio.h>
#include <string.h>
#include "../bench.h"

long long solve(void) {
    long long dp[10][10];
    long long ndp[10][10];
    memset(dp, 0, sizeof(dp));

    for (int d1 = 1; d1 <= 9; d1++)
        for (int d2 = 0; d2 <= 9; d2++)
            dp[d1][d2] = 1;

    for (int pos = 3; pos <= 20; pos++) {
        memset(ndp, 0, sizeof(ndp));
        for (int d1 = 0; d1 <= 9; d1++) {
            for (int d2 = 0; d2 <= 9; d2++) {
                if (dp[d1][d2] == 0) continue;
                int max_d3 = 9 - d1 - d2;
                if (max_d3 < 0) continue;
                for (int d3 = 0; d3 <= max_d3; d3++)
                    ndp[d2][d3] += dp[d1][d2];
            }
        }
        memcpy(dp, ndp, sizeof(dp));
    }

    long long total = 0;
    for (int d1 = 0; d1 <= 9; d1++)
        for (int d2 = 0; d2 <= 9; d2++)
            total += dp[d1][d2];
    return total;
}

int main(void) { euler_bench(164, solve); return 0; }
