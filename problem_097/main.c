// Problem 97: Large Non-Mersenne Prime
// Answer: 8739992577
#include <stdio.h>
#include "../bench.h"

#define MOD 10000000000ULL

static unsigned long long mod_pow(unsigned long long base, unsigned long long exp, unsigned long long mod) {
    unsigned __int128 result = 1;
    unsigned __int128 b = base;

    while (exp > 0) {
        if (exp & 1) {
            result = (result * b) % mod;
        }
        b = (b * b) % mod;
        exp >>= 1;
    }

    return (unsigned long long)result;
}

long long solve(void) {
    unsigned long long power = mod_pow(2, 7830457, MOD);
    unsigned __int128 result = (unsigned __int128)power * 28433;
    result = result % MOD;
    result = (result + 1) % MOD;
    return (long long)(unsigned long long)result;
}

int main(void) { euler_bench(97, solve); return 0; }
