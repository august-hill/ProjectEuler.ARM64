// Problem 146: Investigating a Prime Pattern
// Answer: 676333270
#include <stdbool.h>
#include <stdlib.h>
#include <string.h>

#define LIMIT 150000000LL

static bool miller_rabin(long long n) {
    if (n < 2) return false;
    if (n == 2 || n == 3 || n == 5 || n == 7) return true;
    if (n % 2 == 0 || n % 3 == 0 || n % 5 == 0) return false;

    long long d = n - 1;
    int r = 0;
    while (d % 2 == 0) { d /= 2; r++; }

    long long witnesses[] = {2, 3, 5, 7, 11, 13};
    for (int w = 0; w < 6; w++) {
        long long a = witnesses[w];
        if (a >= n) continue;

        __int128 x = 1;
        __int128 base = a;
        long long exp = d;
        while (exp > 0) {
            if (exp & 1) x = x * base % n;
            base = base * base % n;
            exp >>= 1;
        }
        long long xv = (long long)x;
        if (xv == 1 || xv == n - 1) continue;

        bool composite = true;
        for (int i = 0; i < r - 1; i++) {
            xv = (long long)((__int128)xv * xv % n);
            if (xv == n - 1) { composite = false; break; }
        }
        if (composite) return false;
    }
    return true;
}

long long solve(void) {
    long long sum = 0;

    for (long long n = 10; n < LIMIT; n += 10) {
        if (n % 3 == 0) continue;

        int n7 = (int)(n % 7);
        int n2_7 = (n7 * n7) % 7;
        if ((n2_7 + 1) % 7 == 0 || (n2_7 + 3) % 7 == 0 ||
            (n2_7 + 7) % 7 == 0 || (n2_7 + 9) % 7 == 0 ||
            (n2_7 + 13) % 7 == 0 || (n2_7 + 27) % 7 == 0) continue;

        int n13 = (int)(n % 13);
        int n2_13 = (n13 * n13) % 13;
        if ((n2_13 + 1) % 13 == 0 || (n2_13 + 3) % 13 == 0 ||
            (n2_13 + 7) % 13 == 0 || (n2_13 + 9) % 13 == 0 ||
            (n2_13 + 13) % 13 == 0 || (n2_13 + 27) % 13 == 0) continue;

        long long n2 = n * n;

        if (!miller_rabin(n2 + 1)) continue;
        if (!miller_rabin(n2 + 3)) continue;
        if (!miller_rabin(n2 + 7)) continue;
        if (!miller_rabin(n2 + 9)) continue;
        if (!miller_rabin(n2 + 13)) continue;
        if (!miller_rabin(n2 + 27)) continue;

        if (miller_rabin(n2 + 5)) continue;
        if (miller_rabin(n2 + 11)) continue;
        if (miller_rabin(n2 + 15)) continue;
        if (miller_rabin(n2 + 17)) continue;
        if (miller_rabin(n2 + 19)) continue;
        if (miller_rabin(n2 + 21)) continue;
        if (miller_rabin(n2 + 23)) continue;
        if (miller_rabin(n2 + 25)) continue;

        sum += n;
    }
    return sum;
}

#include "../bench.h"
int main(void) { euler_bench(146, solve); return 0; }
