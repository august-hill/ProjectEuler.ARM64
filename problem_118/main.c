// Problem 118: Pandigital Prime Sets
// Answer: 44680
#include <stdio.h>
#include <string.h>

static unsigned long long mod_pow(unsigned long long base, unsigned long long exp, unsigned long long mod) {
    __uint128_t result = 1;
    base %= mod;
    while (exp > 0) {
        if (exp & 1) result = result * base % mod;
        exp >>= 1;
        base = ((__uint128_t)base * base) % mod;
    }
    return (unsigned long long)result;
}

static int is_prime(unsigned long long n) {
    if (n < 2) return 0;
    if (n == 2 || n == 3) return 1;
    if (n % 2 == 0 || n % 3 == 0) return 0;
    unsigned long long witnesses[] = {2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37};
    unsigned long long d = n - 1;
    int r = 0;
    while (d % 2 == 0) { d /= 2; r++; }
    for (int w = 0; w < 12; w++) {
        unsigned long long a = witnesses[w];
        if (a >= n) continue;
        unsigned long long x = mod_pow(a, d, n);
        if (x == 1 || x == n - 1) continue;
        int composite = 1;
        for (int i = 0; i < r - 1; i++) {
            x = ((__uint128_t)x * x) % n;
            if (x == n - 1) { composite = 0; break; }
        }
        if (composite) return 0;
    }
    return 1;
}

static int total_count;

static int next_perm(int *arr, int n) {
    int i = n - 2;
    while (i >= 0 && arr[i] >= arr[i + 1]) i--;
    if (i < 0) return 0;
    int j = n - 1;
    while (arr[j] <= arr[i]) j--;
    int tmp = arr[i]; arr[i] = arr[j]; arr[j] = tmp;
    for (int a = i + 1, b = n - 1; a < b; a++, b--) {
        tmp = arr[a]; arr[a] = arr[b]; arr[b] = tmp;
    }
    return 1;
}

static void search(int used_mask, long long prev_num) {
    if (used_mask == 0x1FF) {
        total_count++;
        return;
    }

    int remaining = (~used_mask) & 0x1FF;

    for (int sub = remaining; sub > 0; sub = (sub - 1) & remaining) {
        int digs[9], nd = 0;
        for (int i = 0; i < 9; i++) {
            if (sub & (1 << i)) digs[nd++] = i + 1;
        }

        int perm[9];
        memcpy(perm, digs, nd * sizeof(int));

        do {
            long long num = 0;
            for (int i = 0; i < nd; i++) num = num * 10 + perm[i];

            if (num > prev_num && is_prime(num)) {
                search(used_mask | sub, num);
            }
        } while (next_perm(perm, nd));
    }
}

long long solve(void) {
    total_count = 0;
    search(0, 0);
    return total_count;
}

#include "../bench.h"
int main(void) { euler_bench(118, solve); return 0; }
