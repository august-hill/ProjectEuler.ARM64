// Problem 62: Cubic Permutations
// Answer: 127035954683
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>

typedef struct { char sig[20]; uint64_t first; int count; } Entry;

#define HASH_SIZE 65536
#define MAX_ENTRIES 50000

static Entry entries[MAX_ENTRIES];
static int entry_count;
static int hash_table[HASH_SIZE];
static int hash_next[MAX_ENTRIES];

static void digit_sig(uint64_t n, char *sig) {
    char buf[20]; int len = 0;
    if (n == 0) buf[len++] = '0';
    while (n > 0) { buf[len++] = '0' + (n % 10); n /= 10; }
    for (int i = 1; i < len; i++) {
        char k = buf[i]; int j = i - 1;
        while (j >= 0 && buf[j] > k) { buf[j+1] = buf[j]; j--; }
        buf[j+1] = k;
    }
    memcpy(sig, buf, len); sig[len] = '\0';
}

static unsigned hash_sig(const char *s) {
    unsigned h = 0;
    for (; *s; s++) h = h * 31 + *s;
    return h & (HASH_SIZE - 1);
}

static int find_or_insert(const char *sig, uint64_t cube) {
    unsigned h = hash_sig(sig);
    int idx = hash_table[h];
    while (idx != -1) {
        if (strcmp(entries[idx].sig, sig) == 0) { entries[idx].count++; return entries[idx].count; }
        idx = hash_next[idx];
    }
    idx = entry_count++;
    strcpy(entries[idx].sig, sig);
    entries[idx].first = cube; entries[idx].count = 1;
    hash_next[idx] = hash_table[h]; hash_table[h] = idx;
    return 1;
}

long long solve(void) {
    memset(hash_table, -1, sizeof(hash_table));
    entry_count = 0;
    char sig[20];
    for (uint64_t n = 1; n < 100000; n++) {
        uint64_t cube = n * n * n;
        digit_sig(cube, sig);
        int cnt = find_or_insert(sig, cube);
        if (cnt == 5) {
            unsigned h = hash_sig(sig);
            int idx = hash_table[h];
            while (idx != -1) {
                if (strcmp(entries[idx].sig, sig) == 0) return (long long)entries[idx].first;
                idx = hash_next[idx];
            }
        }
    }
    return 0;
}

#include "../bench.h"
int main(void) { euler_bench(62, solve); return 0; }
