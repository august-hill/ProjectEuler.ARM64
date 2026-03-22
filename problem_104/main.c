// Problem 104: Pandigital Fibonacci Ends
// Answer: 329468
#include <stdio.h>
#include <string.h>
#include <math.h>

static int is_pandigital(long long n) {
    int digits = 0;
    for (int i = 0; i < 9; i++) {
        int d = n % 10;
        n /= 10;
        if (d == 0) return 0;
        if (digits & (1 << d)) return 0;
        digits |= (1 << d);
    }
    return digits == 0x3FE;
}

long long solve(void) {
    long long MOD = 1000000000LL;
    long long a = 1, b = 1;
    double log_phi = log10((1.0 + sqrt(5.0)) / 2.0);
    double log_sqrt5 = log10(5.0) / 2.0;

    for (int k = 3; ; k++) {
        long long c = (a + b) % MOD;
        a = b;
        b = c;

        if (is_pandigital(b)) {
            double log_fk = (double)k * log_phi - log_sqrt5;
            double frac = log_fk - floor(log_fk);
            long long first9 = (long long)(pow(10.0, frac + 8.0));
            if (is_pandigital(first9)) {
                return k;
            }
        }
    }
}

#include "../bench.h"
int main(void) { euler_bench(104, solve); return 0; }
