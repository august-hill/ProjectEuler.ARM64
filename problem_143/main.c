// Problem 143: Torricelli Triangles
// Answer: 30758397
#include <stdlib.h>
#include <string.h>
#include <math.h>

#define LIMIT 120000

static int gcd(int a, int b) {
    while (b) { int t = b; b = a % b; a = t; }
    return a;
}

#define HASH_SIZE (1 << 22)
#define HASH_MASK (HASH_SIZE - 1)

static int pair_keys[HASH_SIZE][2];
static char pair_used[HASH_SIZE];
static int initialized = 0;

static unsigned int pair_hash(int x, int y) {
    unsigned int h = (unsigned int)x * 1000003u + (unsigned int)y;
    return h & HASH_MASK;
}

static void set_pair(int x, int y) {
    unsigned int h = pair_hash(x, y);
    while (pair_used[h]) {
        if (pair_keys[h][0] == x && pair_keys[h][1] == y) return;
        h = (h + 1) & HASH_MASK;
    }
    pair_keys[h][0] = x;
    pair_keys[h][1] = y;
    pair_used[h] = 1;
}

static int has_pair(int x, int y) {
    unsigned int h = pair_hash(x, y);
    while (pair_used[h]) {
        if (pair_keys[h][0] == x && pair_keys[h][1] == y) return 1;
        h = (h + 1) & HASH_MASK;
    }
    return 0;
}

static int *all_adj;
static int *adj_start;
static int *adj_size;
static int total_pairs;

static void init(void) {
    memset(pair_used, 0, sizeof(pair_used));

    int pair_cap = 1000000;
    int (*pairs)[2] = malloc(pair_cap * sizeof(int[2]));
    int npairs = 0;

    for (int m = 2; m <= 500; m++) {
        for (int n = 1; n < m; n++) {
            if (gcd(m, n) != 1) continue;
            if ((m - n) % 3 == 0) continue;

            int x = m * m - n * n;
            int y = 2 * m * n + n * n;

            for (int k = 1; ; k++) {
                int kx = k * x, ky = k * y;
                if (kx + ky > LIMIT) break;

                set_pair(kx, ky);
                set_pair(ky, kx);

                if (npairs + 2 > pair_cap) {
                    pair_cap *= 2;
                    pairs = realloc(pairs, pair_cap * sizeof(int[2]));
                }
                pairs[npairs][0] = kx; pairs[npairs][1] = ky; npairs++;
                if (kx != ky) {
                    pairs[npairs][0] = ky; pairs[npairs][1] = kx; npairs++;
                }
            }
        }
    }

    adj_size = calloc(LIMIT + 1, sizeof(int));
    for (int i = 0; i < npairs; i++) {
        adj_size[pairs[i][0]]++;
    }

    adj_start = malloc((LIMIT + 2) * sizeof(int));
    adj_start[0] = 0;
    for (int i = 1; i <= LIMIT + 1; i++) {
        adj_start[i] = adj_start[i-1] + (i <= LIMIT ? adj_size[i-1] : 0);
    }
    total_pairs = adj_start[LIMIT + 1];

    all_adj = malloc(total_pairs * sizeof(int));
    int *fill = calloc(LIMIT + 1, sizeof(int));
    for (int i = 0; i < npairs; i++) {
        int v = pairs[i][0];
        all_adj[adj_start[v] + fill[v]++] = pairs[i][1];
    }
    free(fill);
    free(pairs);
}

long long solve(void) {
    if (!initialized) { init(); initialized = 1; }

    static char *seen = NULL;
    if (!seen) seen = (char *)calloc(LIMIT + 1, 1);
    memset(seen, 0, LIMIT + 1);

    long long total = 0;

    for (int p = 1; p <= LIMIT; p++) {
        if (adj_size[p] == 0) continue;

        int *p_adj = all_adj + adj_start[p];
        int p_cnt = adj_size[p];

        for (int i = 0; i < p_cnt; i++) {
            int q = p_adj[i];
            if (q <= p) continue;

            int max_r = LIMIT - p - q;
            if (max_r < 1) continue;

            int *q_adj = all_adj + adj_start[q];
            int q_cnt = adj_size[q];

            for (int j = 0; j < q_cnt; j++) {
                int r = q_adj[j];
                if (r > max_r) continue;
                if (has_pair(p, r)) {
                    int s = p + q + r;
                    if (!seen[s]) {
                        seen[s] = 1;
                        total += s;
                    }
                }
            }
        }
    }

    return total;
}

#include "../bench.h"
int main(void) { euler_bench(143, solve); return 0; }
