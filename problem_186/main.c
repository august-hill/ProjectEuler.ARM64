// Problem 186: Connectedness of a Network
// Answer: 2325629
#include "../bench.h"

#define USERS 1000000

static int parent[USERS];
static int sz[USERS];

static void uf_init(void) {
    for (int i = 0; i < USERS; i++) { parent[i] = i; sz[i] = 1; }
}

static int uf_find(int x) {
    while (parent[x] != x) { parent[x] = parent[parent[x]]; x = parent[x]; }
    return x;
}

static void uf_union(int a, int b) {
    a = uf_find(a); b = uf_find(b);
    if (a == b) return;
    if (sz[a] < sz[b]) { int t = a; a = b; b = t; }
    parent[b] = a;
    sz[a] += sz[b];
}

long long solve(void) {
    long long rb[55];
    for (int k = 1; k <= 55; k++) {
        long long val = (100003LL - 200003LL * k + 300007LL * (long long)k * k * k) % 1000000;
        if (val < 0) val += 1000000;
        rb[k - 1] = val;
    }

    uf_init();
    int PM = 524287;
    int target = 990000;

    int consumed = 0;
    int rp = 0;
    int calls = 0;

    while (1) {
        long long caller_val, called_val;

        if (consumed < 55) {
            caller_val = rb[consumed++];
        } else {
            int i24 = (rp + 55 - 24) % 55;
            int i55 = rp;
            caller_val = (rb[i24] + rb[i55]) % 1000000;
            rb[rp] = caller_val;
            rp = (rp + 1) % 55;
            consumed++;
        }

        if (consumed < 55) {
            called_val = rb[consumed++];
        } else {
            int i24 = (rp + 55 - 24) % 55;
            int i55 = rp;
            called_val = (rb[i24] + rb[i55]) % 1000000;
            rb[rp] = called_val;
            rp = (rp + 1) % 55;
            consumed++;
        }

        int caller = (int)caller_val;
        int called = (int)called_val;

        if (caller == called) continue;

        calls++;
        uf_union(caller, called);

        if (sz[uf_find(PM)] >= target) return calls;
    }
}

int main(void) { euler_bench(186, solve); return 0; }
