// Problem 120: Square Remainders
// Answer: 333082500
#include <stdio.h>

long long solve(void) {
    long long total = 0;
    for (int a = 3; a <= 1000; a++) {
        long long a2 = (long long)a * a;
        long long max_r = 0;
        for (int n = 1; n < 2 * a; n += 2) {
            long long r = (2LL * n * a) % a2;
            if (r > max_r) max_r = r;
        }
        total += max_r;
    }
    return total;
}

#include "../bench.h"
int main(void) { euler_bench(120, solve); return 0; }
