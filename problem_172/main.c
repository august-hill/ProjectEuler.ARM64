// Problem 172: Investigating numbers with few repeated digits
// Answer: 227485267000992000
#include <stdio.h>
#include <string.h>
#include "../bench.h"

static long long C[20][20];

static void init_C(void) {
    for (int n = 0; n < 20; n++) {
        C[n][0] = 1;
        for (int k = 1; k <= n; k++)
            C[n][k] = C[n-1][k-1] + C[n-1][k];
    }
}

long long solve(void) {
    static int inited = 0;
    if (!inited) { init_C(); inited = 1; }

    long long dp[20];
    memset(dp, 0, sizeof(dp));
    dp[18] = 1;

    for (int d = 0; d < 10; d++) {
        long long ndp[20];
        memset(ndp, 0, sizeof(ndp));
        for (int r = 0; r <= 18; r++) {
            if (dp[r] == 0) continue;
            for (int c = 0; c <= 3 && c <= r; c++)
                ndp[r - c] += dp[r] * C[r][c];
        }
        memcpy(dp, ndp, sizeof(dp));
    }
    long long total = dp[0];

    memset(dp, 0, sizeof(dp));
    dp[17] = 1;

    {
        long long ndp[20];
        memset(ndp, 0, sizeof(ndp));
        for (int r = 0; r <= 17; r++) {
            if (dp[r] == 0) continue;
            for (int c = 0; c <= 2 && c <= r; c++)
                ndp[r - c] += dp[r] * C[r][c];
        }
        memcpy(dp, ndp, sizeof(dp));
    }

    for (int d = 1; d < 10; d++) {
        long long ndp[20];
        memset(ndp, 0, sizeof(ndp));
        for (int r = 0; r <= 17; r++) {
            if (dp[r] == 0) continue;
            for (int c = 0; c <= 3 && c <= r; c++)
                ndp[r - c] += dp[r] * C[r][c];
        }
        memcpy(dp, ndp, sizeof(dp));
    }
    long long with_leading_zero = dp[0];

    return total - with_leading_zero;
}

int main(void) { euler_bench(172, solve); return 0; }
