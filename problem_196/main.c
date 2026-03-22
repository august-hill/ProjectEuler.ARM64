// Problem 196: Prime Triplets
// Build a triangle where row r contains r numbers: r*(r-1)/2+1, ..., r*(r-1)/2+r.
// A prime triplet: three primes that can all be found within a 3-row neighbourhood.
// More precisely: for a prime p in row r, look at all primes in rows r-1, r, r+1
// within positions ±2. A prime triplet is a set of 3 primes where each pair is
// adjacent (within the neighbourhood). Find the sum of primes in row r that belong
// to at least one prime triplet, for r = 5678027 and r = 7208785.
// Answer: 322303240771079935
#include <stdlib.h>
#include <string.h>
#include <math.h>

// Miller-Rabin primality test (deterministic for n < 3.3*10^24 with these witnesses)
static unsigned long long mulmod(unsigned long long a, unsigned long long b, unsigned long long m) {
    return (__uint128_t)a * b % m;
}

static unsigned long long powmod(unsigned long long base, unsigned long long exp, unsigned long long mod) {
    unsigned long long result = 1;
    base %= mod;
    while (exp > 0) {
        if (exp & 1) result = mulmod(result, base, mod);
        exp >>= 1;
        base = mulmod(base, base, mod);
    }
    return result;
}

static int miller_rabin(unsigned long long n) {
    if (n < 2) return 0;
    if (n == 2 || n == 3 || n == 5 || n == 7) return 1;
    if (n % 2 == 0 || n % 3 == 0 || n % 5 == 0) return 0;
    unsigned long long d = n - 1;
    int r = 0;
    while (d % 2 == 0) { d /= 2; r++; }
    // Witnesses sufficient for n < 3,317,044,064,679,887,385,961,981
    static const unsigned long long witnesses[] = {2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37};
    for (int w = 0; w < 12; w++) {
        unsigned long long a = witnesses[w];
        if (a >= n) continue;
        unsigned long long x = powmod(a, d, n);
        if (x == 1 || x == n - 1) continue;
        int composite = 1;
        for (int i = 0; i < r - 1; i++) {
            x = mulmod(x, x, n);
            if (x == n - 1) { composite = 0; break; }
        }
        if (composite) return 0;
    }
    return 1;
}

// For row r, the numbers are: start(r) + 0, start(r) + 1, ..., start(r) + r - 1
// where start(r) = r*(r-1)/2 + 1
// Neighbours of position (r, c) [0-indexed c]:
//   same row: (r, c-1), (r, c+1)
//   row above r-1: positions c-1, c (the numbers at row r-1 that are adjacent)
//   row below r+1: positions c, c+1 (two numbers in row r+1 that touch position c)
//
// The full neighbourhood of (r, c): positions in rows r-1, r, r+1 within columns c-1..c+1
// Row r-1 has columns 0..r-2; row r has columns 0..r-1; row r+1 has columns 0..r
//
// A prime p = start(r)+c belongs to a prime triplet if there exist 2 other primes
// in its neighbourhood (rows r-1..r+1, positions roughly c-1..c+1 in each row)
// such that those 2 other primes are ALSO neighbours of each other.
//
// Concretely: the neighbourhood N(r,c) = all numbers in rows r-1,r,r+1 at
// positions max(0,c-1)..min(row_len-1, c+1).
// A triplet: {p, q, s} where p is in row r, and q,s are in N(r,c),
// and s is in N of q (i.e., q and s are also adjacent).
//
// Simplified approach from the well-known solution:
// For each prime p in row r, collect all primes in rows r-1,r,r+1 within columns c-2..c+2
// (slightly wider to not miss). Then check if among those primes, there's a group of 3
// where all are mutually reachable.

static unsigned long long row_start(unsigned long long r) {
    return r * (r - 1) / 2 + 1;
}

