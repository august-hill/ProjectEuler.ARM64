// bench.c - Minimal C harness for ARM64 assembly solutions
// The solve() function is implemented in assembly and linked in.
// This file handles timing and BENCHMARK line output.
//
// Build: as -o solve.o problem_NNN/solve.s
//        cc -O2 -o main bench.c solve.o

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <mach/mach_time.h>

// Implemented in assembly
extern long long solve(void);

static uint64_t now_ns(void) {
    static mach_timebase_info_data_t tb = {0, 0};
    if (tb.denom == 0) mach_timebase_info(&tb);
    return mach_absolute_time() * tb.numer / tb.denom;
}

static int cmp_u64(const void *a, const void *b) {
    uint64_t va = *(const uint64_t *)a, vb = *(const uint64_t *)b;
    return (va > vb) - (va < vb);
}

int main(int argc, char **argv) {
    int problem = 0;
    if (argc > 1) problem = atoi(argv[1]);

    // Use volatile function pointer to prevent inlining
    long long (* volatile solve_fn)(void) = solve;

    // Warmup
    for (int i = 0; i < 3; i++) solve_fn();

    // Calibrate
    uint64_t t0 = now_ns();
    solve_fn();
    uint64_t cal_ns = now_ns() - t0;

    int iters;
    if      (cal_ns < 1000000)     iters = 1000;
    else if (cal_ns < 100000000)   iters = 100;
    else if (cal_ns < 1000000000)  iters = 10;
    else                           iters = 3;

    // Timed runs
    uint64_t *times = malloc(iters * sizeof(uint64_t));
    long long answer = 0;
    for (int i = 0; i < iters; i++) {
        t0 = now_ns();
        answer = solve_fn();
        times[i] = now_ns() - t0;
    }

    // Median
    qsort(times, iters, sizeof(uint64_t), cmp_u64);
    uint64_t median_ns = times[iters / 2];

    printf("BENCHMARK|problem=%03d|answer=%lld|time_ns=%llu|iterations=%d\n",
           problem, answer, (unsigned long long)median_ns, iters);

    free(times);
    return 0;
}
