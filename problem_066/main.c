// Problem 66: Diophantine Equation
// Answer: 661
#include <stdio.h>
#include <string.h>
#include <math.h>

#define MAX_DIGITS 120

typedef struct { unsigned char d[MAX_DIGITS]; } BigNum;

static BigNum big_zero(void) { BigNum r; memset(r.d, 0, MAX_DIGITS); return r; }

static BigNum big_from(unsigned long long n) {
    BigNum r = big_zero(); int i = 0;
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

static BigNum big_mul_small(const BigNum *a, unsigned long long k) {
    BigNum r = big_zero(); unsigned long long carry = 0;
    for (int i = 0; i < MAX_DIGITS; i++) {
        unsigned long long s = (unsigned long long)a->d[i] * k + carry;
        r.d[i] = s % 10; carry = s / 10;
    }
    return r;
}

static BigNum big_mul(const BigNum *a, const BigNum *b) {
    BigNum r = big_zero();
    for (int i = 0; i < MAX_DIGITS; i++) {
        if (a->d[i] == 0) continue;
        unsigned int carry = 0;
        for (int j = 0; j < MAX_DIGITS && i+j < MAX_DIGITS; j++) {
            unsigned int s = r.d[i+j] + (unsigned int)a->d[i] * b->d[j] + carry;
            r.d[i+j] = s % 10; carry = s / 10;
        }
    }
    return r;
}

static int big_cmp(const BigNum *a, const BigNum *b) {
    for (int i = MAX_DIGITS-1; i >= 0; i--)
        if (a->d[i] != b->d[i]) return a->d[i] - b->d[i];
    return 0;
}

long long solve(void) {
    BigNum best_x = big_zero();
    int best_d = 0;
    for (int d = 2; d <= 1000; d++) {
        int a0 = (int)sqrt((double)d);
        if (a0 * a0 == d) continue;
        unsigned long long m = 0, dn = 1, a = a0;
        BigNum hp2 = big_from(1), hp1 = big_from(a0);
        BigNum kp2 = big_from(0), kp1 = big_from(1);
        while (1) {
            m = dn * a - m;
            dn = (d - m * m) / dn;
            a = (a0 + m) / dn;
            BigNum t1 = big_mul_small(&hp1, a);
            BigNum nh = big_add(&t1, &hp2);
            BigNum t2 = big_mul_small(&kp1, a);
            BigNum nk = big_add(&t2, &kp2);
            BigNum h2 = big_mul(&nh, &nh);
            BigNum k2 = big_mul(&nk, &nk);
            BigNum dk2 = big_mul_small(&k2, d);
            BigNum one = big_from(1);
            BigNum dk2p1 = big_add(&dk2, &one);
            if (big_cmp(&h2, &dk2p1) == 0) {
                if (big_cmp(&nh, &best_x) > 0) { best_x = nh; best_d = d; }
                break;
            }
            hp2 = hp1; hp1 = nh;
            kp2 = kp1; kp1 = nk;
        }
    }
    return best_d;
}

#include "../bench.h"
int main(void) { euler_bench(66, solve); return 0; }
