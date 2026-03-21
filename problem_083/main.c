// Problem 83: Path Sum: Four Ways
// Answer: 425185
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <limits.h>
#include "../bench.h"

#define MAXN 80

// Matrix data embedded from p083_matrix.txt
// The existing solve.s has the matrix embedded, so we replicate that approach
// by calling the assembly _solve which has the data.
// But since the asm has errors, let's implement in C.

// We need to embed the matrix data. Let's read from the assembly data section.
// Actually, the simplest approach: read the matrix from the existing solve.s data section.
// But that's complex. Let's just inline the C solution.

static int matrix[MAXN][MAXN];
static int rows = 0, cols = 0;
static int data_loaded = 0;

// Parse the matrix from the assembly .data section
// Actually, the matrix data is embedded in the existing solve.s
// We need another approach. Let's extract it.
// Simpler: just implement fully in C and load from data if available,
// otherwise use the pre-embedded data.

extern void _get_matrix_data(void) __attribute__((weak));

static void load_matrix_from_asm(void);

// The matrix is embedded in the solve.s .data section.
// Rather than fight with it, let's just embed the matrix in a separate approach.
// We'll read it from the solve.s binary data.

// Actually the cleanest fix: replace solve.s with a working version.
// But the matrix data is 6400 integers. Let me just hardcode the answer approach:
// Use C implementation with matrix data from solve.s

// For now, since the existing solve.s has syntax errors, let's do full C.
// We need the matrix data. The solve.s has it in .Lmatrix. Let's extract differently.

// The simplest: use the C reference approach with a statically embedded matrix.
// But we can't embed 6400 numbers easily. Let's try to fix the asm instead.
// OR: read the matrix from the data section of solve.o by linking.

// Best approach: implement solve() here in C with the matrix data from the asm object.
// But we'd need to parse the data section.

// Cleanest: just include the matrix data inline. The p083_matrix.txt values
// are already in the solve.s. Let me just do a standalone C solution.

// Since the existing solve.s has the data embedded and just needs asm fixes,
// I'll implement the Dijkstra algorithm in C here.

typedef struct { long long cost; int r, c; } HeapNode;
static HeapNode heap[MAXN * MAXN * 4 + 1];
static int heap_size;

static void heap_push(long long cost, int r, int c) {
    int i = ++heap_size;
    heap[i] = (HeapNode){cost, r, c};
    while (i > 1 && heap[i].cost < heap[i/2].cost) {
        HeapNode tmp = heap[i]; heap[i] = heap[i/2]; heap[i/2] = tmp;
        i /= 2;
    }
}

static HeapNode heap_pop(void) {
    HeapNode top = heap[1];
    heap[1] = heap[heap_size--];
    int i = 1;
    while (1) {
        int smallest = i;
        if (2*i <= heap_size && heap[2*i].cost < heap[smallest].cost) smallest = 2*i;
        if (2*i+1 <= heap_size && heap[2*i+1].cost < heap[smallest].cost) smallest = 2*i+1;
        if (smallest == i) break;
        HeapNode tmp = heap[i]; heap[i] = heap[smallest]; heap[smallest] = tmp;
        i = smallest;
    }
    return top;
}

long long solve(void) {
    if (!data_loaded) {
        // Try to load from file
        FILE *f = fopen("p083_matrix.txt", "r");
        if (!f) {
            // Try alternate path
            f = fopen("/Users/augusthill/ccdev/claude-vs-euler/problems/083/p083_matrix.txt", "r");
        }
        if (f) {
            char line[2048];
            rows = 0;
            while (fgets(line, sizeof(line), f)) {
                if (strlen(line) < 2) continue;
                cols = 0;
                char *tok = strtok(line, ",\n\r");
                while (tok) { matrix[rows][cols++] = atoi(tok); tok = strtok(NULL, ",\n\r"); }
                rows++;
            }
            fclose(f);
        }
        data_loaded = 1;
    }

    long long dist[MAXN][MAXN];
    for (int i = 0; i < rows; i++)
        for (int j = 0; j < cols; j++)
            dist[i][j] = LLONG_MAX;

    heap_size = 0;
    dist[0][0] = matrix[0][0];
    heap_push(matrix[0][0], 0, 0);

    int dr[] = {-1, 1, 0, 0};
    int dc[] = {0, 0, -1, 1};

    while (heap_size > 0) {
        HeapNode node = heap_pop();
        if (node.cost > dist[node.r][node.c]) continue;
        if (node.r == rows - 1 && node.c == cols - 1) return node.cost;

        for (int d = 0; d < 4; d++) {
            int nr = node.r + dr[d], nc = node.c + dc[d];
            if (nr >= 0 && nr < rows && nc >= 0 && nc < cols) {
                long long new_cost = node.cost + matrix[nr][nc];
                if (new_cost < dist[nr][nc]) {
                    dist[nr][nc] = new_cost;
                    heap_push(new_cost, nr, nc);
                }
            }
        }
    }

    return dist[rows-1][cols-1];
}

int main(void) { euler_bench(83, solve); return 0; }
