// Problem 177: Integer Angled Quadrilaterals
// Answer: 129325
#include <math.h>
#include <string.h>
#include "../bench.h"

static double sinval[181];

static void init_sin(void) {
    for (int i = 0; i <= 180; i++)
        sinval[i] = sin(i * M_PI / 180.0);
}

long long solve(void) {
    static int initialized = 0;
    if (!initialized) { init_sin(); initialized = 1; }

    int count = 0;

    for (int P = 1; P <= 179; P++) {
        int S = 180 - P;
        for (int a2 = 1; a2 < S; a2++) {
            int b1 = S - a2;
            for (int b2 = 1; b2 < P; b2++) {
                int c1 = P - b2;
                for (int c2 = 1; c2 < S; c2++) {
                    int d1 = S - c2;

                    double lhs_partial = sinval[a2] * sinval[b2] * sinval[c2];
                    double rhs_partial = sinval[b1] * sinval[c1] * sinval[d1];

                    for (int a1 = 1; a1 < P; a1++) {
                        int d2 = P - a1;
                        if (a1 + a2 >= 180) continue;
                        if (b1 + b2 >= 180) continue;
                        if (c1 + c2 >= 180) continue;
                        if (d1 + d2 >= 180) continue;

                        double lhs = lhs_partial * sinval[d2];
                        double rhs = rhs_partial * sinval[a1];

                        if (fabs(lhs - rhs) < 1e-8 * (lhs + rhs + 1e-15)) {
                            int reps[8][8] = {
                                {a1,a2,b1,b2,c1,c2,d1,d2},
                                {b1,b2,c1,c2,d1,d2,a1,a2},
                                {c1,c2,d1,d2,a1,a2,b1,b2},
                                {d1,d2,a1,a2,b1,b2,c1,c2},
                                {a2,a1,d2,d1,c2,c1,b2,b1},
                                {d2,d1,c2,c1,b2,b1,a2,a1},
                                {c2,c1,b2,b1,a2,a1,d2,d1},
                                {b2,b1,a2,a1,d2,d1,c2,c1}
                            };

                            int min_idx = 0;
                            for (int r = 1; r < 8; r++) {
                                for (int j = 0; j < 8; j++) {
                                    if (reps[r][j] < reps[min_idx][j]) { min_idx = r; break; }
                                    if (reps[r][j] > reps[min_idx][j]) break;
                                }
                            }

                            if (min_idx == 0) count++;
                        }
                    }
                }
            }
        }
    }

    return count;
}

int main(void) { euler_bench(177, solve); return 0; }
