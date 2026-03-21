// Problem 67: Maximum Path Sum II
// Answer: 7273
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_ROWS 100
#define MAX_COLS 100

static int triangle[MAX_ROWS][MAX_COLS];
static int num_rows = 0;

static void load_triangle(void) {
    FILE *f = fopen("p067_triangle.txt", "r");
    if (!f) { fprintf(stderr, "Cannot open p067_triangle.txt\n"); exit(1); }
    char line[1024];
    num_rows = 0;
    while (fgets(line, sizeof(line), f)) {
        int col = 0; char *p = line;
        while (*p) {
            while (*p == ' ' || *p == '\t') p++;
            if (*p == '\n' || *p == '\r' || *p == '\0') break;
            triangle[num_rows][col++] = atoi(p);
            while (*p >= '0' && *p <= '9') p++;
        }
        if (col > 0) num_rows++;
    }
    fclose(f);
}

long long solve(void) {
    static int inited = 0;
    if (!inited) { load_triangle(); inited = 1; }
    int dp[MAX_COLS];
    for (int j = 0; j < num_rows; j++) dp[j] = triangle[num_rows-1][j];
    for (int i = num_rows-2; i >= 0; i--)
        for (int j = 0; j <= i; j++)
            dp[j] = triangle[i][j] + (dp[j] > dp[j+1] ? dp[j] : dp[j+1]);
    return dp[0];
}

#include "../bench.h"
int main(void) { euler_bench(67, solve); return 0; }
