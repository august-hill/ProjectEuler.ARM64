// Problem 198: Ambiguous Numbers
// Count ambiguous numbers in (0, 1/100) with denominator <= 10^8.
// A number is ambiguous if its best rational approximation (denom <= N) is not unique.
// These are exactly the midpoints of Farey neighbours, i.e., fractions x/y in lowest
// terms with y <= N and x/y < 1/100.
// Count = #{(x,y) : gcd(x,y)=1, 1<=x, 100x < y <= N}
// Using Mobius inversion: sum_{d=1}^{N} mu(d) * F(floor(N/d))
// where F(M) = #{(a,b) : a>=1, 100a < b <= M} = A*(M - 50A - 50), A=floor((M-1)/100).
// Answer: 52374425
#include <stdlib.h>
#include <string.h>

#define N 100000000LL

static signed char *mu;
static int initialized = 0;

static void init(void) {
    mu = (signed char *)malloc((N + 1) * sizeof(signed char));
    memset(mu, 0, (N + 1) * sizeof(signed char));

    // Linear sieve for Mobius function
    int *lp = (int *)calloc((N + 1), sizeof(int)); // least prime factor
    int *primes = (int *)malloc(6000000 * sizeof(int));
    int nprimes = 0;

    for (int i = 0; i <= N; i++) mu[i] = 1;
    mu[1] = 1;

    // Compute mu via sieve
    // mu[1] = 1
    // For prime p: mu[p] = -1
    // mu[p^k] = 0 for k >= 2
    // mu[mn] = mu[m]*mu[n] if gcd(m,n)=1
    // Use standard Mobius sieve:
    // For each prime p, multiply mu[kp] by -1; set mu[kp^2] = 0
    for (int i = 0; i <= (int)N; i++) mu[i] = 1;
    mu[0] = 0;

    for (long long p = 2; p <= N; p++) {
        if (lp[p] == 0) {
            // p is prime
            lp[p] = (int)p;
            primes[nprimes++] = (int)p;
            mu[p] = -1;
        }
        for (int j = 0; j < nprimes; j++) {
            long long q = primes[j];
            if (q > lp[p] || p * q > N) break;
            lp[p * q] = primes[j];
            if (p % q == 0) {
                mu[p * q] = 0;
            } else {
                mu[p * q] = -mu[p];
            }
        }
    }

    free(lp);
    free(primes);
}

static long long F(long long M) {
    if (M <= 100) return 0;
    long long A = (M - 1) / 100;
    return A * (M - 50 * A - 50);
}

long long solve(void) {
    if (!initialized) { init(); initialized = 1; }

    long long ans = 0;
    for (long long d = 1; d <= N; d++) {
        if (mu[d] == 0) continue;
        long long M = N / d;
        if (M <= 100) continue;
        ans += mu[d] * F(M);
    }
    return ans;
}

#include "../bench.h"
int main(void) { euler_bench(198, solve); return 0; }
