// Problem 167: Investigating Ulam sequences
// Answer: 3916160068885
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "../bench.h"

#define TARGET 100000000000LL

typedef unsigned char u8;
static inline int cnt_get(u8 *a, long long i) {
    return (a[i>>2] >> ((i&3)<<1)) & 3;
}
static inline void cnt_inc(u8 *a, long long i) {
    int shift = (int)((i&3)<<1);
    int v = (a[i>>2] >> shift) & 3;
    if (v < 2) a[i>>2] = (u8)((a[i>>2] & ~(3 << shift)) | ((v+1) << shift));
}

static long long ulam_nth(int b, long long n) {
    int max_terms = 500000;
    if (b >= 15) max_terms = 1000000;

    long long *seq = malloc((long long)max_terms * sizeof(long long));
    if (!seq) return -1;
    int diff_cap = max_terms;
    long long *diffs = malloc((long long)diff_cap * sizeof(long long));
    if (!diffs) { free(seq); return -1; }

    seq[0] = 2;
    seq[1] = b;
    int count = 2;

    long long max_val = (long long)max_terms * (b + 2);
    if (max_val < 500000) max_val = 500000;
    long long arr_bytes = (max_val / 4) + 2;
    u8 *cnt = calloc(arr_bytes, 1);
    if (!cnt) { free(seq); free(diffs); return -1; }
    cnt_inc(cnt, 2 + b);

    int ndiffs = 0;
    int period = -1;
    int period_dstart = -1;

    while (count < max_terms) {
        long long prev = seq[count-1];

        if (prev * 2 + b + 1000 >= max_val) {
            long long nmax = max_val + (long long)max_terms * b + 1000000;
            long long narr = (nmax / 4) + 2;
            u8 *nc = realloc(cnt, narr);
            if (!nc) { free(seq); free(diffs); free(cnt); return -1; }
            cnt = nc;
            memset(cnt + arr_bytes, 0, narr - arr_bytes);
            arr_bytes = narr;
            max_val = nmax;
        }

        long long next_val = -1;
        for (long long v = prev + 1; v <= max_val; v++) {
            if (cnt_get(cnt, v) == 1) { next_val = v; break; }
        }
        if (next_val == -1) break;

        seq[count] = next_val;
        diffs[ndiffs++] = next_val - prev;

        for (int i = 0; i < count; i++) {
            long long sum = seq[i] + next_val;
            if (sum < max_val) cnt_inc(cnt, sum);
        }
        count++;

        if (period == -1 && ndiffs >= 2000 && ndiffs % 1000 == 0) {
            for (int P = 1; P <= ndiffs / 25; P++) {
                if (25 * P > ndiffs) break;
                int match = 1;
                for (int k = 0; k < 20 * P; k++) {
                    if (diffs[ndiffs-1-k] != diffs[ndiffs-1-k-P]) { match=0; break; }
                }
                if (match) {
                    period = P;
                    period_dstart = 0;
                    for (int i = ndiffs - 2*P - 1; i >= 1; i--) {
                        if (diffs[i] != diffs[i+P]) { period_dstart = i+1; break; }
                    }
                    goto found;
                }
            }
        }
    }
found:;

    free(cnt);

    if (period == -1) {
        long long r = (n <= (long long)count) ? seq[n-1] : -1;
        free(seq); free(diffs);
        return r;
    }

    long long ps = 0;
    for (int i = 0; i < period; i++) ps += diffs[period_dstart + i];
    long long s01 = (long long)period_dstart + 2;
    long long s0v = seq[period_dstart + 1];

    if (n < s01) { long long r = seq[n-1]; free(seq); free(diffs); return r; }

    long long off = n - s01;
    long long fp = off / period;
    long long rem = off % period;
    long long bv = s0v;
    for (long long k = 0; k < rem; k++) bv += diffs[period_dstart + k];
    long long result = bv + fp * ps;
    free(seq); free(diffs);
    return result;
}

static int initialized = 0;
static long long answer_cache = 0;

long long solve(void) {
    if (initialized) return answer_cache;
    initialized = 1;

    long long total = 0;
    for (int k = 5; k <= 21; k += 2)
        total += ulam_nth(k, TARGET);
    answer_cache = total;
    return answer_cache;
}

int main(void) { euler_bench(167, solve); return 0; }
