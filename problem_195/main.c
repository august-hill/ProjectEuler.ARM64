// Problem 195: 60-degree Triangle Inscribed Circle Counting
// Answer: 75443028
#include "../bench.h"

static int gcd2(long long a, long long b) {
    while (b) { long long t = b; b = a % b; a = t; }
    return (int)a;
}

static long long formula_count(long long L) {
    long long count = L / 3;

    for (long long m = 3; ; m++) {
        for (long long n = 1; 2 * n < m; n++) {
            if (gcd2(m, n) != 1) continue;
            if ((m + n) % 3 == 0) continue;
            long long perim = (2 * m - n) * (m + n);
            if (perim > L) break;
            count += L / perim;
        }
        if ((2 * m - 1) * (m + 1) > L) break;
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
    return formula_count(39900000LL);
}

int main(void) { euler_bench(195, solve); return 0; }
