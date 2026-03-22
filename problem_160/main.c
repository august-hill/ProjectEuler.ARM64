// Problem 160: Factorial Trailing Digits
// Answer: 16576
#include <stdio.h>
#include "../bench.h"

#define MOD 100000

static long long power_mod(long long base, long long exp, long long mod) {
    long long result = 1;
    base %= mod;
    while (exp > 0) {
        if (exp & 1) result = result * base % mod;
        base = base * base % mod;
        exp >>= 1;
    }
    return result;
}

static long long factmod(long long n, long long p, long long pk) {
    if (n <= 1) return 1;
    long long full_period_prod = 1;
    for (long long i = 1; i <= pk; i++) {
        if (i % p != 0) full_period_prod = full_period_prod * (i % pk) % pk;
    }
    long long num_full_periods = n / pk;
    long long result = power_mod(full_period_prod, num_full_periods, pk);
    long long remainder = n % pk;
    for (long long i = 1; i <= remainder; i++) {
        if (i % p != 0) result = result * i % pk;
    }
    result = result * factmod(n / p, p, pk) % pk;
    return result;
}

static long long count_factors(long long n, long long p) {
    long long count = 0;
    long long pk = p;
    while (pk <= n) {
        count += n / pk;
        pk *= p;
    }
    return count;
}

long long solve(void) {
    long long N = 1000000000000LL;

    long long v2 = count_factors(N, 2);
    long long v5 = count_factors(N, 5);

    long long mod5 = 3125;
    long long r5 = factmod(N, 5, mod5);
    long long inv2_mod3125 = power_mod(2, 2499, mod5);
    long long f_mod_3125 = r5 * power_mod(inv2_mod3125, v5 % 2500, mod5) % mod5;

    long long f_mod_32 = 0;
    (void)v2;

    long long inv32 = power_mod(32, 2499, mod5);
    long long k = f_mod_3125 * inv32 % mod5;
    long long result = 32 * k;

    return result % MOD;
}

int main(void) { euler_bench(160, solve); return 0; }
