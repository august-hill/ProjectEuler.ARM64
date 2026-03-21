// Problem 42: Coded Triangle Numbers
// Answer: 162
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_WORDS 2000
#define MAX_WORD_LEN 20

static char words[MAX_WORDS][MAX_WORD_LEN];
static int word_count = 0;

static int is_triangle(int n) {
    for (int k = 1; k * (k + 1) / 2 <= n; k++)
        if (k * (k + 1) / 2 == n) return 1;
    return 0;
}

static int word_value(const char *w) {
    int s = 0;
    for (int i = 0; w[i]; i++) s += w[i] - 'A' + 1;
    return s;
}

static void load_words(void) {
    FILE *f = fopen("words.txt", "r");
    if (!f) { fprintf(stderr, "Cannot open words.txt\n"); exit(1); }
    char buf[50000];
    if (!fgets(buf, sizeof(buf), f)) { fclose(f); return; }
    fclose(f);
    char *tok = strtok(buf, ",");
    while (tok && word_count < MAX_WORDS) {
        char *s = tok;
        while (*s == '"' || *s == ' ') s++;
        char *e = s + strlen(s) - 1;
        while (e > s && (*e == '"' || *e == '\n' || *e == ' ')) e--;
        *(e + 1) = '\0';
        strncpy(words[word_count], s, MAX_WORD_LEN - 1);
        words[word_count][MAX_WORD_LEN - 1] = '\0';
        word_count++;
        tok = strtok(NULL, ",");
    }
}

long long solve(void) {
    static int inited = 0;
    if (!inited) { load_words(); inited = 1; }
    int count = 0;
    for (int i = 0; i < word_count; i++)
        if (is_triangle(word_value(words[i]))) count++;
    return count;
}

#include "../bench.h"
int main(void) { euler_bench(42, solve); return 0; }
