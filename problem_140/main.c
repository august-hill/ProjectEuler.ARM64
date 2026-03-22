// Problem 140: Modified Fibonacci Golden Nuggets
// Answer: 5673835352990
#include <stdlib.h>

static int cmp_ll_140(const void *a, const void *b) {
    long long va = *(const long long *)a, vb = *(const long long *)b;
    return (va > vb) - (va < vb);
}

long long solve(void) {
    long long seeds[][2] = {
        {7, 1}, {8, 2}, {13, 5}, {17, 7}, {32, 14}, {43, 19}
    };
    int nseed = 6;

    long long nuggets[200];
    int count = 0;

    for (int s = 0; s < nseed; s++) {
        long long m = seeds[s][0], k = seeds[s][1];
        for (int iter = 0; iter < 40 && count < 200; iter++) {
            if (m > 7 && m % 5 == 2) {
                long long n = (m - 7) / 5;
                if (n > 0) {
                    nuggets[count++] = n;
                }
            }
            long long nm = 9*m + 20*k;
            long long nk = 4*m + 9*k;
            m = nm; k = nk;
        }
    }

    qsort(nuggets, count, sizeof(long long), cmp_ll_140);

    long long sum = 0;
    int unique = 0;
    for (int i = 0; i < count && unique < 30; i++) {
        if (i == 0 || nuggets[i] != nuggets[i-1]) {
            sum += nuggets[i];
            unique++;
        }
    }
    return sum;
}

#include "../bench.h"
int main(void) { euler_bench(140, solve); return 0; }
