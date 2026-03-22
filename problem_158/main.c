// Problem 158: Exploring strings for which only one character comes lexicographically
// after its neighbour to the left.
// Answer: 409511334375
#include <stdio.h>
#include "../bench.h"

long long solve(void) {
    long long best = 0;
    long long comb = 1;
    for (int n = 1; n <= 26; n++) {
        comb = comb * (26 - n + 1) / n;
        long long pow2 = 1LL << n;
        long long euler = pow2 - n - 1;
        long long pn = comb * euler;
        if (pn > best) best = pn;
    }
    return best;
}

int main(void) { euler_bench(158, solve); return 0; }
