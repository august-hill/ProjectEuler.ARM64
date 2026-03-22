// Problem 136: Singleton Difference
// Answer: 2544559
#include <stdlib.h>
#include <string.h>

#define LIMIT 50000000

static unsigned char *count;
static int initialized = 0;

static void init(void) {
    count = (unsigned char *)calloc(LIMIT, 1);
}

long long solve(void) {
    if (!initialized) { init(); initialized = 1; }
    memset(count, 0, LIMIT);

    for (int y = 1; y < LIMIT; y++) {
        int d_min = y / 4 + 1;
        int d_max = y - 1;
        long long max_d_for_limit = ((long long)(LIMIT - 1) + (long long)y * y) / (4LL * y);
        if (max_d_for_limit < d_max) d_max = (int)max_d_for_limit;

        for (int d = d_min; d <= d_max; d++) {
            long long n = (long long)y * (4 * d - y);
            if (n > 0 && n < LIMIT) {
                if (count[n] < 3) count[n]++;
            }
        }
    }

    int result = 0;
    for (int n = 1; n < LIMIT; n++) {
        if (count[n] == 1) result++;
    }
    return result;
}

#include "../bench.h"
int main(void) { euler_bench(136, solve); return 0; }
