// Problem 197: Investigating the Behaviour of a Recursively Defined Sequence
// f(x) = floor(2^(30.403243784-x^2)) * 10^-9
// u_0 = -1, u_{n+1} = f(u_n)
// Find u_n + u_{n+1} for n = 10^12, rounded to 9 decimal places.
// Answer: 1710637717
#include <math.h>

static double f(double x) {
    return floor(pow(2.0, 30.403243784 - x * x)) * 1e-9;
}

long long solve(void) {
    // The sequence converges to a 2-cycle quickly.
    double u = -1.0;
    for (int i = 0; i < 1000; i++)
        u = f(u);
    double sum = u + f(u);
    // Return answer * 10^9 as integer
    return (long long)round(sum * 1e9);
}

#include "../bench.h"
int main(void) { euler_bench(197, solve); return 0; }
