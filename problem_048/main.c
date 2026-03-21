// Problem 48: Self Powers
// Answer: 9110846700
#include <stdio.h>
#include <stdint.h>

#define MOD 10000000000ULL

static unsigned __int128 mod_pow(__int128 base, __int128 exp, __int128 m) {
    __int128 result = 1;
    base %= m;
    while (exp > 0) {
        if (exp % 2 == 1) result = (result * base) % m;
        exp /= 2;
        base = (base * base) % m;
    }
    return (unsigned __int128)result;
}

long long solve(void) {
    unsigned __int128 sum = 0;
    for (uint64_t i = 1; i <= 1000; i++)
        sum = (sum + mod_pow(i, i, MOD)) % MOD;
    return (long long)(uint64_t)sum;
}

#include "../bench.h"
int main(void) { euler_bench(48, solve); return 0; }
