// Problem 137: Fibonacci Golden Nuggets
// Answer: 1120149658760

long long solve(void) {
    long long fib[65];
    fib[1] = 1; fib[2] = 1;
    for (int i = 3; i <= 62; i++)
        fib[i] = fib[i-1] + fib[i-2];

    return fib[30] * fib[31];
}

#include "../bench.h"
int main(void) { euler_bench(137, solve); return 0; }
