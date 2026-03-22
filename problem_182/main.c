// Problem 182: RSA Encryption
// Answer: 399788195976
#include "../bench.h"

static long long gcd(long long a, long long b) {
    while (b) { long long t = b; b = a % b; a = t; }
    return a;
}

long long solve(void) {
    long long p = 1009, q = 3643;
    long long phi = (p - 1) * (q - 1);

    long long sum = 0;
    for (long long e = 2; e < phi; e++) {
        if (gcd(e, phi) != 1) continue;
        if (gcd(e - 1, p - 1) == 2 && gcd(e - 1, q - 1) == 2)
            sum += e;
    }
    return sum;
}

int main(void) { euler_bench(182, solve); return 0; }
