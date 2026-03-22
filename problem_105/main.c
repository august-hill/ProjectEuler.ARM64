// Problem 105: Special Subset Sums: Testing
// Answer: 73702
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

static char filedata[16384];

static void load_file(void) {
    FILE *f = fopen("p105_sets.txt", "r");
    if (!f) return;
    int len = fread(filedata, 1, sizeof(filedata) - 1, f);
    filedata[len] = 0;
    fclose(f);
}

static int cmp_int(const void *a, const void *b) {
    return *(int *)a - *(int *)b;
}

static int is_special(int *set, int n) {
    int limit = 1 << n;
    int *sums = (int *)malloc(limit * sizeof(int));
    int *sizes = (int *)malloc(limit * sizeof(int));

    for (int mask = 0; mask < limit; mask++) {
        int s = 0, sz = 0;
        for (int i = 0; i < n; i++) {
            if (mask & (1 << i)) { s += set[i]; sz++; }
        }
        sums[mask] = s;
        sizes[mask] = sz;
    }

    int ok = 1;
    for (int a = 1; a < limit && ok; a++) {
        for (int b = a + 1; b < limit && ok; b++) {
            if (a & b) continue;
            if (sums[a] == sums[b]) { ok = 0; break; }
            if (sizes[a] > sizes[b] && sums[a] <= sums[b]) { ok = 0; break; }
            if (sizes[b] > sizes[a] && sums[b] <= sums[a]) { ok = 0; break; }
        }
    }

    free(sums);
    free(sizes);
    return ok;
}

long long solve(void) {
    static int initialized = 0;
    if (!initialized) {
        load_file();
        initialized = 1;
    }

    char buf[16384];
    strcpy(buf, filedata);

    long long total = 0;
    char *line = buf;
    while (*line) {
        char *next = line;
        while (*next && *next != '\n') next++;
        if (*next == '\n') { *next = 0; next++; }

        if (*line) {
            int set[20];
            int n = 0;
            char *p = line;
            while (*p) {
                set[n++] = atoi(p);
                while (*p && *p != ',') p++;
                if (*p == ',') p++;
            }
            qsort(set, n, sizeof(int), cmp_int);

            if (is_special(set, n)) {
                for (int i = 0; i < n; i++) total += set[i];
            }
        }
        line = next;
    }

    return total;
}

#include "../bench.h"
int main(void) { euler_bench(105, solve); return 0; }
