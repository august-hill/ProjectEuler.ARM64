// Problem 139: Pythagorean Tiles
// Answer: 10057761

#define PERIM_LIMIT 100000000LL

static int gcd(int a, int b) {
    while (b) { int t = b; b = a % b; a = t; }
    return a;
}

long long solve(void) {
    long long total = 0;

    for (long long m = 2; 2*m*(m+1) < PERIM_LIMIT; m++) {
        for (long long n = 1; n < m; n++) {
            if ((m + n) % 2 == 0) continue;
            if (gcd((int)m, (int)n) != 1) continue;

            long long a = m*m - n*n;
            long long b = 2*m*n;
            long long c = m*m + n*n;
            long long perim = a + b + c;
            if (perim >= PERIM_LIMIT) break;

            long long gap = a > b ? a - b : b - a;
            if (c % gap == 0) {
                total += (PERIM_LIMIT - 1) / perim;
            }
        }
    }
    return total;
}

#include "../bench.h"
int main(void) { euler_bench(139, solve); return 0; }
