// Problem 115: Counting Block Combinations II
// Answer: 168
#include <stdio.h>

static long long count_ways(int m, int n) {
    long long temp[1001];
    for (int i = 0; i <= n; i++) temp[i] = 0;
    temp[0] = 1;

    for (int i = 1; i <= n; i++) {
        temp[i] = temp[i - 1];
        for (int len = m; len <= i; len++) {
            int start = i - len;
            if (start == 0) {
                temp[i] += 1;
            } else if (start == 1) {
                temp[i] += 1;
            } else {
                temp[i] += temp[start - 1];
            }
        }
    }

    return temp[n];
}

long long solve(void) {
    int m = 50;
    for (int n = m; n <= 1000; n++) {
        if (count_ways(m, n) > 1000000) {
            return n;
        }
    }
    return -1;
}

#include "../bench.h"
int main(void) { euler_bench(115, solve); return 0; }
