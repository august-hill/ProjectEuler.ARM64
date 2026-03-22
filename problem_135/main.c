// Problem 135: Same Differences
// Answer: 4989
#include <string.h>

#define LIMIT 1000000

static int count[LIMIT];

long long solve(void) {
    memset(count, 0, sizeof(count));

    for (int y = 1; y < LIMIT; y++) {
        int d_min = y / 4 + 1;
        int d_max = y - 1;
        long long max_n = (long long)(LIMIT - 1);
        int d_lim = (int)((max_n + (long long)y * y) / (4 * (long long)y));
        if (d_lim < d_max) d_max = d_lim;

        for (int d = d_min; d <= d_max; d++) {
            int n = y * (4 * d - y);
            if (n > 0 && n < LIMIT) {
                count[n]++;
            }
        }
    }

    int result = 0;
    for (int n = 1; n < LIMIT; n++) {
        if (count[n] == 10) result++;
    }
    return result;
}

#include "../bench.h"
int main(void) { euler_bench(135, solve); return 0; }
