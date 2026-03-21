// Problem 80: Square Root Digital Expansion
// Answer: 40886
#include <stdio.h>
#include <string.h>
#include <stdbool.h>
#include "../bench.h"

#define NLIMBS 60
#define LIMB_BASE 10000

typedef struct {
    unsigned int d[NLIMBS];
    int len;
} Big;

static void big_zero(Big *a) { memset(a, 0, sizeof(Big)); a->len = 1; }

static void big_from_int(Big *a, unsigned int val) {
    big_zero(a);
    a->d[0] = val % LIMB_BASE;
    if (val >= LIMB_BASE) { a->d[1] = val / LIMB_BASE; a->len = 2; }
    else a->len = 1;
}

static void big_normalize(Big *a) {
    while (a->len > 1 && a->d[a->len-1] == 0) a->len--;
}

static int big_cmp(const Big *a, const Big *b) {
    if (a->len != b->len) return a->len > b->len ? 1 : -1;
    for (int i = a->len - 1; i >= 0; i--) {
        if (a->d[i] != b->d[i]) return a->d[i] > b->d[i] ? 1 : -1;
    }
    return 0;
}

static void big_add(Big *r, const Big *a, const Big *b) {
    int maxlen = a->len > b->len ? a->len : b->len;
    unsigned int carry = 0;
    for (int i = 0; i < maxlen || carry; i++) {
        unsigned int sum = carry;
        if (i < a->len) sum += a->d[i];
        if (i < b->len) sum += b->d[i];
        r->d[i] = sum % LIMB_BASE;
        carry = sum / LIMB_BASE;
        if (i >= maxlen) maxlen = i + 1;
    }
    r->len = maxlen + (carry ? 1 : 0);
    big_normalize(r);
}

static void big_sub(Big *r, const Big *a, const Big *b) {
    int borrow = 0;
    r->len = a->len;
    for (int i = 0; i < a->len; i++) {
        int diff = (int)a->d[i] - (i < b->len ? (int)b->d[i] : 0) - borrow;
        if (diff < 0) { diff += LIMB_BASE; borrow = 1; } else borrow = 0;
        r->d[i] = diff;
    }
    big_normalize(r);
}

static void big_mul_int(Big *r, const Big *a, unsigned int s) {
    unsigned long long carry = 0;
    r->len = a->len;
    for (int i = 0; i < a->len; i++) {
        unsigned long long prod = (unsigned long long)a->d[i] * s + carry;
        r->d[i] = prod % LIMB_BASE;
        carry = prod / LIMB_BASE;
    }
    while (carry > 0) {
        r->d[r->len] = carry % LIMB_BASE;
        carry /= LIMB_BASE;
        r->len++;
    }
    big_normalize(r);
}

static bool is_perfect_square(int n) {
    int s = 0;
    while (s * s < n) s++;
    return s * s == n;
}

static int sqrt_digit_sum(int n) {
    int pairs[120];
    int npairs = 0;
    if (n < 100) pairs[npairs++] = n;
    else { pairs[npairs++] = n / 100; pairs[npairs++] = n % 100; }
    while (npairs < 110) pairs[npairs++] = 0;

    Big p, rem, tmp1, tmp2;
    big_zero(&p);
    big_zero(&rem);

    int digit_count = 0, digit_sum = 0;

    for (int i = 0; i < npairs && digit_count < 100; i++) {
        big_mul_int(&tmp1, &rem, 100);
        Big pair_big;
        big_from_int(&pair_big, pairs[i]);
        big_add(&rem, &tmp1, &pair_big);

        int x = 0;
        Big twenty_p;
        big_mul_int(&twenty_p, &p, 20);

        for (int d = 9; d >= 1; d--) {
            Big base;
            big_from_int(&tmp1, d);
            big_add(&base, &twenty_p, &tmp1);
            big_mul_int(&tmp2, &base, d);

            if (big_cmp(&tmp2, &rem) <= 0) {
                x = d;
                big_sub(&tmp1, &rem, &tmp2);
                memcpy(&rem, &tmp1, sizeof(Big));
                break;
            }
        }

        big_mul_int(&tmp1, &p, 10);
        Big x_big;
        big_from_int(&x_big, x);
        big_add(&p, &tmp1, &x_big);

        digit_sum += x;
        digit_count++;
    }
    return digit_sum;
}

long long solve(void) {
    int total = 0;
    for (int n = 1; n <= 100; n++) {
        if (!is_perfect_square(n)) {
            total += sqrt_digit_sum(n);
        }
    }
    return total;
}

int main(void) { euler_bench(80, solve); return 0; }
