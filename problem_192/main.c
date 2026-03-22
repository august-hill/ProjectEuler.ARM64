// Problem 192: Best Approximations
// Answer: 57060635927998347
#include <stdio.h>
#include <string.h>
#include <math.h>
#include "../bench.h"

#define BOUND 1000000000000LL

typedef long long ll;
typedef __int128 lll;

static int is_perfect_square(int n) {
    int s = (int)sqrt((double)n);
    while ((ll)s*s > n) s--;
    while ((ll)(s+1)*(s+1) <= n) s++;
    return (ll)s*s == n;
}

static int closer_to_sqrt(ll p1, ll q1, ll p2, ll q2, int n) {
    long double sq = sqrtl((long double)n);
    long double e1 = fabsl((long double)p1 / q1 - sq);
    long double e2 = fabsl((long double)p2 / q2 - sq);
    if (e1 < e2 * (1.0L - 1e-15L)) return 1;
    if (e2 < e1 * (1.0L - 1e-15L)) return 0;
    lll e1_i = (lll)p1*p1 - (lll)n*q1*q1;
    if (e1_i < 0) e1_i = -e1_i;
    lll e2_i = (lll)p2*p2 - (lll)n*q2*q2;
    if (e2_i < 0) e2_i = -e2_i;
    lll A = e1_i * (lll)q2 * p2 - e2_i * (lll)q1 * p1;
    lll B = e2_i * (lll)q1 * q1 - e1_i * (lll)q2 * q2;
    if (B > 0) {
        if (A <= 0) return 1;
        lll A2 = A * A, B2n = B * B * n;
        return A2 < B2n;
    } else if (B < 0) {
        if (A >= 0) return 0;
        lll negA = -A, negB = -B;
        lll A2 = negA * negA, B2n = negB * negB * n;
        return A2 > B2n;
    } else {
        return A < 0;
    }
}

static ll best_denom(int n) {
    int a0 = (int)sqrtl((long double)n);
    while ((ll)(a0+1)*(a0+1) <= n) a0++;
    while ((ll)a0*a0 > n) a0--;

    ll pp = 1, pq = 0;
    ll cp = a0, cq = 1;

    ll m = 0, d = 1, a = a0;

    for (;;) {
        m = (ll)d * a - m;
        d = ((ll)n - m * m) / d;
        if (d == 0) break;
        a = (a0 + m) / d;

        ll np = a * cp + pp;
        ll nq = a * cq + pq;

        if (nq > BOUND) {
            ll j_max = (pq >= 0 && cq > 0) ? (BOUND - pq) / cq : 0;
            if (j_max >= 1) {
                ll sq = j_max * cq + pq;
                ll sp = j_max * cp + pp;
                if (closer_to_sqrt(sp, sq, cp, cq, n))
                    return sq;
            }
            return cq;
        }

        pp = cp; pq = cq;
        cp = np; cq = nq;
    }

    return cq;
}

static int initialized = 0;
static long long answer_cache = 0;

long long solve(void) {
    if (initialized) return answer_cache;
    initialized = 1;

    ll total = 0;
    for (int n = 2; n <= 100000; n++) {
        if (is_perfect_square(n)) continue;
        total += best_denom(n);
    }
    answer_cache = (ll)total;
    return answer_cache;
}

int main(void) { euler_bench(192, solve); return 0; }
