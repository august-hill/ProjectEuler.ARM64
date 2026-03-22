// Problem 162: Hexadecimal Numbers
// Answer: 3D58725572C62302 (hex) = decimal value stored as long long
#include <stdio.h>
#include <string.h>
#include "../bench.h"

long long solve(void) {
    __int128 total = 0;

    __int128 pow16 = 1, pow15 = 1, pow14 = 1, pow13 = 1;
    for (int k = 1; k <= 16; k++) {
        pow16 *= 16;
        pow15 *= 15;
        pow14 *= 14;
        pow13 *= 13;

        __int128 t16_km1 = pow16 / 16;
        __int128 t15_km1 = pow15 / 15;
        __int128 t14_km1 = pow14 / 14;

        __int128 fk = 15 * t16_km1 - pow15 - 2 * 14 * t15_km1 + 2 * pow14 + 13 * t14_km1 - pow13;
        total += fk;
    }

    return (long long)total;
}

int main(void) { euler_bench(162, solve); return 0; }
