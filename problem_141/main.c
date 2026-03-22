// Problem 141: Square Progressive Numbers
// Answer: 878454337159
#include <math.h>

#define LIMIT 1000000000000LL

static int gcd(int a, int b) {
    while (b) { int t = b; b = a % b; a = t; }
    return a;
}

long long solve(void) {
    long long sum = 0;

    for (long long b = 2; b * b * b < LIMIT; b++) {
        for (long long a = 1; a < b; a++) {
            if (gcd((int)a, (int)b) != 1) continue;
            for (long long c = 1; ; c++) {
                long long n = a * c * (b * b * b * c + a);
                if (n >= LIMIT) break;
                long long s = (long long)sqrt((double)n);
                while (s * s < n) s++;
                while (s * s > n) s--;
                if (s * s == n) {
                    sum += n;
                }
            }
        }
    }
    return sum;
}

#include "../bench.h"
int main(void) { euler_bench(141, solve); return 0; }
