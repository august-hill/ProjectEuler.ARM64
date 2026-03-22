// Problem 188: The Hyperexponentiation of a Number
// Answer: 95962097
#include "../bench.h"

#define MOD 100000000ULL

static unsigned long long mod_pow(unsigned long long base, unsigned long long exp, unsigned long long mod) {
    unsigned long long result = 1;
    base %= mod;
    while (exp > 0) {
        if (exp & 1) result = result * base % mod;
        exp >>= 1;
        base = base * base % mod;
    }
    return result;
}

static unsigned long long euler_totient(unsigned long long n) {
    unsigned long long result = n;
    for (unsigned long long p = 2; p * p <= n; p++) {
        if (n % p == 0) {
            while (n % p == 0) n /= p;
            result -= result / p;
        }
    }
    if (n > 1) result -= result / n;
    return result;
}

static unsigned long long hyper(unsigned long long a, unsigned long long b, unsigned long long m) {
    if (m == 1) return 0;
    if (b == 1) return a % m;
    unsigned long long phi = euler_totient(m);
    unsigned long long exp = hyper(a, b - 1, phi);
    return mod_pow(a, exp + phi, m);
}

long long solve(void) {
    return (long long)hyper(1777, 1855, MOD);
}

int main(void) { euler_bench(188, solve); return 0; }
