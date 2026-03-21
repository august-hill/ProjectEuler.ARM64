// Problem 75: Singular Integer Right Triangles
// Answer: 161667
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include "../bench.h"

#define LIMIT 1500000

static int gcd(int a, int b) {
    while (b != 0) {
        int t = b;
        b = a % b;
        a = t;
    }
    return a;
}

long long solve(void) {
    unsigned char *count_arr = calloc(LIMIT + 1, sizeof(unsigned char));

    int m_max = (int)sqrt((double)(LIMIT / 2));

    for (int m = 2; m <= m_max; m++) {
        for (int n = 1; n < m; n++) {
            if ((m - n) % 2 == 0) continue;
            if (gcd(m, n) != 1) continue;

            int perim = 2 * m * (m + n);
            if (perim > LIMIT) break;

            for (int k = perim; k <= LIMIT; k += perim) {
                if (count_arr[k] < 2)
                    count_arr[k]++;
            }
        }
    }

    int result = 0;
    for (int i = 1; i <= LIMIT; i++) {
        if (count_arr[i] == 1)
            result++;
    }

    free(count_arr);
    return result;
}

int main(void) { euler_bench(75, solve); return 0; }
