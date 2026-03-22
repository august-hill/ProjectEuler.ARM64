// Problem 156: Counting Digits
// Answer: 21295121502550
#include <stdio.h>
#include "../bench.h"

static long long count_digit(long long n, int d) {
    if (n <= 0) return 0;
    long long count = 0;
    long long factor = 1;
    while (factor <= n) {
        long long higher = n / (factor * 10);
        long long curr = (n / factor) % 10;
        long long lower = n % factor;
        if (curr < d) count += higher * factor;
        else if (curr == d) count += higher * factor + lower + 1;
        else count += (higher + 1) * factor;
        factor *= 10;
    }
    return count;
}

static long long sum_fixed;

static void find_zeros(int d, long long lo, long long hi) {
    if (lo > hi) return;
    long long g_lo = count_digit(lo, d) - lo;
    long long g_hi = count_digit(hi, d) - hi;

    if (lo == hi) {
        if (g_lo == 0) sum_fixed += lo;
        return;
    }

    if (g_lo > 0 && g_hi > 0) {
        if (g_lo > hi - lo && g_hi > hi - lo) return;
    }
    if (g_lo < 0 && g_hi < 0) {
        if (-g_lo > 12LL * (hi - lo) && -g_hi > 12LL * (hi - lo)) return;
    }

    if (hi - lo < 1000) {
        for (long long n = lo; n <= hi; n++)
            if (count_digit(n, d) == n) sum_fixed += n;
        return;
    }

    long long mid = lo + (hi - lo) / 2;
    find_zeros(d, lo, mid);
    find_zeros(d, mid + 1, hi);
}

long long solve(void) {
    sum_fixed = 0;
    for (int d = 1; d <= 9; d++)
        find_zeros(d, 1, 200000000000LL);
    return sum_fixed;
}

int main(void) { euler_bench(156, solve); return 0; }
