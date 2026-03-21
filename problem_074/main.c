// Problem 74: Digit Factorial Chains
// Answer: 402
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "../bench.h"

#define CACHE_SIZE 2200000

static int factorials[10];
static unsigned char chain_len[CACHE_SIZE];

static void init_factorials(void) {
    factorials[0] = 1;
    for (int i = 1; i <= 9; i++) {
        factorials[i] = factorials[i - 1] * i;
    }
}

static long long digit_factorial_sum(long long n) {
    long long sum = 0;
    while (n > 0) {
        sum += factorials[n % 10];
        n /= 10;
    }
    return sum;
}

long long solve(void) {
    init_factorials();
    memset(chain_len, 0, sizeof(chain_len));

    chain_len[1] = 1;
    chain_len[2] = 1;
    chain_len[145] = 1;
    chain_len[169] = 3;
    chain_len[363601] = 3;
    chain_len[1454] = 3;
    chain_len[871] = 2;
    chain_len[45361] = 2;
    chain_len[872] = 2;
    chain_len[45362] = 2;

    int count = 0;
    long long chain[64];

    for (long long start = 1; start < 1000000; start++) {
        int chain_idx = 0;
        long long n = start;

        while (1) {
            if (n < CACHE_SIZE && chain_len[n] > 0) {
                int remaining = chain_len[n];
                int total = chain_idx + remaining;

                for (int i = 0; i < chain_idx; i++) {
                    int len = total - i;
                    if (chain[i] < CACHE_SIZE && len <= 255) {
                        chain_len[chain[i]] = (unsigned char)len;
                    }
                }

                if (total == 60)
                    count++;
                break;
            }

            int found = 0;
            for (int i = 0; i < chain_idx; i++) {
                if (chain[i] == n) {
                    found = 1;
                    break;
                }
            }
            if (found) break;

            chain[chain_idx++] = n;
            n = digit_factorial_sum(n);
        }
    }

    return count;
}

int main(void) { euler_bench(74, solve); return 0; }
