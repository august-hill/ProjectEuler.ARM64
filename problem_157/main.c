// Problem 157: Solving the Diophantine equation 1/a + 1/b = p/10^n
// Answer: 53490
#include <stdio.h>
#include <math.h>
#include "../bench.h"

static int num_divisors(long long n) {
    if (n <= 0) return 0;
    int count = 0;
    for (long long d = 1; d * d <= n; d++) {
        if (n % d == 0) {
            count++;
            if (d != n / d) count++;
        }
    }
    return count;
}

static long long gcd_ll(long long a, long long b) {
    while (b) { long long t = b; b = a % b; a = t; }
    return a;
}

long long solve(void) {
    long long total = 0;

    for (int n = 1; n <= 9; n++) {
        long long ten_n = 1;
        for (int i = 0; i < n; i++) ten_n *= 10;

        int divs[200];
        int ndivs = 0;
        for (long long d = 1; d * d <= ten_n; d++) {
            if (ten_n % d == 0) {
                divs[ndivs++] = (int)d;
                if (d != ten_n / d) divs[ndivs++] = (int)(ten_n / d);
            }
        }

        for (int i = 0; i < ndivs; i++) {
            for (int j = i; j < ndivs; j++) {
                long long x = divs[i], y = divs[j];
                if (x * y > ten_n) continue;
                if (ten_n % (x * y) != 0) continue;
                if (gcd_ll(x, y) != 1) continue;

                long long m = ten_n / (x * y);
                long long D = m * (x + y);
                int nd = num_divisors(D);
                total += nd;
            }
        }
    }

    return total;
}

int main(void) { euler_bench(157, solve); return 0; }
