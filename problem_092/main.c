// Problem 92: Square Digit Chains
// Answer: 8581146
#include <stdio.h>
#include "../bench.h"

static int square_digit_sum(int n) {
    int sum = 0;
    while (n > 0) {
        int digit = n % 10;
        sum += digit * digit;
        n /= 10;
    }
    return sum;
}

long long solve(void) {
    unsigned char cache[568] = {0};
    int count = 0;

    for (int n = 1; n < 10000000; n++) {
        int chain = n;

        while (1) {
            if (chain == 1) break;
            if (chain == 89) { count++; break; }
            if (chain < 568 && cache[chain] != 0) {
                if (cache[chain] == 89) count++;
                break;
            }
            chain = square_digit_sum(chain);
        }

        if (n < 568) {
            if (chain == 1 || (chain < 568 && cache[chain] == 1))
                cache[n] = 1;
            else
                cache[n] = 89;
        }
    }

    return count;
}

int main(void) { euler_bench(92, solve); return 0; }
