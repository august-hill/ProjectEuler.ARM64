// Problem 138: Special Isosceles Triangles
// Answer: 1118049290473932

long long solve(void) {
    long long sum = 0;
    long long L_prev = 1;
    long long L_curr = 17;

    for (int i = 0; i < 12; i++) {
        sum += L_curr;
        long long L_next = 18 * L_curr - L_prev;
        L_prev = L_curr;
        L_curr = L_next;
    }
    return sum;
}

#include "../bench.h"
int main(void) { euler_bench(138, solve); return 0; }
