// Problem 112: Bouncy Numbers
// Answer: 1587000
#include <stdio.h>

static int is_bouncy(int n) {
    int increasing = 0, decreasing = 0;
    int prev = n % 10;
    n /= 10;
    while (n > 0) {
        int d = n % 10;
        if (d < prev) increasing = 1;
        if (d > prev) decreasing = 1;
        if (increasing && decreasing) return 1;
        prev = d;
        n /= 10;
    }
    return 0;
}

long long solve(void) {
    int bouncy = 0;
    for (int n = 1; ; n++) {
        if (is_bouncy(n)) bouncy++;
        if (bouncy * 100 == n * 99) {
            return n;
        }
    }
}

#include "../bench.h"
int main(void) { euler_bench(112, solve); return 0; }
