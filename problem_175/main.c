// Problem 175: Fractions involving the number of different ways a number can be expressed
// as a sum of powers of 2. Answer: 13717429 (sum of run lengths in SBE "1,13717420,8")
#include <stdio.h>
#include "../bench.h"

long long solve(void) {
    long long p = 123456789LL, q = 987654321LL;
    long long a = p, b = q;
    while (b) { long long t = b; b = a % b; a = t; }
    p /= a; q /= a;

    long long runs[1000];
    int nruns = 0;

    while (p > 0 && q > 0) {
        if (p <= q) {
            long long k;
            if (p == q) {
                k = 1;
                q = 0;
            } else {
                k = (q - 1) / p;
                q -= k * p;
                if (q == p) { k++; q = 0; }
            }
            runs[nruns++] = k;
        } else {
            long long k = (p - 1) / q;
            p -= k * q;
            runs[nruns++] = k;
        }
    }

    for (int i = 0; i < nruns/2; i++) {
        long long t = runs[i]; runs[i] = runs[nruns-1-i]; runs[nruns-1-i] = t;
    }

    long long sum_runs = 0;
    for (int i = 0; i < nruns; i++) sum_runs += runs[i];
    return sum_runs;
}

int main(void) { euler_bench(175, solve); return 0; }
