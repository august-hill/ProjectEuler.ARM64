// Problem 99: Largest Exponential
// Answer: 709
#include <stdio.h>
#include <math.h>
#include <string.h>
#include <stdlib.h>
#include "../bench.h"

static char filedata[65536];

static void load_file(void) {
    FILE *f = fopen("p099_base_exp.txt", "r");
    if (!f) { fprintf(stderr, "Cannot open p099_base_exp.txt\n"); exit(1); }
    int len = fread(filedata, 1, sizeof(filedata) - 1, f);
    filedata[len] = 0;
    fclose(f);
}

long long solve(void) {
    static int initialized = 0;
    if (!initialized) { load_file(); initialized = 1; }

    int best_line = 0;
    double best_val = 0.0;
    int line_num = 0;

    char buf[65536];
    strcpy(buf, filedata);
    char *line = buf;

    while (*line) {
        char *next = line;
        while (*next && *next != '\n') next++;
        if (*next == '\n') { *next = 0; next++; }

        if (*line) {
            line_num++;
            char *comma = strchr(line, ',');
            if (comma) {
                *comma = 0;
                double base = atof(line);
                double exp = atof(comma + 1);
                double val = exp * log(base);
                if (val > best_val) {
                    best_val = val;
                    best_line = line_num;
                }
            }
        }
        line = next;
    }
    return best_line;
}

int main(void) { euler_bench(99, solve); return 0; }
