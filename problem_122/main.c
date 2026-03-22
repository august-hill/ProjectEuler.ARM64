// Problem 122: Efficient Exponentiation
// Answer: 1582
#include <stdio.h>
#include <string.h>

#define MAXN 200

static int best[MAXN + 1];

static void dfs(int *chain, int len, int max_depth) {
    int cur = chain[len - 1];
    if (cur > MAXN) return;

    if (best[cur] > len - 1) {
        best[cur] = len - 1;
    }

    if (len - 1 >= max_depth) return;

    for (int i = len - 1; i >= 0; i--) {
        int next = cur + chain[i];
        if (next > MAXN) continue;
        if (next <= cur) continue;

        chain[len] = next;
        dfs(chain, len + 1, max_depth);
    }
}

long long solve(void) {
    static int initialized = 0;
    if (!initialized) {
        for (int i = 0; i <= MAXN; i++) best[i] = 100;
        best[1] = 0;

        int chain[20];
        chain[0] = 1;

        for (int depth = 1; depth <= 12; depth++) {
            dfs(chain, 1, depth);
        }

        initialized = 1;
    }

    int total = 0;
    for (int i = 1; i <= MAXN; i++) {
        total += best[i];
    }
    return total;
}

#include "../bench.h"
int main(void) { euler_bench(122, solve); return 0; }
