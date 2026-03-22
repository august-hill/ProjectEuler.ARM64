// Problem 180: Rational Zeros of a Function (Golden Triplets)
// Answer: 285196020571078987
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include "../bench.h"

#define K 35

static long long gcd_ll(long long a, long long b) {
    if (a < 0) a = -a;
    if (b < 0) b = -b;
    while (b) { long long t = b; b = a % b; a = t; }
    return a;
}

typedef struct { long long n, d; } Rat;

static Rat mkrat(long long n, long long d) {
    if (d < 0) { n = -n; d = -d; }
    if (n == 0) return (Rat){0, 1};
    long long g = gcd_ll(n < 0 ? -n : n, d);
    return (Rat){n / g, d / g};
}

static Rat radd(Rat a, Rat b) { return mkrat(a.n * b.d + b.n * a.d, a.d * b.d); }

static int rvalid(Rat r) { return r.n > 0 && r.d > 0 && r.n < r.d && r.d <= K; }

#define HSZ (1 << 20)
#define HMASK (HSZ - 1)

static struct { Rat val; char used; } ht[HSZ];

static void hclear(void) {
    for (int i = 0; i < HSZ; i++) ht[i].used = 0;
}

static int hins(Rat r) {
    unsigned long long h = ((unsigned long long)(r.n * 100003LL + r.d * 999983LL)) & HMASK;
    while (ht[h].used) {
        if (ht[h].val.n == r.n && ht[h].val.d == r.d) return 0;
        h = (h + 1) & HMASK;
    }
    ht[h].val = r;
    ht[h].used = 1;
    return 1;
}

long long solve(void) {
    hclear();

    Rat rats[700];
    int nr = 0;
    for (int q = 2; q <= K; q++)
        for (int p = 1; p < q; p++)
            if (gcd_ll(p, q) == 1)
                rats[nr++] = mkrat(p, q);

    Rat total = {0, 1};

    for (int i = 0; i < nr; i++) {
        for (int j = i; j < nr; j++) {
            Rat x = rats[i], y = rats[j];

            { // n=1: z = x+y
                Rat z = radd(x, y);
                if (rvalid(z)) {
                    Rat s = radd(radd(x, y), z);
                    if (hins(s)) total = radd(total, s);
                }
            }

            { // n=-1: z = xy/(x+y)
                long long zn = x.n * y.n;
                long long zd = x.n * y.d + y.n * x.d;
                if (zd > 0 && zn > 0) {
                    Rat z = mkrat(zn, zd);
                    if (rvalid(z)) {
                        Rat s = radd(radd(x, y), z);
                        if (hins(s)) total = radd(total, s);
                    }
                }
            }

            { // n=2: z = sqrt(x^2+y^2)
                long long num2 = x.n*x.n * y.d*y.d + y.n*y.n * x.d*x.d;
                long long den1 = x.d * y.d;
                long long sq = (long long)sqrtl((long double)num2);
                while (sq * sq < num2) sq++;
                while (sq * sq > num2) sq--;
                if (sq > 0 && sq * sq == num2) {
                    Rat z = mkrat(sq, den1);
                    if (rvalid(z)) {
                        Rat s = radd(radd(x, y), z);
                        if (hins(s)) total = radd(total, s);
                    }
                }
            }

            { // n=-2: z = xy/sqrt(x^2+y^2)
                long long num2 = x.n*x.n * y.d*y.d + y.n*y.n * x.d*x.d;
                long long sq = (long long)sqrtl((long double)num2);
                while (sq * sq < num2) sq++;
                while (sq * sq > num2) sq--;
                if (sq > 0 && sq * sq == num2) {
                    Rat z = mkrat(x.n * y.n, sq);
                    if (rvalid(z)) {
                        Rat s = radd(radd(x, y), z);
                        if (hins(s)) total = radd(total, s);
                    }
                }
            }

            if (i != j) {
                for (int ord = 0; ord < 2; ord++) {
                    Rat big = (ord == 0) ? y : x;
                    Rat small = (ord == 0) ? x : y;
                    if (big.n * small.d <= small.n * big.d) continue;

                    { // n=1 diff
                        Rat z = mkrat(big.n * small.d - small.n * big.d, big.d * small.d);
                        if (rvalid(z)) {
                            Rat s = radd(radd(big, small), z);
                            if (hins(s)) total = radd(total, s);
                        }
                    }

                    { // n=2 diff
                        long long num2 = big.n*big.n * small.d*small.d - small.n*small.n * big.d*big.d;
                        if (num2 > 0) {
                            long long den1 = big.d * small.d;
                            long long sq = (long long)sqrtl((long double)num2);
                            while (sq * sq < num2) sq++;
                            while (sq * sq > num2) sq--;
                            if (sq > 0 && sq * sq == num2) {
                                Rat z = mkrat(sq, den1);
                                if (rvalid(z)) {
                                    Rat s = radd(radd(big, small), z);
                                    if (hins(s)) total = radd(total, s);
                                }
                            }
                        }
                    }

                    { // n=-1 diff
                        long long zn = big.n * small.n;
                        long long zd = big.n * small.d - small.n * big.d;
                        if (zd > 0 && zn > 0) {
                            Rat z = mkrat(zn, zd);
                            if (rvalid(z)) {
                                Rat s = radd(radd(big, small), z);
                                if (hins(s)) total = radd(total, s);
                            }
                        }
                    }

                    { // n=-2 diff
                        long long num2 = big.n*big.n * small.d*small.d - small.n*small.n * big.d*big.d;
                        if (num2 > 0) {
                            long long sq = (long long)sqrtl((long double)num2);
                            while (sq * sq < num2) sq++;
                            while (sq * sq > num2) sq--;
                            if (sq > 0 && sq * sq == num2) {
                                Rat z = mkrat(big.n * small.n, sq);
                                if (rvalid(z)) {
                                    Rat s = radd(radd(big, small), z);
                                    if (hins(s)) total = radd(total, s);
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    return total.n + total.d;
}

int main(void) { euler_bench(180, solve); return 0; }
