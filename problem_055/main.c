// Problem 55: Lychrel Numbers
// Answer: 249
#include <stdio.h>
#include <string.h>

#define MAX_DIGITS 64

typedef struct { int d[MAX_DIGITS]; int len; } BigNum;

static BigNum from_int(int n) {
    BigNum b; b.len = 0;
    while (n > 0) { b.d[b.len++] = n % 10; n /= 10; }
    return b;
}

static BigNum reverse_bn(const BigNum *s) {
    BigNum r; r.len = s->len;
    for (int i = 0; i < s->len; i++) r.d[i] = s->d[s->len - 1 - i];
    return r;
}

static void add_bn(BigNum *a, const BigNum *b) {
    int carry = 0, ml = a->len > b->len ? a->len : b->len;
    for (int i = 0; i < ml || carry; i++) {
        int s = carry + (i < a->len ? a->d[i] : 0) + (i < b->len ? b->d[i] : 0);
        if (i < a->len) a->d[i] = s % 10; else a->d[a->len++] = s % 10;
        carry = s / 10;
    }
}

static int is_palindrome(const BigNum *b) {
    for (int i = 0, j = b->len - 1; i < j; i++, j--)
        if (b->d[i] != b->d[j]) return 0;
    return 1;
}

static int is_lychrel(int n) {
    BigNum v = from_int(n);
    for (int i = 0; i < 50; i++) {
        BigNum r = reverse_bn(&v);
        add_bn(&v, &r);
        if (is_palindrome(&v)) return 0;
    }
    return 1;
}

long long solve(void) {
    int count = 0;
    for (int n = 1; n < 10000; n++)
        if (is_lychrel(n)) count++;
    return count;
}

#include "../bench.h"
int main(void) { euler_bench(55, solve); return 0; }
