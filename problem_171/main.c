// Problem 171: Finding numbers for which f(n) is a perfect square
// Answer: 142989277 (last 9 digits of sum)
#include <stdio.h>
#include <string.h>
#include <math.h>
#include "../bench.h"

#define MOD 1000000000LL
#define MAX_SS 1621

static int is_perfect_square(int n) {
    if (n < 0) return 0;
    int s = (int)sqrt((double)n);
    while (s * s > n) s--;
    while ((s+1)*(s+1) <= n) s++;
    return s * s == n;
}

long long solve(void) {
    long long total = 0;

    for (int L = 1; L <= 20; L++) {
        static long long cnt_dp[MAX_SS];
        static long long val_dp[MAX_SS];
        memset(cnt_dp, 0, sizeof(cnt_dp));
        memset(val_dp, 0, sizeof(val_dp));

        for (int d = 1; d <= 9; d++) {
            cnt_dp[d*d] = (cnt_dp[d*d] + 1) % MOD;
            val_dp[d*d] = (val_dp[d*d] + d) % MOD;
        }

        for (int pos = 1; pos < L; pos++) {
            static long long new_cnt[MAX_SS];
            static long long new_val[MAX_SS];
            memset(new_cnt, 0, sizeof(new_cnt));
            memset(new_val, 0, sizeof(new_val));

            for (int ss = 0; ss < MAX_SS; ss++) {
                if (cnt_dp[ss] == 0) continue;
                long long c = cnt_dp[ss];
                long long v = val_dp[ss];

                for (int d = 0; d <= 9; d++) {
                    int nss = ss + d*d;
                    if (nss >= MAX_SS) continue;
                    new_cnt[nss] = (new_cnt[nss] + c) % MOD;
                    new_val[nss] = (new_val[nss] + v * 10 + c * d) % MOD;
                }
            }

            memcpy(cnt_dp, new_cnt, sizeof(cnt_dp));
            memcpy(val_dp, new_val, sizeof(val_dp));
        }

        for (int ss = 0; ss < MAX_SS; ss++) {
            if (cnt_dp[ss] > 0 && is_perfect_square(ss))
                total = (total + val_dp[ss]) % MOD;
        }
    }

    return total;
}

int main(void) { euler_bench(171, solve); return 0; }
