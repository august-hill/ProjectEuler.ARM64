// Problem 57: Square Root Convergents
// Answer: 153
#include <stdio.h>
#include <string.h>

#define MAX_DIGITS 400

typedef struct { int d[MAX_DIGITS]; int len; } BigNum;

static void set_one(BigNum *b) { memset(b->d, 0, sizeof(b->d)); b->d[0] = 1; b->len = 1; }

static BigNum bn_add(const BigNum *a, const BigNum *b) {
    BigNum r; int carry = 0;
    int ml = a->len > b->len ? a->len : b->len;
    r.len = 0;
    for (int i = 0; i < ml || carry; i++) {
        int s = carry + (i < a->len ? a->d[i] : 0) + (i < b->len ? b->d[i] : 0);
        r.d[r.len++] = s % 10; carry = s / 10;
    }
    return r;
}

static BigNum bn_add_twice(const BigNum *a, const BigNum *b) {
    BigNum r; int carry = 0;
    int ml = a->len > b->len ? a->len : b->len;
    r.len = 0;
    for (int i = 0; i < ml || carry; i++) {
        int s = carry + (i < a->len ? a->d[i] : 0) + (i < b->len ? 2*b->d[i] : 0);
        r.d[r.len++] = s % 10; carry = s / 10;
    }
    return r;
}

long long solve(void) {
    int count = 0;
    BigNum n, d;
    set_one(&n); set_one(&d);
    for (int i = 0; i < 1000; i++) {
        BigNum nn = bn_add_twice(&n, &d);
        BigNum nd = bn_add(&n, &d);
        n = nn; d = nd;
        if (n.len > d.len) count++;
    }
    return count;
}

#include "../bench.h"
int main(void) { euler_bench(57, solve); return 0; }
