// Problem 179: Consecutive Positive Divisors
// Answer: 986262
#include <stdlib.h>
#include "../bench.h"

#define LIMIT 10000000

static int *divcount;

static void init(void) {
    divcount = (int *)calloc(LIMIT + 1, sizeof(int));
    for (int i = 1; i <= LIMIT; i++)
        for (int j = i; j <= LIMIT; j += i)
            divcount[j]++;
}

long long solve(void) {
    static int initialized = 0;
    if (!initialized) { init(); initialized = 1; }

    int count = 0;
    for (int n = 2; n < LIMIT; n++)
        if (divcount[n] == divcount[n + 1])
            count++;
    return count;
}

int main(void) { euler_bench(179, solve); return 0; }
