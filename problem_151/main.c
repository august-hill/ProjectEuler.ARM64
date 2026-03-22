// Problem 151: Paper Sheets of Standard Sizes: An Expected-Value Problem
// Answer: 464399
#include <stdio.h>
#include <string.h>
#include "../bench.h"

static double memo[2][4][8][16];
static int visited[2][4][8][16];

static double expected(int a2, int a3, int a4, int a5) {
    int total = a2 + a3 + a4 + a5;
    if (total == 0) return 0.0;
    if (a2 == 0 && a3 == 0 && a4 == 0 && a5 == 1) return 0.0;
    if (visited[a2][a3][a4][a5]) return memo[a2][a3][a4][a5];
    visited[a2][a3][a4][a5] = 1;

    double single = (total == 1) ? 1.0 : 0.0;
    double result = single;

    if (a5 > 0) result += (double)a5 / total * expected(a2, a3, a4, a5 - 1);
    if (a4 > 0) result += (double)a4 / total * expected(a2, a3, a4 - 1, a5 + 1);
    if (a3 > 0) result += (double)a3 / total * expected(a2, a3 - 1, a4 + 1, a5 + 1);
    if (a2 > 0) result += (double)a2 / total * expected(a2 - 1, a3 + 1, a4 + 1, a5 + 1);

    memo[a2][a3][a4][a5] = result;
    return result;
}

long long solve(void) {
    memset(visited, 0, sizeof(visited));
    double result = expected(1, 1, 1, 1);
    return (long long)(result * 1000000 + 0.5);
}

int main(void) { euler_bench(151, solve); return 0; }
