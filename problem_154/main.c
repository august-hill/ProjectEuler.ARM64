// Problem 154: Exploring Pascal's Pyramid
// Answer: 479742450
#include <stdio.h>
#include <string.h>
#include "../bench.h"

#define N 200000

static long long f2[N + 1];
static long long f5[N + 1];

static void init(void) {
    f2[0] = 0; f5[0] = 0;
    for (int i = 1; i <= N; i++) {
        int v = 0, x = i;
        while (x % 2 == 0) { v++; x /= 2; }
        f2[i] = f2[i - 1] + v;
        v = 0; x = i;
        while (x % 5 == 0) { v++; x /= 5; }
        f5[i] = f5[i - 1] + v;
    }
}

long long solve(void) {
    static int initialized = 0;
    if (!initialized) { init(); initialized = 1; }

    long long total_2 = f2[N];
    long long total_5 = f5[N];
    long long count = 0;

    for (int a = 0; a <= N / 3; a++) {
        long long ra2 = total_2 - f2[a];
        long long ra5 = total_5 - f5[a];
        for (int b = a; b <= (N - a) / 2; b++) {
            int c = N - a - b;
            long long rem2 = ra2 - f2[b] - f2[c];
            long long rem5 = ra5 - f5[b] - f5[c];
            if (rem2 >= 12 && rem5 >= 12) {
                if (a == b && b == c) count += 1;
                else if (a == b || b == c) count += 3;
                else count += 6;
            }
        }
    }

    return count;
}

int main(void) { euler_bench(154, solve); return 0; }
