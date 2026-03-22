// Problem 150: Searching a triangular array for a sub-triangle having the minimum-sum
// Answer: -271248680
#include <stdlib.h>

#define ROWS 1000

static long long *prefix[ROWS];
static int initialized = 0;

static void init(void) {
    long long t = 0;

    for (int r = 0; r < ROWS; r++) {
        prefix[r] = (long long *)malloc((r + 2) * sizeof(long long));
        prefix[r][0] = 0;
        for (int j = 0; j <= r; j++) {
            t = (615949LL * t + 797807LL) & ((1LL << 20) - 1);
            long long sv = t - (1LL << 19);
            prefix[r][j + 1] = prefix[r][j] + sv;
        }
    }
}

long long solve(void) {
    if (!initialized) { init(); initialized = 1; }

    long long min_sum = 0x7FFFFFFFFFFFFFFFLL;

    for (int r = 0; r < ROWS; r++) {
        for (int c = 0; c <= r; c++) {
            long long sum = 0;
            for (int size = 0; r + size < ROWS; size++) {
                int row = r + size;
                sum += prefix[row][c + size + 1] - prefix[row][c];
                if (sum < min_sum) min_sum = sum;
            }
        }
    }

    return min_sum;
}

#include "../bench.h"
int main(void) { euler_bench(150, solve); return 0; }
