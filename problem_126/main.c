// Problem 126: Cuboid Layers
// Answer: 18522
#include <string.h>

#define LIMIT 20000

static int count[LIMIT + 1];

static long long layer_cubes(int a, int b, int c, int k) {
    return (long long)2 * ((long long)a*b + (long long)b*c + (long long)a*c) +
           (long long)4 * (k - 1) * (a + b + c) +
           (long long)4 * (k - 1) * (k - 2);
}

long long solve(void) {
    memset(count, 0, sizeof(count));

    for (int a = 1; a <= LIMIT; a++) {
        for (int b = a; ; b++) {
            long long f1 = layer_cubes(a, b, b, 1);
            if (f1 > LIMIT) break;
            for (int c = b; ; c++) {
                long long f = layer_cubes(a, b, c, 1);
                if (f > LIMIT) break;
                for (int k = 1; ; k++) {
                    long long cubes = layer_cubes(a, b, c, k);
                    if (cubes > LIMIT) break;
                    count[(int)cubes]++;
                }
            }
        }
    }

    for (int n = 1; n <= LIMIT; n++) {
        if (count[n] == 1000) return n;
    }
    return -1;
}

#include "../bench.h"
int main(void) { euler_bench(126, solve); return 0; }
