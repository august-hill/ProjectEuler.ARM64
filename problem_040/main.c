// Problem 40: Champernowne's Constant
// Answer: 210
#include <stdio.h>
#include <stdlib.h>

long long solve(void) {
    // Calculate d(n) for specific positions without building full string
    // Positions: 1, 10, 100, 1000, 10000, 100000, 1000000
    int targets[] = {1, 10, 100, 1000, 10000, 100000, 1000000};
    long long product = 1;
    int pos = 0;
    int target_idx = 0;
    char num_buf[10];
    for (int i = 1; target_idx < 7; i++) {
        int len = snprintf(num_buf, sizeof(num_buf), "%d", i);
        for (int j = 0; j < len && target_idx < 7; j++) {
            pos++;
            if (pos == targets[target_idx]) {
                product *= (num_buf[j] - '0');
                target_idx++;
            }
        }
    }
    return product;
}

#include "../bench.h"
int main(void) { euler_bench(40, solve); return 0; }
