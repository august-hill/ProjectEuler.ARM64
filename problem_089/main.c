// Problem 89: Roman Numerals
// Answer: 743
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "../bench.h"

static char *file_data = NULL;

static void load_file(void) {
    FILE *f = fopen("p089_roman.txt", "r");
    if (!f) { fprintf(stderr, "Cannot open p089_roman.txt\n"); exit(1); }
    fseek(f, 0, SEEK_END);
    long len = ftell(f);
    fseek(f, 0, SEEK_SET);
    file_data = malloc(len + 1);
    fread(file_data, 1, len, f);
    file_data[len] = '\0';
    fclose(f);
}

static int roman_char_val(char c) {
    switch (c) {
        case 'M': return 1000; case 'D': return 500;
        case 'C': return 100;  case 'L': return 50;
        case 'X': return 10;   case 'V': return 5;
        case 'I': return 1;    default: return 0;
    }
}

static int roman_to_int(const char *s, int len) {
    int total = 0;
    for (int i = 0; i < len; i++) {
        int v = roman_char_val(s[i]);
        if (i + 1 < len) {
            int next = roman_char_val(s[i + 1]);
            if (v < next) { total += next - v; i++; continue; }
        }
        total += v;
    }
    return total;
}

static int minimal_roman_len(int n) {
    int len = 0;
    int vals[] = {1000,900,500,400,100,90,50,40,10,9,5,4,1};
    int lens[] = {1,2,1,2,1,2,1,2,1,2,1,2,1};
    for (int i = 0; i < 13; i++) {
        while (n >= vals[i]) { len += lens[i]; n -= vals[i]; }
    }
    return len;
}

long long solve(void) {
    static int initialized = 0;
    if (!initialized) { load_file(); initialized = 1; }

    int saved = 0;
    const char *p = file_data;
    while (*p) {
        const char *start = p;
        while (*p && *p != '\n' && *p != '\r') p++;
        int line_len = (int)(p - start);
        while (*p == '\n' || *p == '\r') p++;
        if (line_len == 0) continue;
        int value = roman_to_int(start, line_len);
        int min_len = minimal_roman_len(value);
        saved += line_len - min_len;
    }
    return saved;
}

int main(void) { euler_bench(89, solve); return 0; }
