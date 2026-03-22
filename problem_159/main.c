// Problem 159: Digital Root Sums of Factorisations
// Answer: 14489159
#include <stdio.h>
#include <string.h>
#include "../bench.h"

#define LIMIT 1000000

static int mdrs_arr[LIMIT];

static int digital_root(int n) {
    if (n == 0) return 0;
    int r = n % 9;
    return r == 0 ? 9 : r;
}

static void init(void) {
    for (int i = 2; i < LIMIT; i++)
        mdrs_arr[i] = digital_root(i);

    for (int i = 2; i < LIMIT; i++) {
        for (long long j = 2; (long long)i * j < LIMIT; j++) {
            int prod = (int)(i * j);
            int val = mdrs_arr[i] + mdrs_arr[j];
            if (val > mdrs_arr[prod])
                mdrs_arr[prod] = val;
        }
    }
}

long long solve(void) {
    static int initialized = 0;
    if (!initialized) { init(); initialized = 1; }

    long long sum = 0;
    for (int i = 2; i < LIMIT; i++)
        sum += mdrs_arr[i];
    return sum;
}

int main(void) { euler_bench(159, solve); return 0; }
