// Problem 59: XOR Decryption
// Answer: 129448
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_CIPHER 2000
static int cipher[MAX_CIPHER];
static int cipher_len = 0;

static void load_cipher(void) {
    FILE *f = fopen("p059_cipher.txt", "r");
    if (!f) { fprintf(stderr, "Cannot open p059_cipher.txt\n"); exit(1); }
    char buf[16384];
    int n = fread(buf, 1, sizeof(buf) - 1, f);
    buf[n] = '\0'; fclose(f);
    cipher_len = 0;
    char *p = buf;
    while (*p) {
        while (*p == ',' || *p == ' ' || *p == '\n' || *p == '\r') p++;
        if (!*p) break;
        cipher[cipher_len++] = atoi(p);
        while (*p >= '0' && *p <= '9') p++;
    }
}

long long solve(void) {
    static int inited = 0;
    if (!inited) { load_cipher(); inited = 1; }
    int best_sum = 0, best_spaces = 0;
    for (int a = 'a'; a <= 'z'; a++)
        for (int b = 'a'; b <= 'z'; b++)
            for (int c = 'a'; c <= 'z'; c++) {
                int key[3] = {a, b, c};
                int sum = 0, valid = 1, spaces = 0;
                for (int i = 0; i < cipher_len; i++) {
                    int dec = cipher[i] ^ key[i % 3];
                    if (dec < 32 || dec > 126) { valid = 0; break; }
                    if (dec == ' ') spaces++;
                    sum += dec;
                }
                if (valid && spaces > best_spaces) { best_spaces = spaces; best_sum = sum; }
            }
    return best_sum;
}

#include "../bench.h"
int main(void) { euler_bench(59, solve); return 0; }
