// Problem 127: abc-hits
// Answer: 18407904
#include <string.h>
#include <stdlib.h>

#define LIMIT 120000

static int rad[LIMIT];
static int sorted_by_rad[LIMIT];
static int initialized = 0;

static int gcd(int a, int b) {
    while (b) { int t = b; b = a % b; a = t; }
    return a;
}

static int cmp_by_rad(const void *a, const void *b) {
    int ia = *(const int *)a, ib = *(const int *)b;
    if (rad[ia] != rad[ib]) return rad[ia] - rad[ib];
    return ia - ib;
}

static void init(void) {
    for (int i = 0; i < LIMIT; i++) rad[i] = 1;
    for (int p = 2; p < LIMIT; p++) {
        if (rad[p] == 1) {
            for (int j = p; j < LIMIT; j += p) {
                rad[j] *= p;
            }
        }
    }
    for (int i = 0; i < LIMIT; i++) sorted_by_rad[i] = i;
    qsort(sorted_by_rad, LIMIT, sizeof(int), cmp_by_rad);
}

long long solve(void) {
    if (!initialized) { init(); initialized = 1; }

    long long total = 0;
    for (int c = 2; c < LIMIT; c++) {
        long long rad_limit = (long long)c / rad[c];
        for (int i = 1; i < LIMIT; i++) {
            int a = sorted_by_rad[i];
            if (a == 0) continue;
            if (rad[a] >= rad_limit) break;
            if (a >= c) continue;
            int b = c - a;
            if (b <= a) continue;
            if ((long long)rad[a] * rad[b] >= rad_limit) continue;
            if (gcd(a, b) != 1) continue;
            total += c;
        }
    }
    return total;
}

#include "../bench.h"
int main(void) { euler_bench(127, solve); return 0; }
