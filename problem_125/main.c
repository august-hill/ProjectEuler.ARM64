// Problem 125: Palindromic Sums
// Answer: 2906969179
#include <stdio.h>
#include <string.h>

#define LIMIT 100000000LL
#define HASH_SIZE 131072
#define HASH_MASK (HASH_SIZE - 1)

static int is_palindrome(long long n) {
    if (n < 0) return 0;
    long long rev = 0, orig = n;
    while (n > 0) {
        rev = rev * 10 + n % 10;
        n /= 10;
    }
    return rev == orig;
}

long long solve(void) {
    static long long hash_table[HASH_SIZE];
    static int hash_used[HASH_SIZE];

    memset(hash_used, 0, sizeof(hash_used));

    long long total = 0;

    for (long long i = 1; i * i < LIMIT; i++) {
        long long sum = i * i;
        for (long long j = i + 1; sum + j * j < LIMIT; j++) {
            sum += j * j;
            if (is_palindrome(sum)) {
                int h = (int)(sum & HASH_MASK);
                while (hash_used[h]) {
                    if (hash_table[h] == sum) goto skip;
                    h = (h + 1) & HASH_MASK;
                }
                hash_table[h] = sum;
                hash_used[h] = 1;
                total += sum;
                skip:;
            }
        }
    }

    return total;
}

#include "../bench.h"
int main(void) { euler_bench(125, solve); return 0; }
