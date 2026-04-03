// Problem 152: Writing 1/2 as a Sum of Inverse Squares
// Answer: 301
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "../bench.h"

// Candidates: numbers 2-80 whose prime factors are only from {2,3,5,7,13}
static const int cand_list[] = {2,3,4,5,6,7,8,9,10,12,13,14,15,16,18,20,21,24,27,28,
                                30,32,35,36,39,40,42,45,48,52,54,56,60,63,64,65,70,72,80};
#define CAND_COUNT 39

// LCM of all k^2 = 2^12 * 3^6 * 5^4 * 7^2 * 13^2
static const long long LCM_VAL = 2985984LL * 625 * 49 * 169;

static long long inv_sq_num[CAND_COUNT];
static long long suffix_sum[CAND_COUNT + 1];
static int result_count;

static void dfs(int idx, long long remaining) {
    if (remaining == 0) { result_count++; return; }
    if (remaining < 0) return;
    if (idx >= CAND_COUNT) return;
    if (remaining > suffix_sum[idx]) return;

    long long new_rem = remaining - inv_sq_num[idx];
    if (new_rem >= 0) dfs(idx + 1, new_rem);
    dfs(idx + 1, remaining);
}

long long solve(void) {
    for (int i = 0; i < CAND_COUNT; i++) {
        long long k = cand_list[i];
        inv_sq_num[i] = LCM_VAL / (k * k);
    }
    suffix_sum[CAND_COUNT] = 0;
    for (int i = CAND_COUNT - 1; i >= 0; i--)
        suffix_sum[i] = suffix_sum[i + 1] + inv_sq_num[i];

    result_count = 0;
    dfs(0, LCM_VAL / 2);
    return result_count;
}

int main(void) { euler_bench(152, solve); return 0; }
