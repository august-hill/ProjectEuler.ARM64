// Problem 191: Prize Strings
// Answer: 1918080160
#include <string.h>
#include "../bench.h"

long long solve(void) {
    long long dp[31][3][2];
    memset(dp, 0, sizeof(dp));
    dp[0][0][0] = 1;

    for (int day = 0; day < 30; day++) {
        for (int a = 0; a < 3; a++) {
            for (int l = 0; l < 2; l++) {
                if (dp[day][a][l] == 0) continue;
                long long val = dp[day][a][l];
                dp[day + 1][0][l] += val;
                if (l < 1) dp[day + 1][0][l + 1] += val;
                if (a < 2) dp[day + 1][a + 1][l] += val;
            }
        }
    }

    long long total = 0;
    for (int a = 0; a < 3; a++)
        for (int l = 0; l < 2; l++)
            total += dp[30][a][l];
    return total;
}

int main(void) { euler_bench(191, solve); return 0; }
