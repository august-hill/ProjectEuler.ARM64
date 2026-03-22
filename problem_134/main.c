// Problem 134: Prime Pair Connection
// Answer: 18613426663617118
#include <stdbool.h>
#include <string.h>

#define LIMIT 1100000

static bool not_prime[LIMIT];
static int initialized = 0;

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

    long long total = 0;

    for (int p1 = 5; p1 <= 1000000; ) {
        if (not_prime[p1]) { p1 += 2; continue; }
        int p2 = p1 + 2;
        while (not_prime[p2]) p2 += 2;

        long long pow10 = 1;
        int tmp = p1;
        while (tmp > 0) { pow10 *= 10; tmp /= 10; }

        long long base = pow10 % p2;
        int e = p2 - 2;
        long long mod = p2;
        long long b = base;
        long long r = 1;
        while (e > 0) {
            if (e & 1) r = r * b % mod;
            b = b * b % mod;
            e >>= 1;
        }
        long long inv = r;

        long long k = (((long long)(-p1 % p2) + p2) % p2 * inv) % p2;
        long long n = (long long)p1 + k * pow10;
        total += n;

        p1 = p2;
    }
    return total;
}

#include "../bench.h"
int main(void) { euler_bench(134, solve); return 0; }
