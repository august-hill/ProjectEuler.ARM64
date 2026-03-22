// Problem 128: Hexagonal Tile Differences
// Answer: 14516824220
#include <stdbool.h>

static bool is_prime(long long n) {
    if (n < 2) return false;
    if (n < 4) return true;
    if (n % 2 == 0 || n % 3 == 0) return false;
    for (long long i = 5; i * i <= n; i += 6) {
        if (n % i == 0 || n % (i + 2) == 0) return false;
    }
    return true;
}

long long solve(void) {
    int count = 1;

    for (long long r = 1; ; r++) {
        if (is_prime(6*r - 1) && is_prime(6*r + 1) && is_prime(12*r + 5)) {
            count++;
            if (count == 2000) {
                return 3*r*r - 3*r + 2;
            }
        }

        if (r >= 2) {
            if (is_prime(6*r - 1) && is_prime(6*r + 5) && is_prime(12*r - 7)) {
                count++;
                if (count == 2000) {
                    return 3*r*r + 3*r + 1;
                }
            }
        }
    }
    return -1;
}

#include "../bench.h"
int main(void) { euler_bench(128, solve); return 0; }
