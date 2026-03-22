// Problem 142: Perfect Square Collection
// Answer: 1006193
#include <math.h>

static int isqrt_check(long long n) {
    if (n < 0) return 0;
    long long s = (long long)sqrt((double)n);
    while (s * s < n) s++;
    while (s * s > n) s--;
    return s * s == n;
}

long long solve(void) {
    for (int a = 3; ; a++) {
        for (int c = a - 1; c >= 2; c--) {
            long long f2 = (long long)a*a - (long long)c*c;
            if (!isqrt_check(f2)) continue;

            for (int e = c - 1; e >= 1; e--) {
                long long b2 = (long long)c*c - (long long)e*e;
                if (!isqrt_check(b2)) continue;

                long long d2 = (long long)a*a - (long long)e*e;
                if (!isqrt_check(d2)) continue;

                long long a2 = (long long)a*a;
                long long b2v = b2;
                long long bv = (long long)sqrt((double)b2v);
                while (bv*bv < b2v) bv++;
                if ((a + bv) % 2 != 0) continue;

                long long x = (a2 + b2v) / 2;
                long long y = (a2 - b2v) / 2;
                long long z = x - d2;

                if (z <= 0 || y <= z) continue;

                return x + y + z;
            }
        }
    }
    return -1;
}

#include "../bench.h"
int main(void) { euler_bench(142, solve); return 0; }
