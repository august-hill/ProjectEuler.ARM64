// Problem 155: Counting Capacitor Circuits
// Answer: 3857447
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "../bench.h"

typedef struct { long long p, q; } Frac;

static long long gcd_ll(long long a, long long b) {
    if (a < 0) a = -a;
    if (b < 0) b = -b;
    while (b) { long long t = b; b = a % b; a = t; }
    return a;
}

static Frac make_frac(long long p, long long q) {
    long long g = gcd_ll(p, q);
    return (Frac){p / g, q / g};
}

#define HASH_SIZE (1 << 24)
#define HASH_MASK (HASH_SIZE - 1)

typedef struct Entry {
    long long p, q;
    int next;
} Entry;

static int hash_heads[HASH_SIZE];
static Entry *entry_pool;
static int pool_idx;
static int total_distinct;

static void hash_init(void) {
    memset(hash_heads, -1, sizeof(hash_heads));
    pool_idx = 0;
    total_distinct = 0;
}

static unsigned hash_frac(long long p, long long q) {
    unsigned h = (unsigned)((p * 1000003ULL + q * 999983ULL) ^ (p >> 16) ^ (q >> 16));
    return h & HASH_MASK;
}

static int hash_insert(long long p, long long q) {
    unsigned h = hash_frac(p, q);
    for (int idx = hash_heads[h]; idx >= 0; idx = entry_pool[idx].next) {
        if (entry_pool[idx].p == p && entry_pool[idx].q == q) return 0;
    }
    entry_pool[pool_idx] = (Entry){p, q, hash_heads[h]};
    hash_heads[h] = pool_idx++;
    total_distinct++;
    return 1;
}

#define MAX_N 19
#define MAX_FRACS 2000000

static Frac *level_fracs[MAX_N];
static int level_count[MAX_N];

long long solve(void) {
    static int initialized = 0;
    static long long result = 0;
    if (initialized) return result;

    entry_pool = (Entry *)malloc(10000000 * sizeof(Entry));
    for (int i = 1; i < MAX_N; i++) {
        level_fracs[i] = (Frac *)malloc(MAX_FRACS * sizeof(Frac));
        level_count[i] = 0;
    }

    hash_init();
    level_fracs[1][0] = make_frac(1, 1);
    level_count[1] = 1;
    hash_insert(1, 1);

    for (int n = 2; n <= 18; n++) {
        int new_count = 0;
        for (int k = 1; k <= n / 2; k++) {
            int j = n - k;
            for (int a = 0; a < level_count[k]; a++) {
                long long ap = level_fracs[k][a].p;
                long long aq = level_fracs[k][a].q;
                int b_start = (k == j) ? a : 0;
                for (int b = b_start; b < level_count[j]; b++) {
                    long long bp = level_fracs[j][b].p;
                    long long bq = level_fracs[j][b].q;

                    long long pp = ap * bq + bp * aq;
                    long long pq = aq * bq;
                    long long g = gcd_ll(pp, pq);
                    pp /= g; pq /= g;
                    if (hash_insert(pp, pq) && new_count < MAX_FRACS)
                        level_fracs[n][new_count++] = (Frac){pp, pq};

                    long long sp = ap * bp;
                    long long sq = ap * bq + bp * aq;
                    g = gcd_ll(sp, sq);
                    sp /= g; sq /= g;
                    if (hash_insert(sp, sq) && new_count < MAX_FRACS)
                        level_fracs[n][new_count++] = (Frac){sp, sq};
                }
            }
        }
        level_count[n] = new_count;
    }

    result = total_distinct;
    free(entry_pool);
    for (int i = 1; i < MAX_N; i++) free(level_fracs[i]);
    initialized = 1;
    return result;
}

int main(void) { euler_bench(155, solve); return 0; }
