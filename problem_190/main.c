// Problem 190: Maximising a Weighted Product
// Answer: 371048281
#include <math.h>
#include "../bench.h"

long long solve(void) {
    long long total = 0;
    for (int m = 2; m <= 15; m++) {
        double log_pm = 0.0;
        for (int k = 1; k <= m; k++)
            log_pm += k * log(2.0 * k / (m + 1));
        total += (long long)floor(exp(log_pm));
    }
    return total;
}

int main(void) { euler_bench(190, solve); return 0; }
