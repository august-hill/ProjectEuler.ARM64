// Problem 43: Sub-string Divisibility
// Answer: 16695334890
#include <stdio.h>
#include <string.h>

static void swap(int *a, int *b) { int t = *a; *a = *b; *b = t; }

static void reverse(int *a, int s, int e) {
    while (s < e) { swap(&a[s], &a[e]); s++; e--; }
}

static int next_perm(int *a, int n) {
    int k = n - 2;
    while (k >= 0 && a[k] >= a[k + 1]) k--;
    if (k < 0) return 0;
    int l = n - 1;
    while (a[k] >= a[l]) l--;
    swap(&a[k], &a[l]);
    reverse(a, k + 1, n - 1);
    return 1;
}

long long solve(void) {
    int d[10] = {0,1,2,3,4,5,6,7,8,9};
    int divs[7] = {2,3,5,7,11,13,17};
    long long sum = 0;
    do {
        int valid = 1;
        for (int i = 0; i < 7; i++) {
            int sub = d[i+1]*100 + d[i+2]*10 + d[i+3];
            if (sub % divs[i] != 0) { valid = 0; break; }
        }
        if (valid) {
            long long n = 0, mul = 1;
            for (int i = 9; i >= 0; i--) { n += d[i] * mul; mul *= 10; }
            sum += n;
        }
    } while (next_perm(d, 10));
    return sum;
}

#include "../bench.h"
int main(void) { euler_bench(43, solve); return 0; }