// Get neighbours of position (r, c): all numbers in rows r-1..r+1 at adjacent cols
// Returns count, fills array vals
static int get_neighbourhood(unsigned long long r, int c, unsigned long long *vals) {
    int n = 0;
    // Row r-1: positions max(0, c-1) .. min(r-2, c)  (row r-1 has r-1 elements, indices 0..r-2)
    if (r >= 2) {
        unsigned long long s = row_start(r - 1);
        int lo = (c - 1 < 0) ? 0 : c - 1;
        int hi = (c < (int)(r - 2)) ? c : (int)(r - 2);
        for (int j = lo; j <= hi; j++) vals[n++] = s + j;
    }
    // Row r: all positions except c itself, within ±1
    {
        unsigned long long s = row_start(r);
        if (c > 0) vals[n++] = s + c - 1;
        vals[n++] = s + c; // include self
        if (c < (int)(r - 1)) vals[n++] = s + c + 1;
    }
    // Row r+1: positions c and c+1 (row r+1 has r+1 elements, indices 0..r)
    {
        unsigned long long s = row_start(r + 1);
        if (c < (int)(r + 1)) vals[n++] = s + c;
        if (c + 1 <= (int)r) vals[n++] = s + c + 1;
    }
    return n;
}

// Check if two positions are neighbours
static int are_neighbours(unsigned long long r1, int c1, unsigned long long r2, int c2) {
    if (r1 == r2) return (c1 == c2 - 1 || c1 == c2 + 1);
    if (r1 + 1 == r2) {
        // r2 = r1+1: c2's neighbours in row r1 are c2-1 and c2
        return (c1 == c2 - 1 || c1 == c2);
    }
    if (r1 == r2 + 1) {
        // r1 = r2+1: same but swapped
        return (c2 == c1 - 1 || c2 == c1);
    }
    return 0;
}

// Sum of primes in row r that belong to a prime triplet
static unsigned long long sum_prime_triplets_in_row(unsigned long long r) {
    unsigned long long s = row_start(r);
    unsigned long long total = 0;

    for (int c = 0; c < (int)r; c++) {
        unsigned long long p = s + c;
        if (!miller_rabin(p)) continue;

        // Collect primes in the wider neighbourhood (rows r-1..r+1, cols c-2..c+2)
        // We'll represent them as (row, col) pairs
        #define MAX_NEIGH 20
        unsigned long long prow[MAX_NEIGH];
        int pcol[MAX_NEIGH];
        int np = 0;

        // Row r-1
        if (r >= 2) {
            unsigned long long s2 = row_start(r - 1);
            int lo = (c - 2 < 0) ? 0 : c - 2;
            int hi = (c + 1 < (int)(r - 1)) ? c + 1 : (int)(r - 1) - 1;
            for (int j = lo; j <= hi; j++) {
                if (miller_rabin(s2 + j)) {
                    prow[np] = r - 1; pcol[np] = j; np++;
                }
            }
        }
        // Row r
        {
            int lo = (c - 2 < 0) ? 0 : c - 2;
            int hi = (c + 2 < (int)r) ? c + 2 : (int)r - 1;
            for (int j = lo; j <= hi; j++) {
                if (j == c) continue; // skip self, add separately
                if (miller_rabin(s + j)) {
                    prow[np] = r; pcol[np] = j; np++;
                }
            }
        }
        // Add self
        prow[np] = r; pcol[np] = c; np++;
        int self_idx = np - 1;

        // Row r+1
        {
            unsigned long long s2 = row_start(r + 1);
            int lo = (c - 1 < 0) ? 0 : c - 1;
            int hi = (c + 2 <= (int)r) ? c + 2 : (int)r;
            for (int j = lo; j <= hi; j++) {
                if (miller_rabin(s2 + j)) {
                    prow[np] = r + 1; pcol[np] = j; np++;
                }
            }
        }

        // Check if self (index self_idx) is part of a triplet:
        // Need 2 other primes q, t such that:
        //   self is neighbour of q, self is neighbour of t, q is neighbour of t
        // OR: self is neighbour of q, q is neighbour of t, t is neighbour of self
        // (all three are mutually within each other's neighbourhoods)
        int in_triplet = 0;
        for (int i = 0; i < np && !in_triplet; i++) {
            if (i == self_idx) continue;
            if (!are_neighbours(r, c, prow[i], pcol[i])) continue;
            for (int j = i + 1; j < np && !in_triplet; j++) {
                if (j == self_idx) continue;
                if (!are_neighbours(r, c, prow[j], pcol[j])) continue;
                if (are_neighbours(prow[i], pcol[i], prow[j], pcol[j])) {
                    in_triplet = 1;
                }
            }
        }

        if (in_triplet) total += p;
    }

    return total;
}

long long solve(void) {
    unsigned long long a = sum_prime_triplets_in_row(5678027ULL);
    unsigned long long b = sum_prime_triplets_in_row(7208785ULL);
    return (long long)(a + b);
}

#include "../bench.h"
int main(void) { euler_bench(196, solve); return 0; }
