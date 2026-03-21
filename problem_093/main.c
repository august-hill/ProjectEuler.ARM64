// Problem 93: Arithmetic Expressions
// Answer: 1258
#include <stdio.h>
#include <math.h>
#include <string.h>
#include "../bench.h"

#define MAX_VAL 3500

static int eval_all(double a, double b, double out[]) {
    int n = 0;
    out[n++] = a + b;
    out[n++] = a - b;
    out[n++] = b - a;
    out[n++] = a * b;
    if (fabs(b) > 1e-12) out[n++] = a / b;
    if (fabs(a) > 1e-12) out[n++] = b / a;
    return n;
}

long long solve(void) {
    int best_digits = 0;
    int best_count = 0;
    char seen[MAX_VAL];

    for (int a = 1; a <= 9; a++)
    for (int b = a+1; b <= 9; b++)
    for (int c = b+1; c <= 9; c++)
    for (int d = c+1; d <= 9; d++) {
        double digits[4] = {a, b, c, d};
        memset(seen, 0, sizeof(seen));

        int perm[24][4];
        int np = 0;
        for (int i = 0; i < 4; i++)
        for (int j = 0; j < 4; j++) {
            if (j == i) continue;
            for (int k = 0; k < 4; k++) {
                if (k == i || k == j) continue;
                int l = 6 - i - j - k;
                perm[np][0] = i; perm[np][1] = j;
                perm[np][2] = k; perm[np][3] = l;
                np++;
            }
        }

        for (int p = 0; p < 24; p++) {
            double w = digits[perm[p][0]], x = digits[perm[p][1]];
            double y = digits[perm[p][2]], z = digits[perm[p][3]];

            double wx[6]; int nwx = eval_all(w, x, wx);
            for (int i = 0; i < nwx; i++) {
                double wxy[6]; int nwxy = eval_all(wx[i], y, wxy);
                for (int j = 0; j < nwxy; j++) {
                    double wxyz[6]; int nwxyz = eval_all(wxy[j], z, wxyz);
                    for (int k = 0; k < nwxyz; k++) {
                        double r = wxyz[k];
                        if (r > 0.5 && r < MAX_VAL && fabs(r - round(r)) < 1e-9)
                            seen[(int)round(r)] = 1;
                    }
                }
            }

            double yz[6]; int nyz = eval_all(y, z, yz);
            for (int i = 0; i < nwx; i++) {
                for (int j = 0; j < nyz; j++) {
                    double res[6]; int nres = eval_all(wx[i], yz[j], res);
                    for (int k = 0; k < nres; k++) {
                        double r = res[k];
                        if (r > 0.5 && r < MAX_VAL && fabs(r - round(r)) < 1e-9)
                            seen[(int)round(r)] = 1;
                    }
                }
            }
        }

        int count = 0;
        for (int n = 1; n < MAX_VAL; n++) {
            if (seen[n]) count = n;
            else break;
        }
        if (count > best_count) {
            best_count = count;
            best_digits = a * 1000 + b * 100 + c * 10 + d;
        }
    }
    return best_digits;
}

int main(void) { euler_bench(93, solve); return 0; }
