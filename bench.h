// bench.h - Shared benchmark harness for ARM64 assembly solutions.
// The assembly file must export a _solve function returning long long in x0.
// This C file provides main() and handles timing/output.
//
// Build: as -o solve.o solve.s && cc -O2 -o main_bench bench_main.c solve.o

#ifndef BENCH_H
#define BENCH_H

#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <string.h>

// Defined by the assembly file
extern long long solve(void);

static long long get_ns(void) {
    struct timespec ts;
    clock_gettime(CLOCK_MONOTONIC, &ts);
    return (long long)ts.tv_sec * 1000000000LL + ts.tv_nsec;
}

static int cmp_ll(const void *a, const void *b) {
    long long va = *(const long long *)a;
    long long vb = *(const long long *)b;
    return (va > vb) - (va < vb);
}

static void euler_bench(int problem, long long (*fn)(void)) {
    // Warmup
    for (int i = 0; i < 3; i++) {
        volatile long long r = fn();
        (void)r;
    }

    // Calibrate
    long long t0 = get_ns();
    volatile long long r = fn();
    (void)r;
    long long cal = get_ns() - t0;

    int iters;
    if (cal < 1000000) iters = 1000;
    else if (cal < 100000000) iters = 100;
    else if (cal < 1000000000) iters = 10;
    else iters = 3;

    long long *times = malloc(iters * sizeof(long long));
    long long answer = 0;
    for (int i = 0; i < iters; i++) {
        long long s = get_ns();
        answer = fn();
        times[i] = get_ns() - s;
    }

    qsort(times, iters, sizeof(long long), cmp_ll);
    long long median = times[iters / 2];

    printf("BENCHMARK|problem=%03d|answer=%lld|time_ns=%lld|iterations=%d\n",
           problem, answer, median, iters);
    free(times);
}

#endif
