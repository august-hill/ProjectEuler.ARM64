// Problem 189: Tri-colouring a Triangular Grid
// Answer: 10834893628237824
#include <string.h>
#include "../bench.h"

#define MAXROW 8

static int pow3[10];

static void init_pow3(void) {
    pow3[0] = 1;
    for (int i = 1; i <= 9; i++) pow3[i] = pow3[i - 1] * 3;
}

static int get_colour(int state, int pos) {
    return (state / pow3[pos]) % 3;
}

static long long count_down_ways(int *prev_up, int r, int *cur_up) {
    long long ways = 1;
    for (int j = 0; j < r; j++) {
        int a = prev_up[j], b = cur_up[j], c = cur_up[j + 1];
        int distinct = 1;
        if (b != a) distinct++;
        if (c != a && c != b) distinct++;
        if (distinct == 3) return 0;
        ways *= (3 - distinct);
    }
    return ways;
}

long long solve(void) {
    static int inited = 0;
    if (!inited) { init_pow3(); inited = 1; }

    #define MAXSTATES 6561
    long long dp[MAXSTATES];
    long long ndp[MAXSTATES];

    memset(dp, 0, sizeof(dp));
    dp[0] = 1; dp[1] = 1; dp[2] = 1;

    for (int row = 1; row < MAXROW; row++) {
        int nup_cur = row;
        int nup_next = row + 1;

        memset(ndp, 0, sizeof(ndp));

        for (int s = 0; s < pow3[nup_cur]; s++) {
            if (dp[s] == 0) continue;

            int prev_up[MAXROW + 1];
            for (int j = 0; j < nup_cur; j++)
                prev_up[j] = get_colour(s, j);

            for (int ns = 0; ns < pow3[nup_next]; ns++) {
                int cur_up[MAXROW + 1];
                for (int j = 0; j < nup_next; j++)
                    cur_up[j] = get_colour(ns, j);

                long long ways = count_down_ways(prev_up, nup_cur, cur_up);
                if (ways > 0)
                    ndp[ns] += dp[s] * ways;
            }
        }

        memcpy(dp, ndp, sizeof(dp));
    }

    long long total = 0;
    for (int s = 0; s < pow3[MAXROW]; s++)
        total += dp[s];

    return total;
}

int main(void) { euler_bench(189, solve); return 0; }
