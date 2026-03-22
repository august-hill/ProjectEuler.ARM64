// Problem 101: Optimum Polynomial
// Answer: 37076114526
#include <stdio.h>
#include <string.h>

static long long u(int n) {
    long long val = 0;
    long long power = 1;
    for (int i = 0; i <= 10; i++) {
        if (i % 2 == 0)
            val += power;
        else
            val -= power;
        power *= n;
    }
    return val;
}

static long long lagrange_eval(long long *y, int k, int x) {
    double result = 0.0;
    for (int i = 0; i < k; i++) {
        double li = 1.0;
        for (int j = 0; j < k; j++) {
            if (j != i) {
                li *= (double)(x - (j + 1)) / (double)((i + 1) - (j + 1));
            }
        }
        result += y[i] * li;
    }
    return (long long)(result + (result > 0 ? 0.5 : -0.5));
}

long long solve(void) {
    long long y[11];
    for (int i = 0; i < 11; i++) {
        y[i] = u(i + 1);
    }

    long long total = 0;
    for (int k = 1; k <= 10; k++) {
        long long predicted = lagrange_eval(y, k, k + 1);
        long long actual = u(k + 1);
        if (predicted != actual) {
            total += predicted;
        }
    }
    return total;
}

#include "../bench.h"
int main(void) { euler_bench(101, solve); return 0; }
