// Problem 56: Powerful Digit Sum
// Answer: 972
#include <stdio.h>
#include <string.h>

#define MAX_DIGITS 200

typedef struct { int d[MAX_DIGITS]; int len; } BigNum;

static void set_one(BigNum *b) { memset(b->d, 0, sizeof(b->d)); b->d[0] = 1; b->len = 1; }

static void mul_int(BigNum *b, int f) {
    int carry = 0;
    for (int i = 0; i < b->len; i++) {
        int p = b->d[i] * f + carry;
        b->d[i] = p % 10; carry = p / 10;
    }
    while (carry > 0) { b->d[b->len++] = carry % 10; carry /= 10; }
}

static int digit_sum(const BigNum *b) {
    int s = 0;
    for (int i = 0; i < b->len; i++) s += b->d[i];
    return s;
}

long long solve(void) {
    int max_sum = 0;
    BigNum power;
    for (int a = 2; a < 100; a++) {
        set_one(&power);
        for (int b = 1; b < 100; b++) {
            mul_int(&power, a);
            int s = digit_sum(&power);
            if (s > max_sum) max_sum = s;
        }
    }
    return max_sum;
}

#include "../bench.h"
int main(void) { euler_bench(56, solve); return 0; }
