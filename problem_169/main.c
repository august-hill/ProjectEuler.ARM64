// Problem 169: Exploring the number of different ways a number can be expressed
// as a sum of powers of 2 (each power used at most twice).
// Answer: 178653872807
#include <stdio.h>
#include "../bench.h"

long long solve(void) {
    __uint128_t n = 1;
    for (int i = 0; i < 25; i++) n *= 10;

    int bits[100];
    int nbits = 0;
    __uint128_t temp = n;
    while (temp > 0) {
        bits[nbits++] = (int)(temp & 1);
        temp >>= 1;
    }
    for (int i = 0; i < nbits / 2; i++) {
        int t = bits[i]; bits[i] = bits[nbits - 1 - i]; bits[nbits - 1 - i] = t;
    }

    long long fa = 1;
    long long fb = 1;

    for (int i = 1; i < nbits; i++) {
        if (bits[i] == 0) {
            long long new_fa = fa + fb;
            long long new_fb = fb;
            fa = new_fa;
            fb = new_fb;
        } else {
            long long new_fa = fa;
            long long new_fb = fa + fb;
            fa = new_fa;
            fb = new_fb;
        }
    }

    return fa;
}

int main(void) { euler_bench(169, solve); return 0; }
