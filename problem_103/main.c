// Problem 103: Special Subset Sums: Optimum
// Answer: 20313839404245
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

static int is_special(int *set, int n) {
    int limit = 1 << n;
    int *sums = (int *)calloc(limit, sizeof(int));
    int *sizes = (int *)calloc(limit, sizeof(int));

    for (int mask = 1; mask < limit; mask++) {
        int s = 0, sz = 0;
        for (int i = 0; i < n; i++) {
            if (mask & (1 << i)) { s += set[i]; sz++; }
        }
        sums[mask] = s;
        sizes[mask] = sz;
    }

    int ok = 1;
    for (int a = 1; a < limit && ok; a++) {
        for (int b = a + 1; b < limit && ok; b++) {
            if (a & b) continue;
            if (sums[a] == sums[b]) { ok = 0; break; }
            if (sizes[a] > sizes[b] && sums[a] <= sums[b]) { ok = 0; break; }
            if (sizes[b] > sizes[a] && sums[b] <= sums[a]) { ok = 0; break; }
        }
    }

    free(sums);
    free(sizes);
    return ok;
}

long long solve(void) {
    int base[] = {20, 31, 38, 39, 40, 42, 45};
    int n = 7;
    int best_sum = 0;
    for (int i = 0; i < n; i++) best_sum += base[i];
    int best[7];
    memcpy(best, base, sizeof(base));

    int set[7];
    for (int d0 = -3; d0 <= 3; d0++)
    for (int d1 = -3; d1 <= 3; d1++)
    for (int d2 = -3; d2 <= 3; d2++)
    for (int d3 = -3; d3 <= 3; d3++)
    for (int d4 = -3; d4 <= 3; d4++)
    for (int d5 = -3; d5 <= 3; d5++)
    for (int d6 = -3; d6 <= 3; d6++) {
        set[0] = base[0] + d0;
        set[1] = base[1] + d1;
        set[2] = base[2] + d2;
        set[3] = base[3] + d3;
        set[4] = base[4] + d4;
        set[5] = base[5] + d5;
        set[6] = base[6] + d6;

        int valid = 1;
        for (int i = 0; i < n && valid; i++) {
            if (set[i] <= 0) valid = 0;
            for (int j = i + 1; j < n && valid; j++) {
                if (set[i] >= set[j]) valid = 0;
            }
        }
        if (!valid) continue;

        int s = 0;
        for (int i = 0; i < n; i++) s += set[i];
        if (s >= best_sum) continue;

        if (is_special(set, n)) {
            best_sum = s;
            memcpy(best, set, sizeof(set));
        }
    }

    long long ans = 0;
    for (int i = 0; i < n; i++) {
        ans = ans * 100 + best[i];
    }
    return ans;
}

#include "../bench.h"
int main(void) { euler_bench(103, solve); return 0; }
