// Problem 133: Repunit Nonfactors
// Answer: 453647705
#include <stdbool.h>
#include <string.h>

#define LIMIT 100000

static bool not_prime[LIMIT];
static int initialized = 0;

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

static void init(void) {
    memset(not_prime, 0, sizeof(not_prime));
    not_prime[0] = not_prime[1] = true;
    for (int i = 2; i * i < LIMIT; i++)
        if (!not_prime[i])
            for (int j = i*i; j < LIMIT; j += i)
                not_prime[j] = true;
}

long long solve(void) {
    if (!initialized) { init(); initialized = 1; }

    long long sum = 0;
    long long exp = 1;
    for (int i = 0; i < 16; i++) exp *= 10;

    for (int p = 2; p < LIMIT; p++) {
        if (not_prime[p]) continue;
        if (p == 2 || p == 5) {
            sum += p;
            continue;
        }
        if (p == 3) {
            sum += 3;
            continue;
        }
        if (mod_pow(10, exp, (long long)p) != 1) {
            sum += p;
        }
    }
    return sum;
}

#include "../bench.h"
int main(void) { euler_bench(133, solve); return 0; }
