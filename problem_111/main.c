// Problem 111: Primes with Runs
// Answer: 612407567715
#include <stdio.h>
#include <string.h>
#include <math.h>

static unsigned long long mod_pow(unsigned long long base, unsigned long long exp, unsigned long long mod) {
    __uint128_t result = 1;
    base %= mod;
    while (exp > 0) {
        if (exp & 1) result = result * base % mod;
        exp >>= 1;
        base = ((__uint128_t)base * base) % mod;
    }
    return (unsigned long long)result;
}

static int is_prime(unsigned long long n) {
    if (n < 2) return 0;
    if (n < 4) return 1;
    if (n % 2 == 0 || n % 3 == 0) return 0;
    unsigned long long witnesses[] = {2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37};
    unsigned long long d = n - 1;
    int r = 0;
    while (d % 2 == 0) { d /= 2; r++; }
    for (int w = 0; w < 12; w++) {
        unsigned long long a = witnesses[w];
        if (a >= n) continue;
        unsigned long long x = mod_pow(a, d, n);
        if (x == 1 || x == n - 1) continue;
        int composite = 1;
        for (int i = 0; i < r - 1; i++) {
            x = ((__uint128_t)x * x) % n;
            if (x == n - 1) { composite = 0; break; }
        }
        if (composite) return 0;
    }
    return 1;
}

static long long sum_primes_with_repeated(int d, int nfree, int *found) {
    int n = 10;
    long long total = 0;

    for (int mask = 0; mask < (1 << n); mask++) {
        if (__builtin_popcount(mask) != nfree) continue;

        int free_pos[10];
        int nf = 0;
        for (int i = 0; i < n; i++) {
            if (mask & (1 << i)) free_pos[nf++] = i;
        }

        int digits[10];
        int assignment[10];
        for (int i = 0; i < nf; i++) assignment[i] = 0;

        while (1) {
            int valid = 1;
            for (int i = 0; i < nf; i++) {
                if (assignment[i] == d) { valid = 0; break; }
            }

            if (valid) {
                for (int i = 0; i < n; i++) digits[i] = d;
                for (int i = 0; i < nf; i++) digits[free_pos[i]] = assignment[i];

                if (digits[0] != 0) {
                    unsigned long long num = 0;
                    for (int i = 0; i < n; i++) num = num * 10 + digits[i];
                    if (is_prime(num)) {
                        total += num;
                        (*found)++;
                    }
                }
            }

            int carry = 1;
            for (int i = nf - 1; i >= 0 && carry; i--) {
                assignment[i]++;
                if (assignment[i] >= 10) {
                    assignment[i] = 0;
                } else {
                    carry = 0;
                }
            }
            if (carry) break;
        }
    }

    return total;
}

long long solve(void) {
    long long total = 0;

    for (int d = 0; d <= 9; d++) {
        for (int nfree = 0; nfree <= 9; nfree++) {
            int found = 0;
            long long s = sum_primes_with_repeated(d, nfree, &found);
            if (found > 0) {
                total += s;
                break;
            }
        }
    }

    return total;
}

#include "../bench.h"
int main(void) { euler_bench(111, solve); return 0; }
