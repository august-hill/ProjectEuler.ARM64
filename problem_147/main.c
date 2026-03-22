// Problem 147: Rectangles in Cross-Hatched Grids
// Answer: 846910284

long long solve(void) {
    long long total = 0;
    for (int m = 1; m <= 47; m++) {
        for (int n = 1; n <= 43; n++) {
            long long aa = (long long)m * (m + 1) / 2 * n * (n + 1) / 2;

            long long diag = 0;

            for (int s1 = 1; s1 <= m + n - 2; s1++) {
                for (int s2 = s1 + 1; s2 <= m + n - 1; s2++) {
                    int lo = -s1;
                    int tmp = s2 - 2 * n;
                    if (tmp > lo) lo = tmp;

                    int hi = s1;
                    tmp = 2 * m - s2;
                    if (tmp < hi) hi = tmp;

                    if (lo >= hi) continue;

                    long long cnt = hi - lo + 1;
                    if (cnt >= 2) {
                        diag += cnt * (cnt - 1) / 2;
                    }
                }
            }

            total += aa + diag;
        }
    }
    return total;
}

#include "../bench.h"
int main(void) { euler_bench(147, solve); return 0; }
