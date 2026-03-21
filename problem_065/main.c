// Problem 65: Convergents of e
// Answer: 272
#include <stdio.h>
#include <string.h>

#define MAX_DIGITS 80

typedef struct { unsigned char d[MAX_DIGITS]; } BigNum;

static BigNum big_from(int n) {
    BigNum r; memset(r.d, 0, MAX_DIGITS);
    int i = 0;
    while (n > 0) { r.d[i++] = n % 10; n /= 10; }
    return r;
}

static BigNum big_add(const BigNum *a, const BigNum *b) {
    BigNum r; int carry = 0;
    for (int i = 0; i < MAX_DIGITS; i++) {
        int s = a->d[i] + b->d[i] + carry;
        r.d[i] = s % 10; carry = s / 10;
    }
    return r;
}

static BigNum big_mul_small(const BigNum *a, int k) {
    BigNum r; int carry = 0;
    for (int i = 0; i < MAX_DIGITS; i++) {
        int s = a->d[i] * k + carry;
        r.d[i] = s % 10; carry = s / 10;
    }
    return r;
}

static int digit_sum(const BigNum *a) {
    int s = 0;
    for (int i = 0; i < MAX_DIGITS; i++) s += a->d[i];
    return s;
}

static int cf_coeff(int k) {
    if (k == 0) return 2;
    int j = k - 1;
    if (j % 3 == 1) return 2 * (j / 3 + 1);
    return 1;
}

long long solve(void) {
    BigNum h0 = big_from(1);
    BigNum h1 = big_from(2);
    for (int k = 1; k < 100; k++) {
        int a = cf_coeff(k);
        BigNum mul = big_mul_small(&h1, a);
        BigNum nh = big_add(&mul, &h0);
        h0 = h1; h1 = nh;
    }
    return digit_sum(&h1);
}

#include "../bench.h"
int main(void) { euler_bench(65, solve); return 0; }
