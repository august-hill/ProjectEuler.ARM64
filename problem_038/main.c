// Problem 38: Pandigital Multiples
// Answer: 932718654
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

static int is_pandigital(const char *s) {
    if (strlen(s) != 9) return 0;
    int digits[10] = {0};
    for (int i = 0; s[i]; i++) {
        int d = s[i] - '0';
        if (d == 0 || digits[d]) return 0;
        digits[d] = 1;
    }
    return 1;
}

long long solve(void) {
    long long largest = 0;
    char concat[20], buffer[10];
    for (int num = 1; num < 10000; num++) {
        concat[0] = '\0';
        int n = 1;
        while (strlen(concat) < 9) {
            snprintf(buffer, sizeof(buffer), "%d", num * n);
            strcat(concat, buffer);
            n++;
        }
        if (n > 2 && is_pandigital(concat)) {
            long long val = atoll(concat);
            if (val > largest) largest = val;
        }
    }
    return largest;
}

#include "../bench.h"
int main(void) { euler_bench(38, solve); return 0; }
