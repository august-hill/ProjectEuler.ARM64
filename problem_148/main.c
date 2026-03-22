// Problem 148: Exploring Pascal's Triangle
// Answer: 2129970655314432

long long solve(void) {
    long long N = 1000000000LL;

    int digits[20];
    int ndigits = 0;
    long long tmp = N;
    while (tmp > 0) {
        digits[ndigits++] = (int)(tmp % 7);
        tmp /= 7;
    }

    long long pow28[20];
    pow28[0] = 1;
    for (int i = 1; i < ndigits; i++) pow28[i] = pow28[i-1] * 28;

    long long total = 0;
    long long multiplier = 1;
    for (int i = ndigits - 1; i >= 0; i--) {
        int d = digits[i];
        total += multiplier * d * (d + 1) / 2 * pow28[i];
        multiplier *= (d + 1);
    }

    return total;
}

#include "../bench.h"
int main(void) { euler_bench(148, solve); return 0; }
