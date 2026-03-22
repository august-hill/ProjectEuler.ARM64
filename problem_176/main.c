// Problem 176: Right-angled Triangles that Share a Cathetus
// Answer: 96818198400000
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include "../bench.h"

static int cmp_desc(const void *a, const void *b) {
    return *(const int *)b - *(const int *)a;
}

static long double best_log;
static int best_exps[20];
static int best_nexp;
static int best_a;

static const int small_primes[] = {3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43};

static long double compute_log(int a, int *exps, int ne) {
    long double v = (long double)a * logl(2.0L);
    for (int i = 0; i < ne; i++)
        v += (long double)exps[i] * logl((long double)small_primes[i]);
    return v;
}

static void find_factorizations(int n, int min_val, int *factors, int nf, int a) {
    if (n >= min_val && n % 2 == 1) {
        factors[nf] = n;
        int total = nf + 1;
        int exps[20];
        for (int i = 0; i < total; i++) exps[i] = (factors[i] - 1) / 2;
        qsort(exps, total, sizeof(int), cmp_desc);
        long double v = compute_log(a, exps, total);
        if (v < best_log) {
            best_log = v;
            best_a = a;
            best_nexp = total;
            memcpy(best_exps, exps, total * sizeof(int));
        }
    }

    for (int f = min_val; (long long)f * f <= n; f++) {
        if (f % 2 == 0) continue;
        if (n % f == 0) {
            factors[nf] = f;
            find_factorizations(n / f, f, factors, nf + 1, a);
        }
    }
}

long long solve(void) {
    best_log = 1e30;
    int factors[20];

    find_factorizations(95095, 3, factors, 0, 0);

    int divs[100];
    int nd = 0;
    for (int d = 1; d * d <= 95095; d++) {
        if (95095 % d == 0) {
            divs[nd++] = d;
            if (d != 95095 / d) divs[nd++] = 95095 / d;
        }
    }

    for (int i = 0; i < nd; i++) {
        int d = divs[i];
        if (d % 2 == 0) continue;
        int a = (d + 1) / 2;
        if (a < 1) continue;
        int remaining = 95095 / d;
        if (remaining == 1) {
            long double v = (long double)a * logl(2.0L);
            if (v < best_log) {
                best_log = v;
                best_a = a;
                best_nexp = 0;
            }
        } else {
            find_factorizations(remaining, 3, factors, 0, a);
        }
    }

    long long result = 1;
    for (int i = 0; i < best_a; i++) result *= 2;
    for (int i = 0; i < best_nexp; i++) {
        long long base = small_primes[i];
        for (int j = 0; j < best_exps[i]; j++) result *= base;
    }

    return result;
}

int main(void) { euler_bench(176, solve); return 0; }
