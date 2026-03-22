// Problem 174: Counting the number of "hollow" square laminae that can form 1 to 10
// distinct arrangements. Answer: 209566
#include <stdio.h>
#include <string.h>
#include "../bench.h"

#define LIMIT 1000001

static int nt[LIMIT];

static void init(void) {
    memset(nt, 0, sizeof(nt));
    for (long long n = 3; ; n++) {
        long long m_max = n - 2;
        long long m_min = (n % 2 == 0) ? 2 : 1;
        if (n * n - m_max * m_max >= LIMIT) break;
        for (long long m = m_max; m >= m_min; m -= 2) {
            long long t = n * n - m * m;
            if (t >= LIMIT) continue;
            nt[t]++;
        }
    }
}

long long solve(void) {
    static int initialized = 0;
    if (!initialized) { init(); initialized = 1; }

    long long count = 0;
    for (int t = 1; t < LIMIT; t++)
        if (nt[t] >= 1 && nt[t] <= 10)
            count++;
    return count;
}

int main(void) { euler_bench(174, solve); return 0; }
