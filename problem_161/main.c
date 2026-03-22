// Problem 161: Triominoes
// Answer: 20574308184277971
#include <stdio.h>
#include <string.h>
#include "../bench.h"

#define R 12
#define C 9
#define NCELLS (R * C)
#define WINDOW (2 * C + 1)

static const int SHAPES[6][3][2] = {
    {{0,0},{0,1},{0,2}},
    {{0,0},{1,0},{2,0}},
    {{0,0},{0,1},{1,0}},
    {{0,0},{0,1},{1,1}},
    {{0,0},{1,0},{1,1}},
    {{0,0},{1,-1},{1,0}},
};

static long long dpA[1 << WINDOW];
static long long dpB[1 << WINDOW];
static int initialized = 0;
static long long answer_cache = 0;

long long solve(void) {
    if (initialized) return answer_cache;
    initialized = 1;

    long long *cur_dp = dpA;
    long long *nxt_dp = dpB;

    memset(cur_dp, 0, sizeof(long long) * (1 << WINDOW));
    cur_dp[0] = 1;

    for (int pos = 0; pos < NCELLS; pos++) {
        int row = pos / C;
        int col = pos % C;

        memset(nxt_dp, 0, sizeof(long long) * (1 << WINDOW));

        for (int mask = 0; mask < (1 << WINDOW); mask++) {
            if (cur_dp[mask] == 0) continue;
            long long ways = cur_dp[mask];

            if (mask & 1) {
                nxt_dp[mask >> 1] += ways;
                continue;
            }

            for (int s = 0; s < 6; s++) {
                int ok = 1;
                int offsets[3];
                for (int k = 0; k < 3; k++) {
                    int r2 = row + SHAPES[s][k][0];
                    int c2 = col + SHAPES[s][k][1];
                    if (r2 < 0 || r2 >= R || c2 < 0 || c2 >= C) { ok = 0; break; }
                    int pos2 = r2 * C + c2;
                    int off = pos2 - pos;
                    if (off < 0 || off >= WINDOW) { ok = 0; break; }
                    offsets[k] = off;
                }
                if (!ok) continue;

                int new_mask = mask;
                int conflict = 0;
                for (int k = 0; k < 3; k++) {
                    if (new_mask & (1 << offsets[k])) { conflict = 1; break; }
                    new_mask |= (1 << offsets[k]);
                }
                if (conflict) continue;

                nxt_dp[new_mask >> 1] += ways;
            }
        }

        long long *tmp = cur_dp;
        cur_dp = nxt_dp;
        nxt_dp = tmp;
    }

    answer_cache = cur_dp[0];
    return answer_cache;
}

int main(void) { euler_bench(161, solve); return 0; }
