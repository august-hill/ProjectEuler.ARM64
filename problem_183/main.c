// Problem 183: Maximum Product of Parts
// Answer: 48861552
#include <math.h>
#include "../bench.h"

static long long gcd(long long a, long long b) {
    while (b) { long long t = b; b = a % b; a = t; }
    return a;
}

static int is_terminating(long long num, long long den) {
    long long g = gcd(num, den);
    den /= g;
    while (den % 2 == 0) den /= 2;
    while (den % 5 == 0) den /= 5;
    return den == 1;
}

long long solve(void) {
    long long total = 0;

    for (int N = 5; N <= 10000; N++) {
        int kf = (int)floor((double)N / exp(1.0));
        int kc = kf + 1;
        if (kf < 2) kf = 2;

        double vf = kf * log((double)N / kf);
        double vc = kc * log((double)N / kc);
        int k = (vf >= vc) ? kf : kc;

        if (is_terminating(N, k))
            total -= N;
        else
            total += N;
    }

    return total;
}

int main(void) { euler_bench(183, solve); return 0; }
