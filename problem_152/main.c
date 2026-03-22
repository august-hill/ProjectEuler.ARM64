// Problem 152: Writing 1/2 as a Sum of Inverse Squares
// Answer: 301
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "../bench.h"

typedef __int128 i128;

static i128 gcd128(i128 a, i128 b) {
    if (a < 0) a = -a;
    if (b < 0) b = -b;
    while (b) { i128 t = b; b = a % b; a = t; }
    return a;
}

typedef struct { i128 num, den; } Frac;

static Frac frac_sub(Frac a, Frac b) {
    i128 n = a.num * b.den - b.num * a.den;
    i128 d = a.den * b.den;
    i128 g = gcd128(n < 0 ? -n : n, d < 0 ? -d : d);
    if (g == 0) return (Frac){0, 1};
    return (Frac){n / g, d / g};
}

static Frac frac_add(Frac a, Frac b) {
    i128 n = a.num * b.den + b.num * a.den;
    i128 d = a.den * b.den;
    i128 g = gcd128(n < 0 ? -n : n, d < 0 ? -d : d);
    if (g == 0) return (Frac){0, 1};
    return (Frac){n / g, d / g};
}

static int cand_list[] = {2,3,4,5,6,7,8,9,10,12,13,14,15,16,18,20,21,24,27,28,
                          30,32,35,36,39,40,42,45,48,52,54,56,60,63,64,65,70,72,80};
static int cand_count;
static Frac inv_sq[50];
static Frac suffix_sum[50];
static int result_count;

static void dfs(int idx, Frac remaining) {
    if (remaining.num == 0) { result_count++; return; }
    if (remaining.num < 0) return;
    if (idx >= cand_count) return;

    i128 lhs = remaining.num * suffix_sum[idx].den;
    i128 rhs = suffix_sum[idx].num * remaining.den;
    if (lhs > rhs) return;

    Frac new_rem = frac_sub(remaining, inv_sq[idx]);
    if (new_rem.num >= 0) dfs(idx + 1, new_rem);
    dfs(idx + 1, remaining);
}

long long solve(void) {
    cand_count = (int)(sizeof(cand_list) / sizeof(cand_list[0]));
    for (int i = 0; i < cand_count; i++) {
        i128 k = cand_list[i];
        inv_sq[i] = (Frac){1, k * k};
    }
    suffix_sum[cand_count] = (Frac){0, 1};
    for (int i = cand_count - 1; i >= 0; i--)
        suffix_sum[i] = frac_add(suffix_sum[i + 1], inv_sq[i]);

    result_count = 0;
    Frac target = {1, 2};
    dfs(0, target);
    return result_count;
}

int main(void) { euler_bench(152, solve); return 0; }
