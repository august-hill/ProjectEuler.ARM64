// Problem 181: Investigating in How Many Ways Objects of Two Different Colours Can Be Grouped
// Answer: 83735848679360680
#include <string.h>
#include "../bench.h"

#define B 60
#define W 40

static long long dp[B + 1][W + 1];

long long solve(void) {
    memset(dp, 0, sizeof(dp));
    dp[B][W] = 1;

    for (int b = 0; b <= B; b++) {
        for (int w = 0; w <= W; w++) {
            if (b == 0 && w == 0) continue;

            long long ndp[B + 1][W + 1];
            memset(ndp, 0, sizeof(ndp));

            for (int rb = 0; rb <= B; rb++) {
                for (int rw = 0; rw <= W; rw++) {
                    if (dp[rb][rw] == 0) continue;
                    for (int k = 0; ; k++) {
                        int nb = rb - k * b;
                        int nw = rw - k * w;
                        if (nb < 0 || nw < 0) break;
                        ndp[nb][nw] += dp[rb][rw];
                    }
                }
            }
            memcpy(dp, ndp, sizeof(dp));
        }
    }

    return dp[0][0];
}

int main(void) { euler_bench(181, solve); return 0; }
