// Problem 178: Step Numbers
// Answer: 126461847755
#include <string.h>
#include "../bench.h"

static long long dp[10][1024];
static long long ndp[10][1024];

long long solve(void) {
    memset(dp, 0, sizeof(dp));

    long long total = 0;
    int full_mask = (1 << 10) - 1;

    for (int d = 1; d <= 9; d++)
        dp[d][1 << d] = 1;

    for (int len = 2; len <= 40; len++) {
        memset(ndp, 0, sizeof(ndp));
        for (int d = 0; d <= 9; d++) {
            for (int mask = 0; mask < 1024; mask++) {
                if (dp[d][mask] == 0) continue;
                long long val = dp[d][mask];
                if (d > 0) ndp[d - 1][mask | (1 << (d - 1))] += val;
                if (d < 9) ndp[d + 1][mask | (1 << (d + 1))] += val;
            }
        }
        for (int d = 0; d <= 9; d++)
            total += ndp[d][full_mask];
        memcpy(dp, ndp, sizeof(dp));
    }

    return total;
}

int main(void) { euler_bench(178, solve); return 0; }
