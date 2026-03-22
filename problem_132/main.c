// Problem 132: Large Repunit Factors
// Answer: 843296
#include <stdbool.h>

static long long mod_pow(long long base, long long exp, long long mod) {
    long long result = 1;
    base %= mod;
    while (exp > 0) {
        if (exp & 1) result = result * base % mod;
        base = base * base % mod;
        exp >>= 1;
    }
    return result;
}

static bool is_prime(int n) {
    if (n < 2) return false;
    if (n < 4) return true;
    if (n % 2 == 0 || n % 3 == 0) return false;
    for (int i = 5; i * i <= n; i += 6)
        if (n % i == 0 || n % (i + 2) == 0) return false;
    return true;
}

long long solve(void) {
    long long sum = 0;
    int count = 0;
    for (int p = 2; count < 40; p++) {
        if (!is_prime(p)) continue;
        if (p == 3) continue;
        if (mod_pow(10, 1000000000LL, (long long)p) == 1) {
            sum += p;
            count++;
        }
    }
    return sum;
}

#include "../bench.h"
int main(void) { euler_bench(132, solve); return 0; }
