// Problem 145: How many reversible numbers are there below one-billion?
// Answer: 608720

static int all_odd(long long n) {
    while (n > 0) {
        if ((n % 10) % 2 == 0) return 0;
        n /= 10;
    }
    return 1;
}

static long long reverse_num(long long n) {
    long long rev = 0;
    while (n > 0) { rev = rev * 10 + n % 10; n /= 10; }
    return rev;
}

long long solve(void) {
    long long count = 0;

    for (long long n = 10; n < 10000000; n++) {
        if (n % 10 == 0) continue;
        long long sum = n + reverse_num(n);
        if (all_odd(sum)) count++;
    }

    count += 540000;

    return count;
}

#include "../bench.h"
int main(void) { euler_bench(145, solve); return 0; }
