// Problem 170: Find the largest 0 to 9 pandigital that can be formed by concatenating
// products of an integer with two or more other integers (inputs also pandigital).
// Answer: 9857164023
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "../bench.h"

static int is_pandigital(long long num) {
    if (num < 1000000000LL || num > 9999999999LL) return 0;
    int seen[10] = {0};
    while (num > 0) {
        int d = num % 10;
        if (seen[d]) return 0;
        seen[d] = 1;
        num /= 10;
    }
    for (int i = 0; i < 10; i++) if (!seen[i]) return 0;
    return 1;
}

static long long concat_ll(long long a, long long b) {
    long long tmp = b == 0 ? 10 : b;
    long long mult = 1;
    while (mult <= tmp / 10 + 1 && b >= mult * 10) mult *= 10;
    if (b == 0) return a * 10;
    mult = 1;
    long long bt = b;
    while (bt > 0) { mult *= 10; bt /= 10; }
    return a * mult + b;
}

static long long check_factor(long long n, int *digs_f, int nf, int *digs_nf, int nnf) {
    int arr[10];
    for (int i = 0; i < nf; i++) arr[i] = digs_f[i];
    for (int i = 0; i < nf-1; i++)
        for (int j = i+1; j < nf; j++)
            if (arr[i] > arr[j]) { int t=arr[i]; arr[i]=arr[j]; arr[j]=t; }

    do {
        if (arr[0] == 0 && nf > 1) goto next_perm;
        long long f = 0;
        for (int i = 0; i < nf; i++) f = f*10 + arr[i];
        long long nf_val = n * f;
        int check[10] = {0};
        long long tmp = nf_val;
        int cnt_d = 0;
        while (tmp > 0) { check[tmp%10]++; tmp /= 10; cnt_d++; }
        if (cnt_d != nnf) goto next_perm;
        int sorted_nf_check[10];
        int si = 0;
        for (int d = 0; d <= 9; d++) for (int c = 0; c < check[d]; c++) sorted_nf_check[si++] = d;
        int ok = 1;
        for (int i = 0; i < nnf; i++) if (sorted_nf_check[i] != digs_nf[i]) { ok=0; break; }
        if (ok) return f;
        next_perm:;
        int j = nf-2;
        while (j >= 0 && arr[j] >= arr[j+1]) j--;
        if (j < 0) break;
        int l = nf-1;
        while (arr[l] <= arr[j]) l--;
        int t = arr[j]; arr[j] = arr[l]; arr[l] = t;
        int lo = j+1, hi = nf-1;
        while (lo < hi) { t=arr[lo]; arr[lo]=arr[hi]; arr[hi]=t; lo++; hi--; }
    } while (1);
    return -1;
}

static long long answer_cache = 0;
static int initialized = 0;

long long solve(void) {
    if (initialized) return answer_cache;
    initialized = 1;

    long long best = 0;

    for (int n = 2; n <= 98; n++) {
        int n_digs[3], nn = 0;
        int tmp = n;
        while (tmp > 0) { n_digs[nn++] = tmp%10; tmp /= 10; }
        int n_seen[10] = {0};
        int valid_n = 1;
        for (int i = 0; i < nn; i++) {
            if (n_seen[n_digs[i]]) { valid_n=0; break; }
            n_seen[n_digs[i]] = 1;
        }
        if (!valid_n) continue;

        int rem_digs[10], nrem = 0;
        for (int d = 0; d <= 9; d++) if (!n_seen[d]) rem_digs[nrem++] = d;

        int nsub = 1 << nrem;
        for (int mask1 = 1; mask1 < nsub - 1; mask1++) {
            int digs_f1[10], nf1 = 0;
            int digs_f2[10], nf2 = 0;
            for (int i = 0; i < nrem; i++) {
                if (mask1 & (1<<i)) digs_f1[nf1++] = rem_digs[i];
                else digs_f2[nf2++] = rem_digs[i];
            }

            int max_e = 10 - (nf1 + nf2);
            for (int e1 = 0; e1 <= max_e; e1++) {
                int nf1p = nf1 + e1;
                int nf2p = 10 - nf1p;
                if (nf2p < nf2 || nf2p > nf2 + max_e) continue;
                if (nf1p <= 0 || nf2p <= 0) continue;

                int nc = nf1p;
                if (nc > 10 || 10-nc < nf2p) continue;
                int combo[10];
                for (int i = 0; i < nc; i++) combo[i] = i;
                while (1) {
                    int digs_nf1[10], digs_nf2[10];
                    int in_combo[10] = {0};
                    for (int i = 0; i < nc; i++) in_combo[combo[i]] = 1;
                    int n1=0, n2=0;
                    for (int d=0;d<=9;d++) {
                        if (in_combo[d]) digs_nf1[n1++]=d;
                        else digs_nf2[n2++]=d;
                    }

                    long long f1 = check_factor(n, digs_f1, nf1, digs_nf1, nf1p);
                    if (f1 >= 0) {
                        long long f2 = check_factor(n, digs_f2, nf2, digs_nf2, nf2p);
                        if (f2 >= 0) {
                            long long p1 = (long long)n * f1, p2 = (long long)n * f2;
                            long long prod_concat = concat_ll(p1, p2);
                            if (is_pandigital(prod_concat) && prod_concat > best)
                                best = prod_concat;
                        }
                    }

                    int i2 = nc-1;
                    while (i2 >= 0 && combo[i2] == 10 - nc + i2) i2--;
                    if (i2 < 0) break;
                    combo[i2]++;
                    for (int jj = i2+1; jj < nc; jj++) combo[jj] = combo[jj-1]+1;
                }
            }
        }
    }

    answer_cache = best;
    return answer_cache;
}

int main(void) { euler_bench(170, solve); return 0; }
