// Problem 131: Prime Cube Partnership
// Answer: 173
#include <stdbool.h>

static bool is_prime(long long n) {
    if (n < 2) return false;
    if (n < 4) return true;
    if (n % 2 == 0 || n % 3 == 0) return false;
    for (long long i = 5; i * i <= n; i += 6)
        if (n % i == 0 || n % (i + 2) == 0) return false;
    return true;
}

long long solve(void) {
    int count = 0;
    for (long long a = 1; ; a++) {
        long long p = 3*a*a + 3*a + 1;
        if (p >= 1000000) break;
        if (is_prime(p)) count++;
    }
    return count;
}

#include "../bench.h"
int main(void) { euler_bench(131, solve); return 0; }
