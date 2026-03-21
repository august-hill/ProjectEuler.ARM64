// Problem 51: Prime Digit Replacements
// Answer: 121313
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define UPPER 999999
#define LOWER (UPPER / 10)

static char *is_prime;

static void init_sieve(void) {
    is_prime = malloc(UPPER + 1);
    memset(is_prime, 1, UPPER + 1);
    is_prime[0] = is_prime[1] = 0;
    for (int i = 2; (long long)i * i <= UPPER; i++)
        if (is_prime[i])
            for (int j = i * i; j <= UPPER; j += i)
                is_prime[j] = 0;
}

long long solve(void) {
    static int inited = 0;
    if (!inited) { init_sieve(); inited = 1; }

    for (int p = LOWER + 1; p <= UPPER; p++) {
        if (!is_prime[p]) continue;
        char s[7];
        sprintf(s, "%d", p);
        int n = (int)strlen(s);
        for (int i = 0; i < n - 2; i++)
            for (int j = i + 1; j < n - 1; j++)
                for (int k = j + 1; k < n; k++) {
                    if (s[i] != s[j] || s[j] != s[k]) continue;
                    int prime_count = 0, first = 0;
                    for (char d = '0'; d <= '9'; d++) {
                        char tmp[7];
                        strcpy(tmp, s);
                        tmp[i] = tmp[j] = tmp[k] = d;
                        int num = atoi(tmp);
                        if (num > LOWER && is_prime[num]) {
                            prime_count++;
                            if (!first) first = num;
                        }
                    }
                    if (prime_count == 8) return first;
                }
    }
    return 0;
}

#include "../bench.h"
int main(void) { euler_bench(51, solve); return 0; }
