// Problem 130: Composites with Prime Repunit Property
// Answer: 149253
#include <stdbool.h>

static int repunit_div(int n) {
    int r = 1, k = 1;
    while (r % n != 0) {
        r = (r * 10 + 1) % n;
        k++;
    }
    return k;
}

static bool is_prime(int n) {
    if (n < 2) return false;
    if (n < 4) return true;
    if (n % 2 == 0 || n % 3 == 0) return false;
    for (int i = 5; i * i <= n; i += 6)
        if (n % i == 0 || n % (i + 2) == 0) return false;
    return true;
}

long long solve(void) {
    long long sum = 0;
    int count = 0;
    for (int n = 2; count < 25; n++) {
        if (n % 2 == 0 || n % 5 == 0) continue;
        if (is_prime(n)) continue;
        int a = repunit_div(n);
        if ((n - 1) % a == 0) {
            sum += n;
            count++;
        }
    }
    return sum;
}

#include "../bench.h"
int main(void) { euler_bench(130, solve); return 0; }
