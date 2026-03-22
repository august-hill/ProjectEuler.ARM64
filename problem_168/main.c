// Problem 168: Number Rotations
// Answer: 59206
#include <stdio.h>
#include <string.h>
#include "../bench.h"

#define MOD 100000LL

long long solve(void) {
    long long total = 0;

    for (int k = 1; k <= 9; k++) {
        int D = 10 * k - 1;
        for (int a0 = k; a0 <= 9; a0++) {
            int g = D, tmp_g = a0;
            while (tmp_g) { int t = tmp_g; tmp_g = g % tmp_g; g = t; }
            int Dp = D / g;

            int ord = 0;
            {
                long long pw = 1;
                for (int e = 1; e <= 10000; e++) {
                    pw = pw * 10 % Dp;
                    if (pw == 1 % Dp || Dp == 1) { ord = e; break; }
                }
                if (ord == 0) ord = Dp;
            }

            long long big_mod = (long long)D * MOD;
            long long p10 = 10 % (Dp > 0 ? Dp : 1);
            long long p10_full = 10 % big_mod;

            for (int d = 1; d <= 100; d++) {
                if (d >= 2) {
                    if (Dp == 1 || p10 == 1 % Dp) {
                        long long pd_minus_1 = (p10_full - 1 + big_mod) % big_mod;
                        long long num = ((long long)a0 * pd_minus_1) % big_mod;
                        long long n_mod = (num / D) % MOD;
                        total = (total + n_mod) % MOD;
                    }
                }
                p10 = (Dp > 1) ? (p10 * 10 % Dp) : 0;
                p10_full = p10_full * 10 % big_mod;
            }
        }
    }
    return total;
}

int main(void) { euler_bench(168, solve); return 0; }
