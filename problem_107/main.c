// Problem 107: Minimal Network
// Answer: 259679
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#define N 40

static char filedata[32768];

static void load_file(void) {
    FILE *f = fopen("p107_network.txt", "r");
    if (!f) return;
    int len = fread(filedata, 1, sizeof(filedata) - 1, f);
    filedata[len] = 0;
    fclose(f);
}

typedef struct { int u, v, w; } Edge;

static int parent[N];

static int find_p(int x) {
    while (parent[x] != x) { parent[x] = parent[parent[x]]; x = parent[x]; }
    return x;
}

static int unite(int a, int b) {
    a = find_p(a); b = find_p(b);
    if (a == b) return 0;
    parent[a] = b;
    return 1;
}

static int cmp_edge(const void *a, const void *b) {
    return ((Edge *)a)->w - ((Edge *)b)->w;
}

long long solve(void) {
    static int initialized = 0;
    if (!initialized) {
        load_file();
        initialized = 1;
    }

    int adj[N][N];
    memset(adj, 0, sizeof(adj));

    char buf[32768];
    strcpy(buf, filedata);
    char *lines[N];
    int nlines = 0;
    char *p = buf;
    while (*p && nlines < N) {
        lines[nlines++] = p;
        while (*p && *p != '\n') p++;
        if (*p == '\n') { *p = 0; p++; }
    }

    for (int i = 0; i < nlines; i++) {
        char *tok = lines[i];
        for (int j = 0; j < nlines; j++) {
            char *next = tok;
            while (*next && *next != ',') next++;
            if (*next == ',') { *next = 0; next++; }

            if (tok[0] != '-') {
                adj[i][j] = atoi(tok);
            }
            tok = next;
        }
    }

    int total_weight = 0;
    Edge edges[N * N];
    int nedges = 0;
    for (int i = 0; i < nlines; i++) {
        for (int j = i + 1; j < nlines; j++) {
            if (adj[i][j] > 0) {
                total_weight += adj[i][j];
                edges[nedges++] = (Edge){i, j, adj[i][j]};
            }
        }
    }

    qsort(edges, nedges, sizeof(Edge), cmp_edge);
    for (int i = 0; i < nlines; i++) parent[i] = i;

    int mst_weight = 0;
    for (int i = 0; i < nedges; i++) {
        if (unite(edges[i].u, edges[i].v)) {
            mst_weight += edges[i].w;
        }
    }

    return total_weight - mst_weight;
}

#include "../bench.h"
int main(void) { euler_bench(107, solve); return 0; }
