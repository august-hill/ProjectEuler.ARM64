// Problem 109: Darts
// Answer: 38182
#include <stdio.h>

long long solve(void) {
    int singles[62];
    int ndarts = 0;

    for (int i = 1; i <= 20; i++) singles[ndarts++] = i;
    singles[ndarts++] = 25;
    for (int i = 1; i <= 20; i++) singles[ndarts++] = 2 * i;
    singles[ndarts++] = 50;
    for (int i = 1; i <= 20; i++) singles[ndarts++] = 3 * i;

    int doubles[21];
    int ndoubles = 0;
    for (int i = 1; i <= 20; i++) doubles[ndoubles++] = 2 * i;
    doubles[ndoubles++] = 50;

    int count = 0;

    for (int i = 0; i < ndoubles; i++) {
        if (doubles[i] < 100) count++;
    }

    for (int i = 0; i < ndarts; i++) {
        for (int j = 0; j < ndoubles; j++) {
            int total = singles[i] + doubles[j];
            if (total < 100) count++;
        }
    }

    for (int i = 0; i < ndarts; i++) {
        for (int j = i; j < ndarts; j++) {
            for (int k = 0; k < ndoubles; k++) {
                int total = singles[i] + singles[j] + doubles[k];
                if (total < 100) count++;
            }
        }
    }

    return count;
}

#include "../bench.h"
int main(void) { euler_bench(109, solve); return 0; }
