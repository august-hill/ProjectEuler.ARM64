// Problem 119: Digit Power Sum
// Answer: 248155780267521
#include <stdio.h>
#include <math.h>
#include <stdlib.h>

static int digit_sum(long long n) {
    int s = 0;
    while (n > 0) { s += n % 10; n /= 10; }
    return s;
}

static int cmp_ll_119(const void *a, const void *b) {
    long long va = *(long long *)a, vb = *(long long *)b;
    return (va > vb) - (va < vb);
}

long long solve(void) {
    long long results[10000];
    int count = 0;

    for (int base = 2; base <= 200; base++) {
        long long power = (long long)base * base;
        for (int exp = 2; exp <= 50 && power < (long long)1e16; exp++) {
            if (power >= 10 && digit_sum(power) == base) {
                results[count++] = power;
            }
            if (power > (long long)(1e16 / base)) break;
            power *= base;
        }
    }

    qsort(results, count, sizeof(long long), cmp_ll_119);
    return results[29];
}

#include "../bench.h"
int main(void) { euler_bench(119, solve); return 0; }
