// Problem 129: Repunit Divisibility
// Answer: 1000023

static int repunit_div(int n) {
    int r = 1;
    int k = 1;
    while (r % n != 0) {
        r = (r * 10 + 1) % n;
        k++;
    }
    return k;
}

long long solve(void) {
    for (int n = 1000001; ; n++) {
        if (n % 2 == 0 || n % 5 == 0) continue;
        if (repunit_div(n) > 1000000) return n;
    }
}

#include "../bench.h"
int main(void) { euler_bench(129, solve); return 0; }
