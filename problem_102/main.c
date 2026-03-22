// Problem 102: Triangle Containment
// Answer: 228
#include <stdio.h>
#include <string.h>

static char filedata[65536];

static void load_file(void) {
    FILE *f = fopen("p102_triangles.txt", "r");
    if (!f) return;
    int len = fread(filedata, 1, sizeof(filedata) - 1, f);
    filedata[len] = 0;
    fclose(f);
}

static int contains_origin(int x1, int y1, int x2, int y2, int x3, int y3) {
    long long d1 = (long long)(-x1) * (y2 - y1) - (long long)(-y1) * (x2 - x1);
    long long d2 = (long long)(-x2) * (y3 - y2) - (long long)(-y2) * (x3 - x2);
    long long d3 = (long long)(-x3) * (y1 - y3) - (long long)(-y3) * (x1 - x3);

    int has_neg = (d1 < 0) || (d2 < 0) || (d3 < 0);
    int has_pos = (d1 > 0) || (d2 > 0) || (d3 > 0);

    return !(has_neg && has_pos);
}

long long solve(void) {
    static int initialized = 0;
    if (!initialized) {
        load_file();
        initialized = 1;
    }

    int count = 0;
    char buf[65536];
    strcpy(buf, filedata);

    char *line = buf;
    while (*line) {
        char *next = line;
        while (*next && *next != '\n') next++;
        if (*next == '\n') { *next = 0; next++; }

        if (*line) {
            int x1, y1, x2, y2, x3, y3;
            if (sscanf(line, "%d,%d,%d,%d,%d,%d", &x1, &y1, &x2, &y2, &x3, &y3) == 6) {
                if (contains_origin(x1, y1, x2, y2, x3, y3))
                    count++;
            }
        }
        line = next;
    }

    return count;
}

#include "../bench.h"
int main(void) { euler_bench(102, solve); return 0; }
