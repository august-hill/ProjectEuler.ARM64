// Problem 149: Searching for a maximum-sum subsequence
// Answer: 52852124
#include <string.h>

#define N 2000
#define TOTAL (N * N)

static long long s[TOTAL + 1];
static long long table[N][N];
static int initialized = 0;

static void init(void) {
    for (int k = 1; k <= 55; k++) {
        s[k] = ((100003LL - 200003LL * k + 300007LL * k * (long long)k * k) % 1000000LL + 1000000LL) % 1000000LL - 500000LL;
    }
    for (int k = 56; k <= TOTAL; k++) {
        s[k] = ((s[k-24] + s[k-55] + 1000000LL) % 1000000LL + 1000000LL) % 1000000LL - 500000LL;
    }

    for (int i = 0; i < N; i++)
        for (int j = 0; j < N; j++)
            table[i][j] = s[i * N + j + 1];
}

static long long max_subarray(long long *arr, int len) {
    long long best = arr[0], current = arr[0];
    for (int i = 1; i < len; i++) {
        if (current < 0) current = arr[i];
        else current += arr[i];
        if (current > best) best = current;
    }
    return best;
}

long long solve(void) {
    if (!initialized) { init(); initialized = 1; }

    long long best = -1000000000LL;
    long long line[N];

    for (int i = 0; i < N; i++) {
        long long val = max_subarray(table[i], N);
        if (val > best) best = val;
    }

    for (int j = 0; j < N; j++) {
        for (int i = 0; i < N; i++) line[i] = table[i][j];
        long long val = max_subarray(line, N);
        if (val > best) best = val;
    }

    for (int start = -(N-1); start < N; start++) {
        int len = 0;
        for (int i = 0; i < N; i++) {
            int j = i - start;
            if (j >= 0 && j < N) {
                line[len++] = table[i][j];
            }
        }
        if (len > 0) {
            long long val = max_subarray(line, len);
            if (val > best) best = val;
        }
    }

    for (int start = 0; start < 2 * N - 1; start++) {
        int len = 0;
        for (int i = 0; i < N; i++) {
            int j = start - i;
            if (j >= 0 && j < N) {
                line[len++] = table[i][j];
            }
        }
        if (len > 0) {
            long long val = max_subarray(line, len);
            if (val > best) best = val;
        }
    }

    return best;
}

#include "../bench.h"
int main(void) { euler_bench(149, solve); return 0; }
