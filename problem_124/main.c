// Problem 124: Ordered Radicals
// Answer: 21417
#include <stdio.h>
#include <stdlib.h>

#define N 100000

typedef struct { int n; int rad; } Entry;

static Entry entries[N + 1];

static int cmp_entry(const void *a, const void *b) {
    const Entry *ea = (const Entry *)a, *eb = (const Entry *)b;
    if (ea->rad != eb->rad) return ea->rad - eb->rad;
    return ea->n - eb->n;
}

long long solve(void) {
    static int initialized = 0;
    static int rad[N + 1];
    if (!initialized) {
        for (int i = 1; i <= N; i++) rad[i] = 1;
        for (int i = 2; i <= N; i++) {
            if (rad[i] == 1) {
                for (int j = i; j <= N; j += i) {
                    rad[j] *= i;
                }
            }
        }
        initialized = 1;
    }

    for (int i = 1; i <= N; i++) {
        entries[i - 1].n = i;
        entries[i - 1].rad = rad[i];
    }

    qsort(entries, N, sizeof(Entry), cmp_entry);

    return entries[9999].n;
}

#include "../bench.h"
int main(void) { euler_bench(124, solve); return 0; }
