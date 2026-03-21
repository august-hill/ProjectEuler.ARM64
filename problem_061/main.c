// Problem 61: Cyclical Figurate Numbers
// Answer: 28684
#include <stdio.h>
#include <string.h>

#define MAX_PER_PREFIX 10
static int by_prefix[6][100][MAX_PER_PREFIX];
static int by_prefix_count[6][100];

static void init_figurates(void) {
    memset(by_prefix_count, 0, sizeof(by_prefix_count));
    for (int s = 3; s <= 8; s++) {
        int idx = s - 3;
        for (int n = 1; ; n++) {
            int val = n * ((s-2)*n - (s-4)) / 2;
            if (val >= 10000) break;
            if (val >= 1000) {
                int pfx = val / 100;
                int c = by_prefix_count[idx][pfx];
                if (c < MAX_PER_PREFIX) {
                    by_prefix[idx][pfx][c] = val;
                    by_prefix_count[idx][pfx] = c + 1;
                }
            }
        }
    }
}

static int chain[6];
static int used_type[6];

static int search(int depth) {
    if (depth == 6) {
        if (chain[5] % 100 == chain[0] / 100) {
            int sum = 0;
            for (int i = 0; i < 6; i++) sum += chain[i];
            return sum;
        }
        return 0;
    }
    for (int t = 0; t < 6; t++) {
        if (used_type[t]) continue;
        used_type[t] = 1;
        if (depth == 0) {
            for (int pfx = 10; pfx < 100; pfx++)
                for (int k = 0; k < by_prefix_count[t][pfx]; k++) {
                    int v = by_prefix[t][pfx][k];
                    if (v % 100 < 10) continue;
                    chain[0] = v;
                    int r = search(1);
                    if (r > 0) return r;
                }
        } else {
            int needed = chain[depth-1] % 100;
            if (needed < 10) { used_type[t] = 0; continue; }
            for (int k = 0; k < by_prefix_count[t][needed]; k++) {
                int v = by_prefix[t][needed][k];
                if (v % 100 < 10 && depth < 5) continue;
                chain[depth] = v;
                int r = search(depth + 1);
                if (r > 0) return r;
            }
        }
        used_type[t] = 0;
    }
    return 0;
}

long long solve(void) {
    static int inited = 0;
    if (!inited) { init_figurates(); inited = 1; }
    memset(used_type, 0, sizeof(used_type));
    return search(0);
}

#include "../bench.h"
int main(void) { euler_bench(61, solve); return 0; }
