// Problem 153: Investigating Gaussian Integers
// Answer: 17971254122360635
#include <stdio.h>
#include <math.h>
#include "../bench.h"

#define N 100000000LL

static long long S_div(long long M) {
    if (M <= 0) return 0;
    long long result = 0;
    long long k = 1;
    while (k <= M) {
        long long q = M / k;
        long long k_max = M / q;
        long long sum_k = (k_max - k + 1) * (k + k_max) / 2;
        result += q * sum_k;
        k = k_max + 1;
    }
    return result;
}

static long long gcd_ll(long long a, long long b) {
    while (b) { long long t = b; b = a % b; a = t; }
    return a;
}

long long solve(void) {
    long long real_sum = S_div(N);
    long long gauss_sum = 0;
    for (long long a = 1; a * a + 1 <= N; a++) {
        for (long long b = 1; a * a + b * b <= N; b++) {
            if (gcd_ll(a, b) != 1) continue;
            long long p = a * a + b * b;
            long long M = N / p;
            gauss_sum += 2LL * a * S_div(M);
        }
    }
    return real_sum + gauss_sum;
}

int main(void) { euler_bench(153, solve); return 0; }
