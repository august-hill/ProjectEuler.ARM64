// Problem 60: Prime Pair Sets
// Answer: 26033
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>

#define LIMIT 10000
#define SIEVE_SIZE 100000000

static uint8_t *sieve_data;

static void init_sieve(void) {
    sieve_data = (uint8_t *)calloc((SIEVE_SIZE + 7) / 8, 1);
    sieve_data[0] |= 3;
    for (long i = 2; (long)i * i < SIEVE_SIZE; i++)
        if (!(sieve_data[i/8] & (1 << (i%8))))
            for (long j = i*i; j < SIEVE_SIZE; j += i)
                sieve_data[j/8] |= (1 << (j%8));
}

static inline int sieve_is_prime(long n) {
    if (n < 2 || n >= SIEVE_SIZE) return 0;
    return !(sieve_data[n/8] & (1 << (n%8)));
}

static uint64_t mod_pow(uint64_t base, uint64_t exp, uint64_t mod) {
    __uint128_t r = 1; base %= mod;
    while (exp > 0) {
        if (exp & 1) r = r * base % mod;
        exp >>= 1; base = ((__uint128_t)base * base) % mod;
    }
    return (uint64_t)r;
}

static int miller_rabin(uint64_t n) {
    if (n < 2) return 0; if (n < 4) return 1; if (n%2==0) return 0;
    uint64_t d = n-1; int r = 0;
    while (d%2==0) { d /= 2; r++; }
    uint64_t w[] = {2,3,5,7};
    for (int wi = 0; wi < 4; wi++) {
        uint64_t a = w[wi];
        if (a >= n) continue;
        uint64_t x = mod_pow(a, d, n);
        if (x == 1 || x == n-1) continue;
        int comp = 1;
        for (int i = 0; i < r-1; i++) { x = ((__uint128_t)x*x)%n; if (x==n-1) { comp=0; break; } }
        if (comp) return 0;
    }
    return 1;
}

static int check_prime(long n) {
    if (n < SIEVE_SIZE) return sieve_is_prime(n);
    return miller_rabin((uint64_t)n);
}

static long concat_nums(long a, long b) {
    long m = 1, t = b;
    while (t > 0) { m *= 10; t /= 10; }
    return a * m + b;
}

static int is_pair(long a, long b) {
    return check_prime(concat_nums(a,b)) && check_prime(concat_nums(b,a));
}

long long solve(void) {
    static int inited = 0;
    if (!inited) { init_sieve(); inited = 1; }
    int primes[LIMIT], n = 0;
    for (int i = 2; i < LIMIT; i++) if (sieve_is_prime(i)) primes[n++] = i;
    long best = 1000000000L;
    for (int ai = 0; ai < n; ai++) {
        long a = primes[ai]; if (a*5>=best) break;
        for (int bi = ai+1; bi < n; bi++) {
            long b = primes[bi]; if ((a+b)*5/2>=best) break;
            if (!is_pair(a,b)) continue;
            for (int ci = bi+1; ci < n; ci++) {
                long c = primes[ci]; if ((a+b+c)*5/3>=best) break;
                if (!is_pair(a,c)||!is_pair(b,c)) continue;
                for (int di = ci+1; di < n; di++) {
                    long d = primes[di], partial = a+b+c+d;
                    if (partial>=best) break;
                    if (!is_pair(a,d)||!is_pair(b,d)||!is_pair(c,d)) continue;
                    for (int ei = di+1; ei < n; ei++) {
                        long e = primes[ei], sum = partial+e;
                        if (sum>=best) break;
                        if (!is_pair(a,e)||!is_pair(b,e)||!is_pair(c,e)||!is_pair(d,e)) continue;
                        best = sum;
                    }
                }
            }
        }
    }
    return best;
}

#include "../bench.h"
int main(void) { euler_bench(60, solve); return 0; }
