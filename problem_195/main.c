// Problem 195: Finding exact discrepancy
// Answer: 75085391
#include <string.h>
#include <stdio.h>
#include <math.h>

static int gcd2(long long a, long long b) {
    while (b) { long long t=b; b=a%b; a=t; }
    return (int)a;
}

static long long isqrt2(long long n) {
    long long r = (long long)sqrt((double)n);
    while (r > 0 && r*r > n) r--;
    while ((r+1)*(r+1) <= n) r++;
    return r;
}

static long long formula_count(long long L) {
    long long count = L / 3;

    for (long long m = 3; ; m++) {
        for (long long n = 1; 2*n < m; n++) {
            if (gcd2(m, n) != 1) continue;
            if ((m + n) % 3 == 0) continue;
            long long perim = (2*m - n) * (m + n);
            if (perim > L) break;
            count += L / perim;
        }
        if ((2*m - 1) * (m + 1) > L) break;
    }

    for (long long m = 2; ; m++) {
        long long n_min = m / 2 + 1;
        for (long long n = n_min; n < m; n++) {
            if (gcd2(m, n) != 1) continue;
            if ((m + n) % 3 == 0) continue;
            long long perim = 3 * m * n;
            if (perim > L) break;
            count += L / perim;
        }
        if (3 * m * (m / 2 + 1) > L) break;
    }

    return count;
}

long long solve(void) {
    // Find L where count goes from <75085391 to >=75085391
    long long lo = 39000000LL, hi = 42000000LL;
    while (hi - lo > 1) {
        long long mid = (lo + hi) / 2;
        long long fc = formula_count(mid);
        if (fc < 75085391LL) lo = mid;
        else hi = mid;
    }

    printf("Jump at L=%lld: count(%lld)=%lld, count(%lld)=%lld\n",
           hi, lo, formula_count(lo), hi, formula_count(hi));

    // Now brute-force count for L=hi and L=lo to find the exact primitive added:
    printf("BF count for L=%lld:\n", hi);
    long long bf = 0;
    for (long long a = 1; a <= hi; a++) {
        for (long long b = a; b <= hi; b++) {
            long long c2 = a*a - a*b + b*b;
            long long c = isqrt2(c2);
            if (c*c != c2 || c <= 0) continue;
            if (a + b + c > hi) break;
            if (gcd2(gcd2(a,b), c) == 1) {
                long long perm = a+b+c;
                bf += hi / perm;
                if (perm > lo) printf("  (%lld,%lld,%lld) perm=%lld added at L=%lld\n", a,c,b,perm,hi);
            }
        }
    }
    printf("BF total for L=%lld: %lld\n", hi, bf);

    return formula_count(39900000LL);
}

#include "../bench.h"
int main(void) { euler_bench(195, solve); return 0; }
