// Problem 95: Amicable Chains
// Answer: 14316
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "../bench.h"

#define LIMIT 1000001

long long solve(void) {
    static int sum_div[LIMIT];
    static char visited[LIMIT];
    static int chain[LIMIT];
    static char in_chain[LIMIT];
    static int initialized = 0;

    if (!initialized) {
        for (int i = 0; i < LIMIT; i++) sum_div[i] = 1;
        sum_div[0] = 0;
        sum_div[1] = 0;
        for (int i = 2; i < LIMIT; i++) {
            for (int j = 2 * i; j < LIMIT; j += i) {
                sum_div[j] += i;
            }
        }
        initialized = 1;
    }

    memset(visited, 0, sizeof(visited));
    memset(in_chain, 0, sizeof(in_chain));
    int best_len = 0;
    int best_min = 0;

    for (int start = 2; start < LIMIT; start++) {
        if (visited[start]) continue;

        int chain_len = 0;
        int n = start;

        while (n > 0 && n < LIMIT && !in_chain[n]) {
            in_chain[n] = 1;
            chain[chain_len++] = n;
            n = sum_div[n];
        }

        if (n > 0 && n < LIMIT && in_chain[n]) {
            int cycle_start = 0;
            for (int i = 0; i < chain_len; i++) {
                if (chain[i] == n) { cycle_start = i; break; }
            }
            int cycle_len = chain_len - cycle_start;
            if (cycle_len > best_len) {
                best_len = cycle_len;
                best_min = chain[cycle_start];
                for (int i = cycle_start + 1; i < chain_len; i++) {
                    if (chain[i] < best_min) best_min = chain[i];
                }
            }
        }

        for (int i = 0; i < chain_len; i++) {
            if (chain[i] < LIMIT) {
                visited[chain[i]] = 1;
                in_chain[chain[i]] = 0;
            }
        }
    }

    return best_min;
}

int main(void) { euler_bench(95, solve); return 0; }
