// Problem 200: Find the 200th prime-proof sqube containing the contiguous sub-string "200"
// A sqube is p^2*q^3 where p,q are distinct primes.
// Prime-proof: no single digit change makes it prime.
// Answer: 229161792008
#include <stdlib.h>
#include <string.h>
#include <stdint.h>

static uint64_t mod_pow(uint64_t base, uint64_t exp, uint64_t mod) {
    __uint128_t result = 1;
    base %= mod;
    while (exp > 0) {
        if (exp & 1) result = result * base % mod;
        exp >>= 1;
        base = ((__uint128_t)base * base) % mod;
    }
    return (uint64_t)result;
}

static int miller_rabin(uint64_t n) {
    if (n < 2) return 0;
    if (n < 4) return n >= 2;
    if (n % 2 == 0) return 0;
    uint64_t d = n - 1;
    int r = 0;
    while (d % 2 == 0) { d /= 2; r++; }
    uint64_t witnesses[] = {2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37};
    for (int w = 0; w < 12; w++) {
        uint64_t a = witnesses[w];
        if (a >= n) continue;
        uint64_t x = mod_pow(a, d, n);
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

static int contains_200(uint64_t n) {
    char buf[20];
    int len = 0;
    uint64_t tmp = n;
    while (tmp > 0) { buf[len++] = tmp % 10; tmp /= 10; }
    // Check for "200" = digits 0,0,2 from right to left
    for (int i = len - 1; i >= 2; i--) {
        if (buf[i] == 2 && buf[i-1] == 0 && buf[i-2] == 0) return 1;
    }
    return 0;
}

static int is_prime_proof(uint64_t n) {
    // Check if changing any single digit of n can make it prime
    char digits[20];
    int len = 0;
    uint64_t tmp = n;
    while (tmp > 0) { digits[len++] = tmp % 10; tmp /= 10; }

    for (int pos = 0; pos < len; pos++) {
        int orig = digits[pos];
        for (int d = 0; d <= 9; d++) {
            if (d == orig) continue;
            if (pos == len - 1 && d == 0) continue; // no leading zero
            digits[pos] = d;
            uint64_t val = 0;
            for (int i = len - 1; i >= 0; i--)
                val = val * 10 + digits[i];
            if (miller_rabin(val)) {
                digits[pos] = orig;
                return 0;
            }
        }
        digits[pos] = orig;
    }
    return 1;
}

// Sieve primes up to some limit
#define SIEVE_LIM 1000000
static char sieve[SIEVE_LIM];
static int primes[80000];
static int nprimes;

static void init_sieve(void) {
    memset(sieve, 0, sizeof(sieve));
    sieve[0] = sieve[1] = 1;
    for (int i = 2; i * i < SIEVE_LIM; i++)
        if (!sieve[i])
            for (int j = i * i; j < SIEVE_LIM; j += i) sieve[j] = 1;
    nprimes = 0;
    for (int i = 2; i < SIEVE_LIM; i++)
        if (!sieve[i]) primes[nprimes++] = i;
}

// Comparison function for sorting squbes
static int cmp_u64(const void *a, const void *b) {
    uint64_t va = *(const uint64_t *)a, vb = *(const uint64_t *)b;
    return (va > vb) - (va < vb);
}

long long solve(void) {
    static int initialized = 0;
    if (!initialized) { init_sieve(); initialized = 1; }

    // Generate squbes p^2*q^3 and q^2*p^3 (p,q distinct primes)
    // up to some reasonable limit. 229161792008 ≈ 2.3*10^11
    // p^2*q^3: p up to sqrt(limit/q^3)
    uint64_t limit = 300000000000ULL; // 3*10^11

    // Collect squbes that contain "200"
    uint64_t *squbes = (uint64_t *)malloc(1000000 * sizeof(uint64_t));
    int nsqubes = 0;

    for (int qi = 0; qi < nprimes; qi++) {
        uint64_t q = primes[qi];
        uint64_t q3 = q * q * q;
        if (q3 > limit) break;
        for (int pi = 0; pi < nprimes; pi++) {
            if (pi == qi) continue;
            uint64_t p = primes[pi];
            uint64_t p2 = p * p;
            uint64_t sqube = p2 * q3;
            if (sqube > limit) break;
            if (contains_200(sqube)) {
                squbes[nsqubes++] = sqube;
            }
        }
    }

    // Sort and deduplicate
    qsort(squbes, nsqubes, sizeof(uint64_t), cmp_u64);
    int unique = 0;
    for (int i = 0; i < nsqubes; i++) {
        if (i == 0 || squbes[i] != squbes[i-1])
            squbes[unique++] = squbes[i];
    }

    // Find 200th prime-proof one
    int count = 0;
    uint64_t result = 0;
    for (int i = 0; i < unique; i++) {
        if (is_prime_proof(squbes[i])) {
            count++;
            if (count == 200) {
                result = squbes[i];
                break;
            }
        }
    }

    free(squbes);
    return (long long)result;
}

#include "../bench.h"
int main(void) { euler_bench(200, solve); return 0; }
